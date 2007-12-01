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
		 * Attenuation vector. This is the vector from transparent point to opaque point.
		 */
		public function set fadeTo (p_oW:Vector):void
		{
			_fadeTo = p_oW;
			_fadeToN2 = p_oW.getNorm (); _fadeToN2 *= _fadeToN2;
		}
		
		/**
		 * @private
		 */
		public function get fadeTo ():Vector
		{
			return _fadeTo;
		}

		/**
		 * Transparent point in wx, wy and wz coordinates .
		 */
		public var fadeFrom:Vector;

		/**
		 * Creates a new MediumAttributes object.
		 *
		 * @param p_nColor - Medium color (opaque white by default).
		 * @param p_oFadeTo - Attenuation vector (500 pixels beyond the screen by default).
		 * @param p_oFadeFrom - Transparent point (at the screen by default).
		 */
		public function MediumAttributes (p_nColor:uint = 0xFFFFFFFF, p_oFadeFrom:Vector = null, p_oFadeTo:Vector = null)
		{
			if (p_oFadeFrom == null)
				p_oFadeFrom = new Vector (0, 0, 0);
			if (p_oFadeTo == null)
				p_oFadeTo = new Vector (0, 0, 500);
			// --
			color = p_nColor; fadeTo = p_oFadeTo; fadeFrom = p_oFadeFrom;
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
			var i:int, n:int = l_points.length; if (n < 3) return;

			var l_ratios:Array = new Array (n);
			for (i = 0; i < n; i++) l_ratios[i] = ratioFromWorldVector (l_points[i].getWorldVector ());

			var zIndices:Array = l_ratios.sort (Array.NUMERIC | Array.RETURNINDEXEDARRAY);

			var v0: Vertex = l_points[zIndices[0]];
			var v1: Vertex = l_points[zIndices[1]];
			var v2: Vertex = l_points[zIndices[2]];

			var r0: Number = NumberUtil.constrain (l_ratios[zIndices[0]], 0, 1);
			var r1: Number = NumberUtil.constrain (l_ratios[zIndices[1]], 0, 1);
			var r2: Number = NumberUtil.constrain (l_ratios[zIndices[2]], 0, 1);

			if (!NumberUtil.isZero (r2))
			{
				var c:uint = color & 0xFFFFFF;
				var a:Number = (color - c) / 0x1000000 / 255.0;

				if (NumberUtil.isZero (1 - r0))
				{
					p_oGraphics.beginFill (c, a);
				}

				else
				{
					// gradient matrix
					VertexMath.linearGradientMatrix (v0, v1, v2, r0, r1, r2, matrix);

					p_oGraphics.beginGradientFill ("linear", [c, c], [a * r0, a * r2], [0, 0xFF], matrix);
				}

				// --
				p_oGraphics.moveTo (l_points[0].sx, l_points[0].sy);
				for each (var l_oVertex:Vertex in l_points)
				{
					p_oGraphics.lineTo (l_oVertex.sx, l_oVertex.sy);
				}
				p_oGraphics.endFill();
			}
		}

		// --
		private function ratioFromWorldVector (p_oW:Vector):Number
		{
			p_oW.sub (fadeFrom); return p_oW.dot (_fadeTo) / _fadeToN2;
		}

		// --
		internal var matrix:Matrix = new Matrix();
		internal var _fadeTo:Vector;
		internal var _fadeToN2:Number;
	}
}
