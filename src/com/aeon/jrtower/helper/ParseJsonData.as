package com.aeon.jrtower.helper {
	import com.aeon.jrtower.common.DefineCommonValue;

	/*
	 * @author md760
	 */
	 import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.events.TextEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.net.URLLoader;
	import com.aeon.jrtower.model.ImageObject;
	import com.aeon.jrtower.model.ShopObject;
	
	public class ParseJsonData extends URLLoader {
	
	public var listShopParse:Array;
	/*
	 *  frameDivisionTemplate=Template1-2 using frame_division: 7 or 8
	 *  frameDivisionTemplate=Template3 using frame_division: 9 
	 *  frameDivisionTemplate=Template4 using frame_division: 10
	 */
	public var frameDivisionTemplate:String;	
	public var numShopAdded:int;
	
	public function ParseJsonData() {
		//loadConfigFromUrl();
		numShopAdded = 0;
		listShopParse = new Array();
	}
		
	public function loadConfigFromUrl(template:String):Array
	{
		this.frameDivisionTemplate = template;
    	//var urlRequest:URLRequest  = new URLRequest(DefineCommonValue.JSON_URL);
		var urlRequest:URLRequest  = new URLRequest("esta_vision.json");
		
		//cms_preview_mode_esta_vision.json
    	//var urlLoader:URLLoader = new URLLoader();
    	this.addEventListener(Event.COMPLETE, completeHandler);

    	try{
        	this.load(urlRequest);
    	} catch (error:Error) {
        	trace("Cannot load : " + error.message);
    	}
		//trace("======="+ listShopParse );
		return listShopParse;
	}

	private function completeHandler(event:Event):void {
    	var loader:URLLoader = URLLoader(event.target);
    	var data:Object = JSON.parse(loader.data);
    	var numRow:int = data[0].count;
		
		for(var i:int; i<numRow;i++)
		{
			if(this.frameDivisionTemplate == "Template1-2" && (data[1][i].frame_division == "7" || data[1][i].frame_division == "8"))
			{
				// add mroe condition before add 
				if(Number(data[1][i].broadcast_day) < Number(CommonFunction.getCurrentDayForBroastCast()))
				{
					this.addShop(data, i);
				}
			}else if(this.frameDivisionTemplate == "Template3" && data[1][i].frame_division == "9")
			{
				// add mroe condition before add
				if(Number(data[1][i].broadcast_day) < Number(CommonFunction.getCurrentDayForBroastCast()))
				{
					this.addShop(data, i);
				}
			}else if(this.frameDivisionTemplate == "Template4" && data[1][i].frame_division == "10")
			{
				// add mroe condition before add
				if(Number(data[1][i].broadcast_day) < Number(CommonFunction.getCurrentDayForBroastCast()))
				{
					this.addShop(data, i);
				}
			}
		}
		trace("num shop added: " + numShopAdded);
	}
	
	private function addShop(data:Object, i:int )
	{	
		numShopAdded++;
		var shopObj:ShopObject = new ShopObject();
		shopObj.id = data[1][i].id;
		shopObj.registTime = data[1][i].regist_time;
		shopObj.updateTime = data[1][i].update_time;
		shopObj.broadcastDay = data[1][i].broadcast_day;	
		shopObj.broadcastStartTime = data[1][i].broadcast_start_time;
		shopObj.broadcastEndTime = data[1][i].broadcast_end_time;
		shopObj.frameDivision = data[1][i].frame_division;
		shopObj.title = data[1][i].title;
		shopObj.template = data[1][i].template;
		
		var objImg:ImageObject = new ImageObject();
		objImg.ImgURL = data[1][i].IMG_file;
		shopObj.IMGFile = objImg;
		/*
		var objImg2:ImageObject = new ImageObject();
		objImg2.ImgURL = data[1][i].IMG_file2;
		shopObj.IMGFile2 = objImg2;	
		
		var objImg3:ImageObject = new ImageObject();
		objImg3.ImgURL = data[1][i].IMG_file3;
		shopObj.IMGFile3 = objImg3;
		
		var objImg4:ImageObject = new ImageObject();
		objImg4.ImgURL = data[1][i].IMG_file4;
		shopObj.IMGFile4 = objImg4;	
		*/
		var objImgLogo:ImageObject = new ImageObject();
		objImgLogo.ImgURL = data[1][i].IMG_shop_logo;
		shopObj.IMGShopLogo = objImgLogo;	
		
		shopObj.shopName = data[1][i].shop_name;
		//shopObj.period = data[1][i].period;
		shopObj.shopDetailInfo = data[1][i].shop_detail_info;
		shopObj.IMGTitleImage = data[1][i].IMG_title_image;
		shopObj.saleDay = data[1][i].sale_day;
		
		shopObj.product1 = data[1][i].product1;
		shopObj.product2 = data[1][i].product2;
		shopObj.product3 = data[1][i].product3;
		shopObj.product4 = data[1][i].product4;
		
		shopObj.priceDivision1 = data[1][i].price_division1;
		shopObj.priceDivision2 = data[1][i].price_division2;
		shopObj.priceDivision3 = data[1][i].price_division3;
		shopObj.priceDivision4 = data[1][i].price_division4;
		
		shopObj.price1 = data[1][i].price1;
		shopObj.price2 = data[1][i].price2;
		shopObj.price3 = data[1][i].price3;
		shopObj.price4 = data[1][i].price4;
		
		shopObj.productText1 = data[1][i].product_text1;
		shopObj.productText2 = data[1][i].product_text2;
		shopObj.productText3 = data[1][i].product_text3;
		shopObj.productText4 = data[1][i].product_text4;
		
		shopObj.areaID = data[1][i].area_id;
		
		var objImgFoodShoopLogo1:ImageObject = new ImageObject();
		objImgFoodShoopLogo1.ImgURL = data[1][i].IMG_food_shop_logo1;
		shopObj.IMGFoodShopLogo1 = objImgFoodShoopLogo1;
		
		var objImgFoodShoopLogo2:ImageObject = new ImageObject();
		objImgFoodShoopLogo2.ImgURL = data[1][i].IMG_food_shop_logo2;
		shopObj.IMGFoodShopLogo2 = objImgFoodShoopLogo2;
		
		var objImgFoodShoopLogo3:ImageObject = new ImageObject();
		objImgFoodShoopLogo3.ImgURL = data[1][i].IMG_food_shop_logo3;
		shopObj.IMGFoodShopLogo3 = objImgFoodShoopLogo3;
		
		var objImgFoodShoopLogo4:ImageObject = new ImageObject();
		objImgFoodShoopLogo4.ImgURL = data[1][i].IMG_food_shop_logo4;
		shopObj.IMGFoodShopLogo4 = objImgFoodShoopLogo4;
		
		var objImgFoodShoopLogo5:ImageObject = new ImageObject();
		objImgFoodShoopLogo5.ImgURL = data[1][i].IMG_food_shop_logo5;
		shopObj.IMGFoodShopLogo5 = objImgFoodShoopLogo5;
		
		var objImgFoodShoopLogo6:ImageObject = new ImageObject();
		objImgFoodShoopLogo6.ImgURL = data[1][i].IMG_food_shop_logo6;
		shopObj.IMGFoodShopLogo6 = objImgFoodShoopLogo6;
		
		var objImgFoodShoopLogo7:ImageObject = new ImageObject();
		objImgFoodShoopLogo7.ImgURL = data[1][i].IMG_food_shop_logo7;
		shopObj.IMGFoodShopLogo7 = objImgFoodShoopLogo7;
		
		var objImgFoodShoopLogo8:ImageObject = new ImageObject();
		objImgFoodShoopLogo8.ImgURL = data[1][i].IMG_food_shop_logo8;
		shopObj.IMGFoodShopLogo8 = objImgFoodShoopLogo8;
			
		var objImgFoodShoopLogo9:ImageObject = new ImageObject();
		objImgFoodShoopLogo9.ImgURL = data[1][i].IMG_food_shop_logo9;
		shopObj.IMGFoodShopLogo9 = objImgFoodShoopLogo9;
		
		var objImgFoodShoopLogo10:ImageObject = new ImageObject();
		objImgFoodShoopLogo10.ImgURL = data[1][i].IMG_food_shop_logo10;
		shopObj.IMGFoodShopLogo10 = objImgFoodShoopLogo10;

		var objImgFoodFile1:ImageObject = new ImageObject();
		objImgFoodFile1.ImgURL = data[1][i].IMG_food_file1;
		shopObj.IMGFoodFile1 = objImgFoodFile1;

		var objImgFoodFile2:ImageObject = new ImageObject();
		objImgFoodFile2.ImgURL = data[1][i].IMG_food_file2;
		shopObj.IMGFoodFile2 = objImgFoodFile2;
		
		var objImgFoodFile3:ImageObject = new ImageObject();
		objImgFoodFile3.ImgURL = data[1][i].IMG_food_file3;
		shopObj.IMGFoodFile3 = objImgFoodFile3;
		
		var objImgFoodFile4:ImageObject = new ImageObject();
		objImgFoodFile4.ImgURL = data[1][i].IMG_food_file4;
		shopObj.IMGFoodFile4 = objImgFoodFile4;
		
		var objImgFoodFile5:ImageObject = new ImageObject();
		objImgFoodFile5.ImgURL = data[1][i].IMG_food_file5;
		shopObj.IMGFoodFile5 = objImgFoodFile5;
		
		var objImgFoodFile6:ImageObject = new ImageObject();
		objImgFoodFile6.ImgURL = data[1][i].IMG_food_file6;
		shopObj.IMGFoodFile6 = objImgFoodFile6;
		
		var objImgFoodFile7:ImageObject = new ImageObject();
		objImgFoodFile7.ImgURL = data[1][i].IMG_food_file7;
		shopObj.IMGFoodFile7 = objImgFoodFile7;
		
		var objImgFoodFile8:ImageObject = new ImageObject();
		objImgFoodFile8.ImgURL = data[1][i].IMG_food_file8;
		shopObj.IMGFoodFile8 = objImgFoodFile8;
		
		var objImgFoodFile9:ImageObject = new ImageObject();
		objImgFoodFile9.ImgURL = data[1][i].IMG_food_file9;
		shopObj.IMGFoodFile9 = objImgFoodFile9;
		
		var objImgFoodFile10:ImageObject = new ImageObject();
		objImgFoodFile10.ImgURL = data[1][i].IMG_food_file10;
		shopObj.IMGFoodFile10 = objImgFoodFile10;
		
		
		listShopParse.push(shopObj);
		}
	
	}
	
}