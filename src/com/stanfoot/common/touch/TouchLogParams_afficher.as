package com.stanfoot.common.touch 
{
	/**
	 * ...
	 * @author ...
	 */
	public dynamic class TouchLogParams_afficher extends Object
	{
		public var contentsname:String;
		public var templateid:String;
		public var templatename:String;
		public var templatedataid:String;
		public var templatedataname:String;
		public var remark:String;
		
		public function TouchLogParams_afficher(contentsname:String = null,	templateid:String = null, templatename:String = null, templatedataid:String = null,		templatedataname:String = null,	remark:String = null)
		{
			this.contentsname = contentsname;
			this.templateid = templateid;
			this.templatename = templatename;
			this.templatedataid = templatedataid;
			this.templatedataname = templatedataname;
			this.remark = remark;
		}
		
	}

}