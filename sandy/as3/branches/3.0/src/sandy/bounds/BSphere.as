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
package sandy.bounds 
{
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;	
	
	/**
	 * The <code>BSphere</code> object is used to clip the object faster.
	 * <p>It Creates a bounding sphere that contains the whole object</p>
	 * 
	 * @example 	This example is taken from the Shape3D class. It is used in
	 * 				the <code>updateBoundingVolumes()</code> method:
 	 *
 	 * <listing version="3.0">
 	 *     _oBSphere = BSphere.create( m_oGeometry.aVertex );
 	 *  </listing>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		0.1
	 * @date 		22.03.2006
	 */
	public final class BSphere
	{
		public var center:Vector = new Vector();
		public var radius:Number = 1;
		// -----------------------------
		//    [TRANSFORMED]  -----------
		public var m_oPosition:Vector = new Vector();
		public var m_nTRadius:Number = 1;
	
		/**
		 * Creates a bounding sphere that encloses a 3D object. This object's vertices are passed
		 * to the <code>create</code> method in the form of an <code>Array</code>. Very useful 
		 * for clipping and thus performance!
		 * 
		 * @param p_aVertices		The vertices of the 3D object
		 * @return 					A <code>BSphere</code> instance
		 */	
		public static function create( p_aVertices:Array ):BSphere
		{
		    var l_sphere:BSphere = new BSphere();
		    
		    var l_min:Vector = new Vector();
		    var l_max:Vector = new Vector();
			
			var lTmp:Array;
			lTmp = p_aVertices.sortOn (["x"], [Array.NUMERIC|Array.RETURNINDEXEDARRAY ]);
			l_min.x = p_aVertices[lTmp[0]].x;
			l_max.x = p_aVertices[lTmp[lTmp.length-1]].x;
			  
			lTmp = p_aVertices.sortOn (["y"], [Array.NUMERIC|Array.RETURNINDEXEDARRAY ]);
			l_min.y = p_aVertices[lTmp[0]].y;
			l_max.y = p_aVertices[lTmp[lTmp.length-1]].y;
			  
			lTmp = p_aVertices.sortOn (["z"], [Array.NUMERIC|Array.RETURNINDEXEDARRAY ]);
			l_min.z = p_aVertices[lTmp[0]].z;
			l_max.z = p_aVertices[lTmp[lTmp.length-1]].z;
			
			l_sphere.center.copy( l_max );
			l_sphere.center.add( l_min );
			l_sphere.center.scale( 0.5 );
			
			// TODO : compare this method efficiency compared to the previous compute one
			var lDiff:Vector = l_max.clone();
			lDiff.sub( l_min );
			l_sphere.radius = lDiff.getMaxComponent();
		    //l_sphere.compute( p_aVertices );
			return l_sphere;
		}
				
		/**
		 * <p>Create a new <code>BSphere</code> instance.</p>
		 */ 	
		public function BSphere()
		{
			;
		}
		
		/**
	     * Applies the transformation that is specified in the <code>Matrix4</code> parameter.
	     * 
	     * @param p_oMatrix		The transformation matrix
	     */	
	    public function transform( p_oMatrix:Matrix4 ):void
	    {
	        m_oPosition.copy( center );
	        p_oMatrix.vectorMult( m_oPosition );
	        //var l_ncale:Number = Math.sqrt( p_oMatrix.n11 * p_oMatrix.n11 + p_oMatrix.n22 * p_oMatrix.n22 + p_oMatrix.n33 * p_oMatrix.n33 );
	        m_nTRadius = radius;// * l_ncale;
	    }
	    
		/**
		* Returns a <code>String</code> represntation of the <code>BSphere</code>.
		* 
		* @return	A String representing the bounding sphere
		*/ 	
		public function toString():String
		{
			return "sandy.bounds.BSphere (center : "+center+", radius : "+radius + ")";
		}
		
		/**
		 * Performs the actual computing of the bounding sphere's center and radius
		 * 
		 * @param p_aVertices		The vertices of the 3D object
		 */		
		public function compute( p_aVertices:Array ):void
		{
			var x:Number, y:Number, z:Number, d:Number;
			if(p_aVertices.length == 0) return;
			
			var p:Array = new Array();
			var i:int, j:int, l:int = 0;
			
			for each( var v:Vertex in p_aVertices )
			{
				p.push( v.getVector() );
				l++;
			}
	
			var p1:Vector = p[0];
			var p2:Vector = p[0];
			// find the farthest couple of points
			var dmax:Number = 0;
			i=0;
			
			while( i < l ) 
			{
				j = i + 1;
				while( j < l ) 
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
					
					j++;
				}
				i++;
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
	  
	  
		/**
		 * Return the positions of the array of Position p that are outside the BoundingSphere.
		 * 
		 * @param 	An array containing the points to test
	 	 * @return 	An array of points containing those that are outside. The array has a length 
	 	 * 			of 0 if all the points are inside or on the surface.
		 */
		private function pointsOutofSphere(p_aPoints:Array):Array
		{
			var r:Array = new Array();
			var i:int, l:int = p_aPoints.length;
			
			while( i < l ) 
			{
				if(distance(p_aPoints[int(i)]) > 0) 
				{
					r.push( p_aPoints[int(i)] );
				}
				
				i++;
			}
			return r;
		}
	  
		/**
		 * Returns the distance of a point from the surface.
		 * 
		 * @return 	>0 if position is outside the sphere, <0 if inside, =0 if on the surface of the sphere
		 */
		public function distance(p_oPoint:Vector):Number
		{
			var x:Number = p_oPoint.x - center.x;
			var y:Number = p_oPoint.y - center.y;
			var z:Number = p_oPoint.z - center.z;
			return  Math.sqrt(x * x + y * y + z * z) - radius;
		}
		
		/**
		 * Computes the bounding sphere's radius
		 * 
		 * @param p_aPoints		An array containing the sphere's points
		 * @return 				The bounding sphere's radius
		 */		
		private function computeRadius(p_aPoints:Array):Number
		{
			var x:Number, y:Number, z:Number, d:Number, dmax:Number = 0;
			var i:int, l:int = p_aPoints.length;
			while( i < l ) 
			{
				x = p_aPoints[int(i)].x - center.x;
				y = p_aPoints[int(i)].x - center.x;
				z = p_aPoints[int(i)].x - center.x;
				d = x * x + y * y + z * z;
				if(d > dmax) dmax = d;
				i++;
			}
			return Math.sqrt(dmax);
		}
	}
}