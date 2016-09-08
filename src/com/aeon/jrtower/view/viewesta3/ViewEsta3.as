package com.aeon.jrtower.view.viewesta3 {
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
	//import flash.text.TextFormat.align;
	import com.aeon.jrtower.common.DefineCommonValue;
	/**
	 * @author md760
	 */
	public class ViewEsta3 extends Sprite{
		
		private const PADDING_ALIGNMENT:Number = 50;
		private const TOP_BOX_HEIGHT:Number = 380;
		private const BOTTTOM_BOX_HEIGHT:Number = 93;
		private const BACKGROUND_TOP_PADDING:Number = 545;
		private const SHOP_LOGO_TOP_PADDING:Number = 402;
		
		private const BOX_LARGE_IMG_PADDING_TOP:Number = 586;
		private const BOX_LARGE_IMG_WIDTH:Number = 980;
		private const BOX_LARGE_IMG_HEIGHT:Number = 812;
		
		private const CELL_HEIGHT:Number = 115;
		private var showShopIndex:ShopObject;
		private var boxCenterImg:Sprite;
				
		var backgroundImgLoader:Loader;
		var imgTitleImgLoader:Loader;
		var estaLogoLoader:Loader;
		var imgBigImgCenterLoader = new Loader();
		var shopLogoJsonLoader:Loader;
		//var row1BoxAnimate:Sprite;
		var row2BoxAnimate:Sprite;
		var row3BoxAnimate:Sprite;
		var row4BoxAnimate:Sprite;
		
		var row1SteakLoader:Loader;
		var row2SteakLoader:Loader;
		var row3SteakLoader:Loader;
		var row4SteakLoader:Loader;
		
		var priceIcon1:Loader;
		var priceIcon2:Loader;
		var priceIcon3:Loader;
		var priceIcon4:Loader;

		
		var loadRow1Timer:Timer;
		var loadRow2Timer:Timer;
		var loadRow3Timer:Timer;
		var loadRow4Timer:Timer;
		var drawElasticCircleSaleDay:Timer;
		var boxShadow:Sprite;
		var ballSaleDayHeight:Number;
		var countAnimate:Number;
		
		public function ViewEsta3(showObj:ShopObject) {
			showShopIndex = showObj;
			
			// load bg image
			backgroundImgLoader = new Loader();
			var url:URLRequest = new URLRequest("SystemImg/bg_shop.jpg");
			backgroundImgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBackgroundImgLoaderComplete);
			backgroundImgLoader.load(url);
			
			trace("broadcast day: "+ CommonFunction.getCurrentDayForBroastCast());

		}

		function drawElasticBallSaleDay()
		{
		
			//boxShadow.graphics.lineStyle(1); 
			boxShadow.graphics.beginFill(0x02b704); 
			//boxShadow.graphics.lineStyle(1,0x02b704);		
			boxShadow.graphics.drawEllipse(30, 480, 100, ballSaleDayHeight);
			boxShadow.graphics.endFill(); 
			trace("===cicle:"+ballSaleDayHeight);
				
			countAnimate = countAnimate + 1;
			if(countAnimate<=10)
				ballSaleDayHeight = ballSaleDayHeight - 5;
			else
			   ballSaleDayHeight = ballSaleDayHeight + 5; 	
					
			if(ballSaleDayHeight >= 100)
				drawElasticCircleSaleDay.stop();
			boxShadow.graphics.clear();	
			this.addChild(boxShadow);
		}
		
		private function getSaleDay():String
		{
			var saleDay = showShopIndex.saleDay;
			saleDay = saleDay.substring(4,6) + "/" + saleDay.substring(6,8);
			return saleDay
		}
		
		function loadBackgroundImgLoaderComplete(event:Event):void
		{
			backgroundImgLoader.y =  BACKGROUND_TOP_PADDING;
			backgroundImgLoader.x = 0;
		    backgroundImgLoader.width = DefineCommonValue.SPRITE_WIDTH ;
			backgroundImgLoader.height = DefineCommonValue.SPRITE_HEIGHT;
			addChild(backgroundImgLoader);

			// load img title img on top 
			imgTitleImgLoader = new Loader();
			var url1:URLRequest = new URLRequest(DefineCommonValue.JSON_IMG + showShopIndex.IMGTitleImage);
			imgTitleImgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadImgTitleImgLoaderComplete);
			imgTitleImgLoader.load(url1);
			
			// load logo ESTA
			estaLogoLoader = new Loader();
			var url2:URLRequest = new URLRequest("SystemImg/estaIconTemplate3.png");
			estaLogoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadEstaLogoImageComplete);
			estaLogoLoader.load(url2);
			
			// load shop logo from json
			shopLogoJsonLoader = new Loader();
			var url3:URLRequest = new URLRequest(DefineCommonValue.JSON_IMG + showShopIndex.IMGShopLogo.ImgURL);
			shopLogoJsonLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadShopLogoJsonImageComplete);
			shopLogoJsonLoader.load(url3);
			
			// create box big image center
			CommonFunction.createBox(PADDING_ALIGNMENT, BOX_LARGE_IMG_PADDING_TOP, BOX_LARGE_IMG_WIDTH,BOX_LARGE_IMG_HEIGHT,0xFFFFFF, 0xdfdfdf, this);
			
			// create 3 others cell box
			var y = BOX_LARGE_IMG_HEIGHT + BOX_LARGE_IMG_PADDING_TOP + 13;
			for(var i:Number=0; i<3;i++)
			{
				CommonFunction.createBox(PADDING_ALIGNMENT, y, BOX_LARGE_IMG_WIDTH,CELL_HEIGHT, 0xFFFFFF, 0xdfdfdf, this);
			 	y = y + CELL_HEIGHT + 13;
			}
			
			// load big img center  
			imgBigImgCenterLoader = new Loader();
			var url:URLRequest = new URLRequest(DefineCommonValue.JSON_IMG + showShopIndex.IMGFile.ImgURL);
			imgBigImgCenterLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBigImgCenterLoaderComplete);
			imgBigImgCenterLoader.load(url);
			
			// create elastic ball
			boxShadow = new Sprite();
			var fillColor:uint = 0x02b7d4
			if(showShopIndex.bigFoodTenant == "2")
			{
				fillColor = 0x70bc04;
			}else if(showShopIndex.bigFoodTenant == "3")
			{
				fillColor = 0xe64c66;
			}
			boxShadow.graphics.beginFill(fillColor); 
			boxShadow.graphics.drawEllipse(30, 535, 100, 100);
			boxShadow.graphics.endFill(); 
			this.addChild(boxShadow);
			CommonFunction.addTitleToPanel(42, 573, 70, 50, boxShadow, 26, getSaleDay(), "right",0xFFFFFF);
			this.setChildIndex(boxShadow, 4);
		}
		
		function loadBigImgCenterLoaderComplete(event:Event):void
		{
		
			boxCenterImg = CommonFunction.createBox(PADDING_ALIGNMENT+5, BOX_LARGE_IMG_PADDING_TOP+50, BOX_LARGE_IMG_WIDTH-10, BOX_LARGE_IMG_HEIGHT-50, 0xFFFFFF, 0xFFFFFF, this);
			
			// add big img
			imgBigImgCenterLoader.y = BOX_LARGE_IMG_PADDING_TOP+45;
			imgBigImgCenterLoader.x = PADDING_ALIGNMENT + 26;
		    imgBigImgCenterLoader.width = BOX_LARGE_IMG_WIDTH - 52 ;
			imgBigImgCenterLoader.height = BOX_LARGE_IMG_HEIGHT - 52 - 115;
		    boxCenterImg.addChild(imgBigImgCenterLoader);
			// add title price bellow big image
			//this.setChildIndex(imgBigImgCenterLoader, 1);
			this.setChildIndex(boxCenterImg, 2);
			// animation move up 
			GTweener.to(boxCenterImg, 2, {y:-20, alpha:1},{reflect:true});
			
			//loadRowSteakTop();
			scheduleShowContent();
		}
		
		private function scheduleShowContent()
		{
			// load first row
			loadRow1Timer = new Timer(1000,1); // 1 second
			loadRow1Timer.addEventListener(TimerEvent.TIMER, runFirstRow);
			loadRow1Timer.start();
			function runFirstRow(event:TimerEvent):void {
				loadRow1Steak();
			}
		}
		
		function loadRow1Steak()
		{
			row1SteakLoader = new Loader();
			var url:URLRequest = new URLRequest("SystemImg/steak.png");
			row1SteakLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadIconSteakLoaderComplete);
			row1SteakLoader.load(url);
		}
		
		function loadIconSteakLoaderComplete(event:Event):void
		{
			var y = BOX_LARGE_IMG_HEIGHT + BOX_LARGE_IMG_PADDING_TOP  - 65;
			var yPrice = y - 10 ;
			
			row1SteakLoader.y = y+10;
			row1SteakLoader.x = PADDING_ALIGNMENT + 30;
		    row1SteakLoader.width = 40 ;
			row1SteakLoader.height = 34;
			boxCenterImg.addChild(row1SteakLoader);
			// add product 1 text for big img 
			CommonFunction.addTitleToPanel(PADDING_ALIGNMENT + 85, y+10, 400, 65, boxCenterImg, 36, showShopIndex.product1, "left",0x000000);
			// add product 1 price for big img 
			if(showShopIndex.productText1.length>0)
			{
				yPrice = yPrice  ; // leave space to add productText2 
				CommonFunction.addTitleToPanel(PADDING_ALIGNMENT + 85 + 600,  yPrice+65, 215, 75, boxCenterImg, 14, showShopIndex.productText1,"right",0xd10000);
			}else{
				yPrice = yPrice +10 ; // vertical alignment middle
			}
			CommonFunction.addTitleToPanel(PADDING_ALIGNMENT + 85 + 600, yPrice, 215, 75, boxCenterImg, 80, showShopIndex.price1,"right", 0xd10000);
			
			var iconImage:String = "SystemImg/type_1.png";
			if(showShopIndex.priceDivision1 == "2")
			{
				iconImage = "SystemImg/type_2.png";
			}
			priceIcon1 = new Loader();
			var url:URLRequest = new URLRequest(iconImage);
			priceIcon1.contentLoaderInfo.addEventListener(Event.COMPLETE, loadPriceIcon1Complete);
			priceIcon1.load(url);
			
			
			
			//loadRow2Steak();
		}
		
		private function loadPriceIcon1Complete(event:Event):void
		{
			var y = BOX_LARGE_IMG_HEIGHT + BOX_LARGE_IMG_PADDING_TOP  - 70;
			if(showShopIndex.productText1.length>0)
			{
				y = y  ; // leave space to add productText2 
			}else{
				y = y +10 ; // vertical alignment middle
			}
		
			priceIcon1.y = y;
			priceIcon1.x = PADDING_ALIGNMENT + 85 + 600 + 225;
		    priceIcon1.width = 45 ;
			priceIcon1.height = 58;
			boxCenterImg.addChild(priceIcon1);
			
			// load second row
			loadRow2Timer = new Timer(1500,1); // 1 second
			loadRow2Timer.addEventListener(TimerEvent.TIMER, runSecondRow);
			loadRow2Timer.start();
			function runSecondRow(event:TimerEvent):void {
				loadRow2Steak();
			}
			
			loadRow1Timer.stop();
		}
		
		function loadRow2Steak()
		{
			row2SteakLoader = new Loader();
			var url:URLRequest = new URLRequest("SystemImg/steak.png");
			row2SteakLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadRow2SteakLoaderComplete);
			row2SteakLoader.load(url);			
		}
		
		function loadRow2SteakLoaderComplete(event:Event):void
		{
			var y = BOX_LARGE_IMG_HEIGHT + BOX_LARGE_IMG_PADDING_TOP + 65;
			var yPrice = BOX_LARGE_IMG_HEIGHT + BOX_LARGE_IMG_PADDING_TOP;

			row2BoxAnimate = CommonFunction.createBox(PADDING_ALIGNMENT+5, y, BOX_LARGE_IMG_WIDTH-10, CELL_HEIGHT/2, 0xFFFFFF, 0xFFFFFF, this);
			row2BoxAnimate.alpha = 0;
			row2SteakLoader.y = y;
			row2SteakLoader.x = PADDING_ALIGNMENT + 30;
		    row2SteakLoader.width = 40 ;
			row2SteakLoader.height = 34;
			row2BoxAnimate.addChild(row2SteakLoader);
			// add product 1 text for big img 
			CommonFunction.addTitleToPanel(PADDING_ALIGNMENT + 85 ,y, 400, 75, row2BoxAnimate, 36, showShopIndex.product2, "left", 0x000000);
			// add product 1 price for big img 
			
			if(showShopIndex.productText2.length>0)
			{
				yPrice = yPrice + 40; // leave space to add productText2 
				CommonFunction.addTitleToPanel(PADDING_ALIGNMENT + 85 + 600,  yPrice+65, 215, 65, row2BoxAnimate, 14, showShopIndex.productText2,"right", 0xd10000);
			}else{
				yPrice = yPrice + 45; // vertical alignment middle
			}
			CommonFunction.addTitleToPanel(PADDING_ALIGNMENT + 85 + 600,  yPrice, 215, 68, row2BoxAnimate, 80, showShopIndex.price2,"right",0xd10000);			
			var iconImage:String = "SystemImg/type_1.png";
			if(showShopIndex.priceDivision2 == "2")
			{
				iconImage = "SystemImg/type_2.png";
			}
			priceIcon2 = new Loader();
			var url:URLRequest = new URLRequest(iconImage);
			priceIcon2.contentLoaderInfo.addEventListener(Event.COMPLETE, loadPriceIcon2Complete);
			priceIcon2.load(url);
			GTweener.to(row2BoxAnimate, 2, {y:-10, alpha:1},{reflect:true});
		}
		
		private function loadPriceIcon2Complete(event:Event):void
		{
			var y = BOX_LARGE_IMG_HEIGHT + BOX_LARGE_IMG_PADDING_TOP  + 40 ;
			if(showShopIndex.productText1.length>0)
			{
				y = y +5 ; // leave space to add productText2 
			}else{
				y = y +10 ; // vertical alignment middle
			}
		
			priceIcon2.y = y;
			priceIcon2.x = PADDING_ALIGNMENT + 85 + 600 + 225;
		    priceIcon2.width = 45 ;
			priceIcon2.height = 58;
			row2BoxAnimate.addChild(priceIcon2);
			
			loadRow2Timer.stop();
			
			// load third row
			loadRow3Timer = new Timer(1500,1); // 1 second
			loadRow3Timer.addEventListener(TimerEvent.TIMER, runThirdRow);
			loadRow3Timer.start();
			function runThirdRow(event:TimerEvent):void {
				loadRow3Steak();
			}
		}
		
		function loadRow3Steak()
		{
			row3SteakLoader = new Loader();
			var url:URLRequest = new URLRequest("SystemImg/steak.png");
			row3SteakLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadRow3SteakLoaderComplete);
			row3SteakLoader.load(url);			
		}
		
		function loadRow3SteakLoaderComplete(event:Event):void
		{
			var y = BOX_LARGE_IMG_HEIGHT + BOX_LARGE_IMG_PADDING_TOP + CELL_HEIGHT + 75;
			var yPrice = BOX_LARGE_IMG_HEIGHT + BOX_LARGE_IMG_PADDING_TOP + CELL_HEIGHT+15;

			row3BoxAnimate = CommonFunction.createBox(PADDING_ALIGNMENT+5, y, BOX_LARGE_IMG_WIDTH-10, CELL_HEIGHT/2, 0xFFFFFF, 0xFFFFFF, this);
			row3BoxAnimate.alpha = 0;
			row3SteakLoader.y = y;
			row3SteakLoader.x = PADDING_ALIGNMENT + 30;
		    row3SteakLoader.width = 40 ;
			row3SteakLoader.height = 34;
			row3BoxAnimate.addChild(row3SteakLoader);
			// add product 1 text for big img 
			CommonFunction.addTitleToPanel(PADDING_ALIGNMENT + 85 ,y, 400, 75, row3BoxAnimate, 36, showShopIndex.product3, "left", 0x000000);
			// add product 1 price for big img 
			
			if(showShopIndex.productText3.length>0)
			{
				yPrice = yPrice + 40; // leave space to add productText2 
				CommonFunction.addTitleToPanel(PADDING_ALIGNMENT + 85 + 600,  yPrice+65, 215, 65, row3BoxAnimate, 14, showShopIndex.productText3,"right", 0xd10000);
			}else{
				yPrice = yPrice + 45; // vertical alignment middle
			}
			CommonFunction.addTitleToPanel(PADDING_ALIGNMENT + 85 + 600,  yPrice, 215, 68, row3BoxAnimate, 80, showShopIndex.price3,"right",0xd10000);			
			var iconImage:String = "SystemImg/type_1.png";
			if(showShopIndex.priceDivision3 == "2")
			{
				iconImage = "SystemImg/type_2.png";
			}
			priceIcon3 = new Loader();
			var url:URLRequest = new URLRequest(iconImage);
			priceIcon3.contentLoaderInfo.addEventListener(Event.COMPLETE, loadPriceIcon3Complete);
			priceIcon3.load(url);
			GTweener.to(row3BoxAnimate, 2, {y:-10, alpha:1},{reflect:true});
		}
		
		private function loadPriceIcon3Complete(event:Event):void
		{
			var y = BOX_LARGE_IMG_HEIGHT + BOX_LARGE_IMG_PADDING_TOP + CELL_HEIGHT + 50 ;
			if(showShopIndex.productText3.length>0)
			{
				y = y + 10 ; // leave space to add productText2 
			}else{
				y = y + 15 ; // vertical alignment middle
			}
		
			priceIcon3.y = y;
			priceIcon3.x = PADDING_ALIGNMENT + 85 + 600 + 225;
		    priceIcon3.width = 45 ;
			priceIcon3.height = 58;
			row3BoxAnimate.addChild(priceIcon3);
			
			loadRow3Timer.stop();
			
			// load fourth row
			loadRow4Timer = new Timer(1500,1); // 1 second
			loadRow4Timer.addEventListener(TimerEvent.TIMER, runFourRow);
			loadRow4Timer.start();
			function runFourRow(event:TimerEvent):void {
				loadRow4Steak();
			}
			
		}
		
		function loadRow4Steak()
		{
			row4SteakLoader = new Loader();
			var url:URLRequest = new URLRequest("SystemImg/steak.png");
			row4SteakLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadRow4SteakLoaderComplete);
			row4SteakLoader.load(url);			
		}
		
		function loadRow4SteakLoaderComplete(event:Event):void
		{
			var y = BOX_LARGE_IMG_HEIGHT + BOX_LARGE_IMG_PADDING_TOP + CELL_HEIGHT*2 + 88;
			var yPrice = BOX_LARGE_IMG_HEIGHT + BOX_LARGE_IMG_PADDING_TOP + CELL_HEIGHT*2 + 28;

			row4BoxAnimate = CommonFunction.createBox(PADDING_ALIGNMENT+5, y, BOX_LARGE_IMG_WIDTH-10, CELL_HEIGHT/2, 0xFFFFFF, 0xFFFFFF, this);
			row4BoxAnimate.alpha = 0;
			row4SteakLoader.y = y;
			row4SteakLoader.x = PADDING_ALIGNMENT + 30;
		    row4SteakLoader.width = 40 ;
			row4SteakLoader.height = 34;
			row4BoxAnimate.addChild(row4SteakLoader);
			// add product 1 text for big img 
			CommonFunction.addTitleToPanel(PADDING_ALIGNMENT + 85 ,y, 400, 75, row4BoxAnimate, 36, showShopIndex.product4, "left", 0x000000);
			// add product 1 price for big img 
			
			if(showShopIndex.productText4.length>0)
			{
				yPrice = yPrice + 40; // leave space to add productText2 
				CommonFunction.addTitleToPanel(PADDING_ALIGNMENT + 85 + 600,  yPrice+65, 215, 65, row4BoxAnimate, 14, showShopIndex.productText4,"right", 0xd10000);
			}else{
				yPrice = yPrice + 45; // vertical alignment middle
			}
			CommonFunction.addTitleToPanel(PADDING_ALIGNMENT + 85 + 600,  yPrice, 215, 68, row4BoxAnimate, 80, showShopIndex.price4,"right",0xd10000);			
			
			var iconImage:String = "SystemImg/type_1.png";
			if(showShopIndex.priceDivision4 == "2")
			{
				iconImage = "SystemImg/type_2.png";
			}
			priceIcon4 = new Loader();
			var url:URLRequest = new URLRequest(iconImage);
			priceIcon4.contentLoaderInfo.addEventListener(Event.COMPLETE, loadPriceIcon4Complete);
			priceIcon4.load(url);
			 
			
			 
			GTweener.to(row4BoxAnimate, 2, {y:-10, alpha:1},{reflect:true});
			 
			 
		}
		
		private function loadPriceIcon4Complete(event:Event):void
		{
			var y = BOX_LARGE_IMG_HEIGHT + BOX_LARGE_IMG_PADDING_TOP + CELL_HEIGHT*2 + 63 ;
			if(showShopIndex.productText4.length>0)
			{
				y = y + 10 ; // leave space to add productText2 
			}else{
				y = y + 15 ; // vertical alignment middle
			}
		
			priceIcon4.y = y;
			priceIcon4.x = PADDING_ALIGNMENT + 85 + 600 + 225;
		    priceIcon4.width = 45 ;
			priceIcon4.height = 58;
			row4BoxAnimate.addChild(priceIcon4);
			
			loadRow4Timer.stop();
			
		}
		
				
		function loadShopLogoJsonImageComplete(event:Event):void
		{
			shopLogoJsonLoader.y =  SHOP_LOGO_TOP_PADDING+30;
			shopLogoJsonLoader.x = DefineCommonValue.SPRITE_WIDTH/2 - shopLogoJsonLoader.contentLoaderInfo.width/2;
			addChild(shopLogoJsonLoader);
			/*
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 36;
			var title:TextField = new TextField();
			title.defaultTextFormat = myFormat;
			title.text = showShopIndex.shopName;
			title.width = 500 ;
			title.x= 350;
			title.y =  SHOP_LOGO_TOP_PADDING+20 ;
			
			addChild(title);
			*/
		}
		
		function loadImgTitleImgLoaderComplete(event:Event):void
		{
			imgTitleImgLoader.y =  0;
			imgTitleImgLoader.x = 0;
		    imgTitleImgLoader.width = DefineCommonValue.SPRITE_WIDTH ;
			imgTitleImgLoader.height = TOP_BOX_HEIGHT;
			addChild(imgTitleImgLoader);
		}
				
		function loadEstaLogoImageComplete(event:Event):void
		{
			var boxBottom: Sprite = CommonFunction.createBox(0, DefineCommonValue.SPRITE_HEIGHT - BOTTTOM_BOX_HEIGHT, DefineCommonValue.SPRITE_WIDTH, BOTTTOM_BOX_HEIGHT, 0x000000, 0xdfdfdf, this);

			estaLogoLoader.y =  DefineCommonValue.SPRITE_HEIGHT - 109;
			estaLogoLoader.x = 30;
		    estaLogoLoader.width = 172;
			estaLogoLoader.height = 109;
			addChild(estaLogoLoader);
			
		
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 36;
			var title:TextField = new TextField();
			title.defaultTextFormat = myFormat;
			title.text = CommonFunction.getCurrentTimeNumber();
			title.width = 200 ;
			title.x= DefineCommonValue.SPRITE_WIDTH/2 - title.width/2;
			title.y = DefineCommonValue.SPRITE_HEIGHT - BOTTTOM_BOX_HEIGHT/2 ;
			
			addChild(title);
		}
		

	}
}