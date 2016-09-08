package com.aeon.jrtower.view.viewestajrtowerframe6 {
	import flash.events.Event;
	import flash.display.MovieClip;
	import com.aeon.jrtower.helper.CommonFunction;
	import flash.events.Event;
	import com.aeon.jrtower.model.ShopObject;
	import flash.display.*;
	import flash.text.TextField; 
	import flash.net.URLRequest; 	
	import flash.system.Capabilities;
	import com.gskinner.motion.GTweener;
	//import com.gskinner.motion.GTween;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import com.aeon.jrtower.common.DefineCommonValue;
	import flash.display.Sprite;
	import com.aeon.jrtower.helper.ParseJsonData;
	import com.aeon.jrtower.model.ShopObject;
	/**
	 * @author md760
	 */
	public class EstaJRtowerFrame6 extends Sprite{
		
		private var estaFrame6Loader:Loader;
		
		public function EstaJRtowerFrame6() {
			trace("Load Esta Frame 6");
			estaFrame6Loader = new Loader();
			var url:URLRequest = new URLRequest("pillarVision/index.swf");
			estaFrame6Loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadEstaJRtowerFrame6Complete);
			estaFrame6Loader.load(url);
		}
		
		private function loadEstaJRtowerFrame6Complete(event:Event):void
		{
			estaFrame6Loader.y =  0;
			estaFrame6Loader.x = 0;
		    estaFrame6Loader.width = DefineCommonValue.SPRITE_WIDTH;
			estaFrame6Loader.height = DefineCommonValue.SPRITE_HEIGHT;
			addChild(estaFrame6Loader);
			
			trace("Finish Load Esta Frame 6");
		}
	}
}