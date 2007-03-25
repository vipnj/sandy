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
	* UVCoord
	* <p>The UVCoord class is a data structure class. It represents the position of a vertex in the Bitmap.
	* In other words it is the texture coordinates, used in the TextureSkin class for example</p>
	* @author		Thomas Pfeiffer - kiroukou
	* @version		0.3
	* @date 		28.03.2006
	*/
	class sandy.core.data.UVCoord
	{
		public var v: Number;
		public var u: Number;
		
		/**
		* Create a new {@code UVCoord}.
		* 
		* @param nU Number the x texture position  in the bitmap
		* @param nV Number the y texture position in the bitmap.
		*/ 
		public function UVCoord( nU: Number, nV: Number )
		{
			u = nU;
			v = nV;
		}
		
		/**
		* Get a String representation of the {@code UVCoord}.
		* 
		* @return	A String representing the {@code UVCoord}.
		*/ 	
		public function toString(): String
		{
			return "sandy.core.data.UVCoord" + "(u:" + u+", v:" + v + ")";
		}
		
		public function clone():UVCoord
		{
			return new UVCoord(u, v);
		}
	}