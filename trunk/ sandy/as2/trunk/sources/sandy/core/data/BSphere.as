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

import sandy.core.Object3D;
import sandy.math.VectorMath;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;

/**
* Bounding Sphere object used to clip the object faster.
* 
* <p>Create a bounding Sphere that contains the whole object</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @since		0.3
* @version		0.1
* @date 		22.02.2006
*/
class sandy.core.data.BSphere
{
	public var center:Vector;
	public var radius:Number;
	public var owner:Object3D;
		
	public function compute( pPoints:Array ):Void
	{
	   	var x:Number, y:Number, z:Number, d:Number;
	   	var p:Array = new Array(pPoints.length);
    	p[0] = Vertex(pPoints[0]).getWorldVector();
    	var i:Number, j:Number;
	    for( i = 1; i < pPoints.length; i++) 
	    {
	        p[i] = Vertex(pPoints[i]).getWorldVector();
	    }

    	var p1:Vector = p[0];
    	var p2:Vector = p[0];
    	// find the farthest couple of points
    	var dmax:Number = 0;
    	for( i = 0; i < p.length; i++) 
    	{
      		for( j = i + 1; j < p.length; j++) 
      		{
		        x = p[j].x - p[i].x;
		        y = p[j].y - p[i].y;
		        z = p[j].z - p[i].z;
		        d = x * x + y * y + z * z;
		        if(d > dmax) 
		        {
		          	dmax = d;
		         	p1 = p[i];
		          	p2 = p[j];
		        }
      		}
    	}

    	center = new Vector((p1.x + p2.x) / 2, (p1.y + p2.y) / 2, (p1.z + p2.z) / 2);
    	radius = Math.sqrt(dmax) / 2;

    	var r:Array = pointsOutofSphere(p);
    	if(r.length == 0) 
    	{
      		return;
    	}

    	var q:Vector = VectorMath.clone(center );
    	for( i = 0; i < r.length; i++) 
    	{
			x = r[i].x - center.x;
			y = r[i].y - center.y;
			z = r[i].z - center.z;
			d = Math.sqrt(x * x + y * y + z * z);
			d = 0.5 - radius / d / 2;
			q.x = (q.x + x * d);
			q.y = (q.y + y * d);
			q.z = (q.z + z * d);
    	}
    	center = q;

    	radius = computeRadius(p);
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
			if(distance(p[i]) > 0) 
			{
				r.push( p[i] );
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
		var p:Vector;
		var x = p.x - center.x;
		var y = p.y - center.y;
		var z = p.z - center.z;
		return  Math.sqrt(x * x + y * y + z * z) - radius;
	  }
	  
	private function computeRadius(ps:Array):Number
    {
		var x:Number, y:Number, z:Number, d:Number, dmax:Number = 0;
		var i:Number;
		for(i = 0; i < ps.length; i++) 
		{
			x = ps[i].x - center.x;
			y = ps[i].x - center.x;
			z = ps[i].x - center.x;
			d = x * x + y * y + z * z;
			if(d > dmax) dmax = d;
		}
		return Math.sqrt(dmax);
	}
	
	/**
	* <p>Create a new {@code BSphere} Instance</p>
	* 
	* @param	pos	The center of the sphere
	* @param	radius	THe radius of the Sphere
	*/ 	
	public function BSphere( obj:Object3D )
	{
		owner	= obj;
		compute( obj.aPoints );
	}
	
	/**
	* Get a String represntation of the {@code BSphere}.
	* 
	* @return	A String representing the Bounding Sphere
	*/ 	
	public function toString(Void):String
	{
		return "Bounding Sphere \ncenter : "+center+"\nradius : "+radius;
	}
}
