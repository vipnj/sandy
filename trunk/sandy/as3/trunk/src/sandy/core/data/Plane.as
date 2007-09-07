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

package sandy.core.data
{
	/**
	 * A plane in 3D space.
	 *
	 * <p>Used maily to represent the frustrum planes of the camera.</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		0.1
	 * @version		3.0
	 * @date 		24.08.2007
	 */
	final public class Plane
	{
		public var a:Number;
		public var b:Number;
		public var c:Number;
		public var d:Number;

		/**
		* Creates a new Plane instance.
		*
		* @param	p_nA	the first plane coordinate
		* @param	p_nB	the second plane coordinate
		* @param	p_nC	the third plane coordinate
		* @param	p_nd	the forth plane coordinate
		*/
		public function Plane( p_nA:Number=0, p_nB:Number=0, p_nC:Number=0, p_nd:Number=0 )
		{
			this.a = p_nA;
			this.b = p_nB;
			this.c = p_nC;
			this.d = p_nd;
		}


		/**
		 * Returns a string represntation of this plane.
		 *
		 * @return	The string representing this plane.
		 */
		public function toString():String
		{
			return "sandy.core.data.Plane" + "(a:"+a+", b:"+b+", c:"+c+", d:"+d+")";
		}
	}
}