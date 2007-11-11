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
	import sandy.core.data.Vertex;
	import sandy.errors.SingletonError;
	 
	/**
	 * Math functions for vertex manipulation.
	 *  
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		0.2
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class VertexMath extends VectorMath
	{
		private static var instance:VertexMath;
		private static var create:Boolean;
		
		/**
		 * Creates a VertexMath object.
		 * 
		 * <p>This is a singleton constructor, and should not be called directly.<br />
		 * If called from outside the ColorMath class, it throws a SingletonError.</p>
		 * [<strong>ToDo</strong>: Why instantiate this at all? - all methods are class methods! ]
		 */ 
		public function VertexMath(){
			if ( !create )
			{
				throw new SingletonError();
			}
		}
		
		/**
		 * Returns an instance of this class.
		 *
		 * <p>Call this method to get an instance of VertexMath</p>
		 */
		public static function getInstance():VertexMath
		{
			if (instance == null)
			{
				create = true;
				instance = new VertexMath();
				create = false;
			}
			
			return instance;
		}
		
		/**
		 * Computes the opposite of a vertex.
		 *
		 * <p>The "opposite" vertex is a vertex where all components are multiplied by -1</p>
		 *
		 * @param p_oV 	The vertex.
		 * @return 	The opposite vertex.
		 */
		public static function negate( p_oV:Vertex ): Vertex
		{
			return new Vertex (	
						- p_oV.x,
	                      			- p_oV.y,
	               				- p_oV.z 
	               			);
		}
	
		/**
		 * Computes the dot product of the two vertices.
		 *
		 * @param p_oV 	The first vertex
		 * @param p_oW 	The second vertex
		 * @return 	The dot procuct
		 */
		public static function dot( p_oV: Vertex, p_oW: Vertex):Number
		{
			return ( p_oV.wx * p_oW.wx + p_oV.wy * p_oW.wy + p_oW.wz * p_oV.wz );
		}
		
		/**
		 * Adds the two vertices.
		 *
		 * <p>[<strong>ToDo</strong>: Check here! We should add all the properties of the vertices! ]</p>
		 *
		 * @param p_oV 	The first vertex
		 * @param p_oW 	The second vertex
		 * @return 	The resulting vertex
		 */
		public static function addVertex( p_oV:Vertex, p_oW:Vertex ): Vertex
		{
			return new Vertex(	p_oV.x + p_oW.x ,
	                	        p_oV.y + p_oW.y ,
	                	        p_oV.z + p_oW.z,
	                	        p_oV.wx + p_oW.wx ,
	                	        p_oV.wy + p_oW.wy ,
	                	        p_oV.wz + p_oW.wz );
		}
		
		/**
		 * Substracts one vertices from another
		 *
		 * @param p_oV 	The vertex to subtract from
		 * @param p_oW	The vertex to subtract
		 * @return 	The resulting vertex
		 */
		public static function sub( p_oV:Vertex, p_oW:Vertex ): Vertex
		{
			return new Vertex(	 
						p_oV.x - p_oW.x ,
						p_oV.y - p_oW.y ,
						p_oV.z - p_oW.z ,
						p_oV.wx - p_oW.wx ,
						p_oV.wy - p_oW.wy ,
						p_oV.wz - p_oW.wz 
					);
		}	
		
		/**
		 * Computes the cross product the two vertices.
		 *
		 * @param p_oV 	The first vertex
		 * @param p_oW 	The second vertex
		 * @return 	The resulting cross product
		 */
		public static function cross(p_oW:Vertex, p_oV:Vertex):Vertex
		{
			// cross product vector that will be returned
			return new Vertex (	(p_oW.y * p_oV.z) - (p_oW.z * p_oV.y) ,
						(p_oW.z * p_oV.x) - (p_oW.x * p_oV.z) ,
						(p_oW.x * p_oV.y) - (p_oW.y * p_oV.x)
					);
		}
		
		/**
		 * Clones a vertex.
		 *
		 * @param p_oV	A vertex to clone.
		 * @return 	The clone
		 */	
		public static function clone( p_oV:Vertex ): Vertex
		{
			return new Vertex( p_oV.x, p_oV.y, p_oV.z );
		}	
	}
}