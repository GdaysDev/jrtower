package com.stanfoot.common.setting 
{
	/**
	 * ...
	 * @author 
	 */
	public class PathListFormat extends Object 
	{
		//クラスメンバ====================================================================
		
		
		//インスタンスメンバ================================================================
		
		
		/** URL */
		public var url:String = "";
		/** ファイルタイプ */
		public var type:String = "";
		/** カテゴリー */
		public var category:String = "";
		
		/**
		 * コンストラクタ
		 * @param	url
		 * @param	type
		 * @param	category
		 */
		public function PathListFormat(url:String, type:String, category:String= "" ) 
		{
			super();
			
			this.url = url;
			this.type = type;
			this.category = category;
		}
		
	}

}