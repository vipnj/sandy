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
import sandy.core.data.Vector;
import sandy.math.PlaneMath;

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
	
	public static function get INSIDE():Number { return 1; }
	public static function get OUTSIDE():Number { return  -1; }
	public static function get INTERSECT():Number { return  0; }
	
	public function Frustum() 
	{
		aPlanes = new Array();
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
	
	
	//TODO implement BSphere object and corresponding methods
	public function sphereInFrustum( s:Object/*BSphere*/ ):Number
	{
		var distance:Number;
		var r:Number = s.getRadius(); // radius
		var p:Vector = s.getCenter(); // position (center)
		for( var i:Number = 0; i < 6; i++) 
		{
			distance = PlaneMath.distanceToPoint( aPlanes[i], p );
			if ( distance < -r )
				return OUTSIDE; // outside
			else if ( distance < r )
				return  INTERSECT; // intersect
		}
		return INSIDE ; // inside
	}
	
	// TODO Need to implement BBox object and corresponding methods
	public function boxInFrustum( box:Object /*BBox*/ ):Number
	{

		var result:Number = Frustum.INSIDE, out:Number,iin:Number;

		// for each plane do ...
		for(var i:Number = 0; i < 6; i++) 
		{
			// reset counters for corners in and out
			out = 0; iin = 0;
			// for each corner of the box do ...
			// get out of the cycle as soon as a box as corners
			// both inside and out of the frustum
			for ( var k:Number = 0; k < 8 && ( iin == 0 || out == 0 ); k++ ) 
			{
				// is the corner outside or inside
				if ( PlaneMath.distanceToPoint( aPlanes[i], box.getVertex( k ) ) )
					out++;
				else
					iin++;
			}
			//if all corners are out
			if ( !iin )
				return Frustum.OUTSIDE;
			// if some corners are out and others are in	
			else if ( out )
				result = Frustum.INTERSECT;
		}
		return result;
 	}

		
}