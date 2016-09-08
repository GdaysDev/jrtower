package com.aeon.jrtower.view.viewesta12 {
	//import flash.display.MovieClip;
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
	/**
	 * @author md760
	 */
	public class ViewEsta1 extends Sprite{
		private const BOX_LOGO_HEIGHT:Number = 260;
		private const BIG_SHOP_IMAGE_PADDING:Number = 50;
		private const BIG_SHOP_IMAGE_WIDTH:Number = 960;
		private const BIG_SHOP_IMAGE_HEIGHT:Number = 960;
		private const BIG_SHOP_IMAGE_MOVE_UP_DISTANCE:Number = 20;
		
		private const TITLE_BOX_BG_WIDTH:Number = 658;
		private const TITLE_BOX_BG_HEIGHT:Number = 76;
		private const TITLE_BOX_BG_MOVE_LEFT:Number = 100;
		
	    protected const PADDING_TOP_BOX_INFORMATION:Number = 84;
		
		private const BOX_INFORMATION_HEIGHT:Number = 400; 
		private const BOX_INFORMATION_WIDTH:Number = 1040; 
		
		private const BOX_BOTTOM_HEIGHT:Number = 106; 
		
		
		private var boxInformationMoveFromRightToLeft:Sprite;
		private var titleBoxBackgroundSprite:Sprite;
		private var logoLoader:Loader;
		private var bigShopImageLoader:Loader;
	
		private var showShopIndex:ShopObject;
		
		var runBlackBackgroundBoxTimer:Timer;
		var showTextInBoxBackgroundMoveLeftTimer:Timer;
		var showBoxInformationMoveFromRightToLeftTimer:Timer;
		var showTextShopNameMoveRightToLeftTimer:Timer;
		var showTextShopInformationMoveRightToLeftTimer:Timer;
		var estaLogoLoader:Loader;
		
		public function ViewEsta1(showObj:ShopObject) {

			showShopIndex = showObj;
			
			this.graphics.beginFill(0xe5e5e5); 
			//this.graphics.drawRect(0, DefineCommonValue.SPRITE_Y,DefineCommonValue.SPRITE_WIDTH,  DefineCommonValue.SPRITE_HEIGHT); 
			this.graphics.drawRect(0, 0,1080, 1920); 
			this.graphics.endFill();
			
			// load logo on top
			logoLoader = new Loader();
			var url:URLRequest = new URLRequest(DefineCommonValue.JSON_IMG + showObj.IMGShopLogo.ImgURL);
			logoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadLogoComplete);
			logoLoader.load(url);
			
			// load big image in center
			bigShopImageLoader = new Loader();
			var fileBigImg:String = DefineCommonValue.JSON_IMG + showObj.IMGFile.ImgURL;
			trace("file: "+ showObj.IMGFile.ImgURL);
			if(showObj.IMGFile.ImgURL == null || showObj.IMGFile.ImgURL.length == 0)
			{
				fileBigImg = "SystemImg/noimage.png";
			}
			
			var url2:URLRequest = new URLRequest(fileBigImg);
			bigShopImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBigShopImageComplete);
			bigShopImageLoader.load(url2);
	
		}
		
		private function scheduleShowContent()
		{
			//showShopIndex.shopName ="";// for testing 
			if(showShopIndex.shopName.length > 0)
			{
				runBlackBackgroundBoxTimer = new Timer(1500,1); // 1 second
				runBlackBackgroundBoxTimer.addEventListener(TimerEvent.TIMER, runBlackBackgroundBox);
				runBlackBackgroundBoxTimer.start();
				function runBlackBackgroundBox(event:TimerEvent):void {
					showBoxBackgroundMoveLeft();
				}
			}else{
				// draw box and fill title, shop info 
				
				// run box shop information move from left to right 
		    	showBoxInformationMoveFromRightToLeftTimer = new Timer(2500,1); // 1 second
				showBoxInformationMoveFromRightToLeftTimer.addEventListener(TimerEvent.TIMER, runBoxShopInformation);
				showBoxInformationMoveFromRightToLeftTimer.start();
				function runBoxShopInformation(event:TimerEvent):void {
					showBoxInformationMoveFromRightToLeft();
				}
			}
		}
		
		public function showTextShopInformationMoveRightToLeft():void
		{
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 30;
			var title:TextField = new TextField();
			title.defaultTextFormat = myFormat;
			title.text = showShopIndex.shopDetailInfo;
			title.width = BOX_INFORMATION_WIDTH ;
			title.x= BIG_SHOP_IMAGE_PADDING + 216;
			title.y = 100 + BOX_LOGO_HEIGHT + BIG_SHOP_IMAGE_PADDING + BIG_SHOP_IMAGE_HEIGHT + BIG_SHOP_IMAGE_PADDING+BIG_SHOP_IMAGE_MOVE_UP_DISTANCE+TITLE_BOX_BG_HEIGHT;
			title.alpha = 0;
			boxInformationMoveFromRightToLeft.addChild(title);
			GTweener.to(title, 1, {x:TITLE_BOX_BG_MOVE_LEFT + 50, alpha:1},{reflect:false});
			//GTweener.to(title, 2, {x:50, alpha:1},{reflect:false});
			showTextShopInformationMoveRightToLeftTimer.stop();
			//showTextShopInformationMoveRightToLeftTimer = null;
		}
		
		public function showTextShopInformationMoveRightToLeftWithNoTitle():void
		{
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 30;
			var title:TextField = new TextField();
			title.defaultTextFormat = myFormat;
			title.text = showShopIndex.shopDetailInfo;
			title.width = BOX_INFORMATION_WIDTH ;
			title.x= BIG_SHOP_IMAGE_PADDING + 216;
			//title.y = 100 + BOX_LOGO_HEIGHT + BIG_SHOP_IMAGE_PADDING + BIG_SHOP_IMAGE_HEIGHT + BIG_SHOP_IMAGE_PADDING+BIG_SHOP_IMAGE_MOVE_UP_DISTANCE+TITLE_BOX_BG_HEIGHT;
			title.y = 37 + BOX_LOGO_HEIGHT + BIG_SHOP_IMAGE_PADDING + BIG_SHOP_IMAGE_HEIGHT + BIG_SHOP_IMAGE_PADDING+BIG_SHOP_IMAGE_MOVE_UP_DISTANCE+TITLE_BOX_BG_HEIGHT;
			title.alpha = 0;
			boxInformationMoveFromRightToLeft.addChild(title);
			GTweener.to(title, 1, {x:TITLE_BOX_BG_MOVE_LEFT + 50, alpha:1},{reflect:false});
			//GTweener.to(title, 2, {x:50, alpha:1},{reflect:false});
			showTextShopInformationMoveRightToLeftTimer.stop();
			//showTextShopInformationMoveRightToLeftTimer = null;
		}
		
		
		public function showTextShopNameMoveRightToLeft():void
		{
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 38;
			var title:TextField = new TextField();
			title.defaultTextFormat = myFormat;
			title.text = showShopIndex.title;
			title.width = BOX_INFORMATION_WIDTH ;
			title.x= BIG_SHOP_IMAGE_PADDING + 216;
			title.y = 37 + BOX_LOGO_HEIGHT + BIG_SHOP_IMAGE_PADDING + BIG_SHOP_IMAGE_HEIGHT + BIG_SHOP_IMAGE_PADDING+BIG_SHOP_IMAGE_MOVE_UP_DISTANCE+TITLE_BOX_BG_HEIGHT;
			//title.textColor = 0xffffff;
			boxInformationMoveFromRightToLeft.addChild(title);
			GTweener.to(title, 1, {x:TITLE_BOX_BG_MOVE_LEFT + 50, alpha:1},{reflect:false});
			//GTweener.to(title, 2, {x:50, alpha:1},{reflect:false});
			showTextShopNameMoveRightToLeftTimer.stop();
		
			// run text shop information move from left to right 
			var showTextShopInformationMoveRightToLeftTimer:Timer = new Timer(1000,1); // 1 second
			showTextShopInformationMoveRightToLeftTimer.addEventListener(TimerEvent.TIMER, runTextShopInformation);
			showTextShopInformationMoveRightToLeftTimer.start();
			function runTextShopInformation(event:TimerEvent):void {
				showTextShopInformationMoveRightToLeft();
			}
		}
	
		public function showBoxInformationMoveFromRightToLeft():void
		{
			boxInformationMoveFromRightToLeft = new Sprite(); 
			boxInformationMoveFromRightToLeft.alpha = 0;
			boxInformationMoveFromRightToLeft.graphics.lineStyle(1); 
			boxInformationMoveFromRightToLeft.graphics.beginFill(0xFFFFFF); 
			boxInformationMoveFromRightToLeft.graphics.lineStyle(1,0xdfdfdf);
			var y:Number = BOX_LOGO_HEIGHT + BIG_SHOP_IMAGE_PADDING + BIG_SHOP_IMAGE_HEIGHT + BIG_SHOP_IMAGE_PADDING+BIG_SHOP_IMAGE_MOVE_UP_DISTANCE+TITLE_BOX_BG_HEIGHT;
			// 66 is the padding top from box infor to text, and left, right padding 
			boxInformationMoveFromRightToLeft.graphics.drawRect(100, y - TITLE_BOX_BG_HEIGHT/2, BOX_INFORMATION_WIDTH, BOX_INFORMATION_HEIGHT); 
			boxInformationMoveFromRightToLeft.graphics.endFill(); 
			
			this.addChildAt(boxInformationMoveFromRightToLeft, 1); 
			
			var shadow:DropShadowFilter = new DropShadowFilter(); 
			shadow.distance = 0.5; 
			shadow.angle = 25; 
			shadow.color = 0x303030;
			boxInformationMoveFromRightToLeft.filters = [shadow];
			
			GTweener.to(boxInformationMoveFromRightToLeft, 1.5, {x:-50, alpha:1},{reflect:false});
			//showShopIndex.title = "";// for testing 
			showBoxInformationMoveFromRightToLeftTimer.stop();
			if(showShopIndex.title.length >0)
			{
				// run text shop name move from left to right 
				showTextShopNameMoveRightToLeftTimer = new Timer(2000,1); // 1 second
				showTextShopNameMoveRightToLeftTimer.addEventListener(TimerEvent.TIMER, runTextShopName);
				showTextShopNameMoveRightToLeftTimer.start();
				function runTextShopName(event:TimerEvent):void {
					showTextShopNameMoveRightToLeft();
				}
			}else{
				// run text shop information move from left to right 
				var showTextShopInformationMoveRightToLeftTimer:Timer = new Timer(1000,1); // 1 second
				showTextShopInformationMoveRightToLeftTimer.addEventListener(TimerEvent.TIMER, runTextShopInformation);
				showTextShopInformationMoveRightToLeftTimer.start();
				function runTextShopInformation(event:TimerEvent):void {
					showTextShopInformationMoveRightToLeftWithNoTitle();
				}
			}
		}
		
		public function showTextInBoxBackgroundMoveLeft():void
		{
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 36;
			var title:TextField = new TextField();
			title.defaultTextFormat = myFormat;
			title.text = showShopIndex.shopName;
			title.width = TITLE_BOX_BG_WIDTH ;
			title.x= BIG_SHOP_IMAGE_PADDING-400;
			title.y = BOX_LOGO_HEIGHT + BIG_SHOP_IMAGE_PADDING + BIG_SHOP_IMAGE_HEIGHT + BIG_SHOP_IMAGE_PADDING+BIG_SHOP_IMAGE_MOVE_UP_DISTANCE+20;
			title.textColor = 0xffffff;
			title.alpha = 0;
			titleBoxBackgroundSprite.addChild(title);
			GTweener.to(title, 2, {x:-90, alpha:1},{reflect:false});
			
			showTextInBoxBackgroundMoveLeftTimer.stop();

			// run box shop information move from left to right 
		    showBoxInformationMoveFromRightToLeftTimer = new Timer(2500,1); // 1 second
			showBoxInformationMoveFromRightToLeftTimer.addEventListener(TimerEvent.TIMER, runBoxShopInformation);
			showBoxInformationMoveFromRightToLeftTimer.start();
			function runBoxShopInformation(event:TimerEvent):void {
				showBoxInformationMoveFromRightToLeft();
			}
		}

		public function showBoxBackgroundMoveLeft():void
		{
			trace("loadTitleShopBackgroundBlackComplete");
			titleBoxBackgroundSprite = new Sprite(); 
			titleBoxBackgroundSprite.graphics.lineStyle(1); 
			titleBoxBackgroundSprite.graphics.beginFill(0x000000); 
			titleBoxBackgroundSprite.graphics.lineStyle(1,0xdfdfdf);
			titleBoxBackgroundSprite.graphics.drawRect(-160, BOX_LOGO_HEIGHT + BIG_SHOP_IMAGE_PADDING + BIG_SHOP_IMAGE_HEIGHT + BIG_SHOP_IMAGE_PADDING+BIG_SHOP_IMAGE_MOVE_UP_DISTANCE, TITLE_BOX_BG_WIDTH, TITLE_BOX_BG_HEIGHT); 
			titleBoxBackgroundSprite.graphics.endFill(); 
			titleBoxBackgroundSprite.alpha = 0;
			addChild(titleBoxBackgroundSprite);
			//GTweener.from(titleBoxBackgroundSprite, 0.5, {x:-TITLE_BOX_BG_MOVE_LEFT, alpha:1},{reflect:false});
			GTweener.to(titleBoxBackgroundSprite, 2, {x:140, alpha:1},{reflect:false});
			
			runBlackBackgroundBoxTimer.stop();
			
			// run text in black bg box from right to left 
			showTextInBoxBackgroundMoveLeftTimer = new Timer(1500,1); // 1 second
			showTextInBoxBackgroundMoveLeftTimer.addEventListener(TimerEvent.TIMER, runTextInBlackBackgroundBox);
			showTextInBoxBackgroundMoveLeftTimer.start();
			function runTextInBlackBackgroundBox(event:TimerEvent):void {
				showTextInBoxBackgroundMoveLeft();
			}
			//showTextInBoxBackgroundMoveLeft();
			//runBlackBackgroundBoxTimer = null;
		}

		function loadBigShopImageComplete(event:Event):void
		{
   			trace("Complete");
		    bigShopImageLoader.y = BOX_LOGO_HEIGHT + BIG_SHOP_IMAGE_PADDING + 10 + BIG_SHOP_IMAGE_MOVE_UP_DISTANCE;
			bigShopImageLoader.x = BIG_SHOP_IMAGE_PADDING + 10;
		    bigShopImageLoader.width = BIG_SHOP_IMAGE_WIDTH;
			bigShopImageLoader.height = BIG_SHOP_IMAGE_HEIGHT;
			var boxShadow:Sprite = new Sprite(); 
			boxShadow.graphics.lineStyle(1); 
			boxShadow.graphics.beginFill(0xFFFFFF); 
			boxShadow.graphics.lineStyle(1,0xdfdfdf);
			boxShadow.graphics.drawRect(BIG_SHOP_IMAGE_PADDING, BOX_LOGO_HEIGHT + BIG_SHOP_IMAGE_PADDING+BIG_SHOP_IMAGE_MOVE_UP_DISTANCE, BIG_SHOP_IMAGE_HEIGHT+20, BIG_SHOP_IMAGE_HEIGHT+20); 
			boxShadow.graphics.endFill(); 
			boxShadow.alpha = 0;
			boxShadow.addChild(bigShopImageLoader); 
			
			var shadow:DropShadowFilter = new DropShadowFilter(); 
			shadow.color = 0x303030;
			shadow.distance = 0.5; 
			shadow.angle = 25; 
			boxShadow.filters = [shadow];
			
			addChild(boxShadow);
			GTweener.to(boxShadow, 2, {y:-BIG_SHOP_IMAGE_MOVE_UP_DISTANCE, alpha:1},{reflect:true});
					
			scheduleShowContent();	
			
		}
		
		function loadLogoComplete(event:Event):void
		{
   			trace("loadLogoComplete");
			logoLoader.x = (Capabilities.screenResolutionX - logoLoader.contentLoaderInfo.width)/2; 
			logoLoader.y = BOX_LOGO_HEIGHT/2 - logoLoader.contentLoaderInfo.height/2  + DefineCommonValue.SPRITE_Y;
			var boxShadow:Sprite = new Sprite(); 
			boxShadow.graphics.lineStyle(1); 
			boxShadow.graphics.beginFill(0xFFFFFF); 
			boxShadow.graphics.lineStyle(1,0xdfdfdf);
			boxShadow.graphics.drawRect(0, 0, DefineCommonValue.SPRITE_WIDTH, BOX_LOGO_HEIGHT); 
			boxShadow.graphics.endFill(); 
			
			var shadow:DropShadowFilter = new DropShadowFilter(); 
			shadow.distance = 0.5; 
			shadow.angle = 25; 
			shadow.color = 0x303030;
			boxShadow.filters = [shadow];
			
			boxShadow.addChild(logoLoader); 
			addChild(boxShadow); 
			
			// add box bottom 
			var boxBottom:Sprite = new Sprite(); 
			boxBottom.graphics.lineStyle(1); 
			boxBottom.graphics.beginFill(0xFFFFFF); 
			boxBottom.graphics.lineStyle(1,0xdfdfdf);
			boxBottom.graphics.drawRect(0, DefineCommonValue.SPRITE_HEIGHT - BOX_BOTTOM_HEIGHT, DefineCommonValue.SPRITE_WIDTH, BOX_BOTTOM_HEIGHT); 
			boxBottom.graphics.endFill(); 
			boxBottom.filters = [shadow];	
			addChild(boxBottom);
		
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 36;
			var title:TextField = new TextField();
			title.defaultTextFormat = myFormat;
			title.text = CommonFunction.getCurrentTimeNumber();
			title.width = 200 ;
			title.x= DefineCommonValue.SPRITE_WIDTH - 120;
			title.y = DefineCommonValue.SPRITE_HEIGHT - BOX_BOTTOM_HEIGHT/2 - 25;
			
			boxBottom.addChild(title);

			// load logo ESTA
			estaLogoLoader = new Loader();
			var url2:URLRequest = new URLRequest("SystemImg/estaIcon.png");
			estaLogoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadEstaLogoImageComplete);
			estaLogoLoader.load(url2);
			
		}
		
		function loadEstaLogoImageComplete(event:Event):void
		{
   			trace("Complete");
		    estaLogoLoader.y =  DefineCommonValue.SPRITE_HEIGHT - BOX_BOTTOM_HEIGHT +5;
			estaLogoLoader.x = 30;
		    estaLogoLoader.width = 132;
			estaLogoLoader.height = 80;
			addChild(estaLogoLoader);
		
			
		}

	}
}