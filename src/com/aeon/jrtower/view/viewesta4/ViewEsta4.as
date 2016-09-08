package com.aeon.jrtower.view.viewesta4 {
	import flash.display.Shape;
	import flash.display.MovieClip;

	import com.aeon.jrtower.common.DefineCommonValue;
	import com.stanfoot.common.imageContainer.ImageContainerEventType;

	import flash.events.ErrorEvent;

	import com.stanfoot.common.imageContainer.ImageContainer;

	import flash.events.Event;
	import flash.display.Sprite;

	import com.aeon.jrtower.helper.ParseJsonData;
	import com.aeon.jrtower.model.ShopObject;

	/**
	 * @author md760
	 */
	public class ViewEsta4 extends MovieClip {
		private const headerHeightRatio : Number = 0.1145; // 0.1145
		private const bodyHeightRatio : Number = 0.85; // 0.85
		private const bodyMarginLRRatio : Number = 0.03; // 0.03
		private const bodyMarginTBRatio : Number = 0.01; // 0.01
		public var boxWidth : Number = 1080 ;
		public var boxHeight : Number = 1920 ;
		private var data : ShopObject;
		private var bodyMarginLR : Number = 10;
		private var bodyMarginTB : Number = 10;
		private var count : Number = -1;

		public function ViewEsta4(dataObj : ShopObject) {
			trace("asta 4 constructor start");
			data = dataObj;
			bodyMarginLR = boxWidth * bodyMarginLRRatio;
			bodyMarginTB = boxHeight * bodyMarginTBRatio;
			generateChilds();
		}

		private function generateChilds() : void {
			generateBackground();
			generateHeader();
			generateBody();
			generateFooter();
		}

		private function generateBackground() : void {
			var bgs : Array = ["", "", "bg_orange.png", "bg_green.png", "bg_pink.png"];
			var bgsPath : String = "pillar_vision_cross_jrtower/ESTA4-BG/";
			var bgsPath1 : String = "SystemImg/";
			var bg : ImageContainer = new ImageContainer();
			bg.init(boxWidth, boxHeight);
			bg.load(bgsPath1 + bgs[data.areaID]);
			addChild(bg);
		}

		private function generateHeader() : void {
		}

		private function generateBody() : void {
			var count : Number = getGroupImgCount();
			var groupHeight : Number = ( boxHeight * bodyHeightRatio) / (count + (count % 2)) * 2 ;
			var groupWidth : Number = (boxWidth - bodyMarginLR * 4) / 2;
			drawDottedLines((count + (count % 2)) / 2 - 1, groupHeight);
			trace(count + (count % 2));
			ShopFoodGroup.setBoxSize(groupWidth, groupHeight - bodyMarginTB * 2);
			for (var i : int = 1; i <= count; i++) {
				var group : ShopFoodGroup = new ShopFoodGroup(DefineCommonValue.JSON_IMG + data["IMGFoodFile" + i].ImgURL, DefineCommonValue.JSON_IMG + data["IMGFoodShopLogo" + i].ImgURL);
				group.x = ((i % 2 == 0) ? groupWidth + bodyMarginLR * 2 : 0) + bodyMarginLR; // Margin
				var rowIndex : Number = ((i + (i % 2)) / 2) - 1;
				group.y = (rowIndex * groupHeight) + bodyMarginTB + headerHeightRatio * boxHeight; // Margin
				addChild(group);
//				this[++count] = group; //Some kind of pointer
			}
		}

		private function generateFooter() : void {
		}

		function getGroupImgCount() : Number {
			var count : Number = 0;
			for (var i : int = 1; i < 11; i++) {
				trace("-> IMGFoodFile" + i + " " + data["IMGFoodFile" + i].ImgURL);
				if (data["IMGFoodFile" + i].ImgURL == "") continue;
				count++;
			}
			return count;
		}

		private function drawDottedLines(count : Number, verticalSpacing : Number) : void {
			var colors = [0, 0, 0xFF0000, 0x00FF00, 0x0000FF];
			var color = colors[data.areaID];
			var dotWidth = int(boxWidth * 0.008);
			var dotHeight = (dotWidth / 3);
			for (var i : int = 1; i <= count; i++) {
				var sh : Shape = new DottedLine(boxWidth - bodyMarginLR * 2, dotHeight, color, 1, dotWidth, dotWidth);
				sh.x = bodyMarginLR;
				sh.y = boxHeight * headerHeightRatio + i * verticalSpacing ;
				trace("draw line: ", sh.x, sh.y);
				addChild(sh);
			}

			for (var i : int = 1; i <= count + 1; i++) {
				var  sv : Shape = new DottedLine(verticalSpacing - bodyMarginTB * 2, dotHeight, color, 1, dotWidth, dotWidth);
				sv.x = boxWidth / 2;
				sv.y = boxHeight * headerHeightRatio + (i - 1) * verticalSpacing + bodyMarginTB;
				sv.rotation = 90;
				addChild(sv);
			}
		}
	}
}