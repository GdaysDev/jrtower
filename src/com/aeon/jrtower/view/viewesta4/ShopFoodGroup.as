package com.aeon.jrtower.view.viewesta4 {
	import com.greensock.core.Animation;
	import flash.events.Event;
	import com.stanfoot.common.imageContainer.ImageContainerEventType;
	import flash.geom.Rectangle;
	import flash.display.Sprite;

	import com.stanfoot.common.imageContainer.ImageContainer;

	import flash.display.MovieClip;

	/**
	 * @author lethang
	 */
	public class ShopFoodGroup extends Animator{
		private static var boxWidth : Number = 150;
		private static var boxHeight : Number = 100;
		var foodImgArray : Array = [];
		var shopImgArray : Array = [];

		public static function setBoxSize(width : Number, height : Number) : void {
			boxWidth = width;
			boxHeight = height;
		}

		public function ShopFoodGroup(foodImgURL, shopImgURL) {
			var foodRect : Rectangle = new Rectangle(0, 0, boxWidth * 0.7, boxHeight);
			var shopRect : Rectangle = new Rectangle(boxWidth * 0.75, boxHeight / 4, boxWidth * 0.25, boxHeight / 2);
			generateImg(foodImgURL, foodRect.x, foodRect.y, foodRect.width, foodRect.height);
			generateImg(shopImgURL, shopRect.x, shopRect.y, shopRect.width, shopRect.height);
		}

		private function generateImg(url : String, x : int, y : int, w : int, h : int) : void {
			var img1 : ImageContainer = new ImageContainer(); 
			img1.setBackground(0xffffff, 0,0,0,0);
			img1.fadeDuration = 1;
			img1.init(w, h, null);
			img1.load(url);
			img1.x = x;
			img1.y = y;
			img1.addEventListener(ImageContainerEventType.LOAD_COMPLETE, loadCompleted);
			this.addChild(img1);
		}
		
		private function loadCompleted(e:Event):void {
			var o:ImageContainer = ImageContainer(e.target);
			// Hide object in future for animation
//			dispatchEvent(new Event("shop_food_group_load_completed"));
			trace("img load completed ~~~~~~~~~~~~~~~~~~~~~~~~~~~");
		}
	}
}