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

import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.Object3D;
import sandy.math.VertexMath;
import sandy.math.VectorMath;

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
class sandy.core.data.BBox
{
	/**
	 * max vector, representing the upper point of the cube volume
	 */
	public var max:Vector;
	
	/**
	 * min vector, representing the lower point of the cube volume.
	 */
	public var min:Vector;
	
	/**
	 * the 3D object owning the Bounding Box
	 */
	public var owner:Object3D;
	
	/**
	 * Create a BBox object, representing a Bounding Box volume englobing the 3D object passed in parameters.
	 * Very useful for clipping and so performance !
	 * @param obj Object3D The object that you want to add a bounding Box volume.
	 */
	public function compute( a:Array ):Void
	{
		var l:Number = a.length;
		min.x = max.x = a[0].wx; min.y = max.y = a[0].wy; min.z = max.z = a[0].wz;
		while( --l > 0 )
		{
			var v:Vertex = a[l];
			// --
			if( v.wx < min.x )		min.x = v.wx;
			else if( v.wx > max.x )	max.x = v.wx;
			if( v.wy < min.y )		min.y = v.wy;
			else if( v.wy > max.y )	max.y = v.wy;
			if( v.wz < min.z )		min.z = v.wz;
			else if( v.wz > max.z )	max.z = v.wz;
			
		}
	}
	
	/**
	* <p>Create a new {@code BBox} Instance</p>
	* 
	* @param	obj		the object owner
	* @param	radius	The radius of the Sphere
	*/ 	
	public function BBox( pobj:Object3D, pmin:Vector, pmax:Vector )
	{
		owner	= pobj;
		min		= new Vector();
		max		= new Vector();
		_aCorners = new Array(8);
		var l:Number = 8;
		while( --l > -1 ) _aCorners[l] = new Vector();
		compute( owner.aPoints );
	}
	
	/**
	 * Returns the center of the Bounding Box volume as a 3D vector.
	 * @return A vector representing the center of the Bounding Box
	 */
	public function getCenter( Void ):Vector
	{
		return new Vector( 	(max.x + min.x) / 2,
							(max.y + min.y) / 2,
							(max.z + min.z) / 2);
	}

	/**
	 * Return the size of the Bounding Box.
	 * @return a Vector representing the size of the volume in three dimensions.
	 */
	public function getSize( Void ):Vector
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
	public function getCorners ( b:Boolean ):Array
	{
		if( b )
		{
			var minx:Number = min.x;
			var miny:Number = min.y;
			var minz:Number = min.z;
			
			var maxx:Number = max.x;
			var maxy:Number = max.y;
			var maxz:Number = max.z;
			
			_aCorners[0].x = (minx);_aCorners[0].y =  (maxy); _aCorners[0].z =  (maxz);
			_aCorners[1].x = (maxx);_aCorners[1].y =  (maxy); _aCorners[1].z =  (maxz);
			_aCorners[2].x = (maxx);_aCorners[2].y =  (miny); _aCorners[2].z =  (maxz);
			_aCorners[3].x = (minx);_aCorners[3].y =  (miny); _aCorners[3].z =  (maxz);
			_aCorners[4].x = (minx);_aCorners[4].y =  (maxy); _aCorners[4].z =  (minz);
			_aCorners[5].x = (maxx);_aCorners[5].y =  (maxy); _aCorners[5].z =  (minz);
			_aCorners[6].x = (maxx);_aCorners[6].y =  (miny); _aCorners[6].z =  (minz);
			_aCorners[7].x = (minx);_aCorners[7].y =  (miny); _aCorners[7].z =  (minz);
		}
		return _aCorners;
	}
	
	/**
	* Get a String represntation of the {@code BBox}.
	* 
	* @return	A String representing the BoundingBox
	*/ 	
	public function toString( Void ):String
	{
		return "sandy.core.data.BBox";
	}
	
	private var _aCorners:Array;
}

