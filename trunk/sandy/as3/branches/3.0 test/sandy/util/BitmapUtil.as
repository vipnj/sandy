/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author or authors.
Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.mozilla.org/MPL/MPL-1.1.html
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# ***** END LICENSE BLOCK *****
*/
package sandy.util {
	import flash.display.BitmapData;
	import flash.geom.*;
	import flash.display.Sprite;
	
	/**
	* Utilities for the BitmapData object
	*/
	public class BitmapUtil
	{
		/**
		 * Convert a sprite to a bitmapData. Take care of the sprite position.
		 * The simple BitmapData.draw method doesn't take care of the negative part of the sprite during the draw. 
		 * This method does.
		 * @param	sprite The sprite to convert to a Bitmap
		 * @return BitmapData
		 */
		public static function movieToBitmap( sprite:Sprite, pTransparent:Boolean=true, pColor:Number=0x00FF00CC /* a random color, needed tby the bitmapData constructor to apply transparency */ ):BitmapData
		{
			var bmp:BitmapData;
			// --
			bmp = new BitmapData( sprite.width, sprite.height, pTransparent, pColor );
			bmp.draw( sprite );
			// --
			return bmp;
		}
		
		public static function getScaledBitmap( b:BitmapData, scalex:Number, scaley:Number=0 ):BitmapData
		{
			//scaley = (undefined == scaley) ? scalex : scaley;
			var tex:BitmapData = new BitmapData( scalex * b.width, scaley * b.height);
			tex.draw( b, new Matrix( scalex, 0, 0, scaley ) );
			return tex;
		}
		
		public static function concatBitmapMatrix( m1:Object, m2:Object ):Object
		{	
			var r:Object = new Object();
			// --
			r.a = m1.a * m2.a;
			r.d = m1.d * m2.d;
			r.b = r.c = 0;
			r.ty = m1.ty * m2.d + m2.ty;
			r.tx = m1.tx * m2.a + m2.tx;
			// --
			if( m1.b != 0 || m1.c !=0 || m2.b != 0 || m2.c != 0 )
			{
				r.a  += m1.b * m2.c;
				r.d  += m1.c * m2.b;
				r.b  += m1.a * m2.b + m1.b * m2.d;
				r.c  += m1.c * m2.a + m1.d * m2.c;
				r.tx += m1.ty * m2.c;
				r.ty += m1.tx * m2.b;
			}
			// --
			return r;
		}
	}
}