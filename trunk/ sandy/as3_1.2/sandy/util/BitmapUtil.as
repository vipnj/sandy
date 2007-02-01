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

	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.geom.*;

	
	/**
	* Utilities for the BitmapData object
	*/
	public class BitmapUtil
	{
		/**
		* Convert a movieClip to a bitmapData. Take care of the movieclip position.
		* The simple BitmapData.draw method doesn't take care of the negative part of the movieclip during the draw. 
		* This method does.
		* @param	mc The movieClip to convert to a Bitmap
		* @return BitmapData
		*/
		public static function movieToBitmap( mc:DisplayObject, pTransparent:Boolean = true, pColor:Number = 0x00FF00CC ):BitmapData
		{
			var bmp:BitmapData;
			if( pTransparent )
			{
				bmp = new BitmapData( mc.width, mc.height, pTransparent, pColor );
			}
			else
			{
				bmp = new BitmapData( mc.width, mc.height, pTransparent );
			}
			
			var scale:Matrix = new Matrix();
			scale.scale( mc.scaleX, mc.scaleY );
			bmp.draw( mc, scale, mc.transform.colorTransform );
			
			//
			return bmp;
		}
		
		public static function getScaledBitmap( b:BitmapData, scalex:Number, scaley:Number ):BitmapData
		{
			scaley = (undefined == scaley) ? scalex : scaley;
			var tex:BitmapData = new BitmapData( scalex * b.width, scaley * b.height);
			tex.draw( b, new Matrix( scalex, 0, scaley, 0 ) );
			return tex;
		}
	}
}