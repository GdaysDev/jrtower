package com.stanfoot.common.swipe 
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author 
	 */
	public class SwipeableMovieClip extends MovieClip 
	{
		
		public function SwipeableMovieClip() 
		{
			super();
		}
		
		
		private var _mouseDownPoint:Point = new Point();
		/** スワイプと見なす最小タッチ移動量（ピクセル） */
		public var swipeThreshold:Number = 50;
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
		{
			switch(type)
			{
				case SwipeEvent.EVENT_SWIPE:
					super.addEventListener(SwipeEvent.EVENT_SWIPE, listener, useCapture, priority, useWeakReference);
					super.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown_listener);
					//super.addEventListener(MouseEvent.MOUSE_UP, mouseUp_listener);
					//super.addEventListener(MouseEvent.ROLL_OUT, mouseUp_listener);
					break;
				default:
					super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
		{
			switch(type)
			{
				case SwipeEvent.EVENT_SWIPE:
					super.removeEventListener(SwipeEvent.EVENT_SWIPE, listener, useCapture);
					super.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown_listener);
					super.removeEventListener(MouseEvent.MOUSE_UP, mouseUp_listener);
					super.removeEventListener(MouseEvent.ROLL_OUT, mouseUp_listener);
					break;
				default:
					super.removeEventListener(type, listener, useCapture);
			}
		}
		
		private function mouseDown_listener(e:MouseEvent):void
		{
			_mouseDownPoint.x = e.localX;
			_mouseDownPoint.y = e.localY;
			super.addEventListener(MouseEvent.MOUSE_UP, mouseUp_listener);
			super.addEventListener(MouseEvent.ROLL_OUT, mouseUp_listener);
		}
		
		private function mouseRollOut_listener(e:MouseEvent):void
		{
			calcMouseMovement(e);
			super.removeEventListener(MouseEvent.MOUSE_UP, mouseUp_listener);
			super.removeEventListener(MouseEvent.ROLL_OUT, mouseUp_listener);
		}
		
		private function mouseUp_listener(e:MouseEvent):void
		{
			calcMouseMovement(e);
			super.removeEventListener(MouseEvent.MOUSE_UP, mouseUp_listener);
			super.removeEventListener(MouseEvent.ROLL_OUT, mouseUp_listener);
		}
		
		private function calcMouseMovement(e:MouseEvent):void
		{
			var tmpPoint:Point = new Point(e.localX, e.localY);
			var tmpOffsetX:Number = tmpPoint.x - _mouseDownPoint.x;
			var tmpOffsetY:Number = tmpPoint.y - _mouseDownPoint.y;
			
			/*
			if(Math.abs(tmpOffsetX) > swipeThreshold || Math.abs(tmpOffsetY) > swipeThreshold)
			{
				tmpOffsetX = Math.floor(tmpOffsetX / swipeThreshold);
				tmpOffsetX /= Math.abs(tmpOffsetX);
				tmpOffsetY = Math.floor(tmpOffsetY / swipeThreshold);
				tmpOffsetY /= Math.abs(tmpOffsetY);
				dispatchEvent(new SwipeEvent(SwipeEvent.EVENT_SWIPE, e.bubbles, e.cancelable, e.localX, e.localY, tmpOffsetX, tmpOffsetY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
			}
			*/
			if(myAbs(tmpOffsetX) > swipeThreshold || myAbs(tmpOffsetY) > swipeThreshold)
			{
				tmpOffsetX = (tmpOffsetX / swipeThreshold)|0;
				tmpOffsetX /= myAbs(tmpOffsetX);
				tmpOffsetY = (tmpOffsetY / swipeThreshold)|0;
				tmpOffsetY /= myAbs(tmpOffsetY);
				dispatchEvent(new SwipeEvent(SwipeEvent.EVENT_SWIPE, e.bubbles, e.cancelable, e.localX, e.localY, tmpOffsetX, tmpOffsetY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
			}
		}
		
		private function myAbs(num:Number):Number
		{
			//return (num ^ (num >> 31)) - (num >> 31);
			return num < 0 ? -num : num;
		}
		
		
	}

}