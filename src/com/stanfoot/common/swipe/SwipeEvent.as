package com.stanfoot.common.swipe 
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class SwipeEvent extends MouseEvent 
	{
		public static const EVENT_SWIPE:String = "swipe";
		
		private var _offsetX:Number;
		public function get offsetX():Number
		{
			return _offsetX;
		}
		
		private var _offsetY:Number;
		public function get offsetY():Number
		{
			return _offsetY;
		}
		
		public function SwipeEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, localX:Number = NaN, localY:Number = NaN, offsetX:Number = NaN, offsetY:Number = NaN, relatedObject:InteractiveObject = null, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, buttonDown:Boolean = false, delta:int = 0) 
		{
			super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
			_offsetX = offsetX;
			_offsetY = offsetY;
		}
		
		override public function clone():Event 
		{
			trace(type)
			//return super.clone();
			return new SwipeEvent(type, bubbles, cancelable, localX, localY,offsetX,offsetY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
		}
		
		override public function toString():String 
		{
			//return super.toString();
			return formatToString("swipe", "type", "bubbles", "cancelable", "offsetX", "offsetY", "localX", "localY", "relatedObject", "ctrlKey", "altKey", "shiftKey", "buttonDown", "delta");
		}
	}

}