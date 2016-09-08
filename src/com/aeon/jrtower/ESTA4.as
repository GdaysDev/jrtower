package com.aeon.jrtower {
	import flash.net.SharedObject;
	import flash.geom.Rectangle;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import com.aeon.jrtower.view.viewesta4.ViewEsta4;
	import com.aeon.jrtower.model.ShopObject;
	import com.aeon.jrtower.helper.DataStorage;

	import flash.events.Event;

	import com.aeon.jrtower.helper.ParseJsonData;
	/**
	 * @author md760
	 */
	import flash.display.Sprite;

	public class ESTA4 extends Sprite {
		var parseJson : ParseJsonData;
		var listShop : Array;
		var shareObj : SharedObject;
		private var LAST_ID:String = "esta4_last_index_8352098595723947";

		public function ESTA4() {
			trace("esta 4");
			init();
			getDataFromJson();
		}

		private function getDataFromJson() : void {
			parseJson = new ParseJsonData();
			listShop = parseJson.loadConfigFromUrl("Template4");
			parseJson.addEventListener(Event.COMPLETE, onLoadJsonComplete);
		}

		private function onLoadJsonComplete(e : Event) : void {
			trace("load json completed:", parseJson.listShopParse.length);
			var lastId: String = DataStorage.Data[LAST_ID]==null ? parseJson.listShopParse[0].id : DataStorage.Data[LAST_ID];
			var shopCount:Number = parseJson.listShopParse.length;
			for (var i : int = 0; i < shopCount; i++) {
				if (parseJson.listShopParse[i].id != lastId) continue;
				var elem : ShopObject = parseJson.listShopParse[i];
				var panel : ViewEsta4 = new ViewEsta4(elem);
				addChild(panel);
				DataStorage.Data[LAST_ID] = parseJson.listShopParse[(i+1)%shopCount].id;	
				break;
			}
			
				
		}

		private function init() : void {
			stage.displayState = StageDisplayState.NORMAL;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;				
		}
	}
}