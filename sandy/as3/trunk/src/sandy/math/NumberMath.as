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
	/**
	 * Math functions for Numbers (angles).
	 *
	 * <p>[<strong>ToDo</strong>: Don't we have this somewhere else? ]</p>
	 *  
	 * @author		Thomas Pfeiffer - kiroukou
	 * @author		Tabin Cédric - thecaptain
	 * @author		Nicolas Coevoet - [ NikO ]
	 * @since		0.1
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class NumberMath
	{
		private static var _2rad:Number = Math.PI/180;
		private static var _2deg:Number = 180/Math.PI;
		
		/**
		 * Converts an angular value from degrees to radians.
		 * 
		 * @param p_nAngle 	The angle in degrees
		 * @return		The angle in radians
		 */	
		public static function toRadian( p_nAngle:Number ):Number
		{
			return p_nAngle*_2rad;
		}
	
		/**
		 * Converts an angular value from degrees to radians.
		 * 
		 * @param p_nAngle 	The angle in radians
		 * @return		The angle in degrees
		 */	
		public static function toDegree (p_nAngle:Number):Number
		{
			return p_nAngle*_2deg;
		}
	}
}