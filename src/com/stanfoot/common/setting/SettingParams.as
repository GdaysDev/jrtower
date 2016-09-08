package com.stanfoot.common.setting 
{
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import com.stanfoot.common.*;
	import com.stanfoot.common.debug.Debug;
	
	/**
	 * セッティングのパラメーター格納クラス
	 * ※案件ごとに必要なパラメータは異なるため、extendsで派生クラスを作成し、拡張してください
	 * @author kobayashi
	 */
	public class SettingParams extends EventDispatcher
	{
		//クラスメンバ====================================================================
		
		//インスタンスメンバ====================================================================
		
		
		//パラメーター-------------------------------------------------------------
		
		/** デバッグモードのフラグ */
		protected var _debugMode:Boolean;
		/** デバッグモードのフラグの参照 */
		public function get debugMode():Boolean
		{	return _debugMode;	};
		
		/** レンダリングクオリティ設定 */
		protected var _stageQuality:String = StageQuality.HIGH;
		/** レンダリングクオリティ設定の参照 */
		public function get stageQuality():String
		{	return _stageQuality;	};
		
		protected var _pathList:/*PathListFormat*/Array = [];
		public function get pathList():/*PathListFormat*/Array
		{	return _pathList;	};
		
		/** 読み込まれた設定XML */
		protected var _xml:XML;
		/** 読み込まれた設定XMLの参照 */
		public function get xml():XML
		{	return _xml;	};

		//XMLの読み込みに使用--------------------------------------------------------------
		
		/** @private XML読み込み用URLRequest */
		private var xmlFileURLRequest:URLRequest;
		
		/** @private XMLファイル読み込み用のURLLoader */
		private var xmlFileLoader:URLLoader;
		
		
		//設定パラメーター---------------------------------------------------------------------------------------
		
		/** @private 設定XML（setting.xml）のパス */
		private var xmlFilePath:String;
		
		/** @private 検証用の設定XML（setting.xml）のパス */
		private var xmlFilePath_forTest:String;
		
		
		
		
		//メソッド-------------------------------------------------------------
		/**
		 * コンストラクタ
		 */
		public function SettingParams()
		{
			xmlFileLoader = new URLLoader();
		}
		
		/**
		 * 引数のパスのXMLを設定ファイルとして読み込む。
		 * 読み込みとXMLのパース処理が完了すると SettingEventType.LOAD_COMPLETE タイプのイベントを送出します。
		 * 読み込みまたはパース処理に失敗した場合、SettingEventType.LOAD_FAILED タイプのイベントを送出します。
		 * @param	settingFilePath	設定XMLファイルパス
		 * @param	settingFilePath_forTest	テスト用設定XMLファイルパス
		 */
		public function load(settingFilePath:String, settingFilePath_forTest:String = ""):void
		{
			xmlFilePath = settingFilePath;
			xmlFilePath_forTest = settingFilePath_forTest;
			
			//最初に主設定XMLファイルを読み込む
			if (xmlFilePath_forTest != "")
			{
				Debug.write("[SettingParams] 検証用設定ファイルを読み込む" + xmlFilePath_forTest);
				loadXml(xmlFilePath_forTest);
			}
			else
			{
				Debug.write("[SettingParams] 本番用設定ファイルを読み込む" + xmlFilePath);
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
			
			//Debug.write("[SettingParams] e:  " +e.type);
			var tmpXmlData:XML;
			
			//取得データをXML化する
			try 
			{
				tmpXmlData = new XML(xmlFileLoader.data);
			}
			catch (err:Error)
			{	//XMLに文法エラーがあった場合
				Debug.write("[SettingParams] //// ERROR //// setting.xmlの文法エラー");
				loading_complete_handler(false);
				return;
			}
			//Debug.write("[SettingParams] url:  " +xmlFilePath);
			loading_complete_handler(true, tmpXmlData);
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
			
			Debug.write("[SettingParams] //// ERROR //// " + xmlFileURLRequest.url + "の読み込み失敗");
			
			switch(xmlFileURLRequest.url)
			{
				case xmlFilePath_forTest:
					//テスト用XMLが読み込めなかった場合
					xmlFilePath_forTest = "";
					//本番用を読み込む
					loadXml(xmlFilePath);
					break;
				default:
					loading_complete_handler(false);
					break;
			}
		}
		
		//======================================================================================
		
		/**
		 * 読み込み完了の際のハンドラ
		 * @param	result
		 * @param	loadedXml
		 */
		protected function loading_complete_handler(result:Boolean, loadedXml:XML = null):void
		{
			_xml = loadedXml;
			Debug.write("[SettingParams] 設定XMLを読みの成否：" + result);
			if (result || loadedXml != null)
			{
				//読み込みに成功した場合
				//XMLをパースする
				parseXmlData(loadedXml);
			}
			else
			{
				dispatchEvent_failed();
			}
		}
		
		
		/**
		 * 引数のXMLをパースし、設定情報を抽出し格納する。
		 * パース処理が完了すると SettingEventType.LOAD_COMPLETE タイプのイベントを送出します。
		 * パース処理に失敗した場合、SettingEventType.LOAD_FAILED タイプのイベントを送出します。
		 * 成否はBooleanで返される。
		 * ※基本的にはこの関数をoverrideして活用してください。その際、パースに失敗した場合loadedXmlDataにｎｕｌｌを渡してください
		 * ※overrideの際はsuperで呼び出す必要はありません
		 * @param	loadedXml
		 * @return	パース処理に失敗したかどうか
		 */
		protected function parseXmlData(loadedXmlData:XML = null):Boolean
		{
			/** パース処理に失敗したかどうか */
			var result:Boolean;
			
			var tmpStr:String;
			
			if (loadedXmlData != null)
			{
				
				//パスリストの取得
				if (loadedXmlData.pathList[0] && loadedXmlData.pathList[0].path[0])
				{
					var tmpXml:XML;
					var tmpList:XMLList = loadedXmlData.pathList[0].path;
					var tmpLenght:int = tmpList.length();
					var tmpPathFmt:PathListFormat;
					
					var tmpType:String;
					var tmpCategory:String;
					var tmpUrl:String;
					
					var tmpSameCategoryIndex:int;
					
					for (var i:int = 0; i < tmpLenght; i++) 
					{
						tmpXml = tmpList[i];
						
						
						
						tmpUrl 		= tmpXml.toString();
						tmpType 	= tmpXml.hasOwnProperty("@type") ? tmpXml.@type : "";
						tmpCategory = tmpXml.hasOwnProperty("@category") ? tmpXml.@category : "";
						
						if (tmpUrl != ""/* && tmpType != ""*/)
						{
							tmpPathFmt = new PathListFormat(tmpUrl, tmpType, tmpCategory);
							
							//同じカテゴリがすでに登録されていた場合は上書きする
							tmpSameCategoryIndex = GeneralFuncs.searchIndex(_pathList, "category", tmpCategory);
							if (tmpSameCategoryIndex > -1)
							{
								_pathList[tmpSameCategoryIndex] = tmpPathFmt;
							}
							else
							{
								_pathList.push(tmpPathFmt);
								
							}
						}
					}
					
				}
				
				
				//デバッグモード
				_debugMode 	= loadedXmlData.debugMode[0] ? loadedXmlData.debugMode[0].toString() == "YES" : _debugMode;
				
				//レンダリングクオリティ
				tmpStr 	= loadedXmlData.quality[0]  ? loadedXmlData.quality[0].toString() : _stageQuality;
				switch(tmpStr)
				{
					case StageQuality.BEST :
					case StageQuality.HIGH :
					case StageQuality.MEDIUM :
					case StageQuality.LOW :
						break;
					default:
						tmpStr = _stageQuality;
				}
				_stageQuality = tmpStr;
				
				
				result = true;
				
			}
			else
			{
				result = false;
				
			}
			
			//まとめ
			Debug.write("[SettingParams] 設定XMLをパース処理の成否：" + result);
			if (result)
			{
				//完了を通達
				dispatchEvent_complete();
			}else
			{
				//失敗を通達
				dispatchEvent_failed();
			}
			
			return result;
		}
		
		/**
		 * CMS XMLの読み込み処理とパース処理が完了したとみなし、SettingEventType.LOAD_COMPLETE タイプのイベントを送出する。
		 */
		protected function dispatchEvent_complete():void
		{
			dispatchEvent(new Event(SettingEventType.LOAD_COMPLETE));
		}
		
		/**
		 * CMS XMLの読み込み処理またはパース処理が失敗したとみ無し、SettingEventType.LOAD_FAILED タイプのイベントを送出する。
		 */
		protected function dispatchEvent_failed():void
		{
			dispatchEvent(new Event(SettingEventType.LOAD_FAILED));
		}
		
		/**
		 * 既存のパラメーターをセットする
		 * @param	paramName	セットするパラメーター名
		 * @param	paramValue	セットするの値
		 */
		public function setParam(paramName:String, paramValue:*):void
		{
			try
			{
				this[paramName] = paramValue;
			}
			catch (err:Error)
			{
				Debug.write("[SettingParams] setParam エラーを検出しました : " + paramName);
			}
		}
		
		/**
		 * パスリストから指定インデックスまたは指定カテゴリに該当するURLを1件返す
		 * @param	indexOrCategory
		 * @return
		 */
		public function getPath(indexOrCategory:*):String
		{
			var result:String;
			var tmpPathFmt:PathListFormat;
			var tmpLength:int = _pathList.length;
			
			if (indexOrCategory as int)
			{
				for (var i:int = 0; i < tmpLength; i++) 
				{
					tmpPathFmt = _pathList[i];
					
					if (i == indexOrCategory)
					{
						result = tmpPathFmt.url;
						break;
					}
				}
			}
			else if (indexOrCategory as String)
			{
				for (var j:int = 0; j < tmpLength; j++) 
				{
					tmpPathFmt = _pathList[j];
					
					if (tmpPathFmt.category == indexOrCategory)
					{
						result = tmpPathFmt.url;
						break;
					}
				}
			}
			return result;
		}
		
	}

}