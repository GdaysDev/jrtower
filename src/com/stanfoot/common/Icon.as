package com.stanfoot.common 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	/**
	 * ...
	 * @author 
	 */
	public class Icon extends MovieClip
	{
		protected static var CAPACITY:int;
		protected var numText:TextField;
		protected var _value:Number;
		protected var _icon:MovieClip;
		
		public function Icon()
		{
			
		}
		
		public function init(value:Number = NaN):void
		{
			if (isNaN(value))
			{
				_value = CAPACITY;
			}
			else
			{
				_value = value;
			}
			
			
			if (numText)
			{
				
				numText.text = "x" + Math.floor(_value).toString();
			}
		}
	}

}