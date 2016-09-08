package com.stanfoot.common.touch 
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import com.stanfoot.common.debug.Debug;
	/**
	 * ...
	 * @author STANFOOT INC.
	 */
	public class TouchBlocker 
	{
		/** ブロッカーが有効かどうか */
		private static var _enable:Boolean;
		
		public static function get status():Boolean
		{
			return _enable;
		}
		
		/** タッチブロックするステージ */
		private static var _stage:Stage;
		
		public function TouchBlocker() 
		{
			
		}
		
		/**
		 * 初期化
		 * @param	argStage	ステージ
		 * @param	touchReaction	タッチ時にリアクションをするかどうか
		 */
		public static function init(stage:Stage ,touchReaction:Boolean)
		{
			_stage = stage;
			
			//タッチリアクション--------------------------------
			if (touchReaction)
			{
				//ステージにタッチイベントを登録
				_stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_down_handler);
			}
		}
		
		/**
		 * ブロックするかどうかを引数で指定します。
		 * argEnable が true のときはブロックする false のときは解除する
		 * @param	argEnable
		 */
		public static function block(argEnable:Boolean)
		{
			if ( _enable != argEnable)
			{	//ブロックの状態が変更される場合
				if (argEnable)
				{
					//ブロックを有効に変更
					enableBlocker();
				}
				else
				{
					//ブロックを無効に変更
					disableBlocker();
				}
			}
			else
			{
				//ブロックの状態変更なし
			}
		}
		
		/**
		 * タッチブロックを有効にします
		 */
		public static function enableBlocker()
		{
			if (!_enable)
			{
				Debug.write("\n[TouchBlocker]▼▼▼▼▼ ブロックします ▼▼▼▼▼");
				_stage.mouseChildren = false;
				//_stage.mouseEnabled = false;
				_enable = true;
			}
		}
		
		/**
		 * タッチブロックを無効にします
		 */
		public static function disableBlocker()
		{
			if (_enable)
			{
				Debug.write("[TouchBlocker]▲▲▲▲▲ ブロックを解除します ▲▲▲▲▲\n");
				_stage.mouseChildren = true;
				//_stage.mouseEnabled = true;
				_enable = false;
			}
		}
		
		
		/**
		 * タッチをした際の処理
		 * @param	argEvent
		 */
		private static function stage_down_handler(argEvent:MouseEvent)
		{
			if (!_enable)
			{	//タッチブロッカーが無効のとき、タッチリアクションを返す
				//trace(_stage.mouseX + "," + _stage.mouseY);
				var tmpEffectMc:TouchReaction = new TouchReaction();
				tmpEffectMc.x = _stage.mouseX;
				tmpEffectMc.y = _stage.mouseY;
				_stage.addChild(tmpEffectMc);
			}
		}
		
	}

}