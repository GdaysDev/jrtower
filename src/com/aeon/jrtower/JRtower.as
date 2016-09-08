package com.aeon.jrtower {
	import flash.display.Sprite;
	import flash.display.*;
	import flash.text.TextField; 
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext; 
 	
	import com.gskinner.motion.plugins.*;
	import com.gskinner.motion.easing.*;
	import flash.system.Capabilities;
	import flash.display.Stage; 
	import flash.display.StageAlign; 
	import flash.display.StageScaleMode; 
	import flash.events.Event;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.GTween;
//import com.gskinner.motion.TweenLite;
	//impor tflash.system.Capabilities.*;
	/**
	 * @author md760
	 */
	public class JRtower extends Sprite {
		
		var swfStage:Stage = stage; 
		var pict:Loader;
		
		public function JRtower() {
			trace("jrtower");
			  MotionBlurPlugin.install();
	
	
	
		  var ball:Sprite = new Sprite();
           ball.graphics.beginFill(0xFF0000);
           ball.graphics.drawCircle(5,5,10);
        
          // var myTween:GTween = new GTween(ball, 5, {x:10, y:50}, {swapValues:true});
          
		

			// MotionBlurPlugin is the only plugin that has enabled set to false by default.
			// Instead of setting MotionBlurEnabled on pluginData for all of the tweens
			// you could enable it by default for all tweens with:
			// MotionBlurPlugin.enabled = true;
			/*
			var tween4:GTween = new GTween(ball,0.4, {y:5,alpha:1}, {autoPlay:false,delay:0.5,ease:Sine.easeInOut}, {MotionBlurEnabled:false});
			var tween3:GTween = new GTween(ball,0.4, {x:5,alpha:1}, {autoPlay:false,nextTween:tween4,delay:0.5,ease:Sine.easeInOut}, {MotionBlurEnabled:true});
			var tween2:GTween = new GTween(ball,0.4, {y:1920,alpha:1}, {autoPlay:false,nextTween:tween3,delay:0.5,ease:Sine.easeInOut}, {MotionBlurEnabled:true});
			var tween1:GTween = new GTween(ball,0.5, {x:1080,alpha:1}, {nextTween:tween2,delay:0.5,ease:Sine.easeInOut}, {MotionBlurEnabled:true});
			tween4.nextTween = tween1;
		  //  mainPanel.addChild(ball);
			this.addChild(ball);
			*/
			trace("H" + stage.fullScreenHeight);
			trace("W" + stage.fullScreenWidth);
			
			trace("W"+Capabilities.screenResolutionX);
			trace("H"+Capabilities.screenResolutionY);
			
		//	var appBounds : Rectangle = stage.nativeWindow.bounds;
		//var screen : Screen = Screen.getScreensForRectangle( appBounds )[0];
		//var screenBounds : Rectangle = screen.bounds;
		trace(stage.nativeWindow.bounds);

		/*
		swfStage.scaleMode = StageScaleMode.NO_SCALE; 
		swfStage.align = StageAlign.TOP_LEFT; 
		swfStage.addEventListener(Event.RESIZE, resizeDisplay); 
		*/
		
		var container:Sprite = new Sprite();
		var title:TextField = new TextField();
		title.text = "Hello";
		title.x=10;
		title.y=50;
		 pict = new Loader();
		var url:URLRequest = new URLRequest("pillar_vision_cross_jrtower/img/00001273_00003194_00000211.jpg");
		 pict.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
		pict.load(url);

		pict.name = "banana loader";
		pict.x = 30;
		pict.y = 100;
		
		//GTweener.from(container, 2, {x:400, alpha:0.1, scaleX:0.5, scaleY:0.5}, {repeatCount:1, reflect:false});
		//GTweener.to(container, 2, {x:400, alpha:0.5, scaleX:0.5, scaleY:0.5}, {repeatCount:0, reflect:true});
		//GTweener.to(ball, 0.4, {x: mouseX});
		// alpha show hide
		//GTweener.from(container, 2, {alpha:0.5});
		GTweener.to(container, 1, { alpha:1, ease:Sine.easeInOut });
		
		
		container.addChild(title);
		container.addChild(pict);

		addChild(container); 
		
		//animateTween();
		}
		
		 function loadComplete(event:Event):void
{
   trace("Complete");
  var bm:Bitmap = Bitmap(pict.content);
  // var CXL = bm.width;
  // var CYL = bm.height;
   		trace("pict W: "+ bm.width);
		trace("pict H: "+ bm.height);
}
		
		function animateTween()
		{
			/*
		var container:Sprite = new Sprite();
		var title:TextField = new TextField();
		title.text = "Hello";
		var pict:Loader = new Loader();
		var url:URLRequest = new URLRequest("pillar_vision_cross_jrtower/img/00001433_00006951_00000022.jpg");
		pict.load(url);
		pict.name = "banana loader";
		pict.x = 30;
		pict.y = 100;
		
		GTween.to(ball, 2, {x:200, y:350}, {repeatCount:0, reflect:true});
		
		container.addChild(title);
		container.addChild(pict);

		addChild(container); 
		*/
		}
		
		function resizeDisplay(event:Event):void 
{ 
    		var swfWidth:int = swfStage.stageWidth; 
    		var swfHeight:int = swfStage.stageHeight; 
			trace("W="+swfWidth + ", H="+ swfHeight);

}
	}
}