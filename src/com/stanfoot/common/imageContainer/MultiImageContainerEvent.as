package com.stanfoot.common.imageContainer 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class MultiImageContainerEvent extends Event 
	{
		//クラスメンバ====================================================================
		/** 読み込み失敗時のイベントタイププロパティの値を定義します */
		public static const LOAD_FAILED:String = "load_failed";
		/** 読み込み完了時のイベントタイププロパティの値を定義します */
		public static const LOAD_COMPLETE:String = "load_complete";
		
		/** キューリストすべての読み込み完了時のイベントタイププロパティの値を定義します */
		public static const LOAD_FINISH:String = "load_finish";
		
		
		
		//====================================================================
		public var content:DisplayObject;
		public var url:String;
		
		/**
		 * 
		 * @param	type
		 * @param	bubbles
		 * @param	cancelable
		 * @param	contentm	DisplayObject
		 * @param	url
		 */
		public function MultiImageContainerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, content:DisplayObject = null, url:String = null):void
		{
			super(type, bubbles, cancelable);
			
			this.content = content;
			this.url = url;
		}
		
	}

}