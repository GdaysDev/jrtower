package com.aeon.jrtower {
	import com.aeon.jrtower.helper.CommonFunction;
	import air.net.URLMonitor;
	import flashx.textLayout.conversion.ImportExportConfiguration;
	/**
	 * @author md760
	 */
	import flash.events.Event;
	import flash.display.Sprite;
	import com.aeon.jrtower.helper.ParseJsonData;
	import com.aeon.jrtower.model.ShopObject;
	import com.aeon.jrtower.view.viewesta12.*;
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
	import flash.net.*;
	import flash.desktop.*;
	import com.aeon.jrtower.helper.DataStorage;
//import com.gskinner.motion.TweenLite;	
	public class ESTA12 extends Sprite {
		
		var monitor:URLMonitor;
		
		var template1:ViewEsta1 ;
		var template2:ViewEsta2 ;
			
		private var parseJSon:ParseJsonData;
		private var indexShop:int;
		private var LAST_ID:String = "esta2_last_index_8352098595723947";
		
		public function ESTA12() {
			
			init() ;
			MotionBlurPlugin.install();
			trace("Status change. You are connected to the internet");
			indexShop = 0;
		 	parseJSon = new ParseJsonData();
			var listShop:Array = parseJSon.loadConfigFromUrl("Template1-2");
			parseJSon.addEventListener(Event.COMPLETE, completeHandler);
			///NativeApplication.nativeApplication.addEventListener(Event.NETWORK_CHANGE,onNetworkChange);
		}
		
		private function init() : void {
			stage.displayState = StageDisplayState.NORMAL;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;		
		}
		
		protected function onNetworkChange(e:Event):void
        {

            monitor = new URLMonitor(new URLRequest('http://www.google.com'));
            monitor.addEventListener(StatusEvent.STATUS, netConnectivity);
            monitor.start();
        }

        protected function netConnectivity(e:StatusEvent):void 
        {
            if(monitor.available)
            {
                trace("Status change. You are connected to the internet");
				indexShop = 0;
		 		parseJSon = new ParseJsonData();
				var listShop:Array = parseJSon.loadConfigFromUrl("Template1-2");
				parseJSon.addEventListener(Event.COMPLETE, completeHandler);
            }
            else
            {
                trace("Status change. You are not connected to the internet");
				 estaFrame6Exception();
            }

            monitor.stop();
        }

		private function completeHandler(event:Event):void {
			
			trace("load json completed:", parseJSon.listShopParse.length);
			var lastId: String = DataStorage.Data[LAST_ID]==null ? parseJSon.listShopParse[0].id : DataStorage.Data[LAST_ID];
			var shopCount:Number = parseJSon.listShopParse.length;
			for (var i : int = 0; i < shopCount; i++) {
				if (parseJSon.listShopParse[i].id != lastId) continue;
				var elem : ShopObject = parseJSon.listShopParse[i];
				
				if(elem.template == "1")// frame division 7
				{ 
					// will add check time, shop name, title, image, broasdcast day, startime, end time 
					// before call 
					 template1 = new ViewEsta1(elem);
					trace("x: "+ template1.x + ", y: "+ template1.y +", w:"+ template1.width + ",h:"+template1.height);
					this.addChild(template1);
					trace("Call template 1");
				}else if(elem.template == "2"){ // frame division 8
					template2 = new ViewEsta2(elem);
					this.addChild(template2);
					trace("Call template 2");
				}
				DataStorage.Data[LAST_ID] = parseJSon.listShopParse[(i+1)%shopCount].id;
			
				break;
			}
			/*
			//indexShop=1; // FOR TESTING
			
			viewNextShopOnTimer(null);
			// schedule call next shop, when finish loading one shop for AD
			
			var nextShopTimer:Timer=new Timer(DefineCommonValue.SECOND_LOAD_NEXT_TEMPLATE);
			nextShopTimer.addEventListener(TimerEvent.TIMER, viewNextShopOnTimer);
			nextShopTimer.start(); 
			 */
	
		}
		
		function viewNextShopOnTimer(e:TimerEvent):void {
			if(template1)
			{
			 	this.removeChild(template1);
				template1 = null;
			}
			if(template2)
			{
			 	this.removeChild(template2);
				template2 = null;
			}
			 this.graphics.clear();
		//	for(var i:int; i<parseJSon.listShopParse.length;i++)

		    if(parseJSon.listShopParse.length>0)
			{
				var shopObj:ShopObject = parseJSon.listShopParse[indexShop];
				//trace(shopObj.title+ ", "+ shopObj.IMGFile1.ImgURL);
				// handle view and time slide between esta 1 & 2 
				if(shopObj.template == "1")// frame division 7
				{ 
					// will add check time, shop name, title, image, broasdcast day, startime, end time 
					// before call 
					 template1 = new ViewEsta1(shopObj);
					trace("x: "+ template1.x + ", y: "+ template1.y +", w:"+ template1.width + ",h:"+template1.height);
					this.addChild(template1);
					trace("Call template 1");
				}else if(shopObj.template == "2"){ // frame division 8
					template2 = new ViewEsta2(shopObj);
					this.addChild(template2);
					trace("Call template 2");
				}
				// add index of next shop
				indexShop++;
				trace("indexShop: "+indexShop);
				if(indexShop >= parseJSon.listShopParse.length)
				{
					indexShop = 0;
				}
			}else{
				 estaFrame6Exception();
				trace("Call esta frame 6 - exception");
			}
		}
		
		private function estaFrame6Exception()
		{
			//call ESTA JR TOWER FRAME 6, Exception 
			var frame6:EstaJRtowerFrame6 = new EstaJRtowerFrame6();
			this.addChild(frame6);
			trace("Call esta frame 6 - exception");
		}
		
	}
}