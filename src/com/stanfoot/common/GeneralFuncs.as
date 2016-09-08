package com.stanfoot.common {
	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;

	import com.stanfoot.common.debug.Debug;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	/**
	 * こまごまとした汎用的な関数たち
	 * @author koba
	 */
	public class GeneralFuncs {
		/**
		 * 改行コードの整形
		 * @param	src
		 * @return
		 */
		public static function fixLineFeedCcode(src : String) : String {
			var tmpStr : String = src as String ? src : "";
			var result : String;
			var refLfc : RegExp = /\r\n|\r|\n/gx;

			tmpStr = tmpStr.replace(refLfc, "\n");
			result = tmpStr;
			return result;
		}

		/**
		 * 文字列中から改行コード除去し、<br />を\nに変換し、HTMLタグを除去した文字列を返す
		 * @param	src
		 * @return
		 */
		public static function removeHtmlTags(src : String) : String {
			var tmpStr : String = src as String ? src : "";
			var result : String;
			var refLfc : RegExp = /\r\n|\r|\n/gx;
			var refBr : RegExp = /<br.*?>|<BR.*?>/gx;
			var refTags : RegExp = /<.*?>/gx;

			tmpStr = tmpStr.replace(refLfc, "");
			tmpStr = tmpStr.replace(refBr, "\n");
			tmpStr = tmpStr.replace(refTags, "");

			result = tmpStr;
			return result;
		}

		/**
		 * 引数と一致するものを除去した新しい配列を返す
		 * @param	list
		 * @param	removeItem
		 * @return
		 */
		public static function removeItemFromArray(list : Array, removeItem : *) : Array {
			var result : Array = [];
			var tmplist : Array = list.concat();
			var tmpLength : int = tmplist.length;
			var tmpItem : *;

			for (var i : int = 0; i < tmpLength; i++) {
				tmpItem = tmplist[i];
				if (removeItem !== tmpItem) {
					result.push(tmpItem);
				}
			}

			return result;
		}

		/**
		 * 文字列か数値で構成された配列要素から重複する要素を除去した新しい配列を返す
		 * ※配列にオブジェクトが含まれていると正しく機能しません。
		 * @param	list
		 * @return
		 */
		public static function getUniqueArray(list : Array) : Array {
			var result : Array = [];
			var oValues : Object = {};
			var tmpLength : int = list.length;

			for (var i : int = 0; i < tmpLength; i++) {
				var myValue : * = list[i];
				if (!oValues[myValue]) {
					oValues[myValue] = true;
					result.push(myValue);
				}
			}

			return result;
		}

		/**
		 * 引数の配列要素の順番をシャッフルしたた新しい配列を返す
		 * @param	list
		 * @return
		 */
		public static function getShuffledArray(list : Array) : Array {
			var n : uint = list.length;
			// 配列を複製
			var sList : Array = list.concat();

			while (n--) {
				// ランダムな番地
				var i : uint = uint(Math.random() * (n + 1));

				var t : * = sList[n];
				sList[n] = sList[i];
				sList[i] = t;
			}
			return sList;
		}

		/**
		 * 引数の文字列が指定最大値（maxCharNum）を超えた場合、…で省略する
		 * @param	str			処理対象文字列
		 * @param	maxCharNum	文字最大数
		 * @param	ellipsis	省略記号
		 * @return
		 */
		public static function strTrim(str : String, maxCharNum : int, ellipsis : String = "…") : String {
			var result : String;
			var tmpEllipsis : String = ellipsis as String ? ellipsis : "…" ;
			var tmpStr : String = str as String ? str : "";

			if (tmpStr.length > maxCharNum) {
				// 文字が最大数を超えた場合
				result = tmpStr.slice(0, maxCharNum - tmpEllipsis.length) + tmpEllipsis;
			} else {
				result = tmpStr;
			}

			return result;
		}

		/**
		 * 半角を1、全角を2として文字列の長さを算出する
		 * @param	s
		 * @return
		 */
		public static function getNumMultiByte(s : String) : Number {
			var byteArray : ByteArray = new ByteArray();
			byteArray.writeMultiByte(s, "shift-jis");
			return byteArray.length;
		}

		/**
		 * コードチェック（文字,範囲小,範囲大）
		 * 文字列が全て指定範囲の文字コードに含まれているかどうかをチェック
		 * @param	str	チェックする文字列
		 * @param	min	範囲小
		 * @param	max 範囲大
		 * @return
		 */
		public static function checkCode(str : String, min : int, max : int) : Boolean {
			var len : int = str.length;
			var result: Boolean = true;
			while (len--) {
				var num : int = str.substr(len, 1).charCodeAt(0);
				if ((num < min) || (num > max)) {
					result = false;
					break;
				}
			}
			return result;
		}

		/** Rectangleをもとに着色したSpriteを生成する */
		public static function createPaintedSprite(srcRect : Rectangle, paintColor : uint = 0xff0000, paintAlpha : Number = 1) : Sprite {
			var tmpSprite : Sprite = new Sprite();
			tmpSprite.graphics.beginFill(paintColor);
			tmpSprite.graphics.drawRect(srcRect.left, srcRect.top, srcRect.width, srcRect.height);
			tmpSprite.graphics.endFill();
			tmpSprite.alpha = paintAlpha;
			tmpSprite.mouseEnabled = false;

			return tmpSprite;
		}

		/**
		 * 本体SWFのディレクトリパスを取得する
		 * 取得できなかった場合は、空文字""を返す
		 * @param	stage
		 * @return	String	本体SWFのディレクトリパス
		 */
		public static function getSwfDirPath(stage : Stage) : String {
			/** 結果 */
			var result : String;

			var tmpObj : Object = getSwfDirPathAndFileName(stage);
			result = tmpObj.dirPath;

			if (result == null) result = "";

			return result;
		}

		/**
		 * 本体SWFのディレクトリパスとファイル名を取得する
		 * @param	stageLoaderInfo	ステージのLoaderInfo
		 * @return	Object	{dirPath:dirPath, fileName:fileName};
		 */
		public static function getSwfDirPathAndFileName(stage : Stage) : Object {
			/** 本体SWFのURL（クエリ値有り） */
			var url : String = stage.loaderInfo.url;
			/** 本体SWFのURL（クエリ値無し） */
			var swfUrl : String = url.split("?")[0];

			var token : Array = swfUrl.split("/");
			/** SWFファイル名 */
			var fileName : String = token[token.length - 1];

			var resultUrl : RegExp = new RegExp(".*[^" + fileName + "]", "i");
			/** ディレクトリパス */
			var dirPath : String = resultUrl.exec(swfUrl);

			if (dirPath == null) dirPath = "";
			if (fileName == null) fileName = "";

			/** 結果 */
			var result : Object = {dirPath:dirPath, fileName:fileName, fullUrl:url};

			return result;
		}

		/**
		 * ソースをクローンしてObjectで返す
		 * @param	source
		 * @return
		 */
		public static function clone(source : Object) : * {
			var tmpBA : ByteArray = new ByteArray();
			tmpBA.writeObject(source);
			tmpBA.position = 0;
			return tmpBA.readObject();
		}

		/**
		 * baseURLに基準となるURLの絶対パス。pathに相対パスを指定すると、相対パスを適用した絶対パスが帰ってきます。
		 * 引用元 motion lab （http://www.shin-go.net/motionlab/?p=449）
		 * @param	baseURL	基準となるURLの絶対パス
		 * @param	path	相対パス
		 * @return
		 */
		public static function relativeToAbsolute(baseURL : String, path : String) : String {
			// pathが絶対パスの時はお帰りください
			if (path.substr(0, 4) == "http") {
				return path;
			} else if (path.substr(0, 4) == "file") {
				return path;
			}

			var _ary : Array = baseURL.split("//");
			var ary : Array;
			var absolute : String;
			ary = _ary[1].split("/");
			if (ary.length > 1 && ary[ary.length - 1].split(".").length > 1) {
				// 末尾がファイル名で終わる時
				ary.pop();
			} else if (ary[ary.length - 1] == "") {
				// 末尾が/で終わるとき
				ary.pop();
			}
			if (path.charAt(0) == "/") {
				// pathが「/」で始まる時
				absolute = _ary[0] + "//" + ary[0] + path;
			} else if (path.substr(0, 2) == "./") {
				// pathが「./」で始まる時
				absolute = _ary[0] + "//" + ary.join("/") + "/";
			} else if (path.substr(0, 3) == "../") {
				// pathが「../」で始まる時
				var i : int = 0;
				while (path.substr(i * 3, 3) == "../") {
					ary.pop();
					i += 1;
				}
				absolute = _ary[0] + "//" + ary.join("/") + "/" + path.substr(i * 3);
			} else {
				absolute = _ary[0] + "//" + ary.join("/") + "/" + path;
			}
			return absolute;
		}

		/**
		 * 各要素がすべて同一フォーマットのオブジェクトで構成された配列tgtArrayから　propertyName の値が value と合致する最初のインデックスを返す
		 * @param	tgtArray	検索対象配列
		 * @param	propertyName	プロパティ名
		 * @param	value	適合と見なす値
		 * @return	index
		 */
		public static function searchIndex(tgtArray : Array, propertyName : String, value : *) : int {
			var result : int = -1;
			var arrayLength : int = tgtArray.length;
			var tmpObj : Object;
			for (var i : int = 0; i < arrayLength; i++) {
				tmpObj = tgtArray[i] as Object;
				if (tmpObj != null) {
					if (tmpObj[propertyName] == value) {
						result = i;
						break;
					}
				}
			}

			return result;
		}

		/**
		 * 各要素がすべて同一フォーマットのオブジェクトで構成された配列tgtArrayから　propertyName の値が value と合致するものを抽出した配列を返す
		 * @param	tgtArray	検索対象配列
		 * @param	propertyName	プロパティ名
		 * @param	value	適合と見なす値
		 * @return
		 */
		public static function filterOut(tgtArray : Array, propertyName : String, value : *) : Array {
			var result : Array = [];

			var arrayLength : int = tgtArray.length;
			var tmpObj : Object;
			for (var i : int = 0; i < arrayLength; i++) {
				tmpObj = tgtArray[i] as Object;
				if (tmpObj != null) {
					if (tmpObj[propertyName] == value) {
						result.push(tgtArray[i]);
					}
				}
			}

			return result;
		}

		/**
		 * 引数(argNum)の 一定割合(rate)をランダム化して返す
		 * @param	argNum
		 * @param	rate
		 * @return
		 */
		public static function getRandomNum(argNum : Number, rate : Number = 0.1) : Number {
			if (rate <= 0 && 1 < rate) {
				throw new Error("0より大きく、1以下のrateを指定してください");
			}
			var result : Number = argNum * (1 - rate) + Math.round(Math.random() * argNum * rate * 2 * 10) / 10 ;

			return result;
		}

		/* 双曲線関数：Hyperbolic function */
		/**
		 * sinh
		 * @param	n
		 * @return
		 */
		public static function sinh(n : Number) : Number {
			return (Math.exp(n) - Math.exp(-n)) / 2;
		}

		/**
		 * cosh
		 * @param	n
		 * @return
		 */
		public static function cosh(n : Number) : Number {
			return (Math.exp(n) + Math.exp(-n)) / 2;
		}

		/**
		 * tanh
		 * @param	n
		 * @return
		 */
		public static function tanh(n : Number) : Number {
			var t1 : Number = Math.exp(n);
			var t2 : Number = Math.exp(-n);
			return (t1 - t2) / (t1 + t2);
		}

		/**
		 * sech
		 * @param	n
		 * @return
		 */
		public static function sech(n : Number) : Number {
			return 1 / cosh(n);
		}

		/**
		 * csch
		 * @param	n
		 * @return
		 */
		public static function csch(n : Number) : Number {
			return 1 / sinh(n);
		}

		/**
		 * coth
		 * @param	n
		 * @return
		 */
		public static function coth(n : Number) : Number {
			return 1 / tanh(n);
		}

		/**
		 * URLにクエリを追加し、返す。クエリ名かクエリ値がブランクの場合、元をそのまま返す
		 * @param	originalUrl	元となるURL
		 * @param	queryName	クエリの名前
		 * @param	queryValue	クエリの値
		 * @return
		 */
		public static function setQuery(originalUrl : String, queryName : String, queryValue : String) : String {
			var result : String = originalUrl;

			if (queryName == "" || queryValue == "") {
			} else if (result.indexOf("http") == 0) {	// httpで読み込む場合
				if (result.indexOf("?") >= 0) {	// すでに何かしらクエリ値がすでにある場合
					if (result.indexOf(queryName) < 0) {	// クエリ値にまだqueryNameがない場合 queryNameを付加する
						result += "&" + queryName + "=" + queryValue;
					}
				} else {	// クエリ値が何もない場合 ifkeyを付加する
					result += "?" + queryName + "=" + queryValue;
				}
			}

			return result;
		}

		/**
		 * キャッシュ回避用に引数URLに現在時刻のクエリ文字列を追記する
		 * @param	argUrl
		 * @return
		 */
		public static function setNowDateQuery(argUrl : String) : String {
			var result : String = argUrl;
			if (argUrl.substr(0, 5) == "http:" || argUrl.substr(0, 6) == "https:") {	// URL文字列にhttp:やhttps:が含まれる場合
				if (argUrl.indexOf("?") < 0) {	// URL文字列にまだクエリ文字列がないと予想される場合
					result += "?";
				}
				// 現在時刻のクエリ文字列を追記する
				result += "nowdate=" + new Date().getTime()
			}
			return result;
		}

		/****************************************************************
		 * 文字置換（String.replace()メソッドと正規表現で文字列を検索・置換 よりも高速）
		 * @param	source_str
		 * @param	find_str
		 * @param	replace_str
		 * @return
		 */
		public static function xReplace(source_str : String, find_str : String, replace_str : String) : String {
			var numChar : uint = find_str.length;
			var end : uint;
			var result_str : String = "";

			if (source_str as String) {
				for (var i : uint = 0; -1 < (end = source_str.indexOf(find_str, i)); i = end + numChar) {
					result_str += source_str.substring(i, end) + replace_str;
				}
				result_str += source_str.substring(i);
			}
			return result_str;
		}

		/**
		 * 入力整数を フロア表記文字列にして返す
		 * @param	floorInt
		 * @param	langMode
		 * @return
		 */
		public static function getFloorStr(floorInt : int, langMode : int = 0) : String {
			var tmpStr : String = "";
			if (floorInt < 0) {
				tmpStr = "B" + ( floorInt - 1) + "F";
			} else {
				tmpStr = floorInt + "F";
			}
			return tmpStr;
		}

		/**
		 * 0 1 の値をブーリアンに変換
		 * @param	arg
		 * @return
		 */
		public static function zeroOneToBoolean(arg : *) : Boolean {
			var tmpInt : int = parseInt(arg, 10);
			var result : Boolean;
			switch (tmpInt) {
				case 0:
					result = false;
					break;
				case 1:
					result = true;
					break;
			}
			return result;
		}

		/**
		 * "YES" なら trueを返す
		 * @param	argStr
		 * @return
		 */
		public static function yesToTrue(argStr : String) : Boolean {
			var result : Boolean = false;
			if (argStr == "YES") {
				result = true;
			}
			return result;
		}

		/**
		 * 引数がnullである場合は、空欄に変換して返す
		 * @param	argStr
		 * @return
		 */
		public static function nullToBlank(argStr : String) : String {
			var result : String = "";
			if (argStr != null) {
				result = argStr;
			}

			return result;
		}

		/**
		 * フロア表記を数値化する
		 * @param	argFloor
		 */
		public static function floorToInt(argFloor : String) : int {
			var result : int = parseInt(argFloor, 10);
			if (argFloor.indexOf("B") > 0) {
				result = result * -1 + 1;
			}

			return result;
		}

		/**
		 * 文字列をDATE型に変換　書式： YYYY-MM-DD hh:mm:ss
		 * @param	dateStr
		 * @return
		 */
		public static function strToDate(dateStr : String) : Date {
			var result : Date;
			var tmpDateArray :/*String*/ 
			Array;

			if (dateStr == "") {
				// result = new Date(0);
				result = null;
			} else {
				tmpDateArray = dateStr.split(" ");
				tmpDateArray = tmpDateArray.concat(tmpDateArray[0].split("-"));
				tmpDateArray = tmpDateArray.concat(tmpDateArray[1].split(":"));
				for (var i : int = 0; i < tmpDateArray.length; i++) {
					tmpDateArray[i] = nanToZero(tmpDateArray[i]);
				}

				result = new Date(parseInt(tmpDateArray[2], 10), parseInt(tmpDateArray[3], 10) - 1, parseInt(tmpDateArray[4], 10), parseInt(tmpDateArray[5], 10), parseInt(tmpDateArray[6], 10), parseInt(tmpDateArray[7], 10));
			}

			return result;
		}

		/**
		 * 文字列をDATE型に変換　書式： YYYYMMDDhhmmss
		 * @param	dateStr
		 * @return
		 */
		public static function strToDate2(dateStr : String) : Date {
			var result : Date;
			var tmpDateArray :/*String*/ 
			Array = [];

			// Debug.write( dateStr + "  dateStr------------------------------------------")

			if (dateStr == "") {
				// result = new Date(0);
				result = null;
			} else {
				tmpDateArray[0] = dateStr.substr(0, 4);	// 年
				tmpDateArray[1] = dateStr.substr(4, 2);	// 月
				tmpDateArray[2] = dateStr.substr(6, 2); // 日
				tmpDateArray[3] = dateStr.substr(8, 2); // 時
				tmpDateArray[4] = dateStr.substr(10, 2); // 分
				tmpDateArray[5] = dateStr.substr(12, 2); // 秒

				// Debug.write( parseInt(tmpDateArray[1], 10)- 1 + "  MONTH------------" + tmpDateArray.  + "-------------------")

				result = new Date(parseInt(tmpDateArray[0], 10), parseInt(tmpDateArray[1], 10) - 1, parseInt(tmpDateArray[2], 10), parseInt(tmpDateArray[3], 10), parseInt(tmpDateArray[4], 10), parseInt(tmpDateArray[5], 10));
			}

			return result;
		}

		/** 日本語用の曜日文字配列 */
		public static const dayLabel_Ja_Array : Array = ["日", "月", "火", "水", "木", "金", "土"];
		public static const monthLabel_En_Array : Array = ["Jan.", "Feb.", "Mar.", "Apr.", "May", "Jun.", "Jul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec.",];

		/**
		 * Date型をYYYY/MM/DD(曜日)の書式の文字列へ変換（未実装）
		 * @param	argDate
		 * @param	pattern Y(年) M（月） D（日） d（曜日） h（時） m（分） s（秒） S（ミリ秒）
		 * @param	lang	言語
		 * @return
		 */
		public static function dateToStr(argDate : Date, pattern : String = "YYYY/MM/DD/hh:mm", lang : String = "ja") : String {
			var result : String = "";

			// パターンを一文字ずつ分解
			// TODO パターン解析

			// 暫定で、強制デフォルトフォーマット
			result = digitFormat(argDate.getFullYear(), 4) + "/" + digitFormat(argDate.getMonth() + 1, 2) + "/" + digitFormat(argDate.getDate(), 2) + "/" + digitFormat(argDate.getHours(), 2) + ":" + digitFormat(argDate.getMinutes(), 2);
			// result = argDate.getFullYear() + "/" + (argDate.getMonth() + 1) + "/" + argDate.getDate() + "(" + dayLabel_Ja_Array[argDate.getDay()] + ")";
			return result;
		}

		public static function dateToTimeStr(argDate : Date) : String {
			var result : String = "";
			result = digitFormat(argDate.getHours(), 2) + ":" + digitFormat(argDate.getMinutes(), 2);
			return result;
		}

		/**
		 * 数字の桁合わせをし、文字列を返す
		 * @param	argNum
		 * @param	digitInt	整数部分の桁数
		 * @param	digitFloat	小数点以下の桁数
		 * @param	{Boolean} commaSeparate	桁区切りをするかどうか
		 * @return
		 */
		public static function digitFormat(argNum : Number, digitInt : int, digitFloat : int = 0, commaSeparate : Boolean = false) : String {
			var result : String;

			/** 整数部分の文字列 */
			var intStr : String = "";
			/** 小数点以下部分の文字列 */
			var floatStr : String = "";

			var tmpNum : Number;
			var tmpStr : String;
			var tmpChar : String;

			var pattern : RegExp = /(\d)(?=(\d{3})+(?!\d))/g;

			if (isNaN(argNum)) {
				argNum = 0;
			} else {
				tmpNum = argNum;
			}

			// 少数点以下の桁合わせ------------
			if (digitFloat > 0) {
				// 指定の位で四捨五入
				tmpNum *= Math.pow(10, digitFloat);
				tmpNum = Math.round(tmpNum);
				tmpNum /= Math.pow(10, digitFloat);

				// 小数点以下の数値文字列の取得
				tmpStr = String(tmpNum).split(".")[1];
				if (tmpStr == null) {
					tmpStr = "0";
				}

				for (var i : int = 0; i < digitFloat; i++) {
					tmpChar = tmpStr.charAt(i);
					if (tmpChar == "") {
						tmpChar = "0"
					}
					floatStr += tmpChar;
				}

				floatStr = "." + floatStr;
			}

			// 整数部分の桁ぞろえ--------------------
			intStr = String(Math.floor(argNum));
			while (intStr.length < digitInt) {
				intStr = "0" + intStr;
			}

			// カンマ桁区切り-------------
			if (commaSeparate) {
				intStr = intStr.replace(pattern, "$1,");
			}

			return intStr + floatStr;
		}

		/**
		 * 非数の場合0を返す
		 * @param	value
		 * @return
		 */
		public static function nanToZero(value : *) : Number {
			var result : Number = 0;
			if (isNaN(value)) {
			} else {
				result = value;
			}

			return result;
		}

		/**
		 * ムービークリップからすべての子供要素をリムーブする
		 * @param	container
		 */
		public static function removeChildren(container : DisplayObjectContainer) : void {
			while (container.numChildren) {
				container.removeChildAt(0);
			}
		}

		/**
		 * length 未満の範囲でループされた数字を返す（超えたら0へ戻って再換算）
		 * @param	argIndex
		 * @param	length
		 * @return
		 */
		public static function getLoopIindex(argIndex : int, length : int) : int {
			var result : int;

			if (argIndex >= length) {
				result = getLoopIindex(argIndex - length, length);
			} else {
				result = argIndex;
			}
			return result
		}
	}
}