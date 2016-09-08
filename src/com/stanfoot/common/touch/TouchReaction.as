package com.stanfoot.common.touch 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.BlendMode;
	
	//TweenMax / TweenLite
	import com.greensock.*;
	import com.greensock.easing.*;
	
	
	/**
	 * エフェクトアニメーションを実行して消える
	 * ※タイムライン最後でコンプリートイベントをディスパッチします。
	 * @author STANFOOT INC.
	 */
	public class TouchReaction extends MovieClip
	{
		
		/**
		 * コンストラクタ
		 */
		public function TouchReaction() 
		{
			addEventListener(Event.COMPLETE, anime_complete_handler);
			TweenMax.to(this, 0.2, { alpha:0, blurFilter: { blurX:8, blurY:8 }, delay:0.15 } );
			this.play();
			this.blendMode = BlendMode.SCREEN;
		}
		
		/**
		 * アニメーション終了検出時の処理
		 * @param	argEvent
		 */
		private function anime_complete_handler(argEvent:Event)
		{
			this.stop();
			removeEventListener(Event.COMPLETE, anime_complete_handler);
			if (this.parent != null)
			{
				this.parent.removeChild(this);
			}
		}
		
	}

}