package com.stanfoot.common.scrollWorld 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.text.TextField;
	
	import com.greensock.*; 
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ScrollWorld extends MovieClip
	{
		/** 登録されているアイテムコンテナの一覧 */
		private var itemContainerList:/*ItemContainer*/Array;
		/** 登録されているアイテムコンテナの個数 */
		private var itemContainerListLength:int;
		
		
		private var rootContainerGround:Sprite;
		/** ルートコンテナ */
		private var rootContainer:Sprite;
		
		
		/** 表示更新フラグ */
		private var renderFlag:Boolean;
		/** 表示更新タイマー */
		private var timer:Timer;
		
		
		/** デフォルトの単位時間当たりの移動距離 */
		private var defaultMoveDistance:Point3D;
		/** 単位時間当たりの移動距離 */
		private var moveDistance:Point3D;
		
		/** ルートコンテナが何個分動いたか */
		private var rootContainerShift:Point3D = new Point3D();
		
		private var rootContainerRotationTween:TweenMax;
		private var rootContainerMoveXTween:TweenMax;
		
		/** 表示領域 */
		private var displayLimit:Point3D;
		
		/** デバッグモード */
		private var _debugMode:Boolean;
		/** デバッグ用テキスト表示 */
		private var debugTxt:TextField;
		
		/**
		 * コンストラクタ
		 */
		public function ScrollWorld(displayLimit_x:Number, displayLimit_y:Number, displayLimit_z:Number, center_x:Number = 0, center_y:Number = 0, center_z:Number = 0, argDebugMode:Boolean = false)
		{
			displayLimit = new Point3D(displayLimit_x, displayLimit_y, displayLimit_z);
			defaultMoveDistance = new Point3D();
			moveDistance = new Point3D(defaultMoveDistance.x, defaultMoveDistance.y, defaultMoveDistance.z);
			
			//プラグインの初期化
			TweenPlugin.activate([ColorTransformPlugin, TintPlugin]);
			
			rootContainerGround = new Sprite();
			rootContainerGround.x = center_x;
			rootContainerGround.y = center_y;
			rootContainerGround.z = center_z;
			addChild(rootContainerGround);
			rootContainerGround.mouseEnabled = false;
			
			
			//アイテムコンテナのコンテナ
			rootContainer = new Sprite();
			rootContainerGround.addChild(rootContainer);
			rootContainer.mouseEnabled = false;
			
			//アイテムコンテナのリストを生成
			itemContainerList = [];
			
			addEventListener(Event.ADDED_TO_STAGE, addedStage_handler);
			
			//timer = new Timer(30);
			//timer.addEventListener(TimerEvent.TIMER, timer_handler);
			addEventListener(Event.ENTER_FRAME, enterFrame_handler);
			
			//ゆらぎ-------------------------------
			rootContainerGround.rotation = -4.5;
			rootContainerGround.x += -200;
			
			rootContainerRotationTween = new TweenMax(rootContainerGround, 9, { repeat: -1, yoyo:true, rotation:4.5 , x:center_x + 200, ease:Sine.easeInOut } );
			rootContainerRotationTween.pause();
			//rootContainerMoveXTween = new TweenMax(rootContainerGround, 15, { repeat: -1, yoyo:true, x:400, ease:Sine.easeInOut } );
			
			//
			/*
			var _pp:PerspectiveProjection = new PerspectiveProjection();
			//_pp.fieldOfView = 120;
			_pp.projectionCenter.y = -10000;
			rootContainer.transform.perspectiveProjection = _pp;
			*/
			_debugMode = argDebugMode;
			
			if (_debugMode)
			{
				setDebugTextField("デバッグ");
				
				var rootContainerGuide:Sprite = new Sprite();
				rootContainerGuide.graphics.beginFill(0xeeffee, 0.8);
				rootContainerGuide.graphics.drawRect(0, 0, displayLimit.x, displayLimit.z);
				rootContainerGuide.graphics.endFill();
				rootContainerGuide.rotationX = 90;
				
				rootContainer.addChild(rootContainerGuide);
				
				
				//--------------------------------
				
				/*
				var grid:Sprite = new Sprite();
				grid.graphics.lineStyle(10,0x885555,0.7);
				for (var i:int = 0; i < 6; i++) 
				{	//縦
					grid.graphics.moveTo(i * displayLimit.x , 0);
					grid.graphics.lineTo(i * displayLimit.x , displayLimit.z * 6);
				}
				for (i = 0; i < 6; i++) 
				{	//横
					grid.graphics.moveTo( 0 ,  displayLimit.z * i);
					grid.graphics.lineTo( displayLimit.x * 6 ,  displayLimit.z * i);
				}
				grid.graphics.endFill()
				grid.scaleX = 1;
				grid.scaleY = 1;
				
				
				var gridBitmapData:BitmapData = new BitmapData(grid.width, grid.height, true, 0);
				gridBitmapData.draw(grid);
				var gridBitmap:Bitmap = new Bitmap(gridBitmapData, "auto", true);
				
				gridBitmap.rotationX = 90;
				gridBitmap.x -= displayLimit.x * 2;
				gridBitmap.z -= displayLimit.z;
				rootContainerGround.addChild(gridBitmap);
				
				
				grid.rotationX = 90;
				rootContainerGround.addChild(grid);
				grid = null;
				*/
			}
		}
		
		/**
		 * 通常移動方向を設定
		 * @param	_x
		 * @param	_y
		 * @param	_z
		 */
		public function setDefaultMoveDistance(_x:Number = 0, _y:Number = 0, _z:Number = 0):void
		{
			defaultMoveDistance.x = moveDistance.x = _x;
			defaultMoveDistance.y = moveDistance.y = _y;
			defaultMoveDistance.z = moveDistance.z = _z;
			
		}
		
		/** アイテムコンテナのクラス */
		private var _itemContainerClass:Class = ItemContainer;
		public function set itemContainerClass(newClass:Class):void
		{
			_itemContainerClass = newClass;
		}
		
		public function addItem(addedItem:DisplayObjectContainer, datumX:Number = 0, datumY:Number = 0, datumZ:Number = 0 ):void
		{
			var newItemContainer:ItemContainer = new ItemContainer(datumX, datumY, datumZ, 1, 1);
			
			newItemContainer.addChild(addedItem);
			
			itemContainerList.push(newItemContainer);
			itemContainerListLength = itemContainerList.length;
			rootContainer.addChild(newItemContainer);
			
			newItemContainer.blendMode = BlendMode.MULTIPLY;
		}
		
		/**
		 * アイテムコンテナを追加する
		 * @param	addObjClass
		 * @param	arg_x
		 * @param	arg_y
		 * @param	arg_z
		 * @param	scale
		 * @param	mirror
		 */
		public function addItemContainer(addObjClass:Class, arg_x:Number = 0, arg_y:Number = 0, arg_z:Number = 0, scale:Number = 1 , mirror:int = 1):void
		{
			var newItemContainer:ItemContainer = new _itemContainerClass(arg_x, arg_y, arg_z, scale, mirror);
			newItemContainer.addChild(new addObjClass());
			
			itemContainerList.push( newItemContainer);
			itemContainerListLength = itemContainerList.length;
			rootContainer.addChild(newItemContainer);
		}
		
		
		/**
		 * 表示中の位置から指定距離分移動させる（相対距離）
		 * @param	_X
		 * @param	_y
		 * @param	_z
		 * @param	duration
		 */
		public function move(_x:Number = 0, _y:Number = 0, _z:Number = 0, duration:Number = 0, delay:Number = 0):void
		{
			trace("move")
			//TweenLite.to(rootContainer, duration, { x:rootContainer.x + _x, y:rootContainer.y + _y, z:rootContainer.z + _z, ease:Sine.easeInOut } );
			
			moveDistance.x = _x;
			moveDistance.y = _y;
			moveDistance.z = _z;
			
			TweenLite.to(moveDistance, duration, { x:defaultMoveDistance.x, y:defaultMoveDistance.y, z:defaultMoveDistance.z, ease:Sine.easeInOut, delay:delay } );
			
		}
		
		
		/**
		 * アニメーションを再生・再開
		 */
		public function start():void
		{
			rootContainerRotationTween.play();
			//rootContainerMoveXTween.play();
			
			//timer.start();
			renderFlag = true;
		}
		
		
		
		public function slowDownAndStop(delay:Number = 0):void
		{
			rootContainerRotationTween.pause();
			
			if (delay > 0)
			{	//一定秒数後に終了させる場合
				TweenNano.to(moveDistance, delay, {x:0,y:0,z:0,  onComplete:stop, ease:Sine.easeOut } );
			}
			else
			{	//通常処理
				stop();
			}
			
		}
		
		
		/**
		 * アニメーションを停止（一時停止）
		 */
		override public function stop():void 
		{
			super.stop();
			rootContainerRotationTween.pause();
			
			//timer.stop();
			renderFlag = false;
			
			moveDistance.x = defaultMoveDistance.x;
			moveDistance.y = defaultMoveDistance.y;
			moveDistance.z = defaultMoveDistance.z;
		}
		
		
		
		private function enterFrame_handler(argEvent:Event):void
		{
			if (renderFlag)
			{
				moveRootContainer(moveDistance.x,moveDistance.y,moveDistance.z);
			}
		}
		
		/**
		 * タイマー実行のハンドラ
		 * @param	argEvent
		 */
		private function timer_handler(argEvent:TimerEvent):void
		{
			moveRootContainer(moveDistance.x,moveDistance.y,moveDistance.z);
		}
		
		/**
		 * ツリーコンテナの移動
		 * @param	valueX 左右移動量
		 * @param	valueY 上下移動量
		 * @param	valueZ 前後移動量
		 */
		private function moveRootContainer(valueX:Number, valueY:Number, valueZ:Number):void
		{
			var tmpItemContainer:ItemContainer;
			
			rootContainer.x += valueX;
			rootContainer.y += valueY;
			rootContainer.z += valueZ;
			
			var tmpX:Number;
			var tmpY:Number;
			var tmpZ:Number;
			
			//ルートコンテナが何個分動いたか
			//rootContainerShift.x = Math.floor(rootContainer.x / displayLimit.x);
			//rootContainerShift.y = Math.floor(rootContainer.y / displayLimit.y);
			//rootContainerShift.z = Math.floor(rootContainer.z / displayLimit.z);
			rootContainerShift.x = (rootContainer.x / displayLimit.x)|0;
			rootContainerShift.y = (rootContainer.y / displayLimit.y)|0;
			rootContainerShift.z = (rootContainer.z / displayLimit.z)|0;
			
			
			// アイテムコンテナ各個に対して処理
			// 領域を食み出たオブジェクトがあればループ配置
			for (var i:uint = 0; i < itemContainerListLength; i++) 
			{
				tmpItemContainer = itemContainerList[i];
				tmpX = tmpItemContainer.x + rootContainer.x;
				tmpY = tmpItemContainer.y + rootContainer.y;
				tmpZ = tmpItemContainer.z + rootContainer.z;
				
				if ( tmpX < 0)
				{
					tmpItemContainer.x = tmpItemContainer.defaultX - displayLimit.x * (rootContainerShift.x );
				}
				else if (displayLimit.x < tmpX )
				{
					//tmpItemContainer.x = tmpItemContainer.defaultX - displayLimit.x * (Math.floor((tmpItemContainer.defaultX + rootContainer.x) / displayLimit.x) );
					tmpItemContainer.x = tmpItemContainer.defaultX - displayLimit.x * (((tmpItemContainer.defaultX + rootContainer.x) / displayLimit.x)|0 );
				}
				
				if ( tmpZ < 0)
				{	//手前に来すぎたコンテナに対する処理
					tmpItemContainer.z = tmpItemContainer.defaultZ - displayLimit.z * (rootContainerShift.z );
					/*
					TweenMax.to( tmpItemContainer, 0 , { colorTransform: { tint:0xFFFFFF, tintAmount:1 }} );
					TweenMax.to( tmpItemContainer, 0.8 ,{colorTransform:{tint:0xFFFFFF, tintAmount:0}});
					*/
					//TweenMax.to( tmpItemContainer, 0 ,{colorTransform:{tint:0x329BB8, tintAmount:(1-(1400 - tmpTree.z) /200)}});
				}
				else if (displayLimit.z < tmpZ )
				{	//奥へ行き過ぎたコンテナに対する処理
					
					//tmpItemContainer.z = tmpItemContainer.defaultZ - displayLimit.z * (Math.floor((tmpItemContainer.defaultZ + rootContainer.z) / displayLimit.z) );
					tmpItemContainer.z = tmpItemContainer.defaultZ - displayLimit.z * (((tmpItemContainer.defaultZ + rootContainer.z) / displayLimit.z)|0 );
				}
				else
				{	//表示領域内のコンテナに対する処理
					/*
					if (tmpZ < 200)
					{	//手前直前のコンテナに対する処理
						//上へずらす
						tmpItemContainer.y = tmpItemContainer.defaultY - 100 + tmpZ/2;
					}
					else
					{
						tmpItemContainer.y = tmpItemContainer.defaultY;
					}
					*/
				}
				
				tmpZ = tmpItemContainer.z + rootContainer.z;
				var fogDistance:Number = 100;
				
				if (tmpZ < fogDistance)
				{
					tmpItemContainer.alpha = tmpZ / fogDistance;
				}
				else if ( tmpZ < displayLimit.z - fogDistance)
				{
					tmpItemContainer.alpha = 1;
				}
				else
				{
					tmpItemContainer.alpha = (displayLimit.z - tmpZ) / fogDistance;
				}
				
				tmpX = tmpItemContainer.x + rootContainer.x;
				if (tmpX < fogDistance)
				{
					tmpItemContainer.alpha = tmpX / fogDistance;
				}
				else if ( tmpX < displayLimit.x - fogDistance)
				{
					//tmpItemContainer.alpha = 1;
				}
				else
				{
					tmpItemContainer.alpha = (displayLimit.x - tmpX) / fogDistance;
				}
				
			}
			
			
			// zの値を見てソートする(降順)
			itemContainerList.sortOn("z", Array.NUMERIC | Array.DESCENDING);
			// addChild()し直す
			for (i = 0; i < itemContainerListLength; i++) 
			{
				rootContainer.addChild(itemContainerList[i]);
			}
		}
		
		
		/**
		 * キーボードの矢印押下時のイベントハンドラ
		 * @param	argEvent
		 */
		private function keyDown_handler(argEvent:KeyboardEvent):void
		{
			var keyCode:uint = argEvent.keyCode;
			var moveValue:Point3D = new Point3D();
			switch(keyCode)
			{
				case 38:
					//trace("↑");
					moveValue.z = -20;
					break;
				case 39:
					//trace("→");
					moveValue.x = 20;
					break;
				case 40:
					//trace("↓");
					moveValue.z = 20;
					break;
				case 37:
					//trace("←");
					moveValue.x = -20;
					break;
			}
			moveRootContainer(moveValue.x, moveValue.y, moveValue.z);
		}
		
		
		
		/**
		 * ステージに配置された時用のハンドラ
		 * @param	argEvent
		 */
		private function addedStage_handler(argEvent:Event):void
		{
			//イベントリスナの解除
			removeEventListener(Event.ADDED_TO_STAGE, addedStage_handler);
			//ステージにキーボードのイベントリスナを追加
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown_handler);
			//リムーブ時のイベントリスナを追加
			addEventListener(Event.REMOVED_FROM_STAGE, removeStage_handler);
		}
		
		/**
		 * ステージからリムーブされた際のハンドラ
		 * @param	argEvent
		 */
		private function removeStage_handler(argEvent:Event):void
		{
			rootContainerRotationTween.kill();
			
			renderFlag = false;
			removeEventListener(Event.ENTER_FRAME, enterFrame_handler);
			
			//timer.stop();
			//timer.removeEventListener(TimerEvent.TIMER, timer_handler);
			//stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown_handler);
		}
		
		
		
		//デバッグ関連------------------------------------------------------------------------
		/**
		 * デバッグテキストを設置
		 * @param	message	初期メッセージ
		 */
		public function setDebugTextField(message:*):void
		{
			if (debugTxt == null)
			{
				debugTxt = new TextField();
				debugTxt.textColor = 0xdd0000;
				debugTxt.border = true;
				debugTxt.borderColor = 0xdd0000;
				debugTxt.selectable = false;
				addChild(debugTxt);
				debugTxt.x = 100;
				debugTxt.y = 100;
				
				debugTxt.text = String(message);
				
				debugTxt.addEventListener(Event.ENTER_FRAME, debugText_enterFrame_handler);
				debugTxt.addEventListener(Event.REMOVED_FROM_STAGE, debugText_removedFromStage_handler);
			}
		}
		/**
		 * デバッグテキストの表示内容を更新
		 * @param	argStr
		 */
		public function debugTxtUpdate(message:*):void
		{
			if (debugTxt != null)
			{
				debugTxt.text = String(message);
			}
		}
		private function debugText_enterFrame_handler(argEvent:Event):void
		{
			var tmpStr:String = "";
			
			tmpStr = tmpStr
				+ "rootContainer"
				+ "\n x : " + rootContainerShift.x + " / " + + rootContainer.x
				+ "\n y : " + rootContainerShift.y + " / " + + rootContainer.y
				+ "\n z : " + rootContainerShift.z + " / " + rootContainer.z
				;
			debugTxtUpdate(tmpStr);
		}
		private function debugText_removedFromStage_handler(argEvent:Event):void
		{
			debugTxt.removeEventListener(Event.ENTER_FRAME, debugText_enterFrame_handler);
			debugTxt.removeEventListener(Event.REMOVED_FROM_STAGE, debugText_removedFromStage_handler);
		}
		
	}

}


class Point3D
{
	public var x:Number;
	public var y:Number;
	public var z:Number;
	
	public function Point3D (_x:Number = 0, _y:Number = 0, _z:Number = 0)
	{
		x = _x;
		y = _y;
		z = _z;
	}
}

