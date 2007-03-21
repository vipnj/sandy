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
* Math functions for Numbers (angles).
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @since		0.1
* @version		0.2
* @date 		12.01.2006* 
**/
class sandy.math.NumberMath
{
	private static var _2rad:Number = Math.PI/180;
	private static var _2deg:Number = 180/Math.PI;
	
	/**
	 * Transform a degree angle to radian.
	 * 
	 * @param	n	A degree number.
	 * @return	The radian.
	 */	
	public static function toRadian( n:Number ):Number
	{
		return n*_2rad;
	}

	/**
	 * Transform a radian angle to degree.
	 * 
	 * @param	n	a radian number.
	 * @return	The degree.
	 */	
	public static function toDegree (n:Number):Number
	{
		return n*_2deg;
	}
}