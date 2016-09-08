package com.stanfoot.common.debug
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * デバッグメッセージ表示クラス
	 * @author STANFOOT INC.
	 */
	public class Debug
	{
		private static var _container:DisplayObjectContainer;
		private static var containerMc:MovieClip;
		
		private static var activeFlag:Boolean = false;
		private static var traceEnable:Boolean = true;
		private static var mainTFld:TextField;
		private static var paramTFld:TextField;
		private static var paramList:Array;
		private static var defaultTFmt:TextFormat;
		
		private static var TFWidth:Number = 500;
		private static var TFHeight:Number = 750;
		
		private static var bgSprite:Sprite;
		
		private static var maxLineNum:int = 30;
		
		/**
		 * 初期化
		 * @param	container	//ログ表示のコンテナ
		 * @param	activateFlag	//デバッグ表示を有効にするかどうか
		 * @param	traceEnable	//traceにもログを流すかどうか
		 * @param	tFWidth	//ログ用のテキストフィールドの幅
		 * @param	tFHeight	//ログ用のテキストフィールドの高さ
		 */
		public static function init(container:DisplayObjectContainer, activateFlag:Boolean = false, traceEnable:Boolean = true, tFWidth:Number = 500, tFHeight:Number = 750 ):void
		{
			_container = container;
			_container.mouseEnabled = false;
			_container.mouseChildren = false;
			
			containerMc = new MovieClip();
			_container.addChild(containerMc);
			
			activeFlag = activateFlag;
			traceEnable = traceEnable;
			
			TFWidth = tFWidth;
			TFHeight = tFHeight;
			
			if (activeFlag)
			{
				//半透明背景
				bgSprite = new Sprite();
				bgSprite.graphics.beginFill(0xffffff);
				bgSprite.graphics.drawRect(0, 0, TFWidth, TFHeight);
				bgSprite.graphics.endFill();
				bgSprite.alpha = 0.7;
				containerMc.addChild(bgSprite);
				
				//メインのテキストフィールド
				mainTFld = new TextField();
				containerMc.addChild(mainTFld);
				
				//パラメーター監視用テキストフィールド
				paramTFld = new TextField();
				containerMc.addChild(paramTFld);
				
				//テキストフォーマット
				defaultTFmt = new TextFormat();
				defaultTFmt.color = 0x000000;
				defaultTFmt.font = "_ゴシック";
				//defaultTFmt.size = 14;
				
				
				
				
				//主表示テキストフィールドの設定
				mainTFld.width = TFWidth;
				//mainTFld.height = (Number(defaultTFmt.size) * maxLineNum);
				//trace("maxLineNum" + maxLineNum)
				maxLineNum = mainTFld.height / 12;
				mainTFld.height = TFHeight;
				mainTFld.defaultTextFormat = defaultTFmt;
				mainTFld.selectable = false;
				
				//パラメータ表示テキストフィールドの設定
				paramTFld.width = TFWidth;
				paramTFld.height = TFHeight;
				paramTFld.x = TFWidth;
				paramTFld.defaultTextFormat = defaultTFmt;
				paramTFld.selectable = false;
				
				paramList = [];
				
				containerMc.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			}
		}
		
		
		/**
		 * ログを表示する
		 * @param	logContent
		 */
		public static function write(logContent:*):void
		{
			var logString:String = "";
			if (activeFlag || traceEnable)
			{
				logString = String(logContent);
			}
			
			if(activeFlag)
			{
				mainTFld.appendText(logString + "\n");
				
				//maxLineNum行以上は表示しない
				if (mainTFld.numLines > maxLineNum)
				{	//メインのテキストフィールドの行数がmaxLineNumを超えた場合
					//trace("mainTFld.numLines " + mainTFld.numLines)
					for (var i:int = 0; mainTFld.numLines <= maxLineNum ; i )
					{	//メインのテキストフィールドの行数がmaxLineNum以下になるまで先頭行を削除する
						
						var endIndex:int = mainTFld.getLineLength(0);
						mainTFld.replaceText( 0, endIndex + 2, "");
						/*
						
						
							var endIndex:int = mainTFld.text.indexOf("\r" , 1);
							mainTFld.replaceText( 0 , endIndex , "");
						}
						*/
						
						
					}
					
					mainTFld.scrollV = mainTFld.maxScrollV;
				}
			}
			
			if (traceEnable)
			{
				trace(logString)
			}
		}
		
		
		/**
		 * 常にモニタリングしたいオブジェクトを登録する
		 * @param	argLabel ログ用の表示ラベル 
		 * @param	argObj モニタリング対象オブジェクト
		 * @param	paramName	モニタリング対象オブジェクトのパラメーター名
		 */
		public static function addParamsTracer(argLabel:String, argObj:Object = null, paramName:String = ""):void
		{
			if (activeFlag)
			{
				if (argObj != null)
				{
					paramList.push( { name:argLabel, obj: argObj, paramName:paramName } );
				}
			}
		}
		
		/**
		 * モニタリングの表示
		 * @param	argEvent
		 */
		private static function onEnterFrameHandler(argEvent:Event):void
		{
			var tmpStr:String = "";
			var paramListMax:uint = paramList.length;
			var tmpParam:Object;
			
			for (var i:int = 0; i < paramListMax; i++)
			{
				tmpParam = paramList[i];
				if (tmpParam.name == "_blank")
				{
					tmpStr += "\n";
				}
				else if ( tmpParam.obj is Function)
				{
					var tmpFunction:Function = tmpParam.obj;
					tmpStr += "FUNCTION\n" + String(tmpParam.name) + " : " + tmpFunction() + "\n";
				}
			}
			
			paramTFld.text = tmpStr;
		}
		
	}
	
}