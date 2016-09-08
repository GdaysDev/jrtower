package com.stanfoot.common.imageContainer 
{
	import com.greensock.TweenNano;
	import com.stanfoot.common.GeneralFuncs;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import com.greensock.layout.*;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;
	import com.stanfoot.common.debug.Debug;
	
	/**
	 * ...
	 * @author kobayashi
	 */
	public class ImageContainer extends MovieClip
	{
		/**
		 * sourceImaegeContainer のコンテンツ内容を targetImageContainer へクローンする
		 * @param	targetImageContainer
		 * @param	sourceImaegeContainer
		 */
		public static function cloneContent(targetImageContainer:ImageContainer, sourceImaegeContainer:ImageContainer):void
		{
			var tmpContent:DisplayObject;
			var tmpBmp:Bitmap;
			var sourceBmpData:BitmapData;
			var tmpRect:Rectangle;
			var tmpPoint:Point;
			var tmpBmpData:BitmapData;
			
			tmpContent = sourceImaegeContainer.content as DisplayObject;
			if (tmpContent)
			{
				tmpBmp = tmpContent as Bitmap;
				if (tmpBmp)
				{
					//ソースがビットマップだった場合
					sourceBmpData = tmpBmp.bitmapData;
					tmpBmpData = new BitmapData(sourceBmpData.width, sourceBmpData.height);
					tmpRect = new Rectangle(0, 0, sourceBmpData.width, sourceBmpData.height);
					tmpPoint = new Point();
					
					tmpBmpData.copyPixels(sourceBmpData,tmpRect,tmpPoint);
					
					targetImageContainer.setContent(new Bitmap(tmpBmpData,"auto", true));
				}
			}
		}
		
		
		//ディスプレイオブジェクト---------------------------------------------
		protected var _loader:Loader;
		
		/** Loaderインスタンスの参照 */
		public function get loader():Loader
		{	return _loader; }
		
		/** 表示コンテンツの参照 */
		public function get content():DisplayObject
		{	return _content;	}
		protected var _content:DisplayObject;
		
		protected var _background:Sprite;
		
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
		
		public function get areaWidth():Number
		{
			return _autoFitArea.width;
		}
		public function set areaWidth(value:Number):void
		{
			_autoFitArea.width = value;
			
			//_background.scaleX = _autoFitArea.width / 100;
			var tmpThickness = _bgThickness ? _bgThickness : 0 ;
			_background.scaleX = (value + tmpThickness) / 100;
			_background.x = _autoFitArea.x - (tmpThickness / 2);
		}
		public function get areaHeight():Number
		{
			return _autoFitArea.height;
		}
		public function set areaHeight(value:Number):void
		{
			_autoFitArea.height = value;
			
			//_background.scaleY = _autoFitArea.height / 100;
			var tmpThickness = _bgThickness ? _bgThickness : 0 ;
			_background.scaleY = (value + tmpThickness) / 100;
			_background.y = _autoFitArea.y - (tmpThickness / 2);
		}
		
		protected var _baseUrl:String;
		/** loadメソッド呼び出しの際に渡されたURL文字列の参照 */
		public function get baseUrl():String
		{	return _baseUrl;	}
		
		public var preview:Boolean;
		
		private var _bgColor:int = -1;
		private var _bgAlpha:Number = 1;
		
		private var _bgThickness:Number = NaN;
		private var _bgBorderColor:int = 0;
		private var _bgBorderAlpha:Number = 1;
		
		/**
		 * フェードに要する秒数
		 */
		public var fadeDuration:Number = 0;
		
		//メソッド---------------------------------------------
		/**
		 * コンストラクタ
		 * @param	areaWidth	表示領域の幅
		 * @param	areaHeight	表示領域の高さ
		 * @param	autoFitAreaParams	画像読み込み後の自動リサイズの設定値（greensockのAutoFitAreaを参照）
		 */
		public function ImageContainer(areaWidth:Number = 100, areaHeight:Number = 100, autoFitAreaParams:Object = null) 
		{
			_background = new Sprite();
			addChildAt(_background, 0);
			
			_autoFitArea = new AutoFitArea(this);
			init(areaWidth, areaHeight, autoFitAreaParams);
			_loader = new Loader();
			
			
			_contentLoaderInfo = _loader.contentLoaderInfo;
			_contentLoaderInfo.addEventListener(Event.COMPLETE, loaderInfo_complete_handler);
			_contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderInfo_iOError_handler);
			_urlRequest = new URLRequest();
			
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage_handler);
		}
		
		/**
		 * 初期化
		 * @param	areaWidth
		 * @param	areaHeight
		 * @param	autoFitAreaParams	画像読み込み後の自動リサイズの設定値（greensockのAutoFitAreaを参照）
		 */
		public function init(areaWidth:Number, areaHeight:Number, autoFitAreaParams:Object = null):void
		{
			//Debug.write("[ImageContainer] init " + areaWidth + "," + areaHeight);
			_autoFitAreaParams = autoFitAreaParams;
			
			this.areaWidth = areaWidth;
			this.areaHeight = areaHeight;
			
			setBackground(_bgColor, _bgAlpha, _bgThickness, _bgBorderColor, _bgBorderAlpha);
		}
		
		/**
		 * 画像の読み込み開始
		 * 全てが正常に完了した場合、イベント（タイプ値：ImageContainerEventType.LOAD_COMPLETE）を送出します。
		 * 読み込みに失敗した場合、イベント（タイプ値：ImageContainerEventType.LOAD_FAILED）を送出します。
		 * @param	url
		 * @param	noCacheQuery	キャッシュしないためにクエリを付加するかどうか
		 */
		public function load(url:String, noCacheQuery:Boolean = true, applicationDomain:ApplicationDomain = null, securityDomain:SecurityDomain = null ):void
		{
			_baseUrl = url;
			trace("start load from url=", url);
			clear();
			
			if (url.indexOf("http") == 0 && noCacheQuery)
			{	//httpで読み込む場合
				if (url.indexOf("?") >= 0)
				{	//すでに何かしらクエリ値がすでにある場合
					if (url.indexOf("noCache") < 0)
					{	//クエリ値にまだnoCacheがない場合 noCacheを付加する
						url += "&noCache=" + new Date().time;
					}
					else
					{	//クエリ値にnoCacheがある場合 noCacheの値を書き換える
						var tmpStrArray:Array = url.split("noCache=");
						tmpStrArray = String(tmpStrArray[1]).split("&");
						var tmpNoCacheValue:String = tmpStrArray[0];
						url = GeneralFuncs.xReplace(url, tmpNoCacheValue, String(new Date().time));
					}
				}
				else
				{	//クエリ値が何もない場合 noCacheを付加する
					url += "?noCache=" + new Date().time;
				}
			}
			
			_urlRequest.url = url;
			if (url && url != "")
			{
				//Debug.write("[ImageContainer] 画像読み込み開始 " + url);
				//_loader.load(_urlRequest);
				
				_loader.load(_urlRequest, new LoaderContext(false, applicationDomain, securityDomain));
			}
			else
			{
				//Debug.write("[ImageContainer] URLが未指定です");
				dispatchEvent(new Event(ImageContainerEventType.LOAD_FAILED));
			}
		}
		
		public function loadBytes(bytes:ByteArray, context:LoaderContext = null):void
		{
			_loader.loadBytes(bytes, context);
		}
		
		public function close():void
		{
			_loader.close();
		}
		
		public function clear():void
		{
			if (_content)
			{
				if (contains(_content))
				{
					removeChild(_content);
					_autoFitArea.release(_content);
				}
			}
		}
		
		/**
		 * ローダーが読み込みを完了した際のハンドラ
		 * @param	e
		 */
		protected function loaderInfo_complete_handler(e:Event):void
		{
			Debug.write("[ImageContainer] 画像読み込み完了 " + _contentLoaderInfo.url);
			trace("[ImageContainer] img load completed " + _contentLoaderInfo.url);
			
			var tmpContent:DisplayObject = _loader.content as DisplayObject;
			
			if (tmpContent)
			{
				setContent(tmpContent);
				_loader.visible = true;
			}
			dispatchEvent(new Event(ImageContainerEventType.LOAD_COMPLETE));
		}
		
		public function setContent(sourceContent:DisplayObject):void
		{
			var tmpContent:DisplayObject = sourceContent;
			
			//既に表示コンテンツがある場合は消去する
			clear();
			
			if (tmpContent)
			{
				_content = tmpContent;
				
				var tmpContentType:String = _contentLoaderInfo.contentType;
				Debug.write("[ImageContainer] contentType:" + tmpContentType);
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
				
				if (fadeDuration > 0 )
				{
					tmpContent.alpha = 0;
					TweenNano.to(tmpContent, fadeDuration, { alpha:1 } );
				}
				else
				{
					tmpContent.alpha = 1;
				}
			
				addChild(_content);
				_autoFitArea.attach(_content, _autoFitAreaParams);
				_autoFitArea.preview = preview;
				
			}
		}
		
		protected function loaderInfo_iOError_handler(e:IOErrorEvent):void
		{
			Debug.write("[ImageContainer] img load fail " + _contentLoaderInfo.url +" "+ e);
			dispatchEvent(new Event(ImageContainerEventType.LOAD_FAILED));
		}
		
		
		protected function removedFromStage_handler(e:Event):void
		{
			_loader.unloadAndStop();
			removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage_handler);
			if (_contentLoaderInfo)
			{
				_contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderInfo_complete_handler);
				_contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loaderInfo_iOError_handler);
			}
		}
		
		
		/**
		 * フィットエリア用の背景を指定する
		 * @param	color
		 * @param	alpha
		 */
		public function setBackground(color:int, alpha:Number = 1, thickness:Number = NaN, borderColor:int = 0, borderAlpha:Number = 1):void
		{
			_bgColor = color;
			_bgAlpha = alpha;
			_bgThickness = thickness;
			_bgBorderColor = borderColor;
			_bgBorderAlpha = borderAlpha;
			
			if (_background && _autoFitArea)
			{
				if (_bgColor < 0 && (isNaN(thickness) || thickness < 0 || borderColor < 0))
				{
					//背景色と、背景用枠線設定が無い場合は、クリアする
					_background.graphics.clear();
				}
				else
				{
					var tmpBgColor:uint = 0;
					if (_bgColor >= 0) tmpBgColor = _bgColor;
					
					_background.graphics.clear();
					
					_background.graphics.lineStyle(_bgThickness, _bgBorderColor, _bgBorderAlpha, false, LineScaleMode.NONE, null, JointStyle.MITER);
					_background.graphics.beginFill(tmpBgColor, _bgAlpha);
					_background.graphics.drawRect(_autoFitArea.x, _autoFitArea.y, 100, 100);
					_background.graphics.endFill();
				}
			}
			
			//_backgroundの変形を反映
			areaWidth = areaWidth;
			areaHeight = areaHeight;
		}
		

	}

}