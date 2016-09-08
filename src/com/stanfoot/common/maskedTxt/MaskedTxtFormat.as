package com.stanfoot.common.maskedTxt 
{
	import flash.text.Font;
	/**
	 * ...
	 * @author kobayashi
	 */
	public class MaskedTxtFormat extends Object
	{
		public var font:Font;
		public var fontSize:Number = 26;
		public var fontleading:Number = 0;
		public var fontColor:uint = 0x000000;
		public var letterSpacing:Number = 0;
		public var textValign = MaskedTxt.VALIGN_TOP;
		public var textAlign:String = MaskedTxt.ALIGN_LEFT;
		public var squeezeLimit:Number = 0.3;
		public var multiLine:Boolean = false;
		/** スクイーズするかどうか デフォルト true */
		public var squeezeFlg:Boolean = true;
		/** ティッカーの必要性 */
		public var tickerFlg:Boolean = false;
		
		/**
		 * コンストラクタ
		 */
		public function MaskedTxtFormat() 
		{
			
		}
		
	}

}