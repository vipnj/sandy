/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author Thomas PFEIFFER
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

package sandy.materials.attributes
{
	import flash.display.Graphics;
	import flash.geom.Matrix;

	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.materials.Material;
	import sandy.math.ColorMath;
	import sandy.math.VertexMath;
	import sandy.util.NumberUtil;
	
	/**
	 * This attribute provides very basic simulation of partially opaque medium.
	 * You can use this attribute to achieve wide range of effects (e.g., fog, Rayleigh scattering, light attached to camera, etc).
	 * 
	 * @author		makc
	 * @version		3.0
	 * @date 		01.12.2007
	 */
	public final class MediumAttributes implements IAttributes
	{
		/**
		 * Medium color (32-bit value).
		 */
		public var color:uint;
		
		/**
		 * Attenuation vector.
		 */
		public var fadeTo:Vector;

		/**
		 * Creates a new MediumAttributes object.
		 *
		 * @param p_nColor - Medium color (opaque white by default).
		 * @param p_oFadeTo - Attenuation vector (500 pixels behind the screen by default).
		 */
		public function MediumAttributes (p_nColor:uint = 0xFFFFFFFF, p_oFadeTo:Vector = null)
		{
			if (p_oFadeTo == null)
				p_oFadeTo = new Vector (0, 0, 500);
			// --
			color = p_nColor; fadeTo = p_oFadeTo;
		}
		
		/**
		 * Draw the attribute onto the graphics object to simulate viewing through partially opaque medium.
		 *  
		 * @param p_oGraphics the Graphics object to draw attributes into
		 * @param p_oPolygon the polygon which is going o be drawn
		 * @param p_oMaterial the refering material
		 * @param p_oScene the scene
		 */
		public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			const l_points:Array = ((p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices);
			if( !l_points.length ) return;

			var zIndices: Array = l_points.sortOn( "wz", Array.NUMERIC | Array.RETURNINDEXEDARRAY );

			var v0: Vertex = l_points[zIndices[0]];
			var v1: Vertex = l_points[zIndices[1]];
			var v2: Vertex = l_points[zIndices[2]];

			var vc: Vertex = new Vertex (0, 0, 0,
				0, 0, // <- should we account for excentric viewport here?
				-p_oScene.camera.near); // <- should a distance to camera be used instead?

			// relate vertices to screen
			var v0c: Vector = VertexMath.sub (v0, vc).getWorldVector ();
			var v1c: Vector = VertexMath.sub (v1, vc).getWorldVector ();
			var v2c: Vector = VertexMath.sub (v2, vc).getWorldVector ();

			// ratios
			var ft: Number = fadeTo.getNorm (); ft *= ft;
			var r0: Number = NumberUtil.constrain (fadeTo.dot (v0c) / ft, 0, 1);
			var r1: Number = NumberUtil.constrain (fadeTo.dot (v1c) / ft, 0, 1);
			var r2: Number = NumberUtil.constrain (fadeTo.dot (v2c) / ft, 0, 1);

			// gradient matrix
			VertexMath.linearGradientMatrix (v0, v1, v2, r0, r1, r2, matrix);

			// draw it
			p_oGraphics.lineStyle();
			p_oGraphics.beginGradientFill ("linear", [color, color], [r0, r2], [0, 0xFF], matrix);
			p_oGraphics.moveTo (l_points[0].sx, l_points[0].sy);
            for each (var l_oVertex:Vertex in l_points)
            {
                p_oGraphics.lineTo (l_oVertex.sx, l_oVertex.sy);
            }
			p_oGraphics.endFill();
		}

		// --
		internal var matrix:Matrix = new Matrix();
	}
}
