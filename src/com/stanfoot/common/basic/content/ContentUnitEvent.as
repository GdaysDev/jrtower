package com.stanfoot.common.basic.content 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class ContentUnitEvent extends Event 
	{
		public static const SHOWCOMPLETE:String = "showComplete";
		public static const SHOWFAILED:String = "showFailed";
		public static const HIDECOMPLETE:String = "hideComplete";
		public static const HIDEFAILED:String = "hideFailed";
		
		
		
		public function ContentUnitEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
	}

}