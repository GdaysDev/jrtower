package com.aeon.jrtower.helper {
	import flash.text.TextField; 
	import flash.net.URLRequest; 	
	import flash.system.Capabilities;
	import com.gskinner.motion.GTweener;
	//import com.gskinner.motion.GTween;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.display.*;
	
	/**
	 * @author md760
	 */
	public class CommonFunction {
		
		public static function getCurrentTimeNumber():String
		{
			var now:Date = new Date();
			var hour:String = String(now.getHours());
			var minute:String = String(now.getMinutes());
			if(hour.length == 1)
				hour = "0" + hour;
			if(minute.length == 1)
				minute = "0" + minute;
			return hour +":" + minute;
		}
		
		public static function getCurrentDayForBroastCast():String
		{
			var now:Date = new Date();
			var month:String = String(now.month + 1);
			var day: String = String(now.date);
			if(month.length == 1 )
				month = "0" + month;
			if(day.length == 1 )
				day = "0" + day;				
			return now.fullYear + month + day;
		}
		
		public static function getCurrentDay():String
		{
			var now:Date = new Date();
			var month:String = String(now.month + 1);
			var day: String = String(now.date);
			if(month.length == 1 )
				month = "0" + month;
			if(day.length == 1 )
				day = "0" + day;	
							
			var dayOfWeek_array:Array = new Array("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"); 
			//var today_date:Date = new Date(); 
			var day_str:String = dayOfWeek_array[now.getDay()]; 
			trace("Today is "+day_str);	
							
			return  month + "." + day + "." + day_str ;
		}
		
		public static function addTitleToPanel(x:Number, y:Number, w:Number, h:Number, panel:Sprite, fontSize:Number, txtMsg:String, align:String, color:uint):void
		{
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = fontSize;
			myFormat.color = color;
			var title:TextField = new TextField();
			title.defaultTextFormat = myFormat;
			//title.text = txtMsg;
			title.htmlText = "<body><p align='"+ align +"'>"+ txtMsg +"</p></body>";
			title.width = w ;
			title.x= x;
			title.y =  y ;
			panel.addChild(title);
		}
		
		public static function createBox(x:Number, y:Number, w:Number, h:Number, fillColor:uint, lineColor:uint, panel:Sprite):Sprite
		{
			var boxShadow:Sprite = new Sprite(); 
			boxShadow.graphics.lineStyle(1); 
			boxShadow.graphics.beginFill(fillColor); 
			boxShadow.graphics.lineStyle(1,lineColor);
			boxShadow.graphics.drawRect(x, y, w, h); 
			boxShadow.graphics.endFill(); 
			/*
			var shadow:DropShadowFilter = new DropShadowFilter(); 
			shadow.distance = 0.5; 
			shadow.angle = 25; 
			boxShadow.filters = [shadow];
			panel.addChild(boxShadow); 
			 
			 */
			panel.addChild(boxShadow); 
			return boxShadow;
		}
		
		public static function createBoxShadow(x:Number, y:Number, w:Number, h:Number, fillColor:uint, lineColor:uint, panel:Sprite):Sprite
		{
			var boxShadow:Sprite = new Sprite(); 
			boxShadow.graphics.lineStyle(1); 
			boxShadow.graphics.beginFill(fillColor); 
			boxShadow.graphics.lineStyle(1,lineColor);
			boxShadow.graphics.drawRect(x, y, w, h); 
			boxShadow.graphics.endFill(); 
			var shadow:DropShadowFilter = new DropShadowFilter(); 
			shadow.distance = 0.5; 
			shadow.angle = 25; 
			boxShadow.filters = [shadow];
			panel.addChild(boxShadow); 
			return boxShadow;
		}
		
	}
}