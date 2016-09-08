package com.stanfoot.common.debug 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author 
	 */
	public class DebugCounter extends Sprite
	{
		private var _textF1:TextField;
		private var _textF2:TextField;
		private var _startTime:Number = new Date().getTime();
		private var _startFlag:Boolean;
		private var _countDownSec:int = 10;
		
		public function DebugCounter() 
		{
			_textF1 = new TextField();
			_textF1.x = 0;
			_textF1.y = 0;
			_textF1.height = 80;
			_textF1.width = 150;
			_textF1.border = true;
			addChild(_textF1);
			
			_textF2 = new TextField();
			_textF2.x = 0;
			_textF2.y = 100;
			_textF2.height = 80;
			_textF2.width = 150;
			_textF2.border = true;
			addChild(_textF2);
			
			init();
			addEventListener(Event.ENTER_FRAME, enterFrame_listener);
		}
		
		
		public function init(countDownSec:int= 10, fontSize:Number = 60, color:int = 0xff0000):void
		{
			_countDownSec = countDownSec;
			_setTextFormat(fontSize, color);
		}
		
		
		private function _setTextFormat(fontSize:Number = 60, color:int = 0xff0000):void
		{
			var tmpTFormat:TextFormat = new TextFormat();
			tmpTFormat.align = TextFormatAlign.RIGHT;
			tmpTFormat.bold = true;
			tmpTFormat.size = fontSize;
			tmpTFormat.color = color;
			
			
			_textF1.setTextFormat(tmpTFormat);
			_textF1.defaultTextFormat = tmpTFormat;
			_textF2.setTextFormat(tmpTFormat);
			_textF2.defaultTextFormat = tmpTFormat;
		}
		
		public function start():void
		{
			_startTime = new Date().getTime();
			_startFlag = true;
			
			_textF2.text = String(_countDownSec);
		}
		
		private function enterFrame_listener(e:Event):void
		{
			if (_startFlag)
			{
				var currentTime:Number = new Date().getTime();
				var elapsedSec:Number = ((currentTime - _startTime) / 1000) | 0;
				_textF1.text = String(elapsedSec);
				_textF2.text = String(_countDownSec - elapsedSec);
			}
		}
		
		
		
	}

}