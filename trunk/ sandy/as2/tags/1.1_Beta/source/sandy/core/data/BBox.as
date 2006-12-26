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
	public var max:Vertex;
	
	/**
	 * min vector, representing the lower point of the cube volume.
	 */
	public var min:Vertex;
	
	/**
	 * the 3D object owning the Bounding Box
	 */
	public var owner:Object3D;
	
	/**
	 * Create a BBox object, representing a Bounding Box volume englobing the 3D object passed in parameters.
	 * Verry usefull for clipping and so performance !
	 * @param obj Object3D The object that you want to add a bounding Box volume.
	 */
	public static function create( obj:Object3D ):BBox
	{
		var minx:Number, miny:Number, minz:Number, maxx:Number, maxy:Number, maxz:Number;
		var a:Array = obj.aPoints;
		var l:Number = a.length;
		minx = maxx = a[0].wx; miny = maxy = a[0].wy; minz = maxz = a[0].wz;
		while( --l > 0 )
		{
			var v:Vertex = a[l];
			// --
			if( v.wx < minx )		minx = v.wx;
			else if( v.wx > maxx )	maxx = v.wx;
			if( v.wy < miny )		miny = v.wy;
			else if( v.wy > maxy )	maxy = v.wy;
			if( v.wz < minz )		minz = v.wz;
			else if( v.wz > maxz )	maxz = v.wz;
			
		}
		return new BBox( obj, new Vector( minx, miny, minz ), new Vector( maxx, maxy, maxz ) );
	}
	
	/**
	* <p>Create a new {@code BBox} Instance</p>
	* 
	* @param	obj		the object owner
	* @param	radius	The radius of the Sphere
	*/ 	
	private function BBox( pobj:Object3D, pmin:Vector, pmax:Vector )
	{
		owner	= pobj;
		min		= (undefined == pmin) ? new Vertex() : new Vertex( pmin.x, pmin.y, pmin.z );
		max		= (undefined == pmax) ? new Vertex() : new Vertex( pmax.x, pmax.y, pmax.z );
		_aCorners = [];
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
		if( !b )
			return _aCorners;
		else
			return _aCorners =  
			[
				new Vertex(min.x, max.y, max.z),
				VertexMath.clone( max ),
				new Vertex(max.x, min.y, max.z),
				new Vertex(min.x, min.y, max.z),
				new Vertex(min.x, max.y, min.z),
				new Vertex(max.x, max.y, min.z),
				new Vertex(max.x, min.y, min.z),
				VertexMath.clone( min )
			];
	/*
		pts=new Vector();
		pts.add(p1);
		pts.add(p2);
		pts.add(p3);
		pts.add(p4);
		s1=new Polygon(pts);
		pts=new Vector();
		pts.add(p2);
		pts.add(p6);
		pts.add(p7);
		pts.add(p3);
		s2=new Polygon(pts);
		pts=new Vector();
		pts.add(p1);
		pts.add(p5);
		pts.add(p6);
		pts.add(p2);
		s3=new Polygon(pts);
		pts=new Vector();
		pts.add(p5);
		pts.add(p1);
		pts.add(p4);
		pts.add(p8);
		s4=new Polygon(pts);
		pts=new Vector();
		pts.add(p7);
		pts.add(p8);
		pts.add(p4);
		pts.add(p3);
		s5=new Polygon(pts);
		pts=new Vector();
		pts.add(p6);
		pts.add(p5);
		pts.add(p8);
		pts.add(p7);
		s6=new Polygon(pts);
	*/
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

