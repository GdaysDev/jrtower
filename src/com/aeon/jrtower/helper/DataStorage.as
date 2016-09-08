package com.aeon.jrtower.helper {
	import flash.net.SharedObject;
	/**
	 * @author lethang
	 */
	 
	public class DataStorage {
		private static var APP_KEY_WORD:String = "com.jrtower.esta2016";
		private static var shareObject:SharedObject = SharedObject.getLocal(APP_KEY_WORD);
		public static function get Data() : Object {
			return shareObject.data;
		}
	}
}