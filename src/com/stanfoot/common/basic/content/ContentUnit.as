package com.stanfoot.common.basic.content 
{
	import com.stanfoot.common.GeneralFuncs;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * コンテンツのユニット
	 * @author 
	 */
	public class ContentUnit extends MovieClip 
	{
		//インスタンスメンバ==================================================================================
		
		//表示オブジェクト---------------------------------------------
		
		
		//オブジェクト---------------------------------------------
		
		/** gotoAndPlayLabel の 終了時のコールバック */
		protected var _gapl_onComplete:Function;
		protected var _gapl_onCompleteParams:Array;
		
		//パラメーター---------------------------------------------
		
		/** 設定された言語モードのID */
		protected var _langId:String = "";
		/** 設定された言語モードのIDを返す */
		public function get langId():String
		{	return _langId;	};
		
		/** gotoAndPlayLabel の 最後のフレームラベル名 */
		protected var _gapl_lastFrameLabel:String;
		
		protected var _initialized:Boolean;
		
		//メソッド---------------------------------------------
		
		/**
		 * コンストラクタ
		 */
		public function ContentUnit() 
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, addedToStage_listener);
			stop();
			
		}
		
		/**
		 * 初期化
		 * @param	paramsObj	パラメーターオブジェクト
		 */
		public function init(paramsObj:Object = null):void
		{
			_initialized = true;
		}
		
		/**
		 * 表示するアニメーションを実行
		 * @param	paramsObj	パラメーターオブジェクト
		 */
		public function show(paramsObj:Object = null):void
		{
			if (paramsObj && _initialized == false ) init(paramsObj);
		}
		
		protected function _dispatchEvent_showComplete():void
		{
			dispatchEvent(new ContentUnitEvent(ContentUnitEvent.SHOWCOMPLETE));
		}
		protected function _dispatchEvent_showFailed():void
		{
			dispatchEvent(new ContentUnitEvent(ContentUnitEvent.SHOWFAILED));
		}
		protected function _dispatchEvent_hideComplete():void
		{
			dispatchEvent(new ContentUnitEvent(ContentUnitEvent.HIDECOMPLETE));
		}
		protected function _dispatchEvent_hideFailed():void
		{
			dispatchEvent(new ContentUnitEvent(ContentUnitEvent.HIDEFAILED));
		}
		
		/**
		 * 隠すアニメーションを実行
		 * @param	paramsObj	パラメーターオブジェクト
		 */
		public function hide(paramsObj:Object = null):void
		{
			
		}
		
		/**
		 * 言語モードの切り替え
		 * "LABEL_" + langId のフレームラベルがあれば、そのラベルに移動する
		 * @param	langId	言語ID
		 */
		public function changeLangMode(langId:String):void
		{
			if (langId as String && _langId != langId )
			{
				_langId = langId;
			}
			var tmpLabel:String = "LABEL_" + this.langId;
			var tmpIndex:int = GeneralFuncs.searchIndex(currentLabels, "name", tmpLabel);
			if (tmpIndex >= 0 && currentLabel != tmpLabel)
			{
				//目標となる言語のラベルがあり、現在は異なるラベルにいるとき、移動する。
				gotoAndStop(tmpLabel);
			}
		}
		
		/**
		 * 即削除
		 */
		public function clear():void
		{
			stop();
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage_listener);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removeFromStage_listener);
			
			_gapl_onComplete = null;
			_gapl_onCompleteParams = null;
		}
		
		/**
		 * ステージ追加時のリスナ
		 * @param	e
		 */
		protected function addedToStage_listener(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage_listener);
			addEventListener(Event.REMOVED_FROM_STAGE, _removeFromStage_listener);
		}
		
		protected function _removeFromStage_listener(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, _removeFromStage_listener);
			clear();
		}
		
		/**
		 * 指定されたフレームラベルの間だけタイムラインを進める。
		 * （異なるフレームラベルに突入したらstopする）
		 * @param	label
		 * @return	該当するラベルの有無
		 */
		protected function gotoAndPlayLabel(label:String, onComplete:Function = null, onCompleteParams:Array = null):Boolean
		{
			var result:Boolean;
			var tmpLength:int = currentLabels.length;
			var tmpLabel:FrameLabel;
			
			_gapl_onComplete = onComplete as Function;
			_gapl_onCompleteParams = onCompleteParams as Array;
			
			for (var i:int = 0; i < tmpLength; i++) 
			{
				tmpLabel = currentLabels[i];
				
				//目的とするラベルがあった場合
				if (tmpLabel.name == label) {
					result = true;
					_gapl_lastFrameLabel = label;
					
					gotoAndPlay(_gapl_lastFrameLabel);
					addEventListener(Event.ENTER_FRAME, gotoAndPlayLabel_enterFrame_listener);
					break;
				}
			}
			
			return result;
		}
		
		/**
		 * タイムラインの停止（gotoAndPlayLabel の enterFrameをリムーブ）
		 */
		override public function stop():void 
		{
			removeEventListener(Event.ENTER_FRAME, gotoAndPlayLabel_enterFrame_listener);
			super.stop();
		}
		
		/**
		 *gotoAndPlayLabel のenterFrameリスナ
		 * @param	e
		 */
		protected function gotoAndPlayLabel_enterFrame_listener(e:Event):void
		{
			//もし指定ラベルが変わったら停止する。
			if (currentLabel != _gapl_lastFrameLabel) {
				stop();
				
				if (_gapl_onComplete is Function)
				{
					if (_gapl_onCompleteParams)
					{
						_gapl_onComplete.apply(null, _gapl_onCompleteParams);
					}
					else
					{
						_gapl_onComplete();
					}
				}
				_gapl_onComplete = null;
				_gapl_onCompleteParams = null;
			}
		}
	}
}
