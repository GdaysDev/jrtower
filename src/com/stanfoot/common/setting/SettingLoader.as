package com.stanfoot.common.setting
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import com.stanfoot.common.*;
	import com.stanfoot.common.debug.Debug;
	
	/**
	 * 設定ファイルの読み込み処理をする
	 * @author STANFOOT INC.
	 */
	public class SettingLoader 
	{
		
		//XMLの読み込みに使用--------------------------------------------------------------
		
		/** @private XML読み込み用URLRequest */
		private var xmlFileURLRequest:URLRequest;
		
		/** @private XMLファイル読み込み用のURLLoader */
		private var xmlFileLoader:URLLoader;
		
		/** @private XML読み込み完了時のコールバック関数 callback(Boolean, XML)*/
		private var callbackFunc:Function;
		
		
		//設定パラメーター---------------------------------------------------------------------------------------
		
		/** @private 設定XML（setting.xml）のパス */
		private var xmlFilePath:String;
		/** @private 検証用の設定XML（setting.xml）のパス */
		private var xmlFilePath_forTest:String;
		
		private var paramsClass:Class;
		
		

		
		
		//メソッド======================================================================================
		
		/**
		 * コンストラクタ
		 */
		public function SettingLoader()
		{
			xmlFileLoader = new URLLoader();
		}
		
		/**
		 * 設定XMLファイルの読み込み開始
		 * 読み込みが完了するとコールバック関数に対して成否のBoolean値と取得XMLデータを渡します callback(Boolean, XML);
		 * @param	settingFilePath	設定XMLファイルパス
		 * @param	callback(Boolean, XML)	コールバック関数
		 * @param	settingFilePath_forTest	テスト用設定XMLファイルパス
		 */
		public function load(settingFilePath:String, callback:Function = null, settingFilePath_forTest:String = ""):void
		{
			xmlFilePath = settingFilePath;
			xmlFilePath_forTest = settingFilePath_forTest;
			
			if (callback == null)
			{	//コールバック関数が未定義の場合、ダミーの関数を用意
				callbackFunc = function(result:Boolean,loadedXml:XML = null) { };
			}
			else
			{
				callbackFunc = callback;
			}
			
			//最初に主設定XMLファイルを読み込む
			if (xmlFilePath_forTest != "")
			{
				Debug.write("[SettingLoader]検証用設定ファイルを読み込む" + xmlFilePath_forTest);
				loadXml(xmlFilePath_forTest);
			}
			else
			{
				Debug.write("[SettingLoader]本番用設定ファイルを読み込む" + xmlFilePath);
				loadXml(xmlFilePath);
			}
		}
		
		/**
		 * XMLファイルを読み込む
		 * @param	argXmlFilePath	読み込むURLパス
		 */
		private function loadXml(argXmlFilePath:String):void
		{
			var currentTimeStr:String = String(new Date().getTime());
			if (argXmlFilePath.indexOf("http") == 0)
			{
				if (argXmlFilePath.indexOf("?") >= 0)
				{
					argXmlFilePath += "&nowTime=" + currentTimeStr;
				}
				else
				{
					argXmlFilePath += "?nowTime=" + currentTimeStr;
				}
			}

			
			xmlFileURLRequest = new URLRequest(argXmlFilePath);
			
			xmlFileLoader.addEventListener(Event.COMPLETE, xmlFileLoader_complete_handler);
			xmlFileLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlFileLoader_error_handler);
			
			
			xmlFileLoader.load(xmlFileURLRequest);
		}
		
		
		/**********************************************************************
		 * XMLファイル読み込み完了時のハンドラ
		 * @param	e
		 */
		private function xmlFileLoader_complete_handler(e:Event):void
		{
			//XML読み込み用のイベントリスナをはずす
			xmlFileLoader.removeEventListener(Event.COMPLETE, xmlFileLoader_complete_handler);
			xmlFileLoader.removeEventListener(IOErrorEvent.IO_ERROR, xmlFileLoader_error_handler);
			
			//Debug.write("[SettingLoader] e:  " +e.type);
			var tmpXmlData:XML;
			
			//取得データをXML化する
			try 
			{
				tmpXmlData = new XML(xmlFileLoader.data);
			}
			catch (err:Error)
			{	//XMLに文法エラーがあった場合
				Debug.write("[Setting]//// ERROR //// setting.xmlの文法エラー");
				callbackFunc(false);
				return;
			}
			//Debug.write("[SettingLoader] url:  " +xmlFilePath);
			
			callbackFunc(true, tmpXmlData);
		}
		
		
		//======================================================================================
		
		/**********************************************************************
		 * XMLファイルの読み込み失敗時のハンドラ
		 * @param	e
		 */
		private function xmlFileLoader_error_handler(e:IOErrorEvent):void
		{
			xmlFileLoader.removeEventListener(Event.COMPLETE, xmlFileLoader_complete_handler);
			xmlFileLoader.removeEventListener(IOErrorEvent.IO_ERROR, xmlFileLoader_error_handler);
			
			Debug.write("[Setting]//// ERROR //// " + xmlFileURLRequest.url + "の読み込み失敗");
			
			switch(xmlFileURLRequest.url)
			{
				case xmlFilePath_forTest:
					//テスト用XMLが読み込めなかった場合
					xmlFilePath_forTest = "";
					//本番用を読み込む
					loadXml(xmlFilePath);
					break;
				default:
					callbackFunc(false);
					break;
			}
		}
		
	}

}