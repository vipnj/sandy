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

import sandy.core.data.Plane;
import sandy.core.data.Vector;
import sandy.math.VectorMath;

/**
* Math functions for planes.
*  
* @author		Thomas Pfeiffer - kiroukou
 * @since		0.3
 * @version		0.1
 * @date 		21.02.2006
* 
**/
class sandy.math.PlaneMath
{
	private function PlaneMath(){;}
	
	public static function get NEGATIVE():Number { return -1; }
	public static function get ON_PLANE():Number { return  0; }
	public static function get POSITIVE():Number { return  1; }
	
	/**
	 * Normalize the plane. Often before making some calculations with a plane you have to normalize it.
	 * @param plane Plane The plane that we want to normalize.
	 */
	public static function normalizePlane( plane:Plane ):Void
	{
		var mag:Number;
		mag = Math.sqrt( plane.a * plane.a + plane.b * plane.b + plane.c * plane.c );
		plane.a = plane.a / mag;
		plane.b = plane.b / mag;
		plane.c = plane.c / mag;
		plane.d = plane.d / mag;
	}
	
	/**
	 * Computes the distance between a plane and a 3D point (a vector here).
	 * @param plane Plane The plane we want to compute the distance from
	 * @param pt Vector The vector in the 3D space
	 * @return Number The distance between the point and the plane.
	 */
	public static function distanceToPoint( plane:Plane, pt:Vector ):Number
	{
		return plane.a * pt.x + plane.b * pt.y + plane.c * pt.z + plane.d ;
	}
	
	/**
	 * Returns a constant PlaneMath.NEGATIVE PlaneMath.POSITIVE PlaneMath.ON_PLANE depending of the position
	 * of the point compared to the plane
	 * @param plane Plane The reference plane
	 * @param pt Vector The point we want to classify
	 * @return Number The classification of the point PlaneMath.NEGATIVE or PlaneMath.POSITIVE or PlaneMath.ON_PLANE 
	 */
	public static function classifyPoint( plane:Plane, pt:Vector ):Number
	{
		var d:Number;
		d = PlaneMath.distanceToPoint( plane, pt );
		if (d < 0) return PlaneMath.NEGATIVE;
		if (d > 0) return PlaneMath.POSITIVE;
		return PlaneMath.ON_PLANE;
	}
	
	public static function computePlaneFromPoints( pA:Vector, pB:Vector, pC:Vector ):Plane
	{
		var p:Plane = new Plane();
		var n:Vector = VectorMath.cross( VectorMath.sub( pA, pB), VectorMath.sub( pA, pC) );
		VectorMath.normalize( n );
		var d:Number = VectorMath.dot( pA, n);
		// --
		p.a = n.x;
		p.b = n.y;
		p.c = n.z;
		p.d = d;
		// --
		return p;
	}
	
	public static function createFromNormalAndPoint( pNormal:Vector, pD:Number ):Plane
	{
		var p:Plane = new Plane();
		VectorMath.normalize(pNormal);
		p.a = pNormal.x;
		p.b = pNormal.y;
		p.c = pNormal.z;
		p.d = pD;
		PlaneMath.normalizePlane( p );
		return p;
	}
	
}

