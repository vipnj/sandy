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

package sandy.math 
{
	import sandy.errors.SingletonError;
	
	/**
	 * Math functions for colors.
	 *  
	 * @author		Thomas Pfeiffer - kiroukou
	 * @author		Tabin Cédric - thecaptain
	 * @author		Nicolas Coevoet - [ NikO ]
	 * @since		0.1
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class ColorMath
	{
		private static var instance:ColorMath;
		private static var create:Boolean;
		
		/**
		 * Creates a ColorMath object.
		 * 
		 * <p>This is a singleton constructor, and should not be called directly.<br />
		 * If called from outside the ColorMath class, it throws a SingletonError.</p>
		 * [<strong>ToDo</strong>: Why instantiate this at all? - all methods are class methods! ]
		 */ 
		public function ColorMath(){
			if ( !create )
			{
				throw new SingletonError();
			}
		}
		
		/**
		 * Returns an instance of this class.
		 *
		 * <p>Call this method to get an instance of ColorMath</p>
		 */
		public static function getInstance():ColorMath
		{
			if (instance == null)
			{
				create = true;
				instance = new ColorMath();
				create = false;
			}
			
			return instance;
		}
		
		/**
		 * Converts color component values ( rgb ) to one hexadecimal value.
		 * 
		 * @param r	Red Color. 	( 0 - 255 )
		 * @param g	Green Color. 	( 0 - 255 )
		 * @param b	Blue Color. 	( 0 - 255 )
		 * @return	The hexadecimal value
		 */
		public static function rgb2hex(r:Number, g:Number, b:Number):Number  
		{
			return ((r << 16) | (g << 8) | b);
		}
	
		/**
		 * Converts a hexadecimal color value to rgb components
		 * 
		 * @param	hex	hexadecimal color.
		 * @return	The rgb color of the hexadecimal given.
		 */   
		public static function hex2rgb(hex:Number):Object 
		{
			var r:Number;
			var g:Number;
			var b:Number;
			r = (0xFF0000 & hex) >> 16;
			g = (0x00FF00 & hex) >> 8;
			b = (0x0000FF & hex);
			return {r:r,g:g,b:b} ;
		}
	
		/**
		* Converts hexadecimal color value to normalized rgb components ( 0 - 1 ).
		* 
		* @param	hex	hexadecimal color value.
		* @return	The normalized rgb components ( 0 - 1.0 )
		*/   
		public static function hex2rgbn(hex:Number):Object 
		{
			var r:Number;
			var g:Number;
			var b:Number;
			r = (0xFF0000 & hex) >> 16;
			g = (0x00FF00 & hex) >> 8;
			b = (0x0000FF & hex);
			return {r:r/255,g:g/255,b:b/255} ;
		}
	}
}