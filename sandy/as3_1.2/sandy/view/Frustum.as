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

package sandy.view 
{
	import sandy.bounds.BBox;
	import sandy.bounds.BSphere;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Plane;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.math.PlaneMath;
	import sandy.util.NumberUtil;
	import sandy.math.VectorMath;	

	/**
	* Frustum
	* Class used to determine if a box, a sphere, or a point is in the frustrum of the camera.
	* @author		Thomas Pfeiffer - kiroukou
	* @since		1.0
	* @version		1.0
	* @date 		12.05.2006
	**/
	public class Frustum 
	{
		public var aPlanes:Array;
		//  0-> +
		//  |
		//  V     5---4
		//  -    /|  /|
		//      / 6-/-7
		//     / / / /
		//    1---0 /   
		//    |/  |/
		//    2---3 	
		public var aPoints:Array;
		public var aNormals:Array;
		public var aConstants:Array;
		// front plane : aNormals[0], aConstants[0] <-> aPoints[0], aPoints[1], aPoints[2], aPoints[3]
		// upper plane : aNormals[1], aConstants[1] <-> aPoints[0], aPoints[1], aPoints[4], aPoints[5]
		// lower plane : aNormals[2], aConstants[2] <-> aPoints[2], aPoints[3], aPoints[6], aPoints[7]
		// right plane : aNormals[3], aConstants[3] <-> aPoints[0], aPoints[3], aPoints[4], aPoints[7]
		// left plane  : aNormals[4], aConstants[4] <-> aPoints[1], aPoints[2], aPoints[5], aPoints[6]
		// back plane  : aNormals[5], aConstants[5] <-> aPoints[4], aPoints[5], aPoints[6], aPoints[7] 	
		public static const NEAR:int 	= 0;
		public static const FAR:int 	= 1;
		public static const RIGHT:int 	= 2;
		public static const LEFT:int	= 3;
        public static const TOP:int 	= 4;
		public static const BOTTOM:int  = 5; 
		
		public static const INSIDE:uint = 1;
		public static const OUTSIDE:uint = 2;
		public static const INTERSECT:uint = 3;
		public static const EPSILON:Number = 0.005;

		
		public function Frustum() 
		{
			aPlanes = new Array(6);
			aPoints = new Array(8);
			aNormals = new Array(6);
			aConstants = new Array(6);
		}
		
		public function computePlanes( nAspect:Number, fNear:Number, fFar:Number, nFov:Number ):void
		{
			// store the information
			var lRadAngle:Number = NumberUtil.toRadian( nFov );
			// compute width and height of the near and far plane sections
			var tang:Number = Math.tan(lRadAngle * 0.5) ;
			
			// we inverse the vertical axis as Flash as a vertical axis inversed by our 3D one. VERY IMPORTANT
			var yNear:Number = -tang * fNear;			
			var xNear:Number = yNear * nAspect;
			var yFar:Number = yNear * fFar / fNear;
			var xFar:Number = xNear * fFar / fNear;
			fNear = -fNear;
			fFar = -fFar;
			var p:Array = aPoints;
			p[0] = new Vector( xNear, yNear, fNear); // Near, right, top
			p[1] = new Vector( xNear,-yNear, fNear); // Near, right, bottom
			p[2] = new Vector(-xNear,-yNear, fNear); // Near, left, bottom
			p[3] = new Vector(-xNear, yNear, fNear); // Near, left, top
			p[4] = new Vector( xFar,  yFar,  fFar);  // Far, right, top
			p[5] = new Vector( xFar, -yFar,  fFar);  // Far, right, bottom
			p[6] = new Vector(-xFar, -yFar,  fFar);  // Far, left, bottom
			p[7] = new Vector(-xFar,  yFar,  fFar);  // Far, left, top
			
			aPlanes[LEFT] 	= PlaneMath.computePlaneFromPoints( p[2], p[3], p[6] ); // Left
			aPlanes[RIGHT] 	= PlaneMath.computePlaneFromPoints( p[0], p[1], p[4] ); // right
			aPlanes[TOP] 	= PlaneMath.computePlaneFromPoints( p[0], p[7], p[3] ); // Top
			aPlanes[BOTTOM] = PlaneMath.computePlaneFromPoints( p[1], p[2], p[5] ); // Bottom
			aPlanes[NEAR] 	= PlaneMath.computePlaneFromPoints( p[0], p[2], p[1] ); // Near
			aPlanes[FAR] 	= PlaneMath.computePlaneFromPoints( p[4], p[5], p[6] ); // Far
			
			for( var i:Number = 0; i < 6; i++ )
				PlaneMath.normalizePlane( aPlanes[i] );	
		}
		
		public function extractPlanes( comboMatrix:Matrix4, normalize:Boolean ):void
		{
			// Left clipping plane
			aPlanes[0].a = comboMatrix.n14 + comboMatrix.n11;
			aPlanes[0].b = comboMatrix.n24 + comboMatrix.n21;
			aPlanes[0].c = comboMatrix.n34 + comboMatrix.n31;
			aPlanes[0].d = comboMatrix.n44 + comboMatrix.n41;
			// Right clipping plane
			aPlanes[1].a = comboMatrix.n14 - comboMatrix.n11;
			aPlanes[1].b = comboMatrix.n24 - comboMatrix.n21;
			aPlanes[1].c = comboMatrix.n34 - comboMatrix.n31;
			aPlanes[1].d = comboMatrix.n44 - comboMatrix.n41;
			// Top clipping plane
			aPlanes[2].a = comboMatrix.n14 - comboMatrix.n12;
			aPlanes[2].b = comboMatrix.n24 - comboMatrix.n22;
			aPlanes[2].c = comboMatrix.n34 - comboMatrix.n32;
			aPlanes[2].d = comboMatrix.n44 - comboMatrix.n42;
			// Bottom clipping plane
			aPlanes[3].a = comboMatrix.n14 + comboMatrix.n12;
			aPlanes[3].b = comboMatrix.n24 + comboMatrix.n22;
			aPlanes[3].c = comboMatrix.n34 + comboMatrix.n32;
			aPlanes[3].d = comboMatrix.n44 + comboMatrix.n42;
			// Near clipping plane
			aPlanes[4].a = comboMatrix.n13;
			aPlanes[4].b = comboMatrix.n23;
			aPlanes[4].c = comboMatrix.n33;
			aPlanes[4].d = comboMatrix.n43;
			// Far clipping plane
			aPlanes[5].a = comboMatrix.n14 - comboMatrix.n13;
			aPlanes[5].b = comboMatrix.n24 - comboMatrix.n23;
			aPlanes[5].c = comboMatrix.n34 - comboMatrix.n33;
			aPlanes[5].d = comboMatrix.n44 - comboMatrix.n43;
			// Normalize the plane equations, if requested
			if ( normalize == true )
			{
				PlaneMath.normalizePlane( aPlanes[0] );
				PlaneMath.normalizePlane( aPlanes[1] );
				PlaneMath.normalizePlane( aPlanes[2] );
				PlaneMath.normalizePlane( aPlanes[3] );
				PlaneMath.normalizePlane( aPlanes[4] );
				PlaneMath.normalizePlane( aPlanes[5] );
			};
		}
		
		public function pointInFrustum( p:Vector ):int
		{
			for( var i:int = 0; i < 6; i++)
			{
				if ( PlaneMath.classifyPoint( aPlanes[int(i)], p) == PlaneMath.NEGATIVE )
					return OUTSIDE;
			}
			return INSIDE ;
		}
		
		public function sphereInFrustum( p_oS:BSphere ):int
		{
            var p:int = 0; 
            var c:int = 0; 
            var d:Number; 
            var center:Vector = p_oS.m_oPosition;
            var radius:Number = p_oS.m_nTRadius;
            for( p = 0; p < 6; p++ ) 
            { 
                d = aPlanes[p].a * center.x + aPlanes[p].b * center.y + aPlanes[p].c * center.z + aPlanes[p].d; 
                if( d <= -radius ) 
                    return OUTSIDE; 
                if( d > radius ) 
                    c++; 
            } 
            return (c == 6) ? INSIDE : INTERSECT;
		}

		public function boxInFrustum( box:BBox ):int
		{
			var result:Number = Frustum.INSIDE, out:Number,iin:Number;
			var k:int;			
			var d:Number;
			var plane:Plane;
			var p:Array = box.aTCorners;
			// for each plane do ...
			for(var i:int = 0; i < 6; i++) 
			{
				plane = aPlanes[int(i)];
				// reset counters for corners in and out
				out = 0; iin = 0;
				// for each corner of the box do ...
				// get out of the cycle as soon as a box as corners
				// both inside and out of the frustum
				for ( k = 0; k < 8 && ( iin == 0 || out == 0 ); k++ ) 
				{
					d = PlaneMath.distanceToPoint( plane, p[int(k)] ) ;
					// is the corner outside or inside
					if ( d < 0 )
						out++;
					else
						iin++;
				}
				// if all corners are out
				if ( iin == 0 )
				{
					return Frustum.OUTSIDE;
				}
				// if some corners are out and others are in	
				else if ( out > 0 )
				{
					return Frustum.INTERSECT;
				}
			}
			return result;
		}

		public function clipFrustum( cvert: Array ):void
		{
            if( cvert.length <= 2 ) return;
			clipPolygon( aPlanes[NEAR], cvert ); // near
			if( cvert.length <= 2 ) return;
			clipPolygon( aPlanes[LEFT], cvert ); // left
			if( cvert.length <= 2 ) return;
			clipPolygon( aPlanes[RIGHT], cvert ); // right
			if( cvert.length <= 2 ) return;
	        clipPolygon( aPlanes[BOTTOM], cvert ); // top
			if( cvert.length <= 2 ) return;
		    clipPolygon( aPlanes[TOP], cvert ); // bottom	
		}

        
		public function clipPolygon( p:Plane, pts:Array ):void
		{	
			var allin:Boolean = true, allout:Boolean = true;
			var v:Vertex;
			var i:int, l:int = pts.length;
			// -- If no points, we return null
			var aDist:Array = new Array( pts.length );
			// -- otherwise we compute the distances to frustum plane
			for ( i = 0; i < l; i++)
			{	 
				v = pts[i];
				aDist[i] = p.a * v.wx + p.b * v.wy + p.c * v.wz + p.d;
				if (aDist[i] < 0) allin = false;
				if (aDist[i] >= 0) allout = false;			
			}
			
			if (allin)
				return;
			else if (allout)
			{
				// we return an empty array
				pts.splice(0);
				return;
			}
			// Clip a polygon against a plane
			var tmp:Array = pts.splice(0);
			var v1:Vertex = tmp[0];
			//
			var d:Number;
			var t:Vertex;
			var dist2:Number, dist1:Number = aDist[0];
			var clipped:Boolean = false, inside:Boolean = (dist1 >= 0);
			var curv:Number = 0;
			for (i=1; i<= l; i++)
			{	 
				var v2:Vertex = tmp[i%l];
				dist2= aDist[i%l];
				// Sutherland-hodgeman clipping
				if ( inside && (dist2 >= 0) ) 
				{
					pts.push(v2);	// Both in
				}
				else if ( (!inside) && (dist2>=0) )		// Coming in
				{	 
					clipped = inside = true;
					t = new Vertex();
					d = dist1/(dist1-dist2);
					t.wx = (v1.wx+(v2.wx-v1.wx)*d);
					t.wy = (v1.wy+(v2.wy-v1.wy)*d);
					t.wz = (v1.wz+(v2.wz-v1.wz)*d);

					pts.push( t );
					pts.push( v2 );
				} 
				else if ( inside && (dist2<0) )		// Going out
				{	 
					clipped=true;
					inside=false;
					t = new Vertex();
					d = dist1/(dist1-dist2);
					
					t.wx = (v1.wx+(v2.wx-v1.wx)*d);
					t.wy = (v1.wy+(v2.wy-v1.wy)*d);
					t.wz = (v1.wz+(v2.wz-v1.wz)*d);
					
					pts.push( t );
				} 
				else
				{
					clipped = true;		// Both out
				}
				v1 = v2;
				dist1 = dist2;
			}
			// we free the distance array
			aDist = null;
		}

    }

}

/*
		public function boxInFrustum( p_oBox:BBox ):int
		{
        	var mode:uint = 0;// set IN and OUT bit to 0
        	var i:int;
        	var d:Number;
            var plane:Plane;
            var box:Array = new Array( p_oBox.m_oTMin.x, p_oBox.m_oTMin.y, p_oBox.m_oTMin.z, p_oBox.m_oTMax.x, p_oBox.m_oTMax.y, p_oBox.m_oTMax.z );
            
            for ( i = 0; i < 6; ++i)
            {
                plane = aPlanes[int(i)]; 
                mode &= OUTSIDE;        // clear the IN bit to 0 
                d=(plane.a*box[0] + plane.b*box[1] + plane.c*box[2]+ plane.d);
                if ( d >= 0) mode |= INSIDE;  // set IN bit to 1
                else mode |= OUTSIDE;     // set OUT bit to 1
                if (mode == INTERSECT) continue;  // if we found a vertex IN for THIS plane and 
                // a vertex OUT of ANY plane continue ( we have enough information to say: 
                // INTERSECT! IF there is not vertex missing from the FRONT of the remaining planes)
                if (plane.a*box[3] + plane.b*box[1] + plane.c*box[2] + plane.d >= 0) mode |= INSIDE; else mode |= OUTSIDE;
                if (mode == INTERSECT) continue;
                
                if (plane.a*box[0] + plane.b*box[4] + plane.c*box[2] + plane.d >= 0) mode |= INSIDE; else mode |= OUTSIDE;
                if (mode == INTERSECT) continue;
                
                if (plane.a*box[3] + plane.b*box[4] + plane.c*box[2] + plane.d >= 0) mode |= INSIDE; else mode |= OUTSIDE;
                if (mode == INTERSECT) continue;
                
                if (plane.a*box[0] + plane.b*box[1] + plane.c*box[5] + plane.d >= 0) mode |= INSIDE; else mode |= OUTSIDE;
                if (mode == INTERSECT) continue;
                
                if (plane.a*box[3] + plane.b*box[1] + plane.c*box[5] + plane.d >= 0) mode |= INSIDE; else mode |= OUTSIDE;
                if (mode == INTERSECT) continue;
                       
                if (plane.a*box[0] + plane.b*box[4] + plane.c*box[5] + plane.d >= 0) mode |= INSIDE; else mode |= OUTSIDE;
                if (mode == INTERSECT) continue;
                
                if (plane.a*box[3] + plane.b*box[4] + plane.c*box[5] + plane.d >= 0) mode |= INSIDE; else mode |= OUTSIDE;
                if (mode == INTERSECT) continue;
                // if we arrive to this point, then there are two possibilities:
                // there is not vertices in or there is not intersection till know, if 
                // there is a vertice in, continue (we are not over!) 
                if (mode == INSIDE) continue;
                // there is not vertex IN front of this plane, so the box is COMPLETE_OUT
                return OUTSIDE;
            }
            // All planes has a vertex IN FRONT so or the box is intersecting or complete IN
            if (mode == INTERSECT) return INTERSECT;
            else return INSIDE;
        }
*/