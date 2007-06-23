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
import sandy.core.data.Matrix4;
import sandy.math.VectorMath;
import sandy.math.Matrix4Math;

/**
* BoundingBox object used to clip the object faster.
* <p>Create a bounding box that contains the whole object</p>
* @author		Thomas Pfeiffer - kiroukou
* @version		0.1
* @date 		22.03.2006
*/
class sandy.bounds.BBox
{
	/**
	 * max vector, representing the upper point of the cube volume
	 */
	public var max:Vector;		
	
	/**
	 * min vector, representing the lower point of the cube volume.
	 */
	public var min:Vector;		

	public var m_oTMin:Vector;
	public var m_oTMax:Vector;
	
	public var aCorners:Array;
	public var aTCorners:Array;
	
	
	/**
	 * Create a BBox object, representing a Bounding Box volume englobing the 3D object passed in parameters.
	 * Verry usefull for clipping and so performance !
	 * 
	 */	
	public static function create( p_aPts:Array ):BBox
	{
	    var l:Number = p_aPts.length;
	    var l_min:Vector = new Vector();
	    var l_max:Vector = new Vector();
		l_min.x = l_max.x = p_aPts[0].x; 
		l_min.y = l_max.y = p_aPts[0].y; 
		l_min.z = l_max.z = p_aPts[0].z;
		while( --l > 0 )
		{
			var v:Vertex = p_aPts[int(l)];
			// --
			if( v.x < l_min.x )		l_min.x = v.x;
			else if( v.x > l_max.x )	l_max.x = v.x;
			if( v.y < l_min.y )		l_min.y = v.y;
			else if( v.y > l_max.y )	l_max.y = v.y;
			if( v.z < l_min.z )		l_min.z = v.z;
			else if( v.z > l_max.z )	l_max.z = v.z;
		}
		
		return new BBox( l_min, l_max );
	}


	/**
	* <p>Create a new {@code BBox} Instance</p>
	* @param	obj		the object owner
	* @param	radius	The radius of the Sphere
	*/ 	
	public function BBox( p_min:Vector, p_max:Vector )
	{
		min		= (p_min) ? p_min : new Vector( -0.5,-0.5,-0.5 );
		max		= (p_max) ? p_max : new Vector(  0.5, 0.5, 0.5 );
		m_oTMin = new Vector();
		m_oTMax = new Vector();
		aCorners = new Array(8);
		aTCorners = new Array(8);
		__computeCorners(false);
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
	private function __computeCorners( b:Boolean ):Array
	{
		var minx:Number,miny:Number,minz:Number,maxx:Number,maxy:Number,maxz:Number;
		if( b == true )
		{
		    minx = m_oTMin.x;    miny = m_oTMin.y;    minz = m_oTMin.z;
		    maxx = m_oTMax.x;    maxy = m_oTMax.y;    maxz = m_oTMax.z;
		}
		else
		{
		    minx = min.x;    miny = min.y;    minz = min.z;
		    maxx = max.x;    maxy = max.y;    maxz = max.z;
		}
		// --
		aCorners[0] = new Vector((minx), (maxy), (maxz));
		aCorners[1] = new Vector((maxx), (maxy), (maxz));
		aCorners[2] = new Vector((maxx), (miny), (maxz));
		aCorners[3] = new Vector((minx), (miny), (maxz));
		aCorners[4] = new Vector((minx), (maxy), (minz));
		aCorners[5] = new Vector((maxx), (maxy), (minz));
		aCorners[6] = new Vector((maxx), (miny), (minz));
		aCorners[7] = new Vector((minx), (miny), (minz));
		// --
		return aCorners;
	}	
	

    public function transform( p_oMatrix:Matrix4 ):Void
    {
	    var v:Vector;
	    var l_aCorners:Array = aCorners;
	    var i:Number, l:Number = 8;
	    // --
	    for(i=0; i<l; i++)
	        aTCorners[int(i)] = Matrix4Math.vectorMult( p_oMatrix, l_aCorners[int(i)] );
	    // --
	    m_oTMin = m_oTMax = aTCorners[0];
		for( i=1; i<l; i++ )
		{
			v = aTCorners[int(i)];
			// --
			if( v.x < m_oTMin.x )		m_oTMin.x = v.x;
			else if( v.x > m_oTMax.x )	m_oTMax.x = v.x;
			// --
			if( v.y < m_oTMin.y )		m_oTMin.y = v.y;
			else if( v.y > m_oTMax.y )	m_oTMax.y = v.y;
			// --
			if( v.z < m_oTMin.z )		m_oTMin.z = v.z;
			else if( v.z > m_oTMax.z )	m_oTMax.z = v.z;
    	}
    }
    
	/**
	* Get a String represntation of the {@code BBox}.
	* @return	A String representing the BoundingBox
	*/ 	
	public function toString():String
	{
		return "sandy.bounds.BBox";
	}
	
	
	public function clone():BBox
	{
	    var l_oBBox:BBox = new BBox();
	    l_oBBox.max = max.clone();
	    l_oBBox.min = min.clone();
	    l_oBBox.m_oTMax = m_oTMax.clone();
	    l_oBBox.m_oTMin = m_oTMin.clone();
	    return l_oBBox;
	}
	
}