/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author Thomas PFEIFFER
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
	import sandy.core.scenegraph.Shape3D;

	public final class PrimitiveFace
	{
		private var m_iPrimitive:Shape3D;
		public var aPolygons:Array = new Array();
	
	
		public function PrimitiveFace( p_iPrimitive:Shape3D )
		{
			m_iPrimitive = p_iPrimitive;
		}

		public function get primitive():Shape3D
		{
			return m_iPrimitive;
		}
		
		public function addPolygon( p_oPolyId:uint ):void
		{
			aPolygons.push( m_iPrimitive.aPolygons[p_oPolyId] );
		}
	}
}
