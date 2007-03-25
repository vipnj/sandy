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

/**
* Math functions for colors.
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin C�dric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
 * @since		0.1
 * @version		0.2
 * @date 		12.01.2006
* 
**/
class sandy.math.ColorMath
{
	private function ColorMath(){}
	
	/**
	* Convert rgb to hexadecimal.
	* 
	* @param	r	Red Color. Value between 0 and 255
	* @param	g	Green Color. Value between 0 and 255
	* @param	b	Blue Color. Value between 0 and 255
	* @return	The hexadecimal color of the rvb given.
	*/
	public static function rgb2hex(r:Number, g:Number, b:Number):Number  
	{
		return ((r << 16) | (g << 8) | b);
	}

	/**
	* Convert hexadecimal to rvb object
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
	* Convert hexadecimal to rvb object but normalized between (0 and 1.0)
	* 
	* @param	hex	hexadecimal color.
	* @return	The rgb color of the hexadecimal given. (values normalized between 0 and 1.0 )
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