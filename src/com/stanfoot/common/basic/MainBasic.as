package com.stanfoot.common.basic 
{
	import com.stanfoot.common.basic.content.ContentUnit;
	import com.stanfoot.common.cache.CacheManager;
	import com.stanfoot.common.debug.Debug;
	import com.stanfoot.common.debug.DebugCounter;
	import com.stanfoot.common.imageContainer.ImageContainer;
	import com.stanfoot.common.setting.SettingEventType;
	import com.stanfoot.common.GeneralFuncs;
	import com.stanfoot.common.setting.SettingParams;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author 
	 */
	public class MainBasic extends MovieClip
	{
		
		//インスタンスメンバ==================================================================================
		
		//オブジェクト---------------------------------------------
		
		/** 設定情報管理クラス */
		protected var _setting:SettingParams;
		private var _settingCommonFlag:Boolean;
		
		
		/**データ管理クラスリスト*/
		private var _dataManagerList:/**/Array
		
		/** リセット用タイマー */
		protected var _resetTimer:Timer;
		
		/** デバッグ表示コンテナ */
		protected var _debugContainer:Sprite;
		
		/** 情報なしの告知MC */
		protected var _noItemNotice:MovieClip;
		/** ページコンテナ */
		protected var _pageContainer:MovieClip;
		
		//パラメーター---------------------------------------------
		/** 共通設定XMLファイルのパス（第一読み込み） */
		protected var filePath_settingCommonXml:String = "setting_common.xml";
		/** 固有設定XMLファイルのパス（第二読み込み）*/
		protected var filePath_settingXml:String = "setting.xml";
		
		/** 表示したスケジュールインデックス */
		protected var _scheduleIndex:int = -1;
		
		
		//メソッド---------------------------------------------
		
		/**
		 * コンストラクタ
		 */
		public function MainBasic() 
		{
			super();
			stop();
			
			//リセットタイマーの準備
			_resetTimer = new Timer(2 * 1000, 1);
			_resetTimer.addEventListener(TimerEvent.TIMER, _resetTimer_timer_listener);
			
			//エラー（情報なし）表示の準備----
			var noItemImg:ImageContainer = new ImageContainer(stage.stageWidth, stage.stageHeight);
			noItemImg.load("noItems.jpg");
			try 
			{
				var tmpClass:Class = getDefinitionByName("NoItemNotice") as Class;
				
				_noItemNotice = new tmpClass() as MovieClip;
			}
			catch (err:Error)
			{
				_noItemNotice = new MovieClip();
			}
			_noItemNotice.addChild(noItemImg);
			//addChild(_noItemNotice);
			_hideNoItemNotice();
		}
		
		/**
		 * 初期化　（設定ファイルを読み込む）
		 * 読み込まれた設定は、固有設定内容が優先されます。
		 * @param	settingClass	設定クラス
		 * @param	settingXmlFilePath	固有設定のXMLのパス
		 * @param	commonSettingXmlFilePath	共通設定のXMLのパス
		 */
		protected function init(settingClass:Class, settingXmlFilePath:String = "", commonSettingXmlFilePath:String = ""):void
		{
			if(settingXmlFilePath != "") filePath_settingCommonXml = commonSettingXmlFilePath;
			if(commonSettingXmlFilePath != "") filePath_settingXml = settingXmlFilePath;
			
			
			if(settingClass)
			{
				_setting = new settingClass() as SettingParams;
				
				//設定ファイルの読み込み
				if (_setting)
				{
					//第一設定ファイル（共通設定）の読み込み
					_loadCommonSetting();
				}
			}
		}
		
		//- - - - - - - - 
		
		/**
		 * 共通設定XMLを読み込む(設定の読み込み失敗時にはリロードしません)
		 */
		protected function _loadCommonSetting():void
		{
			_setting.addEventListener(SettingEventType.LOAD_COMPLETE, _commonSettingLoad_complete_listener);
			_setting.addEventListener(SettingEventType.LOAD_FAILED, _commonSettingLoad_failed_listener);
			_setting.removeEventListener(SettingEventType.LOAD_COMPLETE, _settingLoad_complete_listener);
			_setting.removeEventListener(SettingEventType.LOAD_FAILED, _settingLoad_failed_listener);
			
			var tmpUrl:String = GeneralFuncs.getSwfDirPath(stage);
			if (tmpUrl.indexOf("http") === 0)
			{
				tmpUrl += filePath_settingCommonXml + "?date=" + new Date().getTime();
			}
			else
			{
				tmpUrl = filePath_settingCommonXml
			}
			
			//第一設定ファイル（共通設定）の読み込み
			_setting.load(tmpUrl);
		}
		
		/**
		 * 共通設定XMLの読み込み完了時のハンドラ
		 * @param	result
		 */
		protected function _commonSettingLoad_complete_listener(e:Event):void
		{
			Debug.write("[Main] 共通設定XML読み込み完了\n");
			
			//暫定の固有設定ファイルパス
			var tmpSettingPathIndex:int = GeneralFuncs.searchIndex(_setting.pathList, "category", "setting");
			
			//共通設定に固有設定ファイルパスが指定されていた場合
			if (tmpSettingPathIndex > -1)
			{
				Debug.write("[Main] 固有設定XML ファイルパス指定有");
				filePath_settingXml = _setting.pathList[tmpSettingPathIndex].url;
			}
			
			_loadSetting();
		}
		
		/**
		 * 共通設定XMLの読み込み失敗時のリスナ
		 * @param	e
		 */
		protected function _commonSettingLoad_failed_listener(e:Event):void
		{
			Debug.write("[Main] 共通設定XML読み込み失敗\n");
			
			_loadSetting();
		}
		
		//- - - - - - - - 
		
		/**
		 * 固有設定を読み込む(設定の読み込み失敗時にはリロードしません)
		 */
		protected function _loadSetting():void
		{
			_setting.removeEventListener(SettingEventType.LOAD_COMPLETE, _commonSettingLoad_complete_listener);
			_setting.removeEventListener(SettingEventType.LOAD_FAILED, _commonSettingLoad_failed_listener);
			_setting.addEventListener(SettingEventType.LOAD_COMPLETE, _settingLoad_complete_listener);
			_setting.addEventListener(SettingEventType.LOAD_FAILED, _settingLoad_failed_listener);
			
			var tmpUrl:String = GeneralFuncs.getSwfDirPath(stage);
			if (tmpUrl.indexOf("http") === 0)
			{
				tmpUrl += filePath_settingXml + "?date=" + new Date().getTime();
			}
			else
			{
				tmpUrl = filePath_settingXml
			}
			
			//第二設定ファイル（固有設定）の読み込み
			_setting.load(tmpUrl);
		}
		
		/**
		 * 固有設定XMLの読み込み完了時のリスナ
		 * @param	result
		 */
		protected function _settingLoad_complete_listener(e:Event):void
		{
			Debug.write("[Main] 固有設定XML読み込み完了\n");
			
			_applySetting();
			_moveFrontCommonDisplayObject();
		}
		
		/**
		 * 固有設定XMLの読み込み失敗時のリスナ
		 * @param	e
		 */
		protected function _settingLoad_failed_listener(e:Event):void
		{
			Debug.write("[Main] 固有設定XML読み込み失敗\n");
			
			_applySetting();
			_moveFrontCommonDisplayObject();
		}
		
		//- - - - - - - - 
		
		/**
		 * 設定ファイルの反映
		 */
		protected function _applySetting():void
		{
			if (_setting == null) return;
			
			//デバッグモード
			if (_setting.debugMode)
			{
				_debugContainer = new Sprite();
				//addChild(debugContainer);
				Debug.init(_debugContainer, true, true, 1080, 1080);
				Debug.write("[Main] DEBUG MODE ON\n");
			}
			else
			{
				Debug.write("[Main] DEBUG MODE OFF\n");
			}
			
			//レンダリングクオリティ
			stage.quality = _setting.stageQuality;
		}
		
		/** 汎用表示オブジェクトを最前面に移動 */
		protected function _moveFrontCommonDisplayObject():void
		{
			if (_noItemNotice) addChild(_noItemNotice);
			if (_debugContainer) addChild(_debugContainer);
		}
		
		
		//= = = = = = = = = = = = = = = = = = = = = = = = = = = =
		
		/**
		 * 全てをリセットする。
		 * _pageContainerの子要素のリムーブ
		 */
		protected function _reset():void
		{
			Debug.write("\n[Main] リセットします。" );
			
			/*
			// 既存コンテンツを消す
			if(_pageContainer) GeneralFuncs.removeChildren(_pageContainer);
			
			
			//進捗パラメータ更新
			_scheduleIndex += 1;
			*/
			
		}
		/**
		 * リセットするためのタイマーをリスタートします。
		 */
		protected function _restartResetTimer():void
		{
			_resetTimer.reset();
			_resetTimer.start();
		}
		/** タイマーがきたらリセットする */
		protected function _resetTimer_timer_listener(e:TimerEvent):void
		{
			_reset();
		}
		
		
		//================================================================================
		
		/**
		 * 表示タイプを判別し、表示準備をする
		 */
		protected function _getReady():void
		{
			Debug.write("\n[Main] getReady" );
		}
		
		
		//================================================================================
		// データの取得
		//================================================================================
		
		
		//= = = = = = = = = = = = = = = = = = = = = = = = = = = =
		
		
		
		//================================================================================
		
		/**
		 * 情報なしの告知を表示する
		 */
		protected function _showNoItemNotice():void
		{
			if (_noItemNotice) _noItemNotice.visible = true;
		}
		
		/**
		 * 情報なしの告知を隠す
		 */
		protected function _hideNoItemNotice():void
		{
			if(_noItemNotice) _noItemNotice.visible = false;
		}
		
		
		//================================================================================
		
		
		/**
		 * 致命的なエラーが発生したとき
		 * @param	message
		 */
		public function criticalError(message:String = ""):void
		{
			Debug.write("[Main] //// ERROR ////\n" + message );
			_showNoItemNotice();
		}
	}
}
