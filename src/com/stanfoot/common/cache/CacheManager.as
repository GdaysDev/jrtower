package com.stanfoot.common.cache 
{
	import com.stanfoot.common.debug.Debug;
	import com.stanfoot.common.GeneralFuncs;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author 
	 */
	public class CacheManager 
	{
		/** シェアドオブジェクト */
		private static var _sharedObject:SharedObject;
		private static var _name:String;
		private static var _localPath:String;
		private static var _objName:String = "lastData";
		private static var _maxCacheImgNum:int = 10;
		
		/**
		 * 初期化
		 * @param	name	シェアオブジェクト用オブジェクト名
		 * @param	maxCacheImgNum	画像の最大保存数
		 * @param	dailyReset	日付が変わるとキャッシュをクリアするかどうか
		 */
		public static function init(name:String, maxCacheImgNum:int = 10, dailyReset:Boolean = false, localPath:String = null):void
		{
			Debug.write("[CacheManager] 初期化")
			
			_name = name;
			_localPath = localPath;
			_sharedObject = SharedObject.getLocal(_name, _localPath);
			
			var tmpDate:Date = _sharedObject.data.updateDate as Date;
			var currentDate:Date;
			Debug.write("[CacheManager] 最終更新日時:" + tmpDate);
			if (dailyReset && tmpDate)
			{
				//最終更新日時と日付が異なる場合は、リセットする。
				currentDate = new Date();
				
				if ((currentDate.getFullYear() != tmpDate.getFullYear()) || (currentDate.getMonth() != tmpDate.getMonth()) || (currentDate.getDate() != tmpDate.getDate())) 
				{
					_sharedObject.clear();
				}
			}
			
			
			_maxCacheImgNum = maxCacheImgNum;
		}
		
		public static function clear():void
		{
			if (_sharedObject)
			{
				_sharedObject.clear();
				_sharedObject.flush();
			}
			else
			{
				Debug.write("[CacheManager] //ERROR// シェアドオブジェクトが見つかりません");
			}
		}
		
		//================================================================================
		
		/**
		 * SharedObjectから前回最終表示データを格納したObjectを取得する
		 * {restXml:XML, lastIndex:int, imageList:Array}
		 * @return
		 */
		 public static function getLastData():Object
		{
			var result:Object;
			var tmpObject:Object = {};
			
			
			
			//SharedObjectの読み込み
			if (_sharedObject == null)
			{
				_sharedObject = SharedObject.getLocal(_name, _localPath);
			}
			
			if (_sharedObject.size > 0 && _sharedObject.data[_objName])
			{
				tmpObject = _sharedObject.data[_objName];
				
				//最終表示インデックスの検証
				/*if (isNaN(tmpObject.lastIndex))
				{
					tmpObject.lastIndex = -1;
				}*/
				if ( tmpObject.lastIndexList == null)
				{
					tmpObject.lastIndexList = [];
				}
				//XMLの検証
				if (tmpObject.restXml == null || tmpObject.restXml == undefined)
				{
					tmpObject.restXml = null;
				}
				//画像リストの検証
				if (tmpObject.imageList == null || tmpObject.imageList == undefined)
				{
					tmpObject.imageList = [];
				}
				
				result = tmpObject;
			}
			else
			{
				Debug.write("[CacheManager] SharedObjectから前回表示した最終データを検出できませんでした。");
				//保存用のObjectを生成
				result = { restXml:null, lastIndexList: [], imageList:[] };
			}
			
			return result;
		}
		
		
		
		
		//================================================================================
		
		private static function _saveUpdateDate():void
		{
			_sharedObject.data.updateDate = new Date();
		}		
		
		//================================================================================
		
		public static function saveMiscObj(obj:Object):void
		{
			if (obj as Object)
			{
				var tmpObject:Object = getLastData();
				tmpObject.misc = obj;
				
				_sharedObject.data[_objName] = tmpObject;
				_saveUpdateDate();
				_sharedObject.flush();
				Debug.write("◆[CacheManager] miscObj SAVED : " + obj);
			}
		}
		
		//================================================================================
		
		/**
		 * 引数を最終インデックスとしてSharedObjectに記録
		 * @param	tgtIndex	保存する最終表示インデックス番号
		 * @param	slotIndex	複数種類のインデックスを保存したいときの管理番号
		 */
		public static function saveLastIndex(lastIndex:int, slotIndex:int = 0):void
		{
			if (!isNaN(lastIndex))
			{
				var tmpObject:Object = getLastData();
				//tmpObject.lastIndex = lastIndex;
				if ((tmpObject.lastIndexList as Array) == null )
				{
					tmpObject.lastIndexList = [];
				}
				slotIndex = isNaN(slotIndex) ? 0 : slotIndex;
				tmpObject.lastIndexList[slotIndex] = lastIndex;
				
				_sharedObject.data[_objName] = tmpObject;
				_saveUpdateDate();
				_sharedObject.flush();
				Debug.write("◆[CacheManager] lastIndex SAVED : " + lastIndex + " @[" + slotIndex + "]");
			}
		}
		
		/**
		 * 引数のXMLデータをSharedObjectに記録
		 * @param	restXml	保存するXML
		 */
		public static function saveRestXml(restXml:XML):void
		{
			var tmpObject:Object = getLastData();
			if (restXml)
			{
				tmpObject.restXml = restXml;
				
				_sharedObject.data[_objName] = tmpObject;
				_saveUpdateDate();
				_sharedObject.flush();
				Debug.write("◆[CacheManager] restXml SAVED");
			}
		}
		
		/**
		 * 引数の画像URLと画像データをSharedObjectに記録（最大_maxCacheImgNum件）
		 * @param	imageUrl	画像のURL
		 * @param	imageByteArray	画像のバイトデータ
		 * @param	imageMakeDate	画像生成日
		 */
		public static function saveImageData(imageUrl:String, imageByteArray:ByteArray, imageMakeDate:Date = null):void
		{
			var tmpObject:Object = getLastData();
			var tmpImageList:Array = tmpObject.imageList != null ? tmpObject.imageList : [] ;
			var tmpArray:Array;
			var tmpListItem:Object;
			
			imageUrl = GeneralFuncs.xReplace(imageUrl, "\r", "");
			imageUrl = GeneralFuncs.xReplace(imageUrl, "\n", "");
			
			
			//画像URLがある場合は、リストに追加する
			if (imageUrl && imageUrl != "" && imageUrl)
			{
				tmpArray = [];
				//画像リストに同一のURLが存在する場合は古いものをリストから削除
				for (var i:int = 0; i < tmpImageList.length; i++) 
				{
					tmpListItem = tmpImageList[i];
					//Debug.write(">>>>" + tmpListItem.imageUrl +"\n<<<<"+ imageUrl)
					if (tmpListItem.imageUrl && tmpListItem.imageUrl != imageUrl)
					{
						//Debug.write("保存する: " + tmpListItem.imageUrl)
						tmpArray.push(tmpListItem);
					}
					else
					{
						//Debug.write("保存しない: " + tmpListItem.imageUrl)
					}
				}
				tmpImageList = tmpArray;
				
				//tmpImageList.unshift( { imageUrl:imageUrl, imageByteArray:imageByteArray, imageMakeDate:imageMakeDate } );
				//Array.unshift高速化 unshiftは超重い
				tmpImageList.reverse();
				tmpImageList.push( { imageUrl:imageUrl, imageByteArray:imageByteArray, imageMakeDate:imageMakeDate } );
				tmpImageList.reverse();
				
				//リストが保存最大数を超えたら後ろからから削除する
				while (tmpImageList.length > _maxCacheImgNum + 1)
				{
					//tmpImageList.shift();
					tmpImageList.pop();
				}
				
				tmpObject.imageList = tmpImageList;
				_sharedObject.data[_objName] = tmpObject;
				_saveUpdateDate();
				_sharedObject.flush();
				Debug.write("◆[CacheManager] ImageData SAVED : " + imageUrl);
			}
		}
		
		
		
		
		/**
		 * SharedObjectに保存されているRESTのXMLを取得する
		 * @return
		 */
		public static function getSavedXML():XML
		{
			var tmpObj:Object = getLastData();
			var result:XML = tmpObj.restXml;
			
			var tmpMessage:String = "";
			tmpMessage = result == null ? "NULL" : "OK";
			Debug.write("◇[CacheManager] restXml LOADED : " + tmpMessage);
			return result;
		}
		
		//================================================================================
		
		/**
		 * SharedObjectに保存されている[{(画像URL)と(画像データ)を格納したObject}の配列]を取得する
		 * {imageUrl:Array, imageByteArray:ByteArray, imageMakeDate:Date}
		 * @return
		 */
		public static function getSavedImageList():Array
		{
			var result:Array = _getSavedImageList();
			
			Debug.write("◇[CacheManager] imageList LOADED : " + result.length);
			return result;
		}
		private static function _getSavedImageList():Array
		{
			var tmpObj:Object = getLastData();
			var result:Array = tmpObj.imageList;
			
			return result;
		}
		
		public static function getMiscObj():Object
		{
			var tmpObject:Object = getLastData();
			var result:Object = tmpObject.misc as Object;
			
			Debug.write("◇[CacheManager] miscObj LOADED : " + result);
			return result;
		}
		
		/**
		 * SharedObjectから前回の最終表示インデックスを取得する
		 * @param	slotIndex	複数種類のインデックスを保存したい場合の管理番号
		 * @return
		 */
		public static function getSavedLastIndex(slotIndex:int = 0):int
		{
			var tmpObj:Object = getLastData();
			//var result:int = tmpObj.lastIndex;
			var tmpList:Array = tmpObj.lastIndexList as Array;
			//var tmpInt:int = -1;
			var tmpNum:Number;
			var result:int = -1;
			
			if (tmpList)
			{
				//tmpInt = parseInt(tmpList[slotIndex], 10);
				//result = isNaN(tmpInt) ? result : tmpInt;
				//int型変数ににNaNを代入すると0になる
				
				tmpNum = parseFloat(tmpList[slotIndex]);
				result = isNaN(tmpNum) ? result : tmpNum | 0;
			}
			
			Debug.write("◇[CacheManager] lastindex LOADED : " + result + " @[" + slotIndex + "]");
			return result;
		}
		
		
		//================================================================================
		
		
		/**
		 * imageList にマッチングしたURLのByteArray(解凍済み)の複製と作成日時を返す
		 * {imageByteArray:ByteArray, imageMakeDate:Date}
		 * @param	targetUrl
		 * @return
		 */
		public static function searchImageList( targetUrl:String):Object
		{
			Debug.write("--[CacheManager] searchImageList : " + targetUrl );
			
			var tmpObject:Object = getLastData();
			var tmpImageList:Array = tmpObject && tmpObject.imageList != null ? tmpObject.imageList : [] ;
			
			var result:Object; 
			var cloneImageByteArray:ByteArray = new ByteArray();
			var tmpImageListItem:ImageListItem;
			
			var tmpImageIndex:int = -1;
			var tmpSplicedList:Array;
			
			var tmpImageMakeDate:Date = new Date("");
			var thresholdDate:Date;
			//採用閾値の日時として、6時間前の日時を生成
			thresholdDate = new Date();
			thresholdDate.time -= 6 * 60 * 60 * 1000;
			
			Debug.write("--[CacheManager] キャッシュを検索 / " + tmpImageList.length );
			
			if (targetUrl && targetUrl != "")
			{
				for (var i:int = 0; i < tmpImageList.length; i++) 
				{
					var tmpItem:Object = tmpImageList[i] as Object;
					
					//Debug.write("--[CacheManager] " + i + tmpItem) ;
					
					//6時間以内,または時間指定なしのデータを採用する
					if (tmpItem)
					{
						tmpImageListItem = new ImageListItem(tmpItem.imageUrl as String, tmpItem.imageByteArray as ByteArray, tmpItem.imageMakeDate as Date);
						
						//Debug.write("--[CacheManager]  URL/ " + tmpImageListItem.imageUrl);
						if (tmpImageListItem.imageUrl && tmpImageListItem.imageUrl.indexOf(targetUrl) >= 0)
						{
							Debug.write("--[CacheManager] ファイルURL適合");
							
							if (tmpImageListItem.imageMakeDate == null || tmpImageListItem.imageMakeDate.toString() == "Invalid Date" || tmpImageListItem.imageMakeDate.getTime() > thresholdDate.getTime())
							{
								//Debug.write("--[CacheManager]  時間適合/ ");
								tmpImageIndex = i;
								break;
							}
						}
					}
					else
					{
						Debug.write("--[CacheManager] not imagelistitem" );
					}
				}
				
				
				//画像のバイトアレイを複製する
				if (tmpImageIndex >= 0 && tmpImageListItem && tmpImageListItem.imageByteArray && tmpImageListItem.imageByteArray.length > 0)
				{
					Debug.write("◇[CacheManager] キャッシュされていた画像を確保 : " + tmpImageIndex + " : " + targetUrl);
					
					//選抜したByteArrayを複製する
					tmpImageListItem.imageByteArray.position = 0;
					
					cloneImageByteArray.writeBytes(tmpImageListItem.imageByteArray);
					cloneImageByteArray.uncompress();
					
					//選抜したDateを複製する
					tmpImageMakeDate = tmpImageListItem.imageMakeDate;
					
					//検索された画像は需要があるものとみなし、消されにくいようにリストの最初に移動する。
					tmpSplicedList = tmpImageList.splice(tmpImageIndex, 1)
					if (tmpSplicedList)
					{
						tmpImageList = tmpSplicedList.concat(tmpImageList);
					}
					
					//SharedObject を更新する
					tmpObject.imageList = tmpImageList;
					_sharedObject.data[_objName] = tmpObject;
					_sharedObject.flush();
					
				}
				else
				{
					Debug.write("◇[CacheManager] キャッシュされていた画像は見つかりませんでした : " + targetUrl);
				}
			}
			else
			{
				Debug.write("◇[CacheManager] 検索URLを参照できませんでした : " + targetUrl);
			}
			
			
			result = {imageByteArray:cloneImageByteArray, imageMakeDate:tmpImageMakeDate}
			return result;
		}
		
		public function CacheManager() 
		{
			
		}
		
	}

}

import flash.utils.ByteArray;


class ImageListItem extends Object
{
	public var imageUrl:String;
	public var imageByteArray:ByteArray;
	public var imageMakeDate:Date;
	
	public function ImageListItem(imageUrl:String, imageByteArray:ByteArray = null, imageMakeDate:Date = null)
	{
		this.imageUrl = imageUrl;
		this.imageByteArray = imageByteArray ? imageByteArray : new ByteArray();
		this.imageMakeDate = imageMakeDate ? imageMakeDate : new Date("");
		
		super();
	}
}

