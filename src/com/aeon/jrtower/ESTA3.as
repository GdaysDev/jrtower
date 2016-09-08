package com.aeon.jrtower {
	/**
	 * @author md760
	 */
	import flash.events.Event;
	import com.aeon.jrtower.model.ShopObject;
	import flash.display.Sprite;
	import com.aeon.jrtower.helper.ParseJsonData;
	import com.aeon.jrtower.model.ShopObject;
	import com.aeon.jrtower.view.viewesta3.*;
    import flash.utils.Timer;
	import flash.events.TimerEvent;
	import com.aeon.jrtower.view.viewestajrtowerframe6.EstaJRtowerFrame6;
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
	import com.aeon.jrtower.common.DefineCommonValue;
	import com.aeon.jrtower.helper.DataStorage;
	public class ESTA3 extends Sprite {
		
		var template3:ViewEsta3 ;

			
		private var parseJSon:ParseJsonData;
		private var indexShop:int;
		private var LAST_ID:String = "esta3_last_index_8352098595723947";
		
		public function ESTA3() {
			trace("esta 3");
			init();
			MotionBlurPlugin.install();
			 
			trace("call Esta 3");


			trace("Main W"+Capabilities.screenResolutionX);
			trace("Main H"+Capabilities.screenResolutionY);
			// 1080, 1920
			this.graphics.beginFill(0xdfdfdf); 
			//this.graphics.drawRect(0, DefineCommonValue.SPRITE_Y,DefineCommonValue.SPRITE_WIDTH,  DefineCommonValue.SPRITE_HEIGHT); 
			this.graphics.drawRect(0, 0,1080, 1920); 
			this.graphics.endFill();
			
			indexShop = 0;
		 	parseJSon = new ParseJsonData();
			var listShop:Array = parseJSon.loadConfigFromUrl("Template3");
			//trace("in esta 12: "+ listShop);
			parseJSon.addEventListener(Event.COMPLETE, completeHandler);
			//parseJSon.addEventListener(Event.COMPLETE, completeLoadData);
		}
		
		private function init() : void {
			stage.displayState = StageDisplayState.NORMAL;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;		
		}		
		
		private function completeHandler(event:Event):void {
			//var lastId: String = DataStorage.Data[LAST_ID]==null ? parseJSon.listShopParse[0].id : DataStorage.Data[LAST_ID];
			trace("load json completed:", parseJSon.listShopParse.length);
			var lastId: String = DataStorage.Data[LAST_ID]==null ? parseJSon.listShopParse[0].id : DataStorage.Data[LAST_ID];
			var shopCount:Number = parseJSon.listShopParse.length;
			for (var i : int = 0; i < shopCount; i++) {
				if (parseJSon.listShopParse[i].id != lastId) continue;
				var elem : ShopObject = parseJSon.listShopParse[i];
				if(elem.frameDivision == "9")
				{
					var panel : ViewEsta3 = new ViewEsta3(elem);
					addChild(panel);
					DataStorage.Data[LAST_ID] = parseJSon.listShopParse[(i+1)%shopCount].id;	
				}
				break;
			}
			
			
			//viewNextShopOnTimer(null);
			/*
			var nextShopTimer:Timer=new Timer(DefineCommonValue.SECOND_LOAD_NEXT_TEMPLATE);
			nextShopTimer.addEventListener(TimerEvent.TIMER, viewNextShopOnTimer);
			nextShopTimer.start(); 	
			*/	
		}
		
		function viewNextShopOnTimer(e:TimerEvent):void {
			if(template3)
			{
			 	this.removeChild(template3);
				template3 = null;
			}
			 indexShop = 0;
			 //this.graphics.clear();
		//	for(var i:int; i<parseJSon.listShopParse.length;i++)

		    if(parseJSon.listShopParse.length>0)
			{
				var shopObj:ShopObject = parseJSon.listShopParse[indexShop];
				trace("shopObj: "+shopObj);
				//trace(shopObj.title+ ", "+ shopObj.IMGFile1.ImgURL);
				// handle view and time slide between esta 1 & 2 
				if(shopObj.frameDivision == "9")// frame template 3 
				{ 
					// will add check time, shop name, title, image, broasdcast day, startime, end time 
					// before call 
					 template3 = new ViewEsta3(shopObj);

					this.addChild(template3);
					trace("Call template 1");
					var shopCount:Number = parseJSon.listShopParse.length;
					DataStorage.Data[LAST_ID] = parseJSon.listShopParse[(indexShop+1)%shopCount].id;
					
				}
				// add index of next shop
				indexShop++;
				trace("indexShop: "+indexShop);
				if(indexShop >= parseJSon.listShopParse.length)
				{
					indexShop = 0;
				}
			}else{
				//call ESTA JR TOWER FRAME 6, Exception 
				var frame6:EstaJRtowerFrame6 = new EstaJRtowerFrame6();
				this.addChild(frame6);
				trace("Call esta frame 6 - exception");
			}
		}
	}
}