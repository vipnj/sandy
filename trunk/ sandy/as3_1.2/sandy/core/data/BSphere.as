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
	public class BSphere
	{
		public var center:Vector;
		public var radius:Number;
		public var owner:Object3D;
		
		public function compute( pPoints:Array ):void
		{
			var x:Number, y:Number, z:Number, d:Number;
			var p:Array = new Array(pPoints.length);
			p[0] = Vertex(pPoints[0]).getWorldVector();
			var i:int, j:int, l:int = pPoints.length;
			for( i = 1; i < l; i++) 
			{
				p[i] = Vertex(pPoints[int(i)]).getWorldVector();
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
			var i:int;
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
			
			var x = point.x - center.x;
			var y = point.y - center.y;
			var z = point.z - center.z;
			return  Math.sqrt(x * x + y * y + z * z) - radius;
		}
		  
		private function computeRadius(ps:Array):Number
		{
			var x:Number, y:Number, z:Number, d:Number, dmax:Number = 0;
			var i:int;
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
		public function toString():String
		{
			return getQualifiedClassName(this) + "(center : "+center+", radius : "+radius + ")";
		}
	}

}