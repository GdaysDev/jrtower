package com.stanfoot.common.text 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.engine.CFFHinting;
	import flash.text.engine.FontLookup;
	import flash.text.engine.RenderingMode;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextLine;
	import flash.text.Font;
	import flash.text.engine.BreakOpportunity;

	/**
	 * http://help.adobe.com/ja_JP/as3/dev/WS9dd7ed846a005b294b857bfa122bd808ea6-7ffa.html
	 * @author ...
	 */
	public class TextContainer extends MovieClip
	{
		public static const ALIGN_LEFT:String = "left";
		public static const ALIGN_CENTER:String = "center";
		public static const ALIGN_RIGHT:String = "right";
		
		public static const BREAKOPPOTUNITY_ALL:String = BreakOpportunity.ALL;
		public static const BREAKOPPOTUNITY_ANY:String = BreakOpportunity.ANY;
		public static const BREAKOPPOTUNITY_AUTO:String = BreakOpportunity.AUTO;
		public static const BREAKOPPOTUNITY_NONE:String = BreakOpportunity.NONE;
		
		private var _textBlock:TextBlock;
		
		protected var _container:Sprite;
		
		protected var _tlList:Array = [];
		
		protected var _text:String = "";
		public function get text():String
		{
			return _text;
		}
		
		public function get numLines():int
		{
			return _tlList.length;
		}
		
		//===============================================
		
		/**
		 * コンストラクタ
		 */
		public function TextContainer() 
		{
			_container = new Sprite();
			addChild(_container);
			
			_textBlock = new TextBlock();
		}
		
		/**
		 * 
		 * @param	str
		 * @param	width
		 * @param	fontName
		 * @param	fontSize
		 * @param	color
		 * @param	leading
		 * @param	maxLine
		 * @param	narrow
		 * @param	align
		 * @param	breakOpportunity
		 */
		public function setText(str:String, width:Number = TextLine.MAX_LINE_WIDTH, fontName:String = null, fontSize:Number = 20, color:uint = 0x000000, leading:Number = 0, maxLine:uint = 0, narrow:Number = 1, align:String = ALIGN_LEFT, breakOpportunity:String = BREAKOPPOTUNITY_AUTO ):void
		{
			
			if (fontName == null || fontName == "")
			{
				fontName = "_sans";
			}
			
			/** 長体処理を踏まえた仮想テキスト幅 */
			var tmpSetWidth:Number = width;
			
			var te:TextElement;
			var elmntFmt:ElementFormat;
			var fd:FontDescription = new FontDescription();
			//var str:String;
			
			var tmpTl:TextLine;
			var tmpTlWidth:Number;
			
			
			//長体の準備
			if (0< narrow && narrow < 1)
			{
				tmpSetWidth = width / narrow;
			}
			//テキストの幅には仕様上上限があるため、上限を適応する
			if (tmpSetWidth > TextLine.MAX_LINE_WIDTH)
			{
				tmpSetWidth = TextLine.MAX_LINE_WIDTH;
			}
			
			
			
			fd.fontLookup = FontLookup.EMBEDDED_CFF;
			fd.fontName = fontName;
			fd.renderingMode = RenderingMode.NORMAL;
			fd.cffHinting = CFFHinting.HORIZONTAL_STEM;
			
			elmntFmt = new ElementFormat(fd);
			elmntFmt.fontSize = fontSize;
			elmntFmt.color = color;
			//elmntFmt.breakOpportunity = flash.text.engine.BreakOpportunity.AUTO;
			elmntFmt.breakOpportunity = breakOpportunity;
			
			clear();
			
			if (str == null || str == "")
			{
				clear();
				return;
			}
			
			_text = str;
			
			te = new TextElement(str,elmntFmt);
			_textBlock.content = te;
			//_textBlock.

			tmpTl = _textBlock.createTextLine(null, tmpSetWidth);

			var n:uint = 0;
			var tmpScaleX:Number = 1;
			var tmpRect:Rectangle;
			while(tmpTl != null)
			{
				_container.addChild(tmpTl);
				
				_tlList.push(tmpTl);
				
				tmpTl.y = (fontSize +leading ) * n;
				//長体処理
				if (0< narrow && narrow < 1)
				{
					tmpTlWidth = tmpTl.width;
					if (width < tmpTlWidth)
					{
						//指定幅より大きいので長体が必要な場合
						tmpScaleX = width / tmpTlWidth;
						if (tmpScaleX < narrow)
						{
							tmpScaleX = narrow
						}
						tmpTl.scaleX = tmpScaleX;
					}
				}
				
				switch(align)
				{
					case ALIGN_CENTER:
						tmpRect = tmpTl.getRect(_container);
						tmpTl.x = - tmpRect.width / 2
						break;
					case ALIGN_RIGHT:
						tmpRect = tmpTl.getRect(_container);
						tmpTl.x = - tmpRect.right;
						break;
					case ALIGN_LEFT:
					default:
						break;
				}
				
				n++;
				
				if (maxLine == n)
				{
					break;
				}
				else
				{
					tmpTl = _textBlock.createTextLine(tmpTl,tmpSetWidth);
				}
			}
			
		}
		
		private function _setText(str:String, width:Number = TextLine.MAX_LINE_WIDTH, fontName:String = null, fontSize:Number = 20, color:uint = 0x000000, leading:Number = 0, maxLine:uint = 0, narrow:Number = 1, align:String = ALIGN_LEFT, breakOpportunity:String = BREAKOPPOTUNITY_AUTO ):void
		{
			
		}
		
		public function clear():void
		{
			var tmpLength:int = _tlList.length;
			var tmpFirstTl:TextLine;
			var tmpTl:TextLine;
			
			for (var i:int = 0; i < tmpLength; i++) 
			{
				tmpTl = _tlList[i] as TextLine;
				if (i == 0)
				{
					tmpFirstTl = tmpTl;
				}
				
				if (tmpTl && tmpTl.parent)
				{
					tmpTl.parent.removeChild(tmpTl);
				}
			}
			
			if (tmpFirstTl)
			{
				_textBlock.releaseLines(tmpFirstTl, tmpTl);
			}
			_tlList = [];
			_text = "";
		}
		
		public function resetFontSize(fontSize:Number):void
		{
			
		}
	}

}