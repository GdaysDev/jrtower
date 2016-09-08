package com.stanfoot.common.maskedTxt
{
	import com.stanfoot.common.GeneralFuncs;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	
	import com.stanfoot.common.debug.Debug;


	
	/**********************************************************************
	 * 引数のMCをマスクオブジェクトとし、その範囲内でティッカーや長体が可能なテキストを生成するクラス
	 * @author STANFOOT INC.
	 */
	public class MaskedTxt extends MovieClip
	{
		//クラスメンバ================================================================
		public static const ALIGN_LEFT:String = "left";
		public static const ALIGN_CENTER:String = "center";
		public static const ALIGN_RIGHT:String = "right";
		
		public static const VALIGN_TOP:String = "top";
		public static const VALIGN_MIDDLE:String = "middle";
		public static const VALIGN_BOTTOM:String = "bottom";
		
		public static const TICKER_TYPE_NORMAL:String = "tickerType_normal";
		public static const TICKER_TYPE_ROLLBACK:String = "tickerType_rollback";
		
		
		//静的変数--------------------------------------------------
		private static var defaultTextFmt:TextFormat = setDefaultTextFormat();
		private static var defaultFont:Font;
		private static var defaultTextAlign:String = ALIGN_LEFT;
		private static var defaultTextValign:String = VALIGN_TOP;
		private static var defaultFontColor:Number = 0x000000;
		private static var defaultFontSize:Number = 23;
		private static var defaultFontLeading:Number = 0;
		
		
		private static function setDefaultTextFormat():TextFormat
		{
			defaultTextFmt = new TextFormat();
			defaultTextFmt.align = defaultTextAlign;
			defaultTextFmt.color = defaultFontColor;
			if ( defaultFont == null)
			{
				defaultTextFmt.font = null;
			}
			else
			{
				defaultTextFmt.font = defaultFont.fontName;
			}
			defaultTextFmt.size = defaultFontSize;
			defaultTextFmt.leading = defaultFontLeading;
			
			defaultTextFmt.leftMargin = 0;
			defaultTextFmt.rightMargin = 0;
			defaultTextFmt.indent = 0;
			defaultTextFmt.letterSpacing = 0;
			
			return defaultTextFmt;
		};
		
		
		
		
		//===========================================================================================
		
		//メンバ変数--------------------------------------------------
		
		/** 表示テキスト文字列 */
		private var _text:String;
		/** 表示テキスト文字列を参照 */
		public function get text():String
		{	return _text;	}
		
		private var _numLines:int;
		public function get numLines():int
		{	return _numLines;	};
		
		//テキストビットマップマスク
		private var maskMC:MovieClip;
		//メインコンテナ
		private var mainContainerMC:MovieClip;
		
		private var mainBmpData:BitmapData;
		private var mainBitmap:Bitmap;
		
		private var maskRect:Rectangle;
		
		//設定-------------------------
		private var _mtFormat:MaskedTxtFormat;
		
		private function get fontColor():Number
		{	return _mtFormat.fontColor; };
		
		private function get font():Font
		{	return _mtFormat.font; };
		
		private function get fontSize():Number
		{	return _mtFormat.fontSize; };
		
		private function get fontLeading():Number
		{	return _mtFormat.fontleading; };
		
		private function get textAlign():String
		{	return _mtFormat.textAlign; };
		
		private function get textValign():String
		{	return _mtFormat.textValign; };
		
		private function get multiLine():Boolean
		{	return _mtFormat.multiLine; };
		
		private function get letterSpacing():Number
		{	return _mtFormat.letterSpacing; };
		
		/** スクイーズするかどうか デフォルト true */
		private function get squeezeFlg():Boolean
		{	return _mtFormat.squeezeFlg; };
		
		private function get squeezeLimit():Number
		{	return _mtFormat.squeezeLimit; };
		
		/** ティッカーの必要性 */
		private function get tickerFlg():Boolean
		{	return _mtFormat.tickerFlg; };
		private function set tickerFlg(value:Boolean):void
		{	_mtFormat.tickerFlg = value;	};
		
		/** スクイーズが固定*/
		private var fixSqueese:Number;
		private var squeezeRate:Number = 1;
		
		private var tickerType:String = TICKER_TYPE_NORMAL;
		private var tickerLoopFlg:Boolean = false;
		private var tickerDelay:int = 60;	//[frame]
		private var tickerSpeed:Number = 1;	//[px/frame]
		private var tickerCounter:int = 0;
		private var autoTickerFlg:Boolean = false;
		
		
		
		/**********************************************************************
		 * コンストラクタ
		 * @param	argMaskMC
		 * @param	argStr
		 * @param	arfMtFormat
		 */
		public function MaskedTxt(argMaskMC:MovieClip, argStr:String, argMtFormat:MaskedTxtFormat)
		{
			//Debug.write("[MaskedTxt]" + argStr + " (" + this.name + ")")
			
			//プロパティ取得
			maskMC = argMaskMC;
			_text = argStr;
			
			setMaskedTxtFormat(argMtFormat);
			
			//コンテナMCの生成
			mainContainerMC = new MovieClip();
			addChild(mainContainerMC);
			
			//削除された時の処理を予約する
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
			
			setText(_text);
		}
		
		public function setMaskedTxtFormat(argMtFormat:MaskedTxtFormat):void
		{
			//設定パラメータの取得
			_mtFormat = argMtFormat;
		}
		
		
		/**
		 * メッセージをセットする
		 * @param	message
		 * @param	setTextFormatArray	フォントサイズ127以上は非対応
		 * @return
		 */
		public function setText(message:String, setTextFormatArray:Array = null, htmlText:Boolean = false ):Rectangle
		{
			//フェーズ1 設置場所の下準備------------------------------------------------------------------
			
			/** セットされたテキストのサイズを返す */
			var result:Rectangle;
			
			var tmpMessage:String = message as String ? message : "";
			_text = tmpMessage;
			
			//右端と左端の取得
			maskRect = new Rectangle(maskMC.x, maskMC.y, maskMC.width, maskMC.height);
			
			//すでに表示内容（ビットマップ）がある場合、いったん削除する
			if (mainBitmap != null)
			{
				if (mainContainerMC.contains(mainBitmap))
				{
					mainContainerMC.removeChild(mainBitmap);
				}
				mainBitmap = null;
				
				//マスクを解除
				mainContainerMC.mask = null;
			}
			else
			{
			}
			
			
			//フェーズ2 キャプチャ用の仮テキストフィールドの生成と設定-----------------------
			
			//TextFormatを取得・設定
			var tmpTextFormat:TextFormat = getTextFormat();
			
			var mainTFld:TextField = new TextField();
			//mainTFld.setTextFormat(tmpTextFormat);
			//mainTFld.defaultTextFormat = tmpTextFormat;
			
			//Debug.write("★_mtFormat  " + _mtFormat);
			
			mainTFld.multiline = multiLine;
			if (font == null)
			{	//フォントが設定されていない場合、デバイスフォントを使う
				mainTFld.embedFonts = false;
			}
			else
			{	//フォントが設定されている場合、埋め込みフォントを使う
				mainTFld.embedFonts = true;
			}
			
			
			//
			if (multiLine)
			{	//複数行設定の場合--------------------------------------------------------------------
				mainTFld.wordWrap = true;	//自然改行する
				//テキストフィールドの幅をマスクに合わせる
				mainTFld.width = maskMC.width;
				//mainTFld.height = maskMC.height;
				
				switch(tmpTextFormat.align)
				{
					case TextFormatAlign.CENTER:
						mainTFld.autoSize = TextFieldAutoSize.CENTER;
						break;
					case TextFormatAlign.LEFT:
						mainTFld.autoSize = TextFieldAutoSize.LEFT;
						break;
					case TextFormatAlign.RIGHT:
						mainTFld.autoSize = TextFieldAutoSize.RIGHT;
						break;
					default:
						mainTFld.autoSize = TextFieldAutoSize.NONE;
				}
			}
			else
			{	//単行の場合--------------------------------------------------------------------
				mainTFld.wordWrap = false;	//自然改行しない
				
				switch(tmpTextFormat.align)
				{
					case TextFormatAlign.CENTER:
						mainTFld.autoSize = TextFieldAutoSize.CENTER;
						break;
					case TextFormatAlign.LEFT:
						mainTFld.autoSize = TextFieldAutoSize.LEFT;
						break;
					case TextFormatAlign.RIGHT:
						mainTFld.autoSize = TextFieldAutoSize.RIGHT;
						break;
					default:
						mainTFld.autoSize = TextFieldAutoSize.NONE;
				}
			}
			
			
			//フェーズ3 テキストの流し込み------------------------------------------------------------------
			
			var limitBrakeScale:Number = 1;
			
			//注意 旧式テキストフィールドのフォントサイズ上限は127
			if (tmpTextFormat.size > 127)
			{
				//127を超えた場合は、内部的に100に設定し、表示にはlimitBrakeScaleをかけたものを用いる
				limitBrakeScale = parseFloat(String(tmpTextFormat.size)) / 100;
				tmpTextFormat.size = 100;
				//limitBrakeScale = isNaN(parseFloat(String(tmpTextFormat.size)))? 127 : parseFloat(String(tmpTextFormat.size)) / 127;
				//Debug.write("[MaskedTxt]■旧テキストの限界値を超えたフォントサイズです。 limitBrakeScale  " + limitBrakeScale)
			}
			mainTFld.setTextFormat(tmpTextFormat);
			mainTFld.defaultTextFormat = tmpTextFormat;
			
			//★テキストの流し込み
			
			if (htmlText)
			{
				mainTFld.condenseWhite = true;
				mainTFld.htmlText = message;
			}
			else
			{
				mainTFld.appendText(_text);
			}
			
			//個別のテキストフォーマット対応
			//TODO setTextFormatArray でのフォントサイズ127以上は非対応
			var tmpLength:int;
			var tmpParam:Object;
			if (setTextFormatArray)
			{
				tmpLength = setTextFormatArray.length
				for (var i:int = 0; i < tmpLength; i++) 
				{
					tmpParam = setTextFormatArray[i] as Object;
					if (tmpParam)
					{
						mainTFld.setTextFormat(tmpParam.format, tmpParam.beginIndex, tmpParam.endIndex);
					}
				}
			}
			
			
			/** テキストフィールドの 1行目 のサイズ */
			var mainTLineMetrics:TextLineMetrics = mainTFld.getLineMetrics(0);
			//mainTFld.scaleX = limitBrakeScale;
			//mainTFld.scaleY = limitBrakeScale;
			
			//Debug.write(mainTLineMetrics.x +","+ mainTLineMetrics.width +","+ mainTLineMetrics.height +","+ mainTLineMetrics.leading  +","+ mainTLineMetrics.ascent )
			
			//テキストフィールドのサイズとマスクのサイズを比較して、ティッカーするかどうか決める-----------
			if (multiLine)
			{	//複数行表示の場合（縦ティッカーをするかどうかの判定）--------------------------------------------------------------------
				
				if ((mainTFld.height)*limitBrakeScale > maskMC.height -4)
				{
					tickerFlg = true;
					
				}
				else
				{
					tickerFlg = false;
				}
			}
			else
			{	//単行表示の場合(横ティッカーをするかどうかの判定)--------------------------------------------------------------------
				if (mainTLineMetrics.width * limitBrakeScale > maskRect.width - 4)
				{	//横ティッカーのチェック　必要なテキストフィールドのサイズがマスクよりも大きい場合　→ スクイーズかティッカーが必要
					
					//Debug.write("[MaskedTxt]マスクよりも大きなテキストです");
					if (squeezeFlg)
					{	//テキストのスクイーズ処理が許可されている場合
						//縮小率の算出
						//限界まで長体をかければマスク内に収まるかどうか
						if (mainTLineMetrics.width * limitBrakeScale * squeezeLimit < maskMC.width -4 )
						{	//収まる場合、縮小率を設定する
							
							squeezeRate = (maskRect.width -4 ) / (mainTLineMetrics.width * limitBrakeScale);
							
							//収まるなら、ティッカーする必要はないので、false
							tickerFlg = false;
							//Debug.write("[MaskedTxt]長体率を設定します squeezeRate=" + squeezeRate);
						}
						else
						{
							//squeezeFlg = false;
							//Debug.write("[MaskedTxt]長体をかけても収まりません");
						}
					}
				}
				else
				{	//必要なテキストフィールドのサイズがマスクよりも小さい場合
					//Debug.write("[MaskedTxt]マスクよりも小さなテキストです（スクイーズ・ティッカー不要）");
					
					mainTFld.width = maskMC.width;
					//squeezeFlg = false;
					tickerFlg = false;
				}
			}
			
			
			
			//フェーズ4 ビットマップデータを作成------------------------------------------------------------------
			var tmpTFWidth = mainTFld.width * limitBrakeScale; 
			var tmpTFHeight = mainTFld.height * limitBrakeScale;
			
			var tmpBmpWidth:int;
			var tmpBmpHeight:int;
			
			if (multiLine)
			{	//複数行設定の場合--------------------------------------------------------------------
				//文字が1行の場合、leading値が負の場合見切れる不具合（FLASHのバグ？）の対処
				if (mainTFld.numLines == 1)
				{	//1行しかない場合、改行幅を0とする
					tmpTextFormat.leading = 0;
					mainTFld.setTextFormat(tmpTextFormat);
				}
				tmpBmpWidth = tmpTFWidth;//mainTFld.width;
				tmpBmpHeight = tmpTFHeight;//mainTFld.height;
			}
			else
			{	//単行の場合--------------------------------------------------------------------
				tmpBmpWidth = tmpTFWidth;//mainTFld.width;
				tmpBmpHeight = mainTLineMetrics.height * limitBrakeScale + 4;
			}
			
			//flashPlayer10以下はビットマップデータのサイズに制約があるので、その範疇に収める処理
			tmpBmpWidth = (tmpBmpWidth < 8000)? tmpBmpWidth : 8000;
			tmpBmpHeight = (tmpBmpHeight < 8000)? tmpBmpHeight : 8000;
			if (tmpBmpHeight * tmpBmpWidth > 16777215)
			{
				tmpBmpWidth = (16777215 / tmpBmpHeight) | 0;
			}
			mainBmpData = new BitmapData(tmpBmpWidth, tmpBmpHeight, true, 0);
			
			
			
			var matrix:Matrix = new Matrix();
			matrix.translate( -mainTFld.x, -mainTFld.y);
			matrix.scale(limitBrakeScale, limitBrakeScale);
			
			//テキストフィールドをキャプチャ
			mainBmpData.draw(mainTFld, matrix, null, null, null, true);
			
			mainBitmap = new Bitmap(mainBmpData);
			mainBitmap.smoothing = true;
			mainContainerMC.addChild(mainBitmap);
			
			//trace("☆★☆" + squeezeFlg +"/"+ fixSqueese +"/"+ squeezeRate)
			
			//スクイーズの処理----------------------------------------------------
			if (squeezeFlg)
			{
				//無理やりサイズ変形（ほんとはdrawで縮小変換したいんだけど…）
				
				var tmpRate:Number;
				if (isNaN(fixSqueese))
				{	//fixSqueeseが指定されていない場合
					
					//mainContainerMC.scaleX = squeezeRate;
					mainBitmap.scaleX = squeezeRate;
					tmpRate = squeezeRate;
				}
				else
				{	//fixSqueeseが指定されている場合
					//mainContainerMC.scaleX = fixSqueese;
					mainBitmap.scaleX = fixSqueese
					tmpRate = fixSqueese;
				}
				
				
				/*
				trace("mainContainerMC  " + mainContainerMC.x + " , " + mainContainerMC.width);
				trace("mainTFld       " + mainTFld.x + " , " + mainTFld.width);
				trace("mainBitmap     " + mainBitmap.x + " , " + mainBitmap.width);
				trace("maskMC         " + maskMC.x + " , " + maskMC.width);
				trace(mainTFld.getRect(mainTFld).right);
				*/
				
				switch(textAlign)
				{
					case MaskedTxt.ALIGN_RIGHT:
						mainContainerMC.x = maskMC.x + maskMC.width - mainBitmap.width;
						break;
					case MaskedTxt.ALIGN_CENTER:
						mainContainerMC.x = maskMC.x + (maskMC.width - mainBitmap.width) / 2 ;
						break;
					default:
						//メインコンテナの位置をリセット
						mainContainerMC.x = maskMC.x;
				}
			}
			
			
			if (multiLine)
			{	//複数行設定の場合--------------------------------------------------------------------
				switch(textValign)
				{
					case VALIGN_TOP:
						mainContainerMC.y = maskMC.y;
						break;
					case VALIGN_MIDDLE:
						if (maskMC.height >= mainBitmap.height)
						{	//全文がマスク内に収まる場合
							//上下中央にレイアウト
							mainContainerMC.y = maskMC.y + (maskRect.height / 2) - (mainContainerMC.height / 2);
						}
						else
						{	//全文がマスク内に収まらない場合
							mainContainerMC.y = maskMC.y;
						}
						break;
					case VALIGN_BOTTOM:
						mainContainerMC.y = maskRect.bottom;
						break;
				}
				
			}
			else
			{	//単行の場合--------------------------------------------------------------------
				mainContainerMC.y = maskMC.y;
			}
			
			//コンテナにマスクを適応
			mainContainerMC.mask = maskMC;
			
			
			//ティッカー処理----------------------------------------------
			
			tickerCounter = 0;
			this.removeEventListener(Event.ENTER_FRAME, tickerEnterFrameHandler);
			
			if (tickerFlg)
			{	//ティッカーする場合
				//Debug.write("[MaskedTxt] ★(" + mainContainerMC.x + " , " + mainContainerMC.y + ") " + tickerCounter)
				//ティッカーカウンタをリセット
				tickerCounter = 0;
				
				//自動でティッカーを開始させるかどうかチェック
				if (autoTickerFlg)
				{
					//ティッカーの開始
					activateTicker();
				}
			}
			
			result = mainBitmap.getRect(this);
			_numLines = mainTFld.numLines;
			
			//不要になったテキストフィールドを削除
			//mainContainerMC.removeChild(mainTFld);
			mainTFld = null;
			//addChild(mainTFld)
			
			/*
			var tmpSprite:Sprite = new Sprite();
			tmpSprite.graphics.beginFill(0xff0000, 0.5);
			tmpSprite.graphics.drawRect(result.x, result.y, result.width, result.height);
			tmpSprite.graphics.endFill();
			addChild(tmpSprite);
			*/
			/*
			//デバッグ
			mainContainerMC.mask = null;
			maskMC.visible = true;
			maskMC.alpha = 0.5;
			*/
			
			return result;
		}
		
		
		
		/**********************************************************************
		 * デフォルトのテキストフォーマットをベースにテキストフォーマットを取得
		 */
		public function getCopyTextFormat():TextFormat
		{
			var result:TextFormat = new TextFormat();
			var tmpTFmt:TextFormat = getTextFormat();
			
			//result = GeneralFuncs.clone(tmpTFmt);
			
			for (var name:String in tmpTFmt) 
			{
				result[name] = tmpTFmt[name];
			}
			
			
			return result;
		}
		 
		private function getTextFormat():TextFormat
		{
			var result:TextFormat;
			
			//デフォルトのフォーマットを生成
			if (MaskedTxt.defaultTextFmt == null)
			{
				MaskedTxt.setDefaultTextFormat();
			}
			result = MaskedTxt.defaultTextFmt as TextFormat;
			
			//デフォルトのフォーマットのコピーに対してプロパティを追加
			if (result && _mtFormat as MaskedTxtFormat)
			{
				result.align = textAlign;
				result.color = fontColor;
				//result.font = fontName;
				if (font == null)
				{
					result.font = null;
				}
				else
				{
					result.font = font.fontName;
				}
				result.size = fontSize;
				result.leading = fontLeading;
				
				result.leftMargin = 0;
				result.rightMargin = 0;
				result.indent = 0;
				result.letterSpacing = letterSpacing;
			}
			else
			{
				Debug.write("[MaskedTxt] 設定値が不正です")
			}
			return result;
		}
		
		
		
		/**********************************************************************
		 * ティッカーの定期処理・開始遅延カウントダウンを開始する
		 */
		public function activateTicker()
		{
			//Debug.write("[MaskedTxt]ティッカーの定期処理・開始遅延カウントダウンを開始する" )
			this.addEventListener(Event.ENTER_FRAME, tickerEnterFrameHandler);
		}
		
		
		/**********************************************************************
		 * ティッカーの定期処理
		 * @param	event
		 */
		private function tickerEnterFrameHandler(event:Event):void
		{
			//Debug.write("[MaskedTxt]" + this.name + tickerLoopFlg + event.target.name)
			//Debug.write("[MaskedTxt] (" + mainContainerMC.x + " , " + mainContainerMC.y + ") " + tickerCounter)
			
			//ティッカーの開始遅延処理
			if (tickerCounter < tickerDelay)
			{	//ティッカー開始までのカウントをまわす
				tickerCounter += 1;
				return;
			}
			
			
			if (multiLine)
			{	//複数行設定の場合　縦ティッカー
				mainContainerMC.y -= tickerSpeed;
				
				if ((mainContainerMC.y + mainContainerMC.height <= maskRect.bottom)/* && !tickerLoopFlg*/)
				{	//ティッカー内容の下端が表示された場合
					if (tickerLoopFlg)
					{	//ループの必要があるとき
						switch(tickerType)
						{
							case TICKER_TYPE_NORMAL:
								//スルー
								break;
							case TICKER_TYPE_ROLLBACK:
								this.removeEventListener(Event.ENTER_FRAME, tickerEnterFrameHandler);
								tickerCounter = 0;
								TweenNano.to(mainContainerMC, 0.8, { y:maskRect.top, ease:Sine.easeOut,onComplete:activateTicker,delay:2 } );
								break;
						}
					}
					else
					{	//ループの必要が無いとき
						//ループ処理を止める
						event.target.removeEventListener(Event.ENTER_FRAME,tickerEnterFrameHandler);
					}
				}
				if ((mainContainerMC.y + mainContainerMC.height <= maskRect.top) && tickerLoopFlg)
				{	//ループの必要があり、ティッカー内容の下端が表示範囲の上端を超えたとき
					
					switch(tickerType)
					{
						case TICKER_TYPE_NORMAL:
							//ティッカーをループさせる（上端へスクロールしきったら下端へ移動）
							mainContainerMC.y = maskRect.bottom;
							break;
						case TICKER_TYPE_ROLLBACK:
							//ありえないケース
							break;
					}
				}
			}
			else
			{	//単数行設定の場合　横ティッカー
				mainContainerMC.x -= tickerSpeed;
				
				if ((mainContainerMC.x + mainContainerMC.width <= maskRect.right) && !tickerLoopFlg)
				{	//ループの必要が無く、ティッカー内容の右端が表示された場合
					//ループ処理を止める
					//trace("[MaskedTxt]ティッカーを止めます " + tickerLoopFlg);
					event.target.removeEventListener(Event.ENTER_FRAME,tickerEnterFrameHandler);
				}
				if ((mainContainerMC.x + mainContainerMC.width <= maskRect.left) && tickerLoopFlg)
				{	//ループの必要があり、ティッカー内容の右端が表示範囲の左端を超えたとき
					//ティッカーをループさせる（左端へスクロールしきったら右端へ移動）
					//trace("[MaskedTxt]ティッカーをループさせます " + maskRect.right);
					mainContainerMC.x = maskRect.right;
				}
			}
		}
		
		/*
		public function setParams(argFontSize:Number, argFontColor:Number = 0xFFFFFF, tickeDelay:int)
		{
			
		}
		*/
		
		
		
		
		/**********************************************************************
		 * 削除された時の処理
		 * @param	event
		 */
		private function removedHandler(event:Event):void
		{
			clear();
		}
		
		/**********************************************************************
		 * クリアー（削除）する
		 */
		public function clear()
		{
			//trace("[MaskedTxt]削除します : " + this._text);
			if (mainContainerMC)
			{
				if (mainContainerMC.contains(mainBitmap))
				{
					mainContainerMC.removeChild(mainBitmap);
				}
				if (mainContainerMC.parent)
				{
					mainContainerMC.parent.removeChild(mainContainerMC);
				}
				mainContainerMC.mask = null;
			}
			
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
			this.removeEventListener(Event.ENTER_FRAME, tickerEnterFrameHandler);
			
			defaultFont = null;
			_mtFormat = null;
		}
	}
	
	
	
}