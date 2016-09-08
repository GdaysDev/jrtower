package com.stanfoot.common.scrollWorld 
{	
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	/**
	 * ScrollWorldクラスで配置されるオブジェクトのコンテナ
	 * @author ...
	 */
	public class ItemContainer extends Sprite
	{
		/** X座標初期値 */
		public var defaultX:Number;
		/** Y座標初期値 */
		public var defaultY:Number;
		/** Z座標初期値 */
		public var defaultZ:Number;
		
		public var content:DisplayObjectContainer;
		
		/**
		 * コンストラクタ
		 * @param	default_x	X座標初期値
		 * @param	default_y	Y座標初期値
		 * @param	default_z	Z座標初期値
		 * @param	scale	大きさ
		 * @param	mirror	反転するかどうか（する場合は-1）
		 */
		public function ItemContainer( arg_x:Number = 0, arg_y:Number = 0, arg_z:Number = 0, scale:Number = 1 , mirror:int = 1) 
		{
			
			defaultX = arg_x;
			defaultY = arg_y;
			defaultZ = arg_z;
			x = arg_x;
			y = arg_y;
			z = arg_z;
			scaleX = scaleY = scale;
			
			if (mirror < 0)
			{
				mirror = -1;
			}
			else
			{
				mirror = 1;
			}
			scaleX = mirror * scaleX;
		}
		
	}

}