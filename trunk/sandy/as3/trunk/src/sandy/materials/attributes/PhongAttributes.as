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
	import flash.utils.Dictionary;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.light.Light3D;
	import sandy.events.SandyEvent;
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
		 * <p>If true, the lit objects use full light range from black to white.<br />
		 * If false (the default) they just range from black to their normal appearance.</p>
		 */
		public function set useBright (p_bUseBright:Boolean):void
		{
			_useBright = p_bUseBright; m_oLightMaps = new Dictionary ();
		}
		
		/**
		 * @private
		 */
		public function get useBright ():Boolean
		{return _useBright;}

				
		/**
		 * Level of ambient light, added to the scene if lighting is enabled.
		 */
		public function set ambient (p_nAmbient:Number):void
		{
			_ambient = p_nAmbient; m_oLightMaps = new Dictionary ();
		}
		
		/**
		 * @private
		 */
		public function get ambient ():Number
		{return _ambient;}

		/**
		 * Compute the light map.
		 * <p>In true Phong shading, normal vectors are supposed to be interpolated across the surface;
		 * here normal vectors projections are interpolated in a lightmap space. The light map is then
		 * used to translate normal vector projection into corresponding color value. We use radial
		 * gradient as a basis for light map, thus we can only roughly approximate Light3D response
		 * as a function of normal vector projection.</p>
		 * <p>Normally you should not need to call this function, as it is done for you automatically
		 * when it is needed. You might call it to compute light map in advance, though.</p>
		 * 
		 * @param p_oLight Light3D object to make the light map for.
		 * @param p_nQuality Quality of light response approximation. A value between 2 and 15 is expected.
		 */
		public function computeLightMap (p_oLight:Light3D, p_nQuality:int = 4):void
		{
			var i:int;
			var l_nQuality:int = NumberUtil.constrain (p_nQuality, 2, 15);

			// get light direction and make any perpendicular vector
			var d:Vector = p_oLight.getDirectionVector ();
			var e:Vector = (Math.abs (d.x) + Math.abs (d.y) > 0) ? new Vector (d.y, -d.x, 0) : new Vector (d.z, 0, -d.x);
			e.normalize ();
	
			// sample Light3D response function
			var l_aResponse:Array = new Array (l_nQuality);
			for (i = 0; i < l_nQuality; i++)
			{
				// radius in the map (scaled 0..1) and its complimentary number
				var r:Number = i * 1.0 / (l_nQuality - 1), q:Number = Math.sqrt (1 - r * r);
				// virtual normal vector
				var n:Vector = new Vector (e.x * r - d.x * q, e.y * r - d.y * q, e.z * r - d.z * q);
				// add ambient to Light3D response
				l_aResponse [i] = NumberUtil.constrain (p_oLight.calculate (n) + ambient, 0, 1);
			}

			// compute the light map
			var l_oLightMap:PhongAttributesLightMap = new PhongAttributesLightMap ();

			if (useBright)
			{
				// find transparent point in a gradient
				// assume that Light3D response gradually decreases (true for Sandy 3.0.1)
				var j:Number = -1;
				if (l_aResponse [0] > 0.5)
				{
					for (i = 1; i < l_nQuality; i++)
						if (l_aResponse [i] <= 0.5)
							j = ((l_aResponse [i-1] - 0.5) * i + (0.5 - l_aResponse [i]) * (i-1)) /
								(l_aResponse [i-1] - l_aResponse [i]);
				}

				for (i = 0; i < l_nQuality; i++)
				{
					l_oLightMap.alphas.push ((l_aResponse [i] > 0.5) ? 2 * l_aResponse [i] - 1 : 1 - 2 * l_aResponse [i]);
					l_oLightMap.colors.push ((l_aResponse [i] > 0.5) ? 0xFFFFFF : 0);
					l_oLightMap.ratios.push ((i * 255) / (l_nQuality - 1));
					if ((i <= j) && (j <= i + 1))
					{
						// we need to add two transparent points, but the number of points is limited
						// we might have to remove one or two points in order to do this
						if (l_nQuality > 13)
						{
							i++;
							if (l_nQuality > 14)
							{
								l_oLightMap.alphas.pop ();
								l_oLightMap.colors.pop ();
								l_oLightMap.ratios.pop ();
							}
						}

						l_oLightMap.alphas.push (0);
						l_oLightMap.colors.push (0xFFFFFF);
						l_oLightMap.ratios.push ((j * 255) / (l_nQuality - 1));

						l_oLightMap.alphas.push (0);
						l_oLightMap.colors.push (0);
						l_oLightMap.ratios.push ((j * 255) / (l_nQuality - 1));
					}
				}
			}

			else
			{
				for (i = 0; i < l_nQuality; i++)
				{
					l_oLightMap.alphas.push (1 - l_aResponse [i]);
					l_oLightMap.colors.push (0);
					l_oLightMap.ratios.push ((i * 255) / (l_nQuality - 1));
				}
			}

			m_oLightMaps [p_oLight] = l_oLightMap;
		}
		
		/**
		 * Create the PhongAttributes object.
		 * @param p_nAmbient The ambient light value. A value between 0 and 1 is expected.
		 * @param p_nQuality Quality of light response approximation. A value between 2 and 15 is expected.
		 */
		public function PhongAttributes (p_bBright:Boolean = false, p_nAmbient:Number = 0.0, p_nQuality:int = 4)
		{
			useBright = p_bBright;
			ambient = NumberUtil.constrain (p_nAmbient, 0, 1);

			m_nQuality = p_nQuality;
		}

		// default quality to pass to computeLightMap (set in constructor)
		private var m_nQuality:int;

		// dictionary to hold light maps
		private var m_oLightMaps:Dictionary = new Dictionary ();

		// on SandyEvent.LIGHT_UPDATED we re-do light map for this light, if we already have it
		private function watchForUpdatedLights (p_oEvent:SandyEvent):void
		{
			if (m_oLightMaps [p_oEvent.target as Light3D] as PhongAttributesLightMap != null)
			{
				computeLightMap (p_oEvent.target as Light3D, m_nQuality);
			}
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
		internal var e1:Vector, e2:Vector, vN:Vector;
		internal var matrix2:Matrix = new Matrix();
		
		public function draw(p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D):void
		{
			var i:int;
			if( !p_oMaterial.lightingEnable )
				return;

			// get the light
			var l_oLight:Light3D = p_oScene.light;
			
			// get its light map
			var l_oLightMap:PhongAttributesLightMap;
			if (m_oLightMaps [l_oLight] as PhongAttributesLightMap == null)
			{
				// when no map, subscribe to this light and make the map
				l_oLight.addEventListener (SandyEvent.LIGHT_UPDATED, watchForUpdatedLights);
				computeLightMap (l_oLight, m_nQuality);
			}
			l_oLightMap = m_oLightMaps [l_oLight] as PhongAttributesLightMap;

			// get its light vector
			var d:Vector = l_oLight.getDirectionVector ();

			// get vertices list
			var l_aPoints:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices.slice() : p_oPolygon.vertices.slice();

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
					p_oGraphics.beginFill( (ambient < 0.5) ? 0 : 0xFFFFFF, (ambient < 0.5) ? (1 - 2 * ambient) : (2 * ambient - 1) );
				else 
					p_oGraphics.beginFill( 0, 1 - ambient );
			}

			else
			{
				aN[0] = v0N; aN[1] = v1N; aN[2] = v2N;

				// calculate two arbitrary vectors perpendicular to light direction
				e1 = (Math.abs (d.x) + Math.abs (d.y) > 0) ? new Vector (d.y, -d.x, 0) : new Vector (d.z, 0, -d.x);
				e2 = d.cross (e1);
				e1.normalize ();
				e2.normalize ();

				// sideface
				var sideface:Boolean = false;

				for (i = 0; i < 3; i++)
				{
					// project normals onto e1 and e2
					aNP[i].x = e1.dot (aN[i]);
					aNP[i].y = e2.dot (aN[i]);

					if (d.dot (aN[i]) > 0)
					{
						// scale up into ambient
						aNP[i].normalize (2 - aNP[i].length); sideface = true;
					}

					// re-calculate into light map coordinates
					aNP[i].x = (16384 - 1) * 0.05 * aNP[i].x;
					aNP[i].y = (16384 - 1) * 0.05 * aNP[i].y;
				}

/*				// check for side faces
				vN = p_oPolygon.normal.getVector().clone();
				p_oPolygon.shape.modelMatrix.vectorMult3x3( vN );
				if (d.dot (vN) > 0)*/
				/*if (sideface)
				{
					// after we normalized some aNP[i] above, gradients are nor longer correct
					// we need to patch against this here
					var l_aInd:Array = aNP.sortOn ("length", Array.NUMERIC | Array.RETURNINDEXEDARRAY);
					for (i = 0; i < 3; i++)
					{
						var j:int = l_aInd[i]
						var a:Number = 0.1 * ((j > 1) ? -1 : j);
						var l:Number = aNP[j].length;
						aNP[j].x = Math.cos (a);
						aNP[j].y = Math.sin (a);
						aNP[j].normalize (l);
					}
				}*/

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

				p_oGraphics.beginGradientFill( "radial", l_oLightMap.colors, l_oLightMap.alphas, l_oLightMap.ratios, matrix );
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

		private var _useBright:Boolean = false;
		private var _ambient:Number = 0.3;
	}
}

class PhongAttributesLightMap
{
	public var alphas:Array = [];
	public var colors:Array = [];
	public var ratios:Array = [];
}
