﻿/*
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

import sandy.core.data.Vertex;

/**
 * <p>The Edge3D class stores two related Vertex objects that make an edge.
 * Multiple polygons can share similar vertices, which are considered edges.</p>
 *
 * @author		Thomas Pfeiffer - kiroukou
 * @author		(porting) Floris - xdevltd
 * @since		1.0
 * @version		2.0.2
 * @date 		24.08.2007
 *
 * @see sandy.core.data.Polygon
 * @see sandy.core.scenegraph.Geometry3D
 */

class sandy.core.data.Edge3D
{
	 
	/**
	 * The index of the first vertex of the edge in the Geometry3D <code>aVertex</code> array.
	 */
	public var vertexId1:Number;

	/**
	 * The index of the second vertex of the edge in the Geometry3D <code>aVertex</code> array.
	 */
	public var vertexId2:Number;

	/**
	 * First vertex of the edge (not in use?).
	 */
	public var vertex1:Vertex;
		
	/**
	 * Second vertex of the edge (not in use?).
	 */
	public var vertex2:Vertex;
		
	/**
	 * Creates an edge from two vertices.
	 */
	public function Edge3D( p_nVertexId1:Number, p_nVertexId2:Number )
	{
		vertexId1 = int( p_nVertexId1 );
		vertexId2 = int( p_nVertexId2 );
	}
	
	/**
	 * Returns a new Edge3D object that is a clone of the original instance. 
	 * 
	 * @return A new Edge3D object that is identical to the original. 
	 */		
	public function clone():Edge3D
	{
		var l_oEdge:Edge3D = new Edge3D( vertexId1, vertexId2 );
		return l_oEdge;
	}
	
}