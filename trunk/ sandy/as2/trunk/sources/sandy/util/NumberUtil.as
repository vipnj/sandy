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
* NumberUtil
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @author		Bruce Epstein - zeusprod
* @since		0.2
* @version		1.2
* @date 		21.03.2007 
**/

class sandy.util.NumberUtil 
{
	/**
	 * Constant used pretty much everywhere. Trick of final const keywords use.
	 */
	public static function get TWO_PI():Number { return __TWO_PI; }
	private static var __TWO_PI:Number = 2 * Math.PI;
	/**
	 * Constant used pretty much everywhere. Trick of final const keywords use.
	 */
	public static function get PI():Number { return __PI; }
	private static var __PI:Number = Math.PI;	
	
	/**
	 * Constant used pretty much everywhere. Trick of final const keywords use.
	 */
	public static function get HALF_PI():Number { return __HALF_PI; }
	private static var __HALF_PI:Number = 0.5 * Math.PI;	
	
	/**
	 * Constant used to convert angle from radians to degress
	 */
	public static function get TO_DEGREE():Number { return __TO_DREGREE; }
	private static var __TO_DREGREE:Number = 180 /  Math.PI;
	
	/**
	 * Constant used to convert degress to radians.
	 */
	public static function get TO_RADIAN():Number { return __TO_RADIAN; }
	private static var __TO_RADIAN:Number = Math.PI / 180;
	
	/**
	 * Value used to compare a number and another one. Basically it's used to say if a number is zero or not.
	 */
	public static var TOL:Number = 0.0001;	
		
	/**
	 * Say if a Number is close enought to zero to ba able to say it's zero. 
	 * Adjust TOL property depending on the precision of your Application
	 * @param n Number The number to compare with zero
	 * @return Boolean true if the Number is comparable to zero, false otherwise.
	 */
	public static function isZero( n:Number ):Boolean
	{
		return _fABS( n ) < TOL ;
	}
	
	/**
	 * Say if a Number is close enought to another to ba able to say they are equal. 
	 * Adjust TOL property depending on the precision of your Application
	 * @param n Number The number to compare m
	 * @param m Number The number you want to compare with n
	 * @return Boolean true if the numbers are comparable to zero, false otherwise.
	 */
	public static function areEqual( n:Number, m:Number ):Boolean
	{
		return _fABS( n - m ) < TOL ;
	}
	
	/**
	 * Convert an angle from Radians to Degrees unit
	 * @param n  Number Number representing the angle in radian
	 * @return Number The angle in degrees unit
	 */
	public static function toDegree ( n:Number ):Number
	{
		return n * TO_DEGREE;
	}
	
	/**
	 * Convert an angle from Degrees to Radians unit
	 * @param n  Number Number representing the angle in dregrees
	 * @return Number The angle in radian unit
	 */
	public static function toRadian ( n:Number ):Number
	{
		return n * TO_RADIAN;
	}
		
	/**
	 * Add a constrain to the number which must be between min and max values. Usually name clamp ?
	 * @param n Number The number to constrain
	 * @param min Number The minimal valid value
	 * @param max Number The maximal valid value
	 * @return Number The number constrained
	 */
	 public static function constrain( n:Number, min:Number, max:Number ):Number
	 {
	 	return Math.max( Math.min( n, max ) , min );
	 }
	 
	/**
	 * Round a number to specified accuracy
	 * @param n Number The number to round
	 * @param roundToInterval Number The accuracy to which to round
     *    (i.e., set roundInterval to 0.01 to round 2 to decimal places)
	 * @return Number The rounded number
	 */

	 public static function roundTo (n:Number, roundToInterval:Number):Number {
		if (roundToInterval == undefined) {
			roundToInterval = 1;
		}
		return Math.round(n/roundToInterval) * roundToInterval;
	}
	 
	private static var _fABS:Function = Math.abs;	
}