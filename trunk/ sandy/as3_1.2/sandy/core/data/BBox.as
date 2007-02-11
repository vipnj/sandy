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
	import flash.utils.*;

	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.Object3D;
	//import sandy.math.VertexMath;
	import sandy.math.VectorMath;
	import sandy.math.Matrix4Math;

	/**
	* BoundingBox object used to clip the object faster.
	* 
	* <p>Create a bounding box that contains the whole object</p>
	*
	* @author		Thomas Pfeiffer - kiroukou
	* @since		0.3
	* @version		0.1
	* @date 		22.03.2006
	*/
	public class BBox
	{
		/**
		 * max vector, representing the upper point of the cube volume
		 */
		public var max:Vector;		
		
		/**
		 * min vector, representing the lower point of the cube volume.
		 */
		public var min:Vector;		
		
		public var aCorners:Array;
		public var aTransformedCorners:Array;
		
		/**
		 * the 3D object owning the Bounding Box
		 */
		public var owner:Object3D;
		
		/**
		 * Create a BBox object, representing a Bounding Box volume englobing the 3D object passed in parameters.
		 * Verry usefull for clipping and so performance !
		 * 
		 */
		private function __compute( a:Array ):void
		{
			var l:int = a.length;
			min.x = max.x = a[0].x; min.y = max.y = a[0].y; min.z = max.z = a[0].z;
			while( --l > 0 )
			{
				var v:Vertex = a[int(l)];
				// --
				if( v.x < min.x )		min.x = v.x;
				else if( v.x > max.x )	max.x = v.x;
				if( v.y < min.y )		min.y = v.y;
				else if( v.y > max.y )	max.y = v.y;
				if( v.z < min.z )		min.z = v.z;
				else if( v.z > max.z )	max.z = v.z;
				
			}
		}	
		
		/**
		* <p>Create a new {@code BBox} Instance</p>
		* 
		* @param	obj		the object owner
		* @param	radius	The radius of the Sphere
		*/ 	
		public function BBox( pobj:Object3D=null )
		{
			owner	= pobj;
			min		= new Vector();
			max		= new Vector();
			aCorners = new Array(8);
			aTransformedCorners = new Array(8);
			var l:int = 8;
			while( --l > -1 )
			{
			    aCorners[int(l)] = new Vector();
			}
			__compute( owner.aPoints );
			__computeCorners();
		}		
		
		/**
		 * Returns the center of the Bounding Box volume as a 3D vector.
		 * @return A vector representing the center of the Bounding Box
		 */
		public function getCenter():Vector
		{
			return new Vector( 	(max.x + min.x) / 2,
								(max.y + min.y) / 2,
								(max.z + min.z) / 2);
		}

		/**
		 * Return the size of the Bounding Box.
		 * @return a Vector representing the size of the volume in three dimensions.
		 */
		public function getSize():Vector
		{
			return new Vector(	Math.abs(max.x - min.x),
								Math.abs(max.y - min.y),
								Math.abs(max.z - min.z));
		}


		/**
		 * get all the 8 corners vertex of the bounding Box volume.
		 * @param b Boolean the b is set to true, we will compute the array of vertex once again, otherwise it will return the last compute array.
		 * @return The array containing 8 Vertex representing the Bounding Box corners.
		 */
		private function __computeCorners():void
		{
			var minx:Number = min.x;
			var miny:Number = min.y;
			var minz:Number = min.z;
			
			var maxx:Number = max.x;
			var maxy:Number = max.y;
			var maxz:Number = max.z;
			
			aCorners[0].x = (minx);aCorners[0].y =  (maxy); aCorners[0].z =  (maxz);
			aCorners[1].x = (maxx);aCorners[1].y =  (maxy); aCorners[1].z =  (maxz);
			aCorners[2].x = (maxx);aCorners[2].y =  (miny); aCorners[2].z =  (maxz);
			aCorners[3].x = (minx);aCorners[3].y =  (miny); aCorners[3].z =  (maxz);
			aCorners[4].x = (minx);aCorners[4].y =  (maxy); aCorners[4].z =  (minz);
			aCorners[5].x = (maxx);aCorners[5].y =  (maxy); aCorners[5].z =  (minz);
			aCorners[6].x = (maxx);aCorners[6].y =  (miny); aCorners[6].z =  (minz);
			aCorners[7].x = (minx);aCorners[7].y =  (miny); aCorners[7].z =  (minz);
		}	
		
	
	    public function transform( p_oMatrix:Matrix4 ):void
	    {
	        var l_nId:int;
	        for( l_nId = 0; l_nId < 8; l_nId++ )
	            aTransformedCorners[l_nId] = Matrix4Math.vectorMult( p_oMatrix, aCorners[l_nId] );
	    }
	    
		/**
		* Get a String represntation of the {@code BBox}.
		* 
		* @return	A String representing the BoundingBox
		*/ 	
		public function toString():String
		{
			return getQualifiedClassName(this);
		}
		
		
		public function clone():BBox
		{
		    var l_oBBox:BBox = new BBox();
		    l_oBBox.owner = owner;
		    l_oBBox.max = max.clone();
		    l_oBBox.min = min.clone();
		    return l_oBBox;
		}
		
	}

}