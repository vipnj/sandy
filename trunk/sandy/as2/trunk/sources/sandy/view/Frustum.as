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

import sandy.core.data.BBox;
import sandy.core.data.BSphere;
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
* UNUSED class right now.
* @author		Thomas Pfeiffer - kiroukou
* @since		1.0
* @version		1.0
* @date 		12.05.2006
**/

 
class sandy.view.Frustum 
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
	public static var FAR:Number 	= 0;
	public static var TOP:Number 	= 1;
	public static var BOTTOM:Number = 2; 
	public static var RIGHT:Number 	= 3;
	public static var LEFT:Number 	= 4;
	public static var NEAR:Number 	= 5;

	
	public static function get INSIDE():Number { return 1; }
	public static function get OUTSIDE():Number { return  -1; }
	public static function get INTERSECT():Number { return  0; }
	public static function get EPSILON():Number { return  0.005; }
	
	public function Frustum() 
	{
		aPlanes = new Array(6);
		aPoints = new Array(8);
		aNormals = new Array(6);
		aConstants = new Array(6);
	}
	
	public function computePlanes( nAspect:Number, fNear:Number, fFar:Number, nFov:Number ):Void
	{
		// store the information
		var lRadAngle:Number = NumberUtil.toRadian( nFov );
		// compute width and height of the near and far plane sections
		var tang:Number = Math.tan(lRadAngle * 0.5) ;
		// We invert the vertical (Y) axis as Flash has a vertical axis inverted relative to our 3D Y axis. VERY IMPORTANT.
		// Flash Y values increase towards bottom of screen. 3D Y axis increases going towards top of screen.
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
	
	public function extractPlanes( comboMatrix:Matrix4, normalize:Boolean ):Void
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
	
	public function pointInFrustum( p:Vector ):Number
	{
		for( var i:Number = 0; i < 6; i++)
		{
			if ( PlaneMath.classifyPoint( aPlanes[i], p) == PlaneMath.NEGATIVE )
				return OUTSIDE;
		}
		return INSIDE ;
	}
	
	public function sphereInFrustum( s:BSphere ):Number
	{
		var d:Number;
		var r:Number = s.radius; // radius
		var p:Vector = s.center;//VectorMath.addVector(s.center, s.owner.getPosition()); // position (center)
		for( var i:Number = 0; i < 6; i++) 
		{
			d = PlaneMath.distanceToPoint( aPlanes[i], p );
			if ( d < -r )
			{
				return Frustum.OUTSIDE; // outside
			}
			else if ( Math.abs(d) < r )
			{
				return  Frustum.INTERSECT; // intersect
			}      
		}
		return Frustum.INSIDE ; // inside
	}

	public function boxInFrustum( box:BBox ):Number
	{
		var result:Number = Frustum.INSIDE, out:Number,iin:Number;
		var k:Number;
		var d:Number;
		var plane:Plane;
		var p:Array = box.getCorners(true);
		// for each plane do ...
		for(var i:Number = 0; i < 6; i++) 
		{
			plane = aPlanes[i];
			// reset counters for corners in and out
			out = 0; iin = 0;
			// for each corner of the box do ...
			// get out of the cycle as soon as a box as corners
			// both inside and out of the frustum
			for ( k = 0; k < 8 && ( iin == 0 || out == 0 ); k++ ) 
			{
				d = PlaneMath.distanceToPoint( plane, p[k] ) ;
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

	public function clipFrustum( cvert: Array ):Array
	{
		if( cvert.length <= 2 )
		{
			return cvert;
		}	
		var tmp:Array = cvert;
		
		tmp = clipPolygon( aPlanes[LEFT], tmp ); // left
		if( tmp.length <= 2 ) return tmp;
		tmp = clipPolygon( aPlanes[RIGHT], tmp ); // right
		if( tmp.length <= 2 ) return tmp;
		tmp = clipPolygon( aPlanes[BOTTOM], tmp ); // top
		if( tmp.length <= 2 ) return tmp;
		tmp = clipPolygon( aPlanes[TOP], tmp ); // bottom
		if( tmp.length <= 2 ) return tmp;
		tmp = clipPolygon( aPlanes[NEAR], tmp ); // near
		//if( tmp.length <= 2 ) return tmp;
		//tmp = clipPolygon( aPlanes[FAR], tmp ); // far
		return tmp;

	}

	public function clipPolygon( p:Plane, pts:Array ):Array
	{
		var allin:Boolean = true, allout:Boolean = true;
		var v:Vertex;
		var i:Number, l:Number = pts.length;
		// -- If no points, we return null
		if( !l )
		{
			return null;
		}
		
		var aDist:Array = new Array( pts.length );
		// -- otherwise we compute the distances to frustum plane
		for ( i=0; i<l; i++)
		{	 
			v = pts[i];
			aDist[i] = p.a * v.wx + p.b * v.wy + p.c * v.wz + p.d;
			if (aDist[i] < 0) allin = false;
			if (aDist[i] >= 0) allout = false;
		}
		
		if (allin)
		{
			return pts;
		} 
		else if (allout)
		{
			return null;
		}
		// Clip a polygon against a plane
		var aClipped:Array = new Array();
		var v1:Vertex = pts[0];
		var v2:Vertex;
		//
		var dist2:Number, dist1:Number = aDist[0];
		var clipped:Boolean = false, inside:Boolean = (dist1 >= 0);
		var curv:Number = 0;
		for (i=1; i<= l; i++)
		{	     
			v2 = pts[i%l];
			dist2= aDist[i%l];
			// Sutherland-hodgeman clipping
			if ( inside && (dist2 >= 0) ) 
			{
				aClipped.push(v2);	// Both in
			}
			else if ( (!inside) && (dist2>=0) )		// Coming in
			{	 
				clipped = inside = true;
				var t:Vertex = new Vertex();
				var  d:Number = dist1/(dist1-dist2);
				t.wx = (v1.wx+(v2.wx-v1.wx)*d);
				t.wy = (v1.wy+(v2.wy-v1.wy)*d);
				t.wz = (v1.wz+(v2.wz-v1.wz)*d);

				aClipped.push( t );
				aClipped.push( v2 );
			} 
			else if ( inside && (dist2<0) )		// Going out
			{	 
				clipped=true;
				inside=false;
				var t:Vertex = new Vertex();
				var d:Number = dist1/(dist1-dist2);
				
				t.wx = (v1.wx+(v2.wx-v1.wx)*d);
				t.wy = (v1.wy+(v2.wy-v1.wy)*d);
				t.wz = (v1.wz+(v2.wz-v1.wz)*d);
				
				aClipped.push( t );
			} 
			//else
			//{
				clipped = true;		// Both out
			//}
			v1 = v2;
			dist1 = dist2;
		}
		
		delete aDist;
		if (!clipped)
		{
			return pts;
		}
		else
		{
			return aClipped;
	 	}
	}

/*
	public function computePlanesTemp( pAspect:Number, pNear:Number, pFar:Number, pFov:Number ):Void
	{
		// store the information
		var lRadAngle:Number = NumberUtil.toRadian( pFov );
		// compute width and height of the near and far plane sections
		var tang:Number = Math.tan(lRadAngle * 0.5) ;
		var nh:Number = pNear * tang;
		var nw:Number = nh * pAspect; 
		var fh:Number = pFar  * tang;
		var fw:Number = fh * pAspect;
		// compute the Z axis of camera
		// this axis points in the opposite direction from 
		// the looking direction
		var Z:Vector = new Vector( 0, 0, 1 );
		// X axis of camera with given "up" vector and Z axis
		var X:Vector = new Vector( 1, 0, 0 );
		// the real "up" vector is the cross product of Z and X
		var Y:Vector = new Vector( 0, 1, 0 );
		// compute the centers of the near and far planes
		var nc:Vector = new Vector( 0, 0, pNear);
		var fc:Vector = new Vector( 0, 0, pFar );
	
		aPlanes[NEAR].setNormalAndPoint(-Z,nc);
		aPlanes[FAR].setNormalAndPoint(Z,fc);
	
		var aux:Vector,normal:Vector;
	
		aux = new Vector(0, nh, pNear);
		normal = aux * X;
		aPlanes[TOP].setNormalAndPoint(normal,nc+Y*nh);
	
		aux = (nc - Y*nh);
		normal = X * aux;
		aPlanes[BOTTOM].setNormalAndPoint(normal,nc-Y*nh);
		
		aux = (nc - X*nw);
		normal = aux * Y;
		aPlanes[LEFT].setNormalAndPoint(normal,nc-X*nw);
	
		aux = (nc + X*nw);
		normal = Y * aux;
		aPlanes[RIGHT].setNormalAndPoint(normal,nc+X*nw);
	}
	*/
}
