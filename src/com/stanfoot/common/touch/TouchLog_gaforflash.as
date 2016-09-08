package com.stanfoot.common.touch 
{
	import com.google.analytics.AnalyticsTracker;
	import com.google.analytics.GATracker;
	import com.stanfoot.common.basic.MainBasic;
	import com.stanfoot.common.debug.Debug;
	import com.stanfoot.common.GeneralFuncs;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.net.SharedObject;
	
	
	
	/**
	 * ...
	 * @author 
	 */
	public class TouchLog_gaforflash extends TouchLog
	{
		/** GoogleAnalyticsトラッカー */
		private var _tracker:GATracker;
		
		private var _container:Sprite = new Sprite();
		private var _display:DisplayObjectContainer;
		private var _accountId:String;
		private var _deviceId:String;
		private var _logCategory:String;
		private var _debugMode:Boolean;
		
		private var _counter:int;
		
		private var _so:SharedObject;
		
		
		/**
		 * コンストラクタ
		 */
		public function TouchLog_gaforflash() 
		{
			super();
			
		}
		
		/**
		 * 初期化
		 * @param	display	※定期的に子供をクリアするので、ルートやステージは登録禁止。専用のコンテナを設けること。
		 * @param	accontId
		 * @param	deviceId
		 * @param	logCategory
		 * @param	debugMode
		 */
		public function init(display:DisplayObjectContainer, accontId:String, deviceId:String, logCategory:String, debugMode:Boolean)
		{
			var message:String;
			if (display as Stage || display as MainBasic)
			{
				message = "ステージやルートは指定しないでください";
				Debug.write(message);
				new Error(message);
			}
			
			_display = display;
			
			_display.addChild(_container);
			
			_accountId = accontId;
			_deviceId = deviceId;
			_logCategory = logCategory;
			_debugMode = debugMode;
			
			reset();
		}
		
		/**
		 * 
		 */
		public function reset():void
		{
			//SharedObjectに記録されたAnalytics情報を削除してセッションのキャッシュをクリアする。
			_so = SharedObject.getLocal("analytics", "/");
			_so.clear();
			
			//1トラッカー（1セッション）あたり500件までしかトラッキングできないので、495件を超えたらトラッカーを作り直す
			if (_counter > 495 || _tracker == null)
			{
				_counter = 0;
				
				//トラッカーが参照しているDisplayObjectContainerからリムーブ
				GeneralFuncs.removeChildren(_container);
				
				
				//※トラッカーのインスタンスは除去しきれず、メモリに残ります。
				//トラッカーを生成しすぎるとメモリを圧迫するので注意。
				
				//GoogleAnalyticsの準備
				_tracker = null;
				_tracker = new GATracker( _container, _accountId, "AS3", _debugMode); 
				//_tracker.setSessionTimeout(1);
				//_tracker.setCookieTimeout(1);
			}
		}
		
		public function trackPageview_searchList(searchGenre:String):void
		{
			if (searchGenre == "") return;
			
			
			var tmpMsg:String = searchGenre;
			
			trackPageview({message: tmpMsg}); 
		}
		
		/**
		 * 詳細パネル展開時用のタッチログを送出
		 * @param	contentId
		 * @param	contentName
		 * @param	fromList
		 */
		public function trackPageview_detailPanel(contentId:String,contentName:String, fromList:Boolean):void
		{
			var tmpName:String = _nameStrFormat(contentId) + "_" + _nameStrFormat(contentName);
			var tmpShowFlg:String = fromList ? DETAILPANELSHOWFLG_LIST : DETAILPANELSHOWFLG_DIRECT ;
			
			//GoogleAnalyticsにトラッキングさせる
			trackPageview( { message:tmpName + "/" + tmpShowFlg } );
		}
		
		/**
		 * 起動時用タッチログを送出
		 * @param	message
		 */
		public function trackPageview_wakeup(message:String):void
		{
			trackPageview({message:message});
		}
		
		/**
		 * タッチログを残す
		 * @param	argPageName
		 */
		//override public function trackPageview(argPageStr:String):void 
		override public function trackPageview(paramsObj:Object):void 
		{
			super.trackPageview(paramsObj);
			
			var tmpStr:String = "";
			
			if (paramsObj)
			{
				
				//ログカテゴリーを追記
				if (_logCategory != null)
				{
					tmpStr += _logCategory + "/";
				}
				
				//端末IDを追記
				if (_deviceId != null)
				{
					tmpStr += _deviceId + "/";
				}
				
				//ログメッセージを追記
				if (paramsObj.message && paramsObj.message != null)
				{
					tmpStr += paramsObj.message;
				}else
				{
					return
				}
				
				_counter += 1;
				reset();
				
				//GoogleAnalyticsにトラッキングさせる
				_tracker.resetSession();
				_tracker.trackPageview(tmpStr);
			}
			
		}
		
		
	}

}