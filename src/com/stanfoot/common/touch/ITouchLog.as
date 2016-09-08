package com.stanfoot.common.touch 
{
	/**
	 * ...
	 * @author ...
	 */
	internal class ITouchLog 
	{
		
		public function ITouchLog() 
		{
			function trackPageview(argPageStr:String):void
			function trackPageview_wakeup(message:String):void
			function trackPageview_detailPanel(contentId:String, contentName:String, fromList:Boolean):void
		}
		
	}

}