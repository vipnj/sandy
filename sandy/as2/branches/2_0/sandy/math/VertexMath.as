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

import sandy.core.data.Vertex;
import sandy.math.VectorMath;
 
/**
* Math functions for {@link Vertex}.
*  
* @author		Thomas Pfeiffer - kiroukou
* @version		0.2
* @date 		12.01.2006 
**/
class sandy.math.VertexMath extends VectorMath
{
	
	private function VertexMath()
	{
	} 
	
	/**
	 * Compute the oposite of the {@code Vertex}.
	 *
	 * @param {@code v} a {@code Vertex}.
	 * @return a {@code Vertex}.
	 */
	public static function negate( v:Vertex ): Vertex
	{
		return new Vertex (	- v.x,
                      		- v.y,
               				- v.z );
	}

	/**
	 * Compute the dot product of the two {@code Vertex}.
	 *
	 * @param {@code v} a {@code Vertex}.
	 * @param {@code w} a {@code Vertex}.
	 * @return the dot procuct of the 2 {@code Vertex}.
	 */
	public static function dot( v: Vertex, w: Vertex):Number
	{
		return ( v.wx * w.wx + v.wy * w.wy + w.wz * v.wz );
	}
	
	/**
	 * Compute the addition of the two {@code Vertex}.
	 * TODO : Check here! We should add all the properties of the vertices!
	 * @param {@code v} a {@code VertexVertex}.
	 * @param {@code w} a {@code Vertex}.
	 * @return The resulting {@code Vertex}.

	 */
	public static function addVertex( v:Vertex, w:Vertex ): Vertex
	{
		return new Vertex(	v.x + w.x ,
                           	v.y + w.y ,
                        	v.z + w.z );
	}
	
	/**
	 * Compute the substraction of the two  {@code Vertex}.
	 *
	 * @param {@code v} a {@code Vertex}.
	 * @param {@code w} a {@code Vertex}.
	 * @return The resulting {@code Vertex}.
	 */
	public static function sub( v:Vertex, w:Vertex ): Vertex
	{
		return new Vertex(	 v.x - w.x ,
                             v.y - w.y ,
                             v.z - w.z ,
                             v.wx - w.wx ,
                             v.wy - w.wy ,
                             v.wz - w.wz );
	}	
	
	/**
	 * Compute the cross product of the two {@code Vertex}.
	 *
	 * @param {@code v} a {@code Vertex}.
	 * @param {@code w} a {@code Vertex}.
	 * @return the {@code Vertex} resulting of the cross product.
	 */
	public static function cross(w:Vertex, v:Vertex):Vertex
	{
		// cross product vector that will be returned
		return new Vertex (		(w.y * v.z) - (w.z * v.y) ,
								(w.z * v.x) - (w.x * v.z) ,
								(w.x * v.y) - (w.y * v.x));
	}
	
	/**
	 * clone the {@code Vertex}.
	 *
	 * @param {@code v} a {@code Vertex}.
	 * @return a clone of the Vertex passed in parameters
	 */	
	public static function clone( v:Vertex ): Vertex
	{
		return new Vertex( v.x, v.y, v.z );
	}	
}