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

import sandy.core.data.Matrix4;
import sandy.math.Matrix4Math;
import sandy.math.VectorMath;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;	

/**
* Bounding Sphere object used to clip the object faster.
* 
* <p>Create a bounding Sphere that contains the whole object</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @version		0.1
* @date 		22.02.2006
*/
class sandy.bounds.BSphere
{
	public var center:Vector;
	public var radius:Number;
	// -----------------------------
	//    [TRANSFORMED]  -----------
	public var m_oPosition:Vector;
	public var m_nTRadius:Number;

	/**
	 * Create a BSphere object, representing a Bounding Sphere volume englobing the 3D object passed in parameters.
	 * Verry usefull for clipping and so performance !
	 * 
	 */	
	public static function create( p_aPts:Array ):BSphere
	{
	    var l_sphere:BSphere = new BSphere();
	    l_sphere.compute( p_aPts );
		return l_sphere;
	}
			
	/**
	* <p>Create a new {@code BSphere} Instance</p>
	* 
	* @param	pos	The center of the sphere
	* @param	radius	THe radius of the Sphere
	*/ 	
	public function BSphere()
	{
		center = new Vector();
		m_oPosition = new Vector();
		radius = 1.0;
	}
	
    public function transform( p_oMatrix:Matrix4 ):Void
    {
        m_oPosition = Matrix4Math.vectorMult( p_oMatrix, center );
        //var l_ncale:Number = Math.sqrt( p_oMatrix.n11 * p_oMatrix.n11 + p_oMatrix.n22 * p_oMatrix.n22 + p_oMatrix.n33 * p_oMatrix.n33 );
        m_nTRadius = radius;// * l_ncale;
    }
    		
	/**
	* Get a String represntation of the {@code BSphere}.
	* 
	* @return	A String representing the Bounding Sphere
	*/ 	
	public function toString():String
	{
		return "sandy.bounds.BSphere (center : "+center+", radius : "+radius + ")";
	}
	
			
	public function compute( pPoints:Array ):Void
	{
		var x:Number, y:Number, z:Number, d:Number;
		var p:Array = new Array(pPoints.length);
		p[0] = pPoints[0].getVector();
		var i:Number, j:Number, l:Number = pPoints.length;
		for( i = 1; i < l; i++) 
		{
			p[i] = pPoints[int(i)].getVector();
		}

		var p1:Vector = p[0];
		var p2:Vector = p[0];
		// find the farthest couple of points
		var dmax:Number = 0;
		for( i = 0; i < l; i++) 
		{
			for( j = i + 1; j < l; j++) 
			{
				x = p[int(j)].x - p[int(i)].x;
				y = p[int(j)].y - p[int(i)].y;
				z = p[int(j)].z - p[int(i)].z;
				d = x * x + y * y + z * z;
				if(d > dmax) 
				{
					dmax = d;
					p1 = p[int(i)];
					p2 = p[int(j)];
				}
			}
		}

		center = new Vector((p1.x + p2.x) / 2, (p1.y + p2.y) / 2, (p1.z + p2.z) / 2);
		radius = Math.sqrt(dmax) / 2;
        /*
		var r:Array = pointsOutofSphere(p);
		if(r.length == 0) 
		{
			return;
		}

		var q:Vector = VectorMath.clone(center );
		for( i = 0; i < r.length; i++) 
		{
			x = r[int(i)].x - center.x;
			y = r[int(i)].y - center.y;
			z = r[int(i)].z - center.z;
			d = Math.sqrt(x * x + y * y + z * z);
			d = 0.5 - radius / d / 2;
			q.x = (q.x + x * d);
			q.y = (q.y + y * d);
			q.z = (q.z + z * d);
		}
		center = q;

		radius = computeRadius(p);
		*/
	}
  
  
	/*
	* Return the positions of the array of Position p that are outside the BoundingSphere
	* @param the array of points to test
	* @return an array of points containing those that are outside. The array has a length of 0 if all the points are inside or on the surface.
	*/
	private function pointsOutofSphere(p:Array):Array
	{
		var r:Array = new Array();
		var i:Number;
		for(i = 0; i < p.length; i++) 
		{
			if(distance(p[int(i)]) > 0) 
			{
				r.push( p[int(i)] );
			}
		}
		return r;
	}
  
	  /**
	   * return where a Position is from the sphere surface
	   * @return >0 if position is outside the sphere, <0 if inside, =0 if on the surface of thesphere
	   */
	public function distance(point:Vector):Number
	{
		
		var x:Number = point.x - center.x;
		var y:Number = point.y - center.y;
		var z:Number = point.z - center.z;
		return  Math.sqrt(x * x + y * y + z * z) - radius;
	}
	  
	private function computeRadius(ps:Array):Number
	{
		var x:Number, y:Number, z:Number, d:Number, dmax:Number = 0;
		var i:Number;
		for(i = 0; i < ps.length; i++) 
		{
			x = ps[int(i)].x - center.x;
			y = ps[int(i)].x - center.x;
			z = ps[int(i)].x - center.x;
			d = x * x + y * y + z * z;
			if(d > dmax) dmax = d;
		}
		return Math.sqrt(dmax);
	}

}
