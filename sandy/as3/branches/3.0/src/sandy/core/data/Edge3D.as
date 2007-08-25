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
	 * <p>[<strong>ToDo</strong>: Explain how to use this creature! ]</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		1.0
	 * @version		3.0
	 * @date 		24.08.2007
	 */
	public final class Edge3D
	{
		/**
		 * [READ-ONLY]
		 * First ID of the vertex which compose the EDGE. The ID correspond to the Geometry3D aVertex list
		 */
		public var vertexId1:uint;
		/**
		 * [READ-ONLY]
		 * Second ID of the vertex which compose the EDGE. The ID correspond to the Geometry3D aVertex list
		 */
		public var vertexId2:uint;

		/**
		 * [READ-ONLY]
		 * First vertex which compose the EDGE. The ID correspond to the Geometry3D aVertex list
		 */
		public var vertex1:Vertex;
		
		/**
		 * [READ-ONLY]
		 * Second vertex which compose the EDGE. The ID correspond to the Geometry3D aVertex list
		 */
		public var vertex2:Vertex;
		
		/**
		 * Creates an Edge3D from two vertices.
		 *
		 */
		public function Edge3D( p_nVertexId1:uint, p_nVertexId2:uint )
		{
			vertexId1 = p_nVertexId1;
			vertexId2 = p_nVertexId2;
		}
		
	}
}