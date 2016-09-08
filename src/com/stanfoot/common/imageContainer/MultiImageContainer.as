package com.stanfoot.common.imageContainer 
{
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import com.greensock.TweenNano;
	import com.stanfoot.common.GeneralFuncs;
	import com.stanfoot.common.debug.Debug;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import com.greensock.layout.*;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author 
	 */
	public class MultiImageContainer extends MovieClip
	{
		//クラスメンバ================================
		
		public static const SLIDESHOWPAGINGCONTROLLERALIGN_LEFT:String = "left";
		public static const SLIDESHOWPAGINGCONTROLLERALIGN_CENTER:String = "center";
		public static const SLIDESHOWPAGINGCONTROLLERALIGN_RIGHT:String = "right";
		
		/**
		 * sourceMultiImageContainer のスライドリスト内容を targetMultiImageContainer へクローンする（ソースがビットマップのもののみ）
		 * @param	targetMultiImageContainer
		 * @param	sourceMultiImageContainer
		 */
		public static function cloneSlides(targetMultiImageContainer:MultiImageContainer, sourceMultiImageContainer:MultiImageContainer):void
		{
			var tmpList:Array = sourceMultiImageContainer.getSlideList(); 
			var tmpLength:int = tmpList.length;
			var tmpContent:DisplayObject;
			var tmpBmp:Bitmap;
			var sourceBmpData:BitmapData;
			var tmpRect:Rectangle;
			var tmpPoint:Point;
			var tmpBmpData:BitmapData;
			
			for (var i:int = 0; i < tmpLength; i++) 
			{
				tmpContent = tmpList[i];
				
				tmpBmp = tmpContent as Bitmap;
				if (tmpBmp)
				{
					//ソースがビットマップだった場合
					sourceBmpData = tmpBmp.bitmapData;
					tmpBmpData = new BitmapData(sourceBmpData.width, sourceBmpData.height);
					tmpRect = new Rectangle(0, 0, sourceBmpData.width, sourceBmpData.height);
					tmpPoint = new Point();
					
					tmpBmpData.copyPixels(sourceBmpData,tmpRect,tmpPoint);
					
					targetMultiImageContainer.addSlide(new Bitmap(tmpBmpData,"auto", true));
				}
				/*
				else
				{
					//tmpContent.scaleX = 1;
					//tmpContent.scaleY = 1;
					tmpBmpData = new BitmapData(tmpContent.width, tmpContent.height);
					tmpBmpData.draw(tmpContent);
					tmpBmp = new Bitmap(tmpBmpData, "auto", true);
					targetMultiImageContainer.addSlide(tmpBmp);
					
					targetMultiImageContainer.addSlide(tmpContent);
				}
				*/
			}
		}
		
		//インスタンスメンバ================================
		
		//ディスプレイオブジェクト---------------------------------------------
		/** ローダー */
		protected var _loader:Loader;
		
		/** コンテンツリスト */
		private var _contentlist:/*ContentListItem*/Array = [];
		/** 現時点のスライドコンテンツリストの長さを取得する */
		public function get slideListLength():int
		{	return _contentlist.length;		}
		
		/**
		 * 現時点のスライドコンテンツのみのリストを生成し取得する
		 * @return
		 */
		public function getSlideList():Array
		{	
			var result:Array = [];
			var tmpLength:int = _contentlist.length;
			var tmpContentListItem:ContentListItem;
			
			for (var i:int = 0; i < tmpLength; i++) 
			{
				tmpContentListItem = _contentlist[i];
				result.push(tmpContentListItem.content);
			}
			return result;
		}
		
		/** 読み込みキューリスト */
		private var _queueList:/*String*/Array = [];
		
		//プロパティ---------------------------------------------
		protected var _urlRequest:URLRequest;
		/** URLRequestインスタンスのurlの参照 */
		public function get url():String
		{	return _urlRequest.url;	}
		/** LoaderインスタンスのcontentLoaderInfo */
		protected var _contentLoaderInfo:LoaderInfo;
		/** LoaderインスタンスのcontentLoaderInfoの参照 */
		public function get contentLoaderInfo():LoaderInfo
		{	return _contentLoaderInfo;	}
		
		protected var _autoFitArea:AutoFitArea;
		protected var _autoFitAreaParams:Object;
		
		//AutoFitAreaのサイズの取得と指定-------------------------
		
		public function get areaWidth():Number
		{
			return _autoFitArea.width;
		}
		public function set areaWidth(value:Number):void
		{
			_autoFitArea.width = value;
		}
		public function get areaHeight():Number
		{
			return _autoFitArea.height;
		}
		public function set areaHeight(value:Number):void
		{
			_autoFitArea.height = value;
		}
		
		public var preview:Boolean;
		
		/** スライドショー用タイマー */
		private var _slideShowTimer:Timer;
		
		/** 読み込み中フラグ */
		private var _isLoading:Boolean;
		
		/** スライドショー用 表示インデックス */
		private var _currentIndex:int;
		
		/** スライドショーのフェードに要する秒数 */
		public var fadeDuration:Number = 0;
		
		
		
		//メソッド---------------------------------------------
		/**
		 * コンストラクタ
		 * @param	areaWidth	表示領域の幅
		 * @param	areaHeight	表示領域の高さ
		 * @param	autoFitAreaParams	画像読み込み後の自動リサイズの設定値（greensockのAutoFitAreaを参照）
		 */
		public function MultiImageContainer(areaWidth:Number = 100, areaHeight:Number = 100, autoFitAreaParams:Object = null) 
		{
			TweenPlugin.activate([AutoAlphaPlugin]);
			
			super();
			_autoFitArea = new AutoFitArea(this);
			init(areaWidth, areaHeight, autoFitAreaParams);
			
			_loader = new Loader();
			_contentLoaderInfo = _loader.contentLoaderInfo;
			_contentLoaderInfo.addEventListener(Event.COMPLETE, _loaderInfo_complete_listener);
			_contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _loaderInfo_iOError_listener);
			_urlRequest = new URLRequest();
			
			addEventListener(Event.REMOVED_FROM_STAGE, _removedFromStage_listener);
			
			_slideShowTimer = new Timer(4 * 1000, 0);
			_slideShowTimer.addEventListener(TimerEvent.TIMER, _slideShowTimer_listener);
			_slideShowTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _slideShowComplete_listener);
		}
		
		/**
		 * 初期化
		 * @param	areaWidth
		 * @param	areaHeight
		 * @param	autoFitAreaParams	画像読み込み後の自動リサイズの設定値（greensockのAutoFitAreaを参照）
		 */
		public function init(areaWidth:Number, areaHeight:Number, autoFitAreaParams:Object = null):void
		{
			//Debug.write("[MultiImageContainer] init " + areaWidth + "," + areaHeight);
			_autoFitAreaParams = autoFitAreaParams;
			
			var tmpList:Array = _autoFitArea.getAttachedObjects();
			var tmpLength:int = tmpList.length;
			var tmpObj:DisplayObject;
			if (tmpLength > 0)
			{
				tmpObj = tmpList[tmpLength -1] as DisplayObject;
				if(tmpObj)	_autoFitArea.attach(tmpObj, _autoFitAreaParams);
			}
			
			this.areaWidth = areaWidth;
			this.areaHeight = areaHeight;
		}
		
		/**
		 * 画像の読み込み開始
		 * 読み込みが正常に完了した場合、イベント（タイプ値：MultiImageContainerEvent.LOAD_COMPLETE）を送出します。
		 * 読み込みに失敗した場合、イベント（タイプ値：MultiImageContainerEvent.LOAD_FAILED）を送出します。
		 * @param	url
		 * @param	noCacheQuery	キャッシュしないためにクエリを付加するかどうか
		 */
		public function loadUrl(url:String, noCacheQuery:Boolean = true ):void
		{
			var tmpUrl:String = url as String;
			
			if (tmpUrl && tmpUrl != "" )
			{
				if (tmpUrl.indexOf("http") == 0 && noCacheQuery)
				{	//httpで読み込む場合
					if (tmpUrl.indexOf("?") >= 0)
					{	//すでに何かしらクエリ値がすでにある場合
						if (tmpUrl.indexOf("noCache") < 0)
						{	//クエリ値にまだnoCacheがない場合 noCacheを付加する
							tmpUrl += "&noCache=" + new Date().time;
						}
						else
						{	//クエリ値にnoCacheがある場合 noCacheの値を書き換える
							var tmpStrArray:Array = tmpUrl.split("noCache=");
							tmpStrArray = String(tmpStrArray[1]).split("&");
							var tmpNoCacheValue:String = tmpStrArray[0];
							tmpUrl = GeneralFuncs.xReplace(tmpUrl, tmpNoCacheValue, String(new Date().time));
						}
					}
					else
					{	//クエリ値が何もない場合 noCacheを付加する
						tmpUrl += "?noCache=" + new Date().time;
					}
				}
				
				_addQueue(tmpUrl);
				
				_loadStart();
			}
		}
		
		/**
		 * バイトアレイデータで画像を読み込む
		 * @param	bytes
		 * @param	context
		 */
		public function loadByteArray(bytes:ByteArray, context:LoaderContext = null):void
		{
			_loader.loadBytes(bytes, context);
		}
		
		/**
		 * ローダーを閉じる
		 */
		public function close():void
		{
			try
			{
				_loader.close();
			}
			catch (err:Error)
			{
				Debug.write(err.message);
			}
			_loader.unload();
		}
		
		
		/**
		 * キューリストのURLのロードを開始する
		 */
		private function _loadStart():void
		{
			if (_isLoading)
			{
				//ロード中の場合
				//Debug.write("[MultiImageContainer] ロード中")
			}
			else if(_queueList.length > 0)
			{
				_urlRequest.url = _queueList[0];
				if (_urlRequest.url && _urlRequest.url != "")
				{
					_isLoading = true;
					//Debug.write("[MultiImageContainer] 画像読み込み開始 " + url);
					_loader.load(_urlRequest);
				}
				else
				{
					//Debug.write("[MultiImageContainer] URLが未指定です");
					//dispatchEvent(new Event(MultiImageContainerEvent.LOAD_FAILED));
					dispatchEvent(new MultiImageContainerEvent(MultiImageContainerEvent.LOAD_FAILED));
					
					_loadNextQueue();
				}
			}
		}
		
		/**
		 * 読み込みキューを追加
		 * @param	url
		 */
		private function _addQueue(url:String):void
		{
			//Debug.write("[MultiImageContainer] add queue : " + url);
			_queueList.push(url);
		}
		
		/**
		 * 読み込みキューを削除
		 * @param	url
		 */
		private function _removeQueue(url:String):void
		{
			
			var tmpIndex:int = -1;
			
			for (var i:int = 0; i < _queueList.length; i++) 
			{
				if (_queueList[i] == url) {
					tmpIndex = i;
					break;
				}
			}
			
			if (tmpIndex >= 0)
			{
				_queueList.splice(tmpIndex, 1);
				//Debug.write("[MultiImageContainer] queue remove");
			}
		}
		
		/**
		 * 次のキューを読み込む
		 */
		protected function _loadNextQueue():void
		{
			//キューを削除し、次の読み込みを開始
			_removeQueue(_urlRequest.url);
			_loader.unloadAndStop();
			_isLoading = false;
			
			if ( _queueList.length > 0)
			{
				_loadStart();
			}
			else
			{
				//キューのすべての画像を読み終えた場合
				_resetSlideshowPagingController();
				
				//dispatchEvent(new Event(MultiImageContainerEvent.LOAD_FINISH));
				dispatchEvent(new MultiImageContainerEvent(MultiImageContainerEvent.LOAD_FINISH));
			}
		}
		//========================================================================
		
		
		/**
		 * スライドショーを開始する
		 * @param	times	切り替える回数（0の場合はエンドレス）
		 */
		public function startSlideShow(times:int = 0):void
		{
			_slideShowTimer.reset();
			_slideShowTimer.repeatCount = times;
			_slideShowTimer.start();
		}
		private function _slideShowTimer_listener(e:TimerEvent):void
		{
			//Debug.write("[MultiImageContainer] slideShow TIMER");
			_showContent(_currentIndex + 1);
		}
		
		private function _slideShowComplete_listener(e:TimerEvent):void
		{
			//Debug.write("[MultiImageContainer] slideShow COMPLETE");
			//stopSlideShow();
		}
		
		public function pauseSlideShow():void
		{
			_slideShowTimer.stop();
		}
		/**
		 * スライドショーをストップする
		 */
		public function stopSlideShow():void
		{
			//Debug.write("[MultiImageContainer] slideShow STOP");
			//_currentIndex = 0;
			_slideShowTimer.stop();
			//showContent(0);
		}
		
		/**
		 * 指定インデックスのスライドを表示する
		 * @param	index
		 */
		public function showSlide(index:int = 0):void
		{
			_showContent(index);
		}
		
		/**
		 * 指定インデックスの画像を表示する
		 * @param	index
		 */
		private function _showContent(index:int = 0):void
		{
			var tmpListItem:ContentListItem;
			var tmpContent:DisplayObject;
			var prevContent:DisplayObject;
			var nextContent:DisplayObject;
			
			//Debug.write("MultiImageContainer showContent " + index);
			
			if (_contentlist.length > 0)
			{
				//インデックス値の整理
				if (index >= _contentlist.length) index = 0;
				
				
				for (var i:int = 0; i < _contentlist.length; i++) 
				{
					tmpListItem = _contentlist[i];
					if(tmpListItem) tmpContent = tmpListItem.content;
					
					if (tmpContent)
					{
						if (i == index)
						{
							//表示したい画像の場合
							if (tmpContent.visible && tmpContent.alpha == 1)
							{
								//
							}
							else
							{
								tmpContent.visible = true;
								TweenLite.to(tmpContent, fadeDuration, { alpha:1 } );
							}
						}
						else if(tmpContent.visible)
						{
							//TweenLite.to(tmpContent, fadeDuration, { alpha:0 } );
							TweenLite.to(tmpContent, fadeDuration, { autoAlpha:0 } );
						}
					}
				}
				
				_currentIndex = index;
			}
			else
			{
				_currentIndex = -1;
			}
			
			_resetSlideshowPagingController()
		}
		/**
		 * //ミリ秒から秒に統一のため
		 * スライドショーの切替ミリ秒数を指定する
		
		public function set setSlideshowDelay(value:Number):void
		{
			_slideShowTimer.delay = value;
		}
		 */
		/**
		 * スライドショーの切替秒数を指定する
		 */
		public function set slideshowDelay(value:Number):void
		{
			_slideShowTimer.delay = value * 1000;
		}
		
		/**
		 * 現在表示中のディスプレイオブジェクトを返す
		 * @return
		 */
		public function getCurrentDisplayObject():DisplayObject
		{
			var result:DisplayObject;
			var tmpListItem:ContentListItem;
			
			tmpListItem = _contentlist[_currentIndex];
			if(tmpListItem) result = tmpListItem.content;
			
			return result;
		}
		
		//========================================================================
		/**
		 * スライドリストにコンテンツを追加する
		 * @param	content
		 * @param	url
		 * @param	cleateDate
		 */
		public function addSlide(content:DisplayObject, url:String = null, cleateDate:Date = null):void
		{
			var tmpListItem:ContentListItem = new ContentListItem(content, url, cleateDate);
			
			content.alpha = 0;
			addChild(content);
			_contentlist.push(tmpListItem);
			
			_autoFitArea.attach(content, _autoFitAreaParams);
			_autoFitArea.preview = preview;
			
			if (_contentlist.length == 1)
			{
				//追加されたコンテンツが最初のコンテンツだった場合、表示する
				_showContent(0);
			}
		}
		
		/**
		 * 指定されたオブジェクトをスライドリストから削除する
		 * @param	tgt
		 */
		public function removeSlide(tgt:*):void
		{
			var tgtContent:DisplayObject = tgt as DisplayObject;
			var tgtUrl:String = tgt as String;
			var tmpIndex:int = -1;
			
			if (tgtContent)
			{
				tmpIndex = GeneralFuncs.searchIndex(_contentlist, "content", tgtContent);
			}
			else if (tgtUrl)
			{
				tmpIndex = GeneralFuncs.searchIndex(_contentlist, "url", tgtUrl);
			}
			
			if (tmpIndex >= 0)
			{
				if (tmpIndex == _currentIndex)
				{
					_showContent(_currentIndex + 1);
				}
				
				tgtContent = _contentlist[tmpIndex].content;
				
				_autoFitArea.release(tgtContent);
				removeChild(tgtContent);
				_contentlist.splice(tmpIndex, 1);
			}
			
			_resetSlideshowPagingController();
		}
		
		//========================================================================
		
		private var _activeMarkerClass:Class = Marker_Active;
		private var _inactiveMarkerClass:Class = Marker_Inactive;
		private var _pagingControllerContainer:DisplayObjectContainer;
		private var _pagingControllerBox:Sprite;
		private var _pagingControllerAlign:String;
		private var _markerMargin:Number = 25;
		
		public function initSlideShowPagingController(pagingControllerContainer:DisplayObjectContainer, activeMarkerClass:Class = null, inactiveMarkerClass:Class = null, align:String = SLIDESHOWPAGINGCONTROLLERALIGN_LEFT, markerMargin:Number = 25 ):void
		{
			if (pagingControllerContainer as DisplayObjectContainer)
			{
				Debug.write("[MultiImageContainer] initSlideShowPagingController");
				_markerMargin = isNaN(markerMargin) ? _markerMargin : markerMargin;
				
				_pagingControllerContainer = pagingControllerContainer;
				_pagingControllerAlign = align;
				
				_activeMarkerClass = activeMarkerClass as Class ? activeMarkerClass : _activeMarkerClass;
				_inactiveMarkerClass = inactiveMarkerClass as Class ? inactiveMarkerClass : _inactiveMarkerClass;
				
				if (_pagingControllerBox == null)
				{
					_pagingControllerBox = new Sprite();
				}
				
				_pagingControllerContainer.addChild(_pagingControllerBox);
				
				_resetSlideshowPagingController();
			}
		}
		
		private function _resetSlideshowPagingController():void
		{
			if (_pagingControllerBox && _pagingControllerContainer)
			{
				//Debug.write("[MultiImageContainer] _resetSlideshowPagingController")
				
				var tmpLength:int = _contentlist.length
				
				GeneralFuncs.removeChildren(_pagingControllerBox);
				
				var tmpMarker:DisplayObject;
				
				//増減
				//表示切替
				for (var i:int = 0; i < tmpLength; i++) 
				{
					if (_currentIndex == i)
					{
						tmpMarker = new _activeMarkerClass() as DisplayObject;
					}
					else
					{
						tmpMarker = new _inactiveMarkerClass() as DisplayObject;
					}
					
					if (tmpMarker)
					{
						tmpMarker.x = i * _markerMargin;
						_pagingControllerBox.addChild(tmpMarker);
					}
					
				}
				
				//位置調整
				var tmpRect:Rectangle = _pagingControllerBox.getRect(_pagingControllerContainer);
				
				switch(_pagingControllerAlign)
				{
					case SLIDESHOWPAGINGCONTROLLERALIGN_CENTER:
						_pagingControllerBox.x = - tmpRect.width / 2;
						break;
					case SLIDESHOWPAGINGCONTROLLERALIGN_RIGHT:
						_pagingControllerBox.x = - tmpRect.width;
						break;
					case SLIDESHOWPAGINGCONTROLLERALIGN_LEFT:
					default:
						_pagingControllerBox.x = 0;
						break;
						
				}
			}
		}
		
		
		//========================================================================
		
		/**
		 * ローダーが読み込みを完了した際のリスナ
		 * @param	e
		 */
		protected function _loaderInfo_complete_listener(e:Event):void
		{
			//Debug.write("[MultiImageContainer] 画像読み込み完了 " + _contentLoaderInfo.url);
			
			var tmpListItem:ContentListItem;
			var tmpContent:DisplayObject = _loader.content as DisplayObject;
			
			try 
			{
				//ディスプレイオブジェクトに設置する
				addSlide(tmpContent, _contentLoaderInfo.url, new Date());
				
				var tmpContentType:String = _contentLoaderInfo.contentType;
				if (tmpContentType && tmpContentType.indexOf("flash") < 0)
				{	//読み込まれたデータがSWFではない場合（画像の可能性がある場合）
					var bmp:Bitmap = Bitmap(tmpContent) as Bitmap;
					
					if (bmp)
					{
						//スムーズ設定
						bmp.smoothing = true;
						bmp.pixelSnapping = PixelSnapping.NEVER;
					}
				}
				
				dispatchEvent(new MultiImageContainerEvent(MultiImageContainerEvent.LOAD_COMPLETE, false, false, tmpContent, _contentLoaderInfo.url));
				//_autoFitArea.attach(tmpContent, _autoFitAreaParams);
				//_autoFitArea.preview = preview;
			}catch (err:Error)
			{
				//ディプレイオブジェクトに置けないものだった
				//Debug.write("[MultiImageContainer] 読み込み画像にエラーを検出");
				dispatchEvent(new Event(MultiImageContainerEvent.LOAD_FAILED));
				//return;
			}
			
			
			_loadNextQueue();
		}
		
		protected function _loaderInfo_iOError_listener(e:IOErrorEvent):void
		{
			Debug.write("[MultiImageContainer] 画像読み込み失敗 " + _contentLoaderInfo.url);
			//dispatchEvent(new Event(MultiImageContainerEvent.LOAD_FAILED));
			dispatchEvent(new MultiImageContainerEvent(MultiImageContainerEvent.LOAD_FAILED));
			
			_loadNextQueue();
		}
		
		
		protected function _removedFromStage_listener(e:Event):void
		{
			_loader.unloadAndStop();
			
			removeEventListener(Event.REMOVED_FROM_STAGE, _removedFromStage_listener);
			if (_contentLoaderInfo)
			{
				_contentLoaderInfo.removeEventListener(Event.COMPLETE, _loaderInfo_complete_listener);
				_contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _loaderInfo_iOError_listener);
			}
			_slideShowTimer.stop();
			_slideShowTimer.removeEventListener(TimerEvent.TIMER, _slideShowTimer_listener);
			_slideShowTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, _slideShowComplete_listener);
			
			var tmpListLength:int = _contentlist.length;
			var tmpListItem:ContentListItem;
			var tmpParent:DisplayObjectContainer;
			for (var i:int = 0; i < tmpListLength; i++) 
			{
				tmpListItem = _contentlist[i];
				if (tmpListItem.content as DisplayObject)
				{
					tmpParent = tmpListItem.content.parent as DisplayObjectContainer;
					if (tmpParent)
					{
						tmpParent.removeChild(tmpListItem.content);
					}
				}
			}
			_contentlist = [];
		}
		
	}

}
import flash.display.DisplayObject;
import flash.display.Sprite;

class ContentListItem extends Object
{
	public var content:DisplayObject;
	public var url:String;
	public var cleateDate:Date;
	
	public function ContentListItem(content:DisplayObject, url:String = null, cleateDate:Date = null)
	{
		this.content = content;
		this.url = url;
		this.cleateDate = cleateDate;
	}
}

class Marker_Active extends Sprite
{
	public function Marker_Active()
	{
		init();
	}
	
	public function init(radius:Number = 5, color:Number = 0xFA8A00):void
	{
		graphics.beginFill(color);
		graphics.drawCircle(5,5,radius);
	}
}

class Marker_Inactive extends Sprite
{
	public function Marker_Inactive()
	{
		init();
	}
	
	public function init(radius:Number = 5, color:Number = 0x999999):void
	{
		graphics.beginFill(color);
		graphics.drawCircle(5,5,radius);
	}
}

