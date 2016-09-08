package com.stanfoot.common.touch 
{
	import com.stanfoot.common.GeneralFuncs;
	import flash.net.URLVariables;
	
	/**
	 * タッチログ
	 * @author ...
	 */
	public class TouchLog 
	{
		/** 詳細画面を直接リストから開いた */
		public static const DETAILPANELSHOWFLG_DIRECT:String = "direct";
		/** 詳細画面をリストから開いた */
		public static const DETAILPANELSHOWFLG_LIST:String = "fromList";
		
		/**
		 * コンストラクタ
		 */
		public function TouchLog()
		{
			
		}
		
		/**
		 * タッチログを残す
		 * @param	argPageName
		 */
		public function trackPageview(paramsObj:Object):void
		{
			
		}
		
		/**
		 * 引数の文字列に必要な情報を追記してログ出力用の文字列を生成する
		 * @param	argStr
		 * @param	formatArgStr	引数の文字列に記号変換処理をするかどうか
		 * @return
		 */
		protected function _makeLogStr(argStr:String, formatArgStr:Boolean = false):String
		{
			var result:String = "";
			
			
			return result;
		}
		protected function _makeURLVariables(paramsObj:Object = null):URLVariables
		{
			var result:URLVariables = new URLVariables();
			
			return result;
		}
		
		/**
		 * ログ掲載に問題のありそうな半角記号を全角に変換する
		 * @param	nameStr
		 * @return
		 */
		protected function _nameStrFormat(nameStr:String):String
		{
			if (nameStr != "")
			{
				//タッチログ
				//Debug.write("■■■■ " + tmpDataList[0].id + tmpDataList[0].name.getString(0));
				//タッチログ用に「/」を置換
				nameStr = GeneralFuncs.xReplace(nameStr, "\"" , "”");
				nameStr = GeneralFuncs.xReplace(nameStr, "#" , "＃");
				nameStr = GeneralFuncs.xReplace(nameStr, "$" , "＄");
				nameStr = GeneralFuncs.xReplace(nameStr, "%" , "％");
				nameStr = GeneralFuncs.xReplace(nameStr, "&" , "＆");
				nameStr = GeneralFuncs.xReplace(nameStr, "+" , "＋");
				nameStr = GeneralFuncs.xReplace(nameStr, "," , "，");
				nameStr = GeneralFuncs.xReplace(nameStr, "/" , "／");
				nameStr = GeneralFuncs.xReplace(nameStr, ":" , "：");
				nameStr = GeneralFuncs.xReplace(nameStr, ";" , "；");
				nameStr = GeneralFuncs.xReplace(nameStr, "<" , "＜");
				nameStr = GeneralFuncs.xReplace(nameStr, "=" , "＝");
				nameStr = GeneralFuncs.xReplace(nameStr, ">" , "＞");
				nameStr = GeneralFuncs.xReplace(nameStr, "?" , "？");
				nameStr = GeneralFuncs.xReplace(nameStr, "@" , "＠");
				nameStr = GeneralFuncs.xReplace(nameStr, "[/" , "［");
				nameStr = GeneralFuncs.xReplace(nameStr, "\\" , "￥");
				nameStr = GeneralFuncs.xReplace(nameStr, "]" , "］");
				nameStr = GeneralFuncs.xReplace(nameStr, "^" , "＾");
				nameStr = GeneralFuncs.xReplace(nameStr, "\'" , "’");
				nameStr = GeneralFuncs.xReplace(nameStr, "{" , "｛");
				nameStr = GeneralFuncs.xReplace(nameStr, "|" , "｜");
				nameStr = GeneralFuncs.xReplace(nameStr, "}" , "｝");
				
			}
			return nameStr
		}
		
	}

}