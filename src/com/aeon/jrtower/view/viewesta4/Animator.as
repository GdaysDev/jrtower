package com.aeon.jrtower.view.viewesta4 {
	import com.gskinner.motion.GTween;
	import flash.display.MovieClip;

	/**
	 * @author lethang
	 */
	public class Animator extends MovieClip {
		private var mTween : GTween;
		public function Animator() {
		}
		
		public function fadeIn(durationInSecond:Number) {
			mTween = new GTween(this, durationInSecond, {opacity: 1});
		}
	}
}