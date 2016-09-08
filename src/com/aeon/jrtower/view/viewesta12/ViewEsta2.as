package com.aeon.jrtower.view.viewesta12 {
	import com.aeon.jrtower.helper.CommonFunction;
	import com.stanfoot.common.imageContainer.ImageContainerEventType;
	import com.stanfoot.common.imageContainer.ImageContainer;
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
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.*;
	
	/**
	 * @author md760
	 */
	public class ViewEsta2 extends Sprite{
		private const TOP_BOX_HEIGHT:Number = 76;
		private const BOTTTOM_BOX_HEIGHT:Number = 152;
		private const BIG_SHOP_IMAGE_MOVE_UP_DISTANCE:Number = 20;
		private var showShopIndex:ShopObject;
		private var bigShopImageLoader:Loader;
		var loadTextAtBottomTimer:Timer;
		var estaLogoLoader:Loader;
		var titleBottomScroll:TextField;
		var postionScrollX:Number = DefineCommonValue.SPRITE_WIDTH;
		
		public function ViewEsta2(showObj:ShopObject) {
			
			showShopIndex = showObj;
			
			loadTopBox();
			
			// load big image in center
			/*
			bigShopImageLoader = new Loader();
			var url2:URLRequest = new URLRequest(DefineCommonValue.JSON_IMG + showObj.IMGFile.ImgURL);
			bigShopImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBigShopImageComplete);
			bigShopImageLoader.load(url2);
			*/
		    var y:Number = 76;
			var x:Number = 0;
		    var width:Number = DefineCommonValue.SPRITE_WIDTH;
			var height:Number = DefineCommonValue.SPRITE_HEIGHT - (TOP_BOX_HEIGHT + BOTTTOM_BOX_HEIGHT);

			var fileBigImg:String = DefineCommonValue.JSON_IMG + showObj.IMGFile.ImgURL;
			//showObj.IMGFile.ImgURL ="";// for testing 
			if(showObj.IMGFile.ImgURL == null || showObj.IMGFile.ImgURL.length == 0)
			{
				fileBigImg = "SystemImg/noimage.png";
			}
			
			var img1: ImageContainer = generateImg(fileBigImg, x, y, width, height);
			GTweener.to(img1, 2, {y: y, alpha:1},{reflect:true});
		}
		
		private function generateImg(url : String, x : int, y : int, w : int, h : int) : ImageContainer {
			var img1 : ImageContainer = new ImageContainer();
			img1.init(w, h, null);
			img1.load(url);
			img1.x = x;
			img1.y = y;
			img1.addEventListener(ImageContainerEventType.LOAD_COMPLETE, loadCompleted);
			this.addChild(img1);
			return img1;
		}
		
		private function loadCompleted(e:Event):void {
//			Todo: get number of completed load image to start animation
			trace("img load completed ~~~~~~~~~~~~~~~~~~~~~~~~~~~");
		}
		
		private function scheduleShowContent()
		{
		   // move text at bottom 
			loadTextAtBottomTimer = new Timer(1000,1); // 1 second
			loadTextAtBottomTimer.addEventListener(TimerEvent.TIMER, runMoveTextAtBottom);
			loadTextAtBottomTimer.start();
			function runMoveTextAtBottom(event:TimerEvent):void {
				loadTextAtBottom();
			}
		}
		
		function loadTextAtBottom()
		{
			var myFormatTitle:TextFormat = new TextFormat();
			myFormatTitle.size = 60;
			var titleBottom:TextField = new TextField();
			titleBottom.text = showShopIndex.title;
			titleBottom.defaultTextFormat = myFormatTitle;
			titleBottom.width = 200 ;
			titleBottom.x= 50 ;
			titleBottom.y = DefineCommonValue.SPRITE_HEIGHT - BOTTTOM_BOX_HEIGHT/2 ;
			this.addChild(titleBottom);
			titleBottom.alpha = 0;
			//GTweener.to(titleBottom, 2, {x:50, alpha:1},{reflect:false});
			//loadTextAtBottomTimer.stop();
		}
		
		function loadBigShopImageComplete(event:Event):void
		{
   			trace("Complete");
		   // bigShopImageLoader.y = 200;//TOP_BOX_HEIGHT+ BIG_SHOP_IMAGE_MOVE_UP_DISTANCE;
		    bigShopImageLoader.y = TOP_BOX_HEIGHT;
			bigShopImageLoader.x = 0;
		    bigShopImageLoader.width = DefineCommonValue.SPRITE_WIDTH;
			this.scaleY = (DefineCommonValue.SPRITE_HEIGHT - (TOP_BOX_HEIGHT + BOTTTOM_BOX_HEIGHT)) / DefineCommonValue.SPRITE_HEIGHT;
			//showShopIndex.title  = ""; // for testing
			if(showShopIndex.title.length >0)
			{
				bigShopImageLoader.height = DefineCommonValue.SPRITE_HEIGHT - (TOP_BOX_HEIGHT + BOTTTOM_BOX_HEIGHT);
			}else{
				bigShopImageLoader.height = DefineCommonValue.SPRITE_HEIGHT - TOP_BOX_HEIGHT ;
			}
			bigShopImageLoader.alpha = 0;
			addChild(bigShopImageLoader);
			//GTweener.to(bigShopImageLoader, 1, {y:TOP_BOX_HEIGHT, alpha:1},{reflect:true});
			//GTweener.to(bigShopImageLoader, 2, {y: bigShopImageLoader.y, alpha:1},{reflect:true});
					
		}
		
		private function loadTopBox()
		{
					// add box bottom 
			var boxTop:Sprite = new Sprite(); 
			boxTop.graphics.lineStyle(1); 
			boxTop.graphics.beginFill(0xFFFFFF); 
			boxTop.graphics.lineStyle(1,0xFFFFFF);
			boxTop.graphics.drawRect(0, 0, DefineCommonValue.SPRITE_WIDTH, TOP_BOX_HEIGHT); 
			boxTop.graphics.endFill(); 
			//boxBottom.filters = [shadow];	
			addChild(boxTop);

			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 36;
			var title:TextField = new TextField();
			title.defaultTextFormat = myFormat;
			title.text = CommonFunction.getCurrentTimeNumber();
			title.width = 200 ;
			title.x= Capabilities.screenResolutionX - 120;
			title.y = TOP_BOX_HEIGHT/2 +20;
			boxTop.addChild(title);
			
			// load day of week
			//CommonFunction.getCurrentDay()
			//CommonFunction.addTitleToPanel(Capabilities.screenResolutionX - 350, TOP_BOX_HEIGHT/2 + 28, 200, 50, this, 26, CommonFunction.getCurrentDay(), "right",0x000000);
			
			var dayofWeekFormat:TextFormat = new TextFormat();
			dayofWeekFormat.size = 25;
			dayofWeekFormat.italic = true;
			var dayofweek:TextField = new TextField();
			dayofweek.defaultTextFormat = dayofWeekFormat;
			dayofweek.text = CommonFunction.getCurrentDay();
			dayofweek.width = 200 ;
			dayofweek.height = 50;
			dayofweek.x= Capabilities.screenResolutionX - 255;
			dayofweek.y = TOP_BOX_HEIGHT/2 + 25;
			boxTop.addChild(dayofweek);
			
			
			// load logo ESTA
			estaLogoLoader = new Loader();
			var url2:URLRequest = new URLRequest("SystemImg/estaIcon.png");
			estaLogoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadEstaLogoImageComplete);
			estaLogoLoader.load(url2);
			
			//load bottom title
			//showShopIndex.title  = ""; // for testing
			if(showShopIndex.title.length >0)
			{
				var myFormatTitle:TextFormat = new TextFormat();
				myFormatTitle.size = 38;
				titleBottomScroll = new TextField();
				titleBottomScroll.defaultTextFormat = myFormatTitle;
				titleBottomScroll.text = showShopIndex.title;
			
				titleBottomScroll.width = DefineCommonValue.SPRITE_WIDTH ;
				titleBottomScroll.x= DefineCommonValue.SPRITE_WIDTH ;
				titleBottomScroll.y = DefineCommonValue.SPRITE_HEIGHT - BOTTTOM_BOX_HEIGHT ;
			
				
				titleBottomScroll.alpha = 1;
				this.addChild(titleBottomScroll);
				var scrollTitle:Timer = new Timer(10,0); // 1 second
				scrollTitle.addEventListener(TimerEvent.TIMER, runScrollText);
				scrollTitle.start();
				function runScrollText(event:TimerEvent):void {
					addScrollText();
				}
			}
		}
		
		function addScrollText()
		{
			postionScrollX = postionScrollX - 1;
			if(postionScrollX <=0 )
			{
				postionScrollX = DefineCommonValue.SPRITE_WIDTH ;
			}
			titleBottomScroll.x = postionScrollX;
			this.addChild(titleBottomScroll);
		}
		
		function loadEstaLogoImageComplete(event:Event):void
		{
   			trace("Complete");
		    estaLogoLoader.y =  TOP_BOX_HEIGHT/2 ;
			estaLogoLoader.x = 15;
		    estaLogoLoader.width = 132;
			estaLogoLoader.height = 80;
			addChild(estaLogoLoader);
		
			//scheduleShowContent();
			//loadTextAtBottom();
		
		}
		
	}
}