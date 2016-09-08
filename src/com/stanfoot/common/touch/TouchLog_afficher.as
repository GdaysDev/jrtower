package com.stanfoot.common.touch 
{
	import com.stanfoot.common.debug.Debug;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	/**
	 * 
	 * 例：
	 * remark=TopicsDetailID23
	 * →画面名=トピックス詳細・ID23の場合
	 * 
	 * remark=TenantDetailID23
	 * →画面名=ショップ詳細・ID23の場合
	 * 
	 * @author ...
	 */
	public class TouchLog_afficher extends TouchLog 
	{
		//レスポンス不要の場合は navigateToURL が使える
		private var _loader:URLLoader;
		
		private var _url:String = "http://localhost/templatelog";
		
		public function TouchLog_afficher() 
		{
			super();
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.TEXT;
			_loader.addEventListener(Event.COMPLETE, _loader_loadComplete_listener);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, _loader_ioError_listener);
		}
		
		public function init(url:String = null):void
		{
			if (url && url != "")
			{
				_url = url;
			}
		}
		
		//override public function trackPageview(touchLogParams:TouchLogParams_afficher):void 
		override public function trackPageview(paramsObj:Object):void 
		{
			super.trackPageview(paramsObj);
			
			var newRequest:URLRequest = new URLRequest(_url);
			var newParams:URLVariables;
			
			newParams = _makeURLVariables(paramsObj);
			
			//newParams.remark = _nameStrFormat(argPageStr);
			
			newRequest.data = newParams;
			newRequest.method = URLRequestMethod.POST;
			
			Debug.write("[TouchLog_afficher] trackPageview >> " + _url);
			
			//_loader.close
			_loader.load(newRequest)
		}
		
		override protected function _makeURLVariables(paramsObj:Object = null):URLVariables 
		{
			var result:URLVariables =  super._makeURLVariables();
			var tmpParams:TouchLogParams_afficher;
			
			if (paramsObj)
			{
				if (paramsObj.contentsname) result.contentsname = paramsObj.contentsname;
				if (paramsObj.templateid) result.templateid = paramsObj.templateid;
				if (paramsObj.templatename) result.templatename = paramsObj.templatename;
				if (paramsObj.templatedataid) result.templatedataid = paramsObj.templatedataid;
				if (paramsObj.templatedataname) result.templatedataname = paramsObj.templatedataname;
				if (paramsObj.remark) result.remark = paramsObj.remark;
			}
			
			return result;
		}
		
		private function _loader_loadComplete_listener(e:Event):void
		{
			Debug.write("[TouchLog_afficher] " + _loader.data);
		}
		private function _loader_ioError_listener(e:IOErrorEvent):void
		{
			//
		}
	}

}