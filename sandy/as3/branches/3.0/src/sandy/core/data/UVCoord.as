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
	 * A 2D coordinate point on a texture that corresponds to a vertex of a polygon in 3D space.
	 *
	 * <p>The UVCoord represents the position of a vertex on the Bitmap used to dress the polygon.<br />
	 * It is the 2D texture coordinates, used in the BitmapMaterial and VideoMaterial.</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		0.3
	 * @version		3.0
	 * @date 		24.08.2007
	 */
	public final class UVCoord
	{
		/**
		 * The u coordinate.
		 */
		public var v: Number;

		/**
		 * The v coordinate.
		 */
		public var u: Number;

		/**
		* Creates a new UV coordinate.
		*
		* @param p_nU Number the x texture position  in the bitmap
		* @param p_nV Number the y texture position in the bitmap.
		*/
		public function UVCoord( p_nU: Number=0, p_nV: Number=0 )
		{
			u = p_nU;
			v = p_nV;
		}

		/**
		* Returns a string representing this UVCoord.
		*
		* @return	The string representation
		*/
		public function toString(): String
		{
			return "sandy.core.data.UVCoord" + "(u:" + u+", v:" + v + ")";
		}

		/**
		 * Return a clone of this UVCoord.
		 *
		 * @return 	The clone
		 */
		public function clone():UVCoord
		{
			return new UVCoord(u, v);
		}
	}
}