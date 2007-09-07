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
	import sandy.core.data.Plane;
	import sandy.core.data.Vector;
	import sandy.errors.SingletonError;
	
	/**
	 * Math functions for planes.
	 *  
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		0.3
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class PlaneMath
	{
		private static var instance:PlaneMath;
		private static var create:Boolean;
		
		/**
		 * Creates a PlaneMath object.
		 * 
		 * <p>This is a singleton constructor, and should not be called directly.<br />
		 * If called from outside the PlaneMath class, it throws a SingletonError.</p>
		 * [<strong>ToDo</strong>: Why instantiate this at all? - all methods are class methods! ]
		 */ 
		public function PlaneMath()
		{
			if ( !create )
			{
				throw new SingletonError();
			}
		}
		
		/**
		 * Returns an instance of this class.
		 *
		 * <p>Call this method to get an instance of ColorMath</p>
		 */
		public static function getInstance():PlaneMath
		{
			if (instance == null)
			{
				create = true;
				instance = new PlaneMath();
				create = false;
			}
			
			return instance;
		}
		
		/**
		 * Defines the numeric value -1
		 */
		public static function get NEGATIVE():Number { return -1; }
		
		/**
		 * Defines the numeric value 0
		 */
		public static function get ON_PLANE():Number { return  0; }
		
		/**
		 * Defines the numeric value 1		 */
		public static function get POSITIVE():Number { return  1; }
		
		/**
		 * Normalizes the plane. 
		 * 
		 * <p>Often before making some calculations with a plane you have to normalize it.</p>
		 *
		 * @param p_oPlane 	The plane to normalize.
		 */
		public static function normalizePlane( p_oPlane:Plane ):void
		{
			var mag:Number;
			mag = Math.sqrt( p_oPlane.a * p_oPlane.a + p_oPlane.b * p_oPlane.b + p_oPlane.c * p_oPlane.c );
			p_oPlane.a = p_oPlane.a / mag;
			p_oPlane.b = p_oPlane.b / mag;
			p_oPlane.c = p_oPlane.c / mag;
			p_oPlane.d = p_oPlane.d / mag;
		}
		
		/**
		 * Computes the distance between a plane and a 3D point (a vector here).
		 *
		 * @param p_oPlane The plane we want to compute the distance from
		 * @param pt 	The point in space
		 * @return 	The distance between the point and the plane.
		 */
		public static function distanceToPoint( p_oPlane:Plane, p_oPoint:Vector ):Number
		{
			return p_oPlane.a * p_oPoint.x + p_oPlane.b * p_oPoint.y + p_oPlane.c * p_oPoint.z + p_oPlane.d ;
		}
		
		/**
		 * Returns a classification constant depending on a points position relative to a plane.
		 * 
		 * <p>The classification is one of PlaneMath.NEGATIVE PlaneMath.POSITIVE PlaneMath.ON_PLANE</p>
		 *
		 * @param p_oPlane 	The reference plane
		 * @param p_oPoint 		The point we want to classify
		 * @return 		The classification of the point
		 */
		public static function classifyPoint( p_oPlane:Plane, p_oPoint:Vector ):Number
		{
			var d:Number;
			d = PlaneMath.distanceToPoint( p_oPlane, p_oPoint );
			if (d < 0) return PlaneMath.NEGATIVE;
			if (d > 0) return PlaneMath.POSITIVE;
			return PlaneMath.ON_PLANE;
		}
		
		/**
		 * Computes a plane from three specified points.
		 *
		 * @param p_oPointA	The first point
		 * @param p_oPointB	The second point
		 * @param p_oPointC	The third point
		 * @return 	The Plane object		 
		 */
		public static function computePlaneFromPoints( p_oPointA:Vector, p_oPointB:Vector, p_oPointC:Vector ):Plane
		{
			var n:Vector = VectorMath.cross( VectorMath.sub( p_oPointA, p_oPointB), VectorMath.sub( p_oPointA, p_oPointC) );
			VectorMath.normalize( n );
			var d:Number = VectorMath.dot( p_oPointA, n);
			// --
			return new Plane( n.x, n.y, n.z, d);
		}
		/**
		 * Computes a plane from a normal vector and a specified point.
		 *
		 * @param p_oNormal	The normal vector
		 * @param p_nPoint		The point
		 * @return 		The Plane object
		 */		
		public static function createFromNormalAndPoint( p_oNormal:Vector, p_nPoint:Number ):Plane
		{
			var p:Plane = new Plane();
			VectorMath.normalize(p_oNormal);
			p.a = p_oNormal.x;
			p.b = p_oNormal.y;
			p.c = p_oNormal.z;
			p.d = p_nPoint;
			PlaneMath.normalizePlane( p );
			return p;
		}
		
	}
}