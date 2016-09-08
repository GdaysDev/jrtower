package com.stanfoot.common.draggableLayerContainer
{
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.stanfoot.common.GeneralFuncs;
	
	import com.stanfoot.common.debug.Debug;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	
	
	/**
	 * ...
	 * @author koba
	 */
	public class DraggableLayerContainer extends MovieClip
	{
		//表示オブジェクト--------------------------
		
		/** メインレイヤー */
		private var _mainLayer:DisplayObjectContainer;
		
		/** ゴールオブジェクト（このオブジェクトめがけてメインレイヤーが徐々に移動） */
		private var goalSprite:Sprite;
		
		//オブジェクト--------------------------
		/** レイヤーリスト */
		private var layerList:/*DisplayObjectContainer*/Array = new Array();
		
		/** メインレイヤー座標 */
		private var _mainLayerCoordinates:Point = new Point();
		
		/** メインレイヤーの座標のクローンを返す */
		public function get mainLayerCoordinates():Point
		{
			_mainLayerCoordinates.x = _mainLayer.x;
			_mainLayerCoordinates.y = _mainLayer.y;
			
			return  _mainLayerCoordinates.clone();
		}
		
		/** 表示エリアレクタングル */
		private var _displayRect:Rectangle;
		
		/** 表示エリアレクタングルの参照 */
		public function getDisplayRect():Rectangle
		{
			return _displayRect;
		}
		
		/** マウス位置 （マウスダウンかマウスムーブをすると更新される）*/
		private var mousePos:Point = new Point();
		
		/** 
		 * マウス変位値 (毎フレーム 直前のマウス位置と減退処理により更新される) 
		 * mouseMoveを検知したとき、どのぐらいマウスの位置が変化したか
		 * */
		private var mouseOffset:Point = new Point();
		
		/** マウスダウン位置 */
		private var mouseDownPos:Point = new Point();
		
		/** 表示領域の基準点に対するメインレイヤーの初期表示座標 */
		private var _startPoint:Point;
		
		/** スワイプ時のタッチアップ検知の遅延タイマー */
		private var touchUpTimer:Timer;
		
		//パラメーター----------------------------
		/** X軸の移動を許可するかどうか */
		public var moveX:Boolean = true;
		/** Y軸の移動を許可するかどうか */
		public var moveY:Boolean = true;
		
		/** ドラッグに対する抵抗係数 */
		private var _coefficientOfDrag:Number = 0.1;;
		
		/** デフォルトの減衰係数 */
		private var _coefficientOfAttenuation:Number = 0.9;
		
		/** スワイプ時のタッチアップ検知の遅延（ミリ秒）。
		 * タッチパネルの特性により、マウスのダウンアップが不安定なため、
		 * タッチアップを検出しても、一定時間タッチアップとみなさない。
		 * ※その間にタッチダウンをしたら遅延タイマーをリセット。*/
		private var _touchUpDelay:Number = 0;
		
		/** はみだし限度距離 */
		private var _dragMargin:Number = 50;
		
		/** ドラッグ中として処理しているかどうかのフラグ */
		private var dragFlag:Boolean = false;
		/** ドラッグ開始日時 */
		private var dragStartDate:Date = new Date();
		/** 実際のマウスのアップダウン状況（up:false , down:true） */
		private var mouseUpDownFlag:Boolean = false;
		/** ドラッグ移動中フラグ */
		private var dragMoveFlag:Boolean = false;
		
		/** 幅が _displayRectよりも_mainLayerが大きいかどうかのフラグ変数(大きいとき1、小さいとき-1) */
		private var bigMapFlagX:Number = 1;
		/** 高さが _displayRectよりも_mainLayerが大きいかどうかのフラグ変数(大きいとき1、小さいとき-1) */
		private var bigMapFlagY:Number = 1;
		
		/** 拡大縮小率 */
		private var _scale:Number = 1;
		/** 拡大縮小率の参照 */
		public function get scale():Number
		{	return _scale;	}
		
		
		/** 初期化済みフラグ */
		private var initialized:Boolean = false;
		
		//デバッグ用--------------------------------
		/** デバッグモードフラグ */
		private var _debugMode:Boolean;
		
		
		/**
		 * コンストラクタ
		 * @param	mainLayer	基本となるレイヤー
		 * @param	coefficientOfDrag	ドラッグに対する抵抗係数 数が大きいほどドラッグに追随しにくくなる
		 * @param	coefficientOfAttenuation	減衰係数　数が大きいほどすぐ止まる
		 * @param	touchUpDelay	スワイプ時のタッチアップ検知の遅延（ミリ秒）
		 * @param	dragMargin	ドラッグ時の移動制限マージン(px)
		 * @param	debugMode	デバッグモード
		 */
		public function DraggableLayerContainer(mainLayer:DisplayObjectContainer, coefficientOfDrag:Number, coefficientOfAttenuation:Number, touchUpDelay:Number = 0, dragMargin:Number = 0, debugMode:Boolean = false )
		{
			_mainLayer = mainLayer;
			
			_coefficientOfDrag = coefficientOfDrag;
			_coefficientOfAttenuation = coefficientOfAttenuation;
			_touchUpDelay = touchUpDelay;
			_dragMargin = dragMargin;
			_debugMode = debugMode;
			//_debugMode = true;
			
			touchUpTimer = new Timer(999, 1);			
			touchUpTimer.addEventListener(TimerEvent.TIMER, touchUpTimer_handler);
			
		}
		
		
		//TODO
		public function set displayCenterPoint(newPoint:Point):void
		{
			
		}
		
		/** 表示の中心座標を返す */
		public function get displayCenterPoint():Point
		{
			var result:Point
			
			if (_displayRect)
			{
				result = new Point();
				result.x = _dispCenter.x;//_displayRect.x + _displayRect.width / 2;
				result.y = _dispCenter.y;// _displayRect.y + _displayRect.height / 2;
			}
			
			return result;
		}
		
		/**
		 * 初期化
		 * @param	startX	メインレイヤーの基準点のX座標
		 * @param	startY	メインレイヤーの基準点のY座標
		 * @param	displayRectangle	表示領域とするレクタングル
		 */
		public function init(startX:Number = 0 , startY:Number = 0, displayRectangle:Rectangle = null)
		{
			if (stage == null)
			{
				throw new Error("初期化する前にDisplayObjectに追加してください");
			}
			
			//表示領域の設定
			if (displayRectangle == null)
			{	//指定された表示領域が無い場合
				//表示領域を暫定で生成
				displayRectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			}
			_displayRect = displayRectangle;
			
				_dispCenter = new Sprite();
				//_dispCenter.x = _displayRect.left + _displayRect.width / 2;
				_dispCenter.x = 0;
				_dispCenter.y = _displayRect.top + _displayRect.height / 2;
				_dispCenter.graphics.beginFill(0x00ff00, 1);
				_dispCenter.graphics.drawCircle(0, 0, 10);
				_dispCenter.graphics.endFill();
				_dispCenter.visible = false;
				addChild(_dispCenter)
			
			
			//開始地点の登録
			_startPoint = new Point(startX, startY);
			
			//メインレイヤーにイベントリスナを登録
			_mainLayer.addEventListener(MouseEvent.MOUSE_DOWN , map_mouseDown_handler);
			_mainLayer.addEventListener(Event.ENTER_FRAME, map_enterFrame_handler);
			_mainLayer.addEventListener(Event.REMOVED_FROM_STAGE, map_removedFromStage_handler);
			addChild(_mainLayer);
			
			//goalSpriteを設定
			resetAreaRect(_mainLayer.getRect(this));
			
			//デバッグ用表示ボックスの設置
			setDebugView();
			
			touchUpTimer.delay = _touchUpDelay;
			
			//初期化の完了
			initialized = true;
			
			Debug.write("[DraggableLayerContainer]" + goalSprite.visible)
		}
		
		/**
		 * メインレイヤーの大きさが変わった場合にこのリセットメソッドをしてください。
		 * (goalSpriteを再設定します)
		 */
		public function resetAreaRect(areaRect:Rectangle):void
		{
			var tmpParent:DisplayObjectContainer;

			trace("RESET goal");
			
			if (goalSprite == null)
			{
				clearObj(goalSprite);

				var tmpMainLayerRectSprite:Sprite = GeneralFuncs.createPaintedSprite(areaRect , 0x00ff00, 0.4);
				
				goalSprite = tmpMainLayerRectSprite;
				
				if(_debugMode == false) goalSprite.visible = false;
				addChild(goalSprite);
			}
			else
			{
				goalSprite.graphics.clear();
				goalSprite.graphics.beginFill(0x000099, 0.7);
				goalSprite.graphics.drawRect(areaRect.x, areaRect.y, areaRect.width, areaRect.height);
				goalSprite.graphics.endFill();
			}
			
			//resetPosition();
			
			Debug.write("[DraggableLayerContainer]  goalSprite reset: " + goalSprite.x + " - " + goalSprite.y)
			
			resetBigMapFlag();
		}
		
		
		/**
		 * 表示領域のレクタングルを指定・変更する
		 * @param	displayRectangle	指定したい表示領域レクタングル
		 */
		public function set displayRectangle(displayRectangle:Rectangle):void
		{
			_displayRect = displayRectangle;
			
			if(_debugMode) debug_paintDisplayRect();
			
			resetBigMapFlag();
		}
		
		/**
		 * 表示対象が、_displayRect（表示領域）よりも大きいかどうかを再設定
		 */
		private function resetBigMapFlag():void
		{
			//x,yそれぞれの軸に対して_displayRectよりも_mainLayerが大きい場合1,小さい場合-1
			//var tmp_mainLayerRect:Rectangle = _mainLayer.getRect(this);
			var tmp_mainLayerRect:Rectangle = goalSprite.getRect(this);
			
			bigMapFlagX = (tmp_mainLayerRect.width >= _displayRect.width) ? 1 : -1;
			bigMapFlagY = (tmp_mainLayerRect.height >= _displayRect.height) ? 1 : -1;
			//bigMapFlagX = (_mainLayer.width >= _displayRect.width) ? 1 : -1;
			//bigMapFlagY = (_mainLayer.height >= _displayRect.height) ? 1 : -1;
			/*
			Debug.write(	"[DraggableLayerContainer]  resetBigMapFlag")
			Debug.write("        メインレイヤーWH : " + _mainLayer.width + " , " + _mainLayer.height);
			Debug.write("        表示領域WH : " + _displayRect.width + " , " + _displayRect.height);
			Debug.write("        bigMapFlagXY : " + bigMapFlagX + " , " + bigMapFlagY);
			*/
		}
		
		
		/**
		 * ズームする
		 */
		public function zoom(scaleVal:Number, duration:Number = 0.5, focusPoint:Point = null):void
		{
			_scale = scaleVal;
			Debug.write("scale to : " + scaleVal);
			
			//各レイヤーに対しての処理
			var tmpLength:int = layerList.length;
			var tmpDisplayObjectContainer:DisplayObjectContainer;
			for (var i:uint = 0; i < tmpLength; i++) 
			{
				tmpDisplayObjectContainer = layerList[i];
				if (tmpDisplayObjectContainer)
				{
					tmpDisplayObjectContainer.cacheAsBitmap = false;
					TweenNano.to(tmpDisplayObjectContainer, duration, { scaleX:scaleVal, scaleY:scaleVal, ease:Quad.easeInOut } );
				}
			}
			//メインレイヤーに対しての処理
			TweenNano.to(_mainLayer, duration, { scaleX:scaleVal, scaleY:scaleVal, ease:Quad.easeInOut, onComplete:onComplete_zoom_handler } );
			//_mainLayer.cacheAsBitmap = false;
			
			//goalSprite.scaleX = goalSprite.scaleY = scaleVal;
			//ゴールスプライトに対しての処理
			var tmpGoalPoint:Point = new Point();
			
			
			//if (focusPoint == null) focusPoint = new Point(_dispCenter.x,_dispCenter.y);
			if (focusPoint == null) focusPoint = new Point(_startPoint.x,_startPoint.y);
			//if (focusPoint == null) focusPoint = new Point(goalSprite.x, goalSprite.y);
			
			//tmpGoalPoint.x  = focusPoint.x - goalSprite.width / 2;
			//tmpGoalPoint.y = focusPoint.y - goalSprite.height / 2;
			
			//tmpGoalPoint.x = (- focusPoint.x) * scale + _displayRect.width / 2 + _displayRect.left;
			//tmpGoalPoint.y = (- focusPoint.y) * scale + _displayRect.height / 2 + _displayRect.top;
			tmpGoalPoint.x = (- focusPoint.x) * scale + _dispCenter.x;
			tmpGoalPoint.y = (- focusPoint.y) * scale + _dispCenter.y;
			TweenLite.to(goalSprite, duration, { x: tmpGoalPoint.x, y: tmpGoalPoint.y, scaleX:scaleVal, scaleY:scaleVal, ease:Quad.easeInOut } );
			
			
		}
		
		
		
		
		
		/**
		 * ズーム完了時のハンドラ
		 */
		private function onComplete_zoom_handler():void
		{
			Debug.write("onComplete_zoom_handler");
			
			//各レイヤーに対しての処理
			var tmpLength:int = layerList.length;
			var tmpDisplayObjectContainer:DisplayObjectContainer;
			for (var i:uint = 0; i < tmpLength; i++) 
			{
				tmpDisplayObjectContainer = layerList[i];
				if (tmpDisplayObjectContainer)
				{
					tmpDisplayObjectContainer.cacheAsBitmap = true;
				}
			}
			//メインレイヤーに対しての処理
			//_mainLayer.cacheAsBitmap = true;
			
			resetBigMapFlag();
		}
		
		
		
		/**
		 * 初期位置にレイヤーをリセットする
		 */
		public function resetPosition():void
		{
			if (initialized)
			{
				goalSprite.x = - _startPoint.x + _dispCenter.x//_displayRect.width / 2 + _displayRect.left;
				goalSprite.y = - _startPoint.y + _dispCenter.y//_displayRect.height / 2 + _displayRect.top;
			}
		}
		
		/**
		 * 指定座標にマップを移動させる
		 * @param	focusX
		 * @param	focusY
		 */
		public function focusPosition(focusX:Number, focusY:Number):void
		{
			var tmpGoalPoint:Point = new Point();
			if (initialized)
			{
				//goalSprite.x = - focusX + _displayRect.width / 2 + _displayRect.left;
				//goalSprite.y = - focusY + _displayRect.height / 2 + _displayRect.top;
				
				tmpGoalPoint.x = (- focusX) * scale + _dispCenter.x//_displayRect.width / 2 + _displayRect.left;
				tmpGoalPoint.y = (- focusY) * scale + _dispCenter.y//_displayRect.height / 2 + _displayRect.top;
				Debug.write("[DraggableLayerContainer] focusPosition " + focusX + "," + focusY);
				
				//TweenLite.to(goalSprite, 0.5, { x: - focusX + _displayRect.width / 2 + _displayRect.left, y: - focusY + _displayRect.height / 2 + _displayRect.top, ease:Quad.easeOut } );
				TweenLite.to(goalSprite, 0.5, { x: tmpGoalPoint.x, y: tmpGoalPoint.y , ease:Quad.easeOut } );
			}
		}
		
		
		/**
		 * マップがリムーブされた時
		 * @param	argEvent
		 */
		private function map_removedFromStage_handler(argEvent:Event):void
		{
			touchUpTimer.stop();
			Debug.write("[DraggableLayerContainer] 削除されました");
			_mainLayer.removeEventListener(MouseEvent.MOUSE_DOWN , map_mouseDown_handler);
			_mainLayer.removeEventListener(Event.ENTER_FRAME, map_enterFrame_handler);
			_mainLayer.removeEventListener(Event.REMOVED_FROM_STAGE, map_removedFromStage_handler);
			try
			{
				touchUpTimer.removeEventListener(TimerEvent.TIMER, touchUpTimer_handler);
				stage.removeEventListener(MouseEvent.MOUSE_UP, map_mouseUp_handler);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, map_mouseMove_handler);
			}
			catch (err:Error)
			{
			}
			
			//レイヤーをクリア
			for (var i:uint = 0; i < layerList.length; i++)
			{
				layerList[i].removeEventListener(MouseEvent.MOUSE_DOWN, map_mouseDown_handler);
				
				var tmpParent:MovieClip = layerList[i].parent;
				tmpParent.removeChild(layerList[i]);
			}
		}
		
		
		
		/**
		 * 多重スクロール用にレイヤーを追加
		 * @param	newLayer
		 * @param	depth
		 * @param	dragable
		 */
		public function addLayer( newLayer:MovieClip , depth:int = 1, dragable:Boolean = true, cacheAsBitmapFlag = true ):void
		{
			newLayer.cacheAsBitmap = true;
			//layerList.push( { mc:newLayer, depth:depth } );
			newLayer.depth = depth;
			newLayer.dragable = dragable
			//レイヤーのパラメータdragableがtrueの場合、レイヤーにイベントを登録する
			
			if (dragable)
			{
				newLayer.addEventListener(MouseEvent.MOUSE_DOWN, map_mouseDown_handler);
				//newLayer.addEventListener(MouseEvent.MOUSE_DOWN, layer_mouseDown_handler);
			}
			
			//レイヤーリストに追加
			layerList.push(newLayer);
			addChild(newLayer);
			
			//TODO 深度順に並べなおす 以下暫定処置
			if (depth > 1)
			{	//深度が1よりも大きい場合、とりあえず後ろに
				swapChildren(_mainLayer, newLayer);
			}
		}
		
		
		
		/*******************************************************************
		 * 毎フレームの処理
		 * @param	argEvent
		 */
		private function map_enterFrame_handler(argEvent:Event):void
		{
			if (!enabled || !initialized || goalSprite == null)
			{//有効ではないときは処理しない
				return;
			}
			
			//大きすぎるmouseOffsetを制限する
			if (80 < mouseOffset.x) mouseOffset.x = 80;
			if (mouseOffset.x < -80) mouseOffset.x = -80;
			if (100 < mouseOffset.y) mouseOffset.y = 80;
			if (mouseOffset.y < -80) mouseOffset.y = -80;
			
			//慣性による移動量mouseOffsetを減衰させる
			if ( !dragMoveFlag || !dragFlag )
			{	//マウス移動中ではなく、移動量もゼロではない場合、減衰させる
				if (mouseOffset.x != 0)
				{
					mouseOffset.x = attenuateNum(mouseOffset.x); 
				}
				if ( mouseOffset.y != 0)
				{
					mouseOffset.y = attenuateNum(mouseOffset.y );
				}
			}
			
			//デバッグ表示の更新
			updateDebug();
			if (_debugMode) appendDebugTxt("dragMoveFlag " + dragMoveFlag);
			
			resetBigMapFlag();
			//マップの位置を動かす
			_moveMainLayer();
			
			dragMoveFlag = false;
		}
		
		
		//=============================================================
		
		/**
		 * マウスボタンがダウンされた時
		 * @param	argEvent
		 */
		private function map_mouseDown_handler(argEvent:MouseEvent):void
		{
			if (mouseUpDownFlag == false)
			{
				dragFlag = true;
				mouseUpDownFlag = true;
				
				dragStartDate = new Date();
				/*
				mousePos.x = mouseX;
				mousePos.y = mouseY;
				
				mouseDownPos.x = _mainLayer.mouseX;
				mouseDownPos.y = _mainLayer.mouseY;
				*/
				mousePos.x = mouseX * _scale;
				mousePos.y = mouseY * _scale;
				
				mouseDownPos.x = _mainLayer.mouseX * _scale;
				mouseDownPos.y = _mainLayer.mouseY * _scale;
				
				Debug.write("[DMap] mouseDownPos(" + mouseDownPos.x + "," +mouseDownPos.y + ")");
				
				//マウスのドラッグを検知するため、ステージにイベントを追加する
				stage.addEventListener(MouseEvent.MOUSE_UP, map_mouseUp_handler);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, map_mouseMove_handler);
			}
			touchUpTimer.reset();
			touchUpTimer.stop();
		}
		
		
		/**
		 * マウスボタンがアップされた時
		 * @param	argEvent
		 */
		private function map_mouseUp_handler(argEvent:MouseEvent):void
		{
			mouseUpDownFlag = false;
			
			//Debug.write(" - - (暫定Up)");
			/*dragFlag = false;
			
			//マウスのドラッグを検知用のイベントをステージから削除
			stage.removeEventListener(MouseEvent.MOUSE_UP, map_mouseUp_handler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, map_mouseMove_handler);
			*/
			
				
			//タッチアップタイマーをスタートさせる
			touchUpTimer.reset();
			touchUpTimer.start();
		}
		
		/**
		 * スワイプ時のタッチアップ検知の遅延タイマーのハンドラ
		 * @param	argEvent
		 */
		private function touchUpTimer_handler(argEvent:TimerEvent):void
		{
			//マウスのドラッグを検知用のイベントをステージから削除
			stage.removeEventListener(MouseEvent.MOUSE_UP, map_mouseUp_handler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, map_mouseMove_handler);
			
			map_mouseUp_process();
		}
		/**
		 * タッチアップした際の処理
		 */
		private function map_mouseUp_process():void
		{
			//Debug.write("[DMap] mouseUpPos(" + mouseDownPos.x + "," +mouseDownPos.y + ")");
			//Debug.write("[DMap] Upとみなしました ドラッグ終了\n");
			//ドラッグ終了とみなす
			dragFlag = false;
		}
		
		
		
		/**
		 * ドラッグ中にマウスを動かした場合
		 * @param	argEvent
		 */
		private function map_mouseMove_handler(argEvent:MouseEvent):void
		{
			if (mouseUpDownFlag)
			{
				//Debug.write(" - - (move)");
				//実際にはダウン状況にあると検出している場合
				dragMoveFlag = true;
				
				//mouseDownかmouseMoveした直前のマウス位置からの動いた距離
				mouseOffset.x = mouseX * _scale - mousePos.x;
				mouseOffset.y = mouseY * _scale - mousePos.y;
				mousePos.x = mouseX * _scale;
				mousePos.y = mouseY * _scale;
				
				//mouseOffset.x = mouseX - mousePos.x;
				//mouseOffset.y = mouseY - mousePos.y;
				//mousePos.x = mouseX;
				//mousePos.y = mouseY;
			}
		}
		
		public function moveLayer(dx:Number, dy:Number):void
		{
			
		}
		
		
		
		/**
		 * メインレイヤを移動させる(毎フレーム呼び出されるメソッド)
		 */
		private function _moveMainLayer():void
		{
			//========================================================
			if (dragFlag && mouseUpDownFlag)
			{	//ドラッグ中のとき
				if (_debugMode) appendDebugTxt("\n ドラッグ中 (" + mouseX + "," + mouseY + ")");
				
				//ドラッグ中の自動調整
				
				//目標到達方式
				//まず、今現在のマウス座標と、ドラッグ開始時のマウス座標の差から、マップの目標座標を求める
				goalSprite.x = mouseX - mouseDownPos.x ;
				goalSprite.y = mouseY - mouseDownPos.y ;
				//goalSprite.x = mouseX * _scale - mouseDownPos.x ;
				//goalSprite.y = mouseY * _scale - mouseDownPos.y ;
				
				//ねっとり動かすため、マップの目標座標を微調整
				goalSprite.x = _mainLayer.x + (goalSprite.x - _mainLayer.x) * _coefficientOfDrag;
				goalSprite.y = _mainLayer.y + (goalSprite.y - _mainLayer.y) * _coefficientOfDrag;
			}
			else
			{	//ドラッグ中でないとき
				//マウスの慣性値を加算
				goalSprite.x = goalSprite.x + mouseOffset.x;
				goalSprite.y = goalSprite.y + mouseOffset.y;
			}
			
			//======================================================================================
			//_displayRectよりも_mainLayerが小さい場合は、はみ出さないように、
			//大きい場合は見切れすぎないように位置制限の調整をする
			
			/**_displayRectよりも_mainLayerが見切れたときの大きさ*/
			var tmpGap:Point = new Point();
			/**Math.abs()計算高速化用の変数*/
			var tmpAbsNum:Number = 0;
			
			//位置制限調整 X軸------------------------------------------------
			
			if (bigMapFlagX * _displayRect.left < bigMapFlagX * goalSprite.getRect(this).left)
			{//左端の摺合せが必要な場合
				tmpGap.x = goalSprite.getRect(this).left - _displayRect.left;
				if (_debugMode) appendDebugTxt("\n ★X軸 行き過ぎ\n   tmpGap.x = " + tmpGap.x);
				if (_debugMode) appendDebugTxt("\n ★X軸 判定" + (_dragMargin < Math.abs(tmpGap.x)));
				
				tmpAbsNum = tmpGap.x;
				//if (/*dragFlag &&*/ _dragMargin < Math.abs(tmpGap.x))
				if (_dragMargin < (tmpAbsNum < 0 ? -tmpAbsNum : tmpAbsNum))	//Math.abs()高速化
				{	//ドラッグ中に位置制限値を超えた場合　-> それ以上はドラッグさせない
					
					//tmpGap.x = bigMapFlagX * _dragMargin;
					
					//goalSprite.x = _displayRect.left - _dragMargin  - ( goalSprite.getRect(goalSprite).left) * _scale;
					goalSprite.x = _displayRect.left + bigMapFlagX * _dragMargin  - ( goalSprite.getRect(goalSprite).left) * _scale;
				}
				else
				{	//ドラッグ中に位置制限値を超えていない場合　-> ドラッグ量を減算し、にぶくさせる
					
					//goalSprite.x = _displayRect.left + attenuateNum(tmpGap.x) - goalSprite.getRect(goalSprite).left;
					goalSprite.x = goalSprite.x - attenuateNum(tmpGap.x) / 5;
				}
			}
			else if (bigMapFlagX * goalSprite.getRect(this).right < bigMapFlagX * _displayRect.right)
			{//右端の摺合せが必要な場合
				tmpGap.x = _displayRect.right - goalSprite.getRect(this).right;
				if (_debugMode) appendDebugTxt("\n ☆X軸 行き過ぎ\n   tmpGap.x = " + tmpGap.x);
				
				tmpAbsNum = tmpGap.x;
				//if (/*dragFlag &&*/ _dragMargin < Math.abs(tmpGap.x))
				if (_dragMargin < (tmpAbsNum < 0 ? -tmpAbsNum : tmpAbsNum))	//Math.abs()高速化
				{	//ドラッグ中に位置制限値を超えた場合
					tmpGap.x = bigMapFlagX * _dragMargin;
				}
				//ドラッグ量を減算し、にぶくさせる
				//goalSprite.x = _displayRect.right - attenuateNum(tmpGap.x) - goalSprite.getRect(goalSprite).right ;
				goalSprite.x = _displayRect.right - attenuateNum(tmpGap.x) - goalSprite.getRect(goalSprite).right * _scale ;
			}
			
			
			//位置制限調整 Y軸------------------------------------------------
			if (bigMapFlagY * _displayRect.top < bigMapFlagY * goalSprite.getRect(this).top)
			{//上端の摺合せが必要な場合
				
				tmpGap.y = goalSprite.getRect(this).top - _displayRect.top;
				if (_debugMode) appendDebugTxt("\n ★Y軸 行き過ぎ\n   tmpGap.y = " + tmpGap.y);
				if (_debugMode) appendDebugTxt("\n ★Y軸 判定" + (_dragMargin < Math.abs(tmpGap.y)));
				
				tmpAbsNum = tmpGap.y;
				//if ( _dragMargin < Math.abs(tmpGap.y))
				if ( _dragMargin < (tmpAbsNum < 0 ? -tmpAbsNum : tmpAbsNum))	//Math.abs()高速化
				/*
				{	//ドラッグ中に位置制限値を超えた場合
					tmpGap.y = bigMapFlagY * _dragMargin;
				}
				//ドラッグ量を減算し、にぶくさせる
				goalSprite.y = _displayRect.y + attenuateNum(tmpGap.y) - goalSprite.getRect(goalSprite).top;
				*/
				{	//ドラッグ中に位置制限値を超えた場合
					if (_debugMode) appendDebugTxt("\n ★goalSprite.getRect(goalSprite).top" + (goalSprite.getRect(goalSprite).top));
					//goalSprite.y = _displayRect.top - _dragMargin  - ( goalSprite.getRect(goalSprite).top) * _scale;
					goalSprite.y = _displayRect.top + bigMapFlagY * _dragMargin -( goalSprite.getRect(goalSprite).top) * _scale;
					if (_debugMode) appendDebugTxt("\n ★goalSprite.y" + (goalSprite.y));
				}
				else
				{
					//ドラッグ量を減算し、にぶくさせる
					goalSprite.y = goalSprite.y - attenuateNum(tmpGap.y) / 5;
				}
				
				
			}
			else if (bigMapFlagY * goalSprite.getRect(this).bottom < bigMapFlagY * _displayRect.bottom)
			{//下端の摺合せが必要な場合
				tmpGap.y = _displayRect.bottom - goalSprite.getRect(this).bottom;
				if (_debugMode) appendDebugTxt("\n ☆Y軸 行き過ぎ\n   tmpGap.y = " + tmpGap.y);
				
				tmpAbsNum = tmpGap.y;
				//if (/*dragFlag &&*/ _dragMargin < Math.abs(tmpGap.y))
				if (_dragMargin < (tmpAbsNum < 0 ? -tmpAbsNum : tmpAbsNum))	//Math.abs()高速化
				{	//ドラッグ中に位置制限値を超えた場合
					tmpGap.y = bigMapFlagY * _dragMargin;
				}
				//ドラッグ量を減算し、にぶくさせる
				//goalSprite.y = _displayRect.bottom - attenuateNum(tmpGap.y) - goalSprite.getRect(goalSprite).bottom;
				goalSprite.y = _displayRect.bottom - attenuateNum(tmpGap.y) - goalSprite.getRect(goalSprite).bottom * _scale;
			}
			
			
			
			
			//調整した値を反映する部分========================================================
			//マップに対して座標を決定する
			
			if (moveX) _mainLayer.x = goalSprite.x;
			if (moveY) _mainLayer.y = goalSprite.y;
			
			
			
			//各レイヤーに対して座標を決定する
			var tmpLayerListLength:int = layerList.length;
			for (var i:uint = 0 ; i < tmpLayerListLength; i++)
			{
				if (moveX) layerList[i].x = goalSprite.x / layerList[i].depth;
				if (moveY) layerList[i].y = goalSprite.y / layerList[i].depth;
			}
			
		}
		
		//--------------------------------------------------------------------
		
		private var AbsorbingAnchorList:Array = new Array();
		
		public function addAbsorbingAnchor(anchorX:Number, anchorY:Number):void
		{
			var tmpAbsorbingAnchor:Sprite = new Sprite();
			tmpAbsorbingAnchor.graphics.beginFill(0x00FF00, 1);
			tmpAbsorbingAnchor.graphics.drawCircle(anchorX, anchorY, 10);
			tmpAbsorbingAnchor.mouseEnabled = false;
			addChild(tmpAbsorbingAnchor);
		}
		
		public function removeAbsorbingAnchor(index:int = -1)
		{
			
		}
		
		
		
		
		//--------------------------------------------------------------------
		
		/**
		 * 数字を0へ減衰
		 * @param	argNum	
		 * @param	argCofficient
		 * @return
		 */
		private function attenuateNum(argNum:Number , argCofficient:Number = NaN):Number
		{
			var threshold:Number = 200
			var coefficient:Number = _coefficientOfAttenuation;
			//var result:Number = Math.floor(argNum * coefficient * threshold) / threshold;
			var result:Number = ((argNum * coefficient * threshold)|0) / threshold;
			
			//if (Math.abs(result) < 0.3)
			if ((result < 0 ? -result : result) < 0.3)	//Math.abs()高速化
			{
				result = 0;
			}
			
			return result;
		}
		
		
		
		//デバッグ関連------------------------------------------------------------
		
		/** デバッグ用テキスト */
		private var _debugTxt:TextField;
		private var _dispCenter:Sprite;
		private var _debug_displayRectGuide:Sprite;
		private var _debut_displayCenterMarker:Sprite;
		
		
		/**
		 * デバッグの表示物をセット
		 */
		private function setDebugView():void
		{
			//デバッグモードの場合の表示
			if (_debugMode && _debugTxt == null)
			{
				_dispCenter.visible = true;
				//表示エリアの中心
				//graphics.beginFill(0x0000ff, 1);
				//graphics.drawCircle(_displayRect.x + _displayRect.width / 2, _displayRect.y + _displayRect.height / 2, 10);
				
				
				//表示領域を着色する-------------------
				debug_paintDisplayRect();
				
				/*
				//初期ポイントアンカー
				var startAncorSprite:Sprite = createCircleSprite()
				startAncorSprite.x = _startPoint.x;
				startAncorSprite.y = _startPoint.y;
				_mainLayer.addChild(startAncorSprite);
				*/
				
				//goalSpriteを表示
				goalSprite.visible = false;
				
				var tmpTFmt:TextFormat = new TextFormat();
				tmpTFmt.font = "ＭＳ ゴシック";
				
				_debugTxt = new TextField();
				_debugTxt.selectable = false;
				_debugTxt.mouseEnabled = false;
				_debugTxt.border = true;
				//debugTxt.background = true;
				_debugTxt.x = 0;
				_debugTxt.y = 0;
				_debugTxt.width = 300;
				_debugTxt.height = 200;
				
				_debugTxt.defaultTextFormat = tmpTFmt;
				//debugTxt.setTextFormat(tmpTFmt);
				addChild(_debugTxt);
				
				rewriteDebugTxt("DEBUG TEXT ");
			}
		}
		
		private function debug_paintDisplayRect():void
		{
			clearObj(_debug_displayRectGuide);
			_debug_displayRectGuide = GeneralFuncs.createPaintedSprite(_displayRect, 0xff0000, 0.5);
			addChild(_debug_displayRectGuide);
		}
		
		private function clearObj(tgt:DisplayObjectContainer):void
		{
			if (tgt)
			{
				if (tgt.parent)
				{
					tgt.parent.removeChild(tgt);
				}
				tgt = null;
			}
		}
		
		private function createCircleSprite(color:uint = 0xFF0000):Sprite
		{
			//初期ポイントアンカー
			var tmpSprite:Sprite = new Sprite();
			tmpSprite.graphics.beginFill(color, 0.8);
			tmpSprite.graphics.drawCircle(0, 0, 5);
			tmpSprite.mouseEnabled = false;
			return tmpSprite;
		}
		
		private function updateDebug()
		{
			if (_debugMode)
			{	//デバッグ用表示処理
				var tmpStr:String = 
					"_mainLayerのほうが幅が長いかどうか " + bigMapFlagX + "\n" +
					"_mainLayerのほうが縦が長いかどうか " + bigMapFlagY + "\n" +
					"scale " + scale + "\n" +
					"[mouseOffset XY] (" + mouseOffset.x +" , " + mouseOffset.y + ")\n" +
					"[goalSprite    XY] (" + Math.round(goalSprite.x) +" , " + Math.round(goalSprite.y) + ")\n" +
					"[_mainLayer  XY] (" + _mainLayer.x +" , " + _mainLayer.y + ")\n";
					
				rewriteDebugTxt(tmpStr);
			}
		}
		private function rewriteDebugTxt(argStr:String):void
		{
			if (_debugMode)
			{
				if(_debugTxt.text != argStr)_debugTxt.text = argStr;
			}
		}
		private function appendDebugTxt(argStr:String):void
		{
			if (_debugMode)
			{
				_debugTxt.appendText(argStr);
			}
		}
		
	}
	
}