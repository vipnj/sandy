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
	import flash.geom.Point;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.materials.Material;
	import sandy.math.VertexMath;
	import sandy.util.NumberUtil;

	/**
	 * Realize a Phong shading on a material.
	 *
	 * @author		Makc
	 * @version		3.0.2
	 * @date 		06.12.2007
	 */
	public final class PhongAttributes implements IAttributes
	{
		/**
		 * Flag for lightening mode.
		 * <p>If true, the lit objects use full light range from black to white.<b />
		 * If false (the default) they just range from black to their normal appearance.</p>
		 */
		public var useBright:Boolean = false;
				
		/**
		 * Level of ambient light, added to the scene if lighting is enabled.
		 */
		public var ambient:Number = 0.3;
		
		/**
		 * Create the PhongAttributes object.
		 * @param p_nAmbient The ambient light value. A value between O and 1 is expected.
		 */
		public function PhongAttributes( p_bBright:Boolean = false, p_nAmbient:Number = 0.0 )
		{
			useBright = p_bBright;
			ambient = NumberUtil.constrain( p_nAmbient, 0, 1 );
		}

		// -- todo: remove unused vars
		internal var v0:Vertex, v1:Vertex, v2:Vertex;
		internal var id0:int, id1:int, id2:int;
		internal var v0N:Vector, v1N:Vector, v2N:Vector;
		internal var v0L:Number, v1L:Number, v2L:Number;
		internal var aL:Array = new Array(3);
		internal var aLId:Array;
		
		internal var alpha:Array;
		internal var matrix:Matrix = new Matrix();
		internal var l_oVertex:Vertex;
		 
		internal var colours:Array; 
		internal var ratios:Array;

		// -- (todo: remove comment - new vars in Phong)
		internal var aN:Array = new Array (3);
		internal var aNP:Array = [new Point (), new Point (), new Point ()], aNPinorm:Number;
		internal var d:Vector, e1:Vector, e2:Vector, vN:Vector;
		internal var matrix2:Matrix = new Matrix();
		
		public function draw(p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D):void
		{
			if( !p_oMaterial.lightingEnable )
				return;

			// get vertices list
			var l_aPoints:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices.slice() : p_oPolygon.vertices.slice();
			
			// get light vector
			d = p_oScene.light.getDirectionVector ();

			// transform all normals
			v0 = l_aPoints[0];
			v1 = l_aPoints[1];
			v2 = l_aPoints[2];

			v0N = p_oPolygon.vertexNormals[0].getVector().clone();
			p_oPolygon.shape.modelMatrix.vectorMult3x3( v0N );
			v1N = p_oPolygon.vertexNormals[1].getVector().clone();
			p_oPolygon.shape.modelMatrix.vectorMult3x3( v1N );
			v2N = p_oPolygon.vertexNormals[2].getVector().clone();
			p_oPolygon.shape.modelMatrix.vectorMult3x3( v2N );

			if ((d.dot (v0N) > 0) && (d.dot (v1N) > 0) && (d.dot (v2N) > 0))
			{
				// no directional light here - render the face in solid ambient
				if( useBright) 
					p_oGraphics.beginFill( (ambient < 0.5) ? 0 : 0xFFFFFF, (ambient < 0.5) ? (1-2 * ambient) : (2 * ambient - 1) );
				else 
					p_oGraphics.beginFill( 0, 1 - ambient );
			}

			else
			{
				aN[0] = v0N; aN[1] = v1N; aN[2] = v2N;

				// check for backside
				vN = p_oPolygon.normal.getVector().clone();
				p_oPolygon.shape.modelMatrix.vectorMult3x3( vN );
				var back:Boolean = (d.dot (vN) > 0);

				// calculate two arbitrary vectors perpendicular to light direction
				e1 = (Math.abs (d.x) + Math.abs (d.y) > 0) ? new Vector (d.y, -d.x, 0) : new Vector (d.z, 0, -d.x);
				e2 = d.cross (e1);
				e1.normalize ();
				e2.normalize ();

				for (var i:int = 0; i < 3; i++)
				{
					// project normals onto e1 and e2
					aNP[i].x = e1.dot (aN[i]);
					aNP[i].y = e2.dot (aN[i]);

					if (back)
					{
						// FIXME
						// this face is on a backside, but has "mixed" vertex normals
						// in theory, this is fixed by setting ambient as lower bound for aL[i]
						// in practice, the direction of gradient on this face is the opposite
						// I think highlight spot "jumps" around for the same reason, but I cant
						// figure it out...
					}

					// calculate light
					// FIXME: I have added 1e-14 to prevent matrix overflow, but it doesnt always help
					// also, simply adding ambient to p_oScene.light.calculate (aN[i]) creates solid-white faces,
					// so it is doctored here...
					aL[i] = NumberUtil.constrain (p_oScene.light.calculate (aN[i]), 0, 1);
					aL[i] = NumberUtil.constrain (aL[i] + (1 - aL[i]) * ambient, ambient, 1);
					
					// invert - we have highlight at the map center
					aL[i] = 1 - aL[i];

					// re-calculate into gradient space
					aNPinorm = Math.sqrt (aNP[i].x * aNP[i].x + aNP[i].y * aNP[i].y);
					aNP[i].x = (16384 - 1) * 0.05 * (aL[i] * aNP[i].x / aNPinorm);
					aNP[i].y = (16384 - 1) * 0.05 * (aL[i] * aNP[i].y / aNPinorm);
				}

				// compute gradient matrix
				matrix.a = aNP[1].x - aNP[0].x;
				matrix.b = aNP[1].y - aNP[0].y;
				matrix.c = aNP[2].x - aNP[0].x;
				matrix.d = aNP[2].y - aNP[0].y;
				matrix.tx = aNP[0].x;
				matrix.ty = aNP[0].y;
				matrix.invert ();

				matrix2.a = v1.sx - v0.sx;
				matrix2.b = v1.sy - v0.sy;
				matrix2.c = v2.sx - v0.sx;
				matrix2.d = v2.sy - v0.sy;
				matrix2.tx = v0.sx;
				matrix2.ty = v0.sy;

				matrix.concat (matrix2);

				// set up gradient
				ratios = useBright ? [0, 0x7F, 0x7F, 0xFF] : [0, 0xFF];
				colours = useBright ? [0xFFFFFF, 0xFFFFFF, 0, 0] : [0, 0];
				alpha = useBright ? [1, 0, 0, 1] : [0, 1];

				p_oGraphics.beginGradientFill( "radial", colours, alpha, ratios, matrix );
			}

			// render the lighting
			p_oGraphics.moveTo( l_aPoints[0].sx, l_aPoints[0].sy );
			for each( l_oVertex in l_aPoints )
			{
				p_oGraphics.lineTo( l_oVertex.sx, l_oVertex.sy );
			}
			p_oGraphics.endFill();
			
			// --
			l_aPoints = null;
			v0N = null;
			v1N = null;
			v2N = null;
		}
	}
}