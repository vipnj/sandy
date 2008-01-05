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
	 * Realize a Cell shading on a material.
	 *
	 * @author		rafajafar + makc :)
	 */
	public final class CelShadeAttributes extends ALightAttributes
	{
		/**
		 * Used if a lightmap needs to be overridden.
		 */
		public var lightmap:PhongAttributesLightMap = null;
		/**
		 * Non-zero value adds sphere normals to actual normals for light rendering.
		 * Use this with flat surfaces or cylinders.
		 */
		public var spherize:Number = 0;

		/**
		 * Flag for rendering mode.
		 * <p>If true, only specular highlight is rendered, when useBright is also true.<br />
		 * If false (the default) ambient and diffuse reflections will also be rendered.</p>
		 */
		public var onlySpecular:Boolean = false;

		/**
		 * Flag for lightening mode.
		 * <p>If true (the default), the lit objects use full light range from black to white.<br />
		 * If false they just range from black to their normal appearance; additionally, current
		 * implementation does not render specular reflection in this case.</p>
		 */
		public function set useBright (p_bIgnore:Boolean):void { }
		public function get useBright ():Boolean {return false;}

		/**
		 * Compute the light map.
		 * <p>Normally you should not need to call this function, as it is done for you automatically
		 * when it is needed. You might call it to compute light map in advance, though.</p>
		 * 
		 * @param p_oLight Light3D object to make the light map for.
		 * @param p_nQuality Quality of light response approximation. A value between 2 and 15 is expected
		 * (Flash radial gradient is used internally light map, thus we can only roughly approximate exact
		 * lighting).
		 * @param p_nSamples A number of calculated samples per anchor. Positive value is expected (greater
		 * values will produce a little bit more accurate interpolation with non-equally spaced anchors).
		 */
		public function computeLightMap (p_oLight:Light3D, p_nQuality:int = 4, p_nSamples:int = 4):void
		{
			var l_oLightMap:PhongAttributesLightMap = new PhongAttributesLightMap ();

			if(lightmap){
				l_oLightMap.alphas[0] = lightmap.alphas[0];
				l_oLightMap.colors[0] = lightmap.colors[0];
				l_oLightMap.ratios[0] = lightmap.ratios[0];
			} else {
				l_oLightMap.alphas[0] = [
					1, 1,
					1, 1,
					1, 1];
				l_oLightMap.colors[0] = [
					0xFFFFFF, 0xFFFFFF ,
					0x888888, 0x888888,
					0x666666, 0x666666];
				l_oLightMap.ratios[0] = [
					  0,  40,
					 40,  80,
					 80, 120];
	
				// add ambient thingy
				l_oLightMap.alphas[0].push (1 - ambient * m_nI);
				l_oLightMap.colors[0].push (0);
				l_oLightMap.ratios[0].push (180);
			}
			// store light map
			m_oCurrentLightMap = l_oLightMap;
		}
		
		// do something clever here
		public function CelShadeAttributes (p_oLightMap:PhongAttributesLightMap = null)
		{
			lightmap = p_oLightMap;
		}

		// override this to prevent clearing of m_oCurrentLightMap
		// since we are not calling super, we need to repeat ALightAttributes code
		override protected function onRenderDisplayList (p_oArg:*):void
		{
			var l_oScene:Scene3D = ((p_oArg as Scene3D != null) ? p_oArg : (p_oArg as SandyEvent).target) as Scene3D;

			// fetch light power
			m_nI = l_oScene.light.getNormalizedPower ();

			// fetch light direction vector
			m_oL = l_oScene.light.getDirectionVector ();
			
			computeLightMap (l_oScene.light);
		}
		// default quality to pass to computeLightMap (set in constructor)
		private var m_nQuality:int;

		// default samples to pass to computeLightMap (set in constructor)
		private var m_nSamples:int;

		// dictionary to hold light maps
		private var m_oLightMaps:Dictionary = new Dictionary ();

		// on SandyEvent.LIGHT_UPDATED we update the light map for this light *IF* we have it
		private function watchForUpdatedLights (p_oEvent:SandyEvent):void
		{
			if (m_oLightMaps [p_oEvent.target as Light3D] as PhongAttributesLightMap != null)
			{
				computeLightMap (p_oEvent.target as Light3D, m_nQuality, m_nSamples);
			}
		}

		// light map to use in this rendering session
		/*private*/protected var m_oCurrentLightMap:PhongAttributesLightMap;

		// --
		override public function draw(p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D):void
		{
			super.draw (p_oGraphics, p_oPolygon, p_oMaterial, p_oScene);

			var i:int, j:int, l_oVertex:Vertex;

			// got anything at all to do?
			if( !p_oMaterial.lightingEnable )
				return;

			// get vertices and prepare matrix2
			var l_aPoints:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;
			matrix2.a = l_aPoints[1].sx - l_aPoints[0].sx;
			matrix2.b = l_aPoints[1].sy - l_aPoints[0].sy;
			matrix2.c = l_aPoints[2].sx - l_aPoints[0].sx;
			matrix2.d = l_aPoints[2].sy - l_aPoints[0].sy;
			matrix2.tx = l_aPoints[0].sx;
			matrix2.ty = l_aPoints[0].sy;

			// transform 1st three normals
			for (i = 0; i < 3; i++)
			{
				aN0 [i].copy (p_oPolygon.vertexNormals [i].getVector ());
				if (spherize > 0)
				{
					var dv:Vector = l_aPoints [i].getVector ();
					dv.sub (p_oPolygon.shape.geometryCenter);
					dv.normalize ();
					dv.scale (spherize);
					aN0 [i].add (dv);
					aN0 [i].normalize ();
				}
				p_oPolygon.shape.modelMatrix.vectorMult3x3 (aN0 [i]);
			}

			// apply ambient + diffuse and specular maps separately
			// note we cannot correctly render specular with useBright off
			for (j = onlySpecular ? 1 : 0; j < (useBright ? 2 : 1); j++)
			{
				// get highlight direction vector
				var d:Vector = (j == 0) ? m_oL : m_oH;

				// see if we are on the backside
				var backside:Boolean = true
				for (i = 0; i < 3; i++)
				{
					aN [i].copy (aN0 [i]);

					var d_dot_aNi:Number = d.dot (aN [i]);
					if (d_dot_aNi < 0) backside = false;

					// intersect with parabola - q(r) in computeLightMap() corresponds to this
					aN[i].scale (1 / (1 - d_dot_aNi));
				}

				if (backside)
				{
					// no reflection here - render the face in solid ambient
					// the way specular is done now, we dont need to render it at all on the backside
					if (j == 0)
					{
						const aI:Number = ambient * m_nI;
						if (useBright) 
							p_oGraphics.beginFill( (aI < 0.5) ? 0 : 0xFFFFFF, (aI < 0.5) ? (1 - 2 * aI) : (2 * aI - 1) );
						else
							p_oGraphics.beginFill( 0, 1 - aI );
					}
				}

				else
				{
					// calculate two arbitrary vectors perpendicular to light direction
					var e1:Vector = (Math.abs (d.x) + Math.abs (d.y) > 0) ? new Vector (d.y, -d.x, 0) : new Vector (d.z, 0, -d.x);
					var e2:Vector = d.cross (e1);
					e1.normalize ();
					e2.normalize ();

					for (i = 0; i < 3; i++)
					{
						// project aN [i] onto e1 and e2
						aNP [i].x = e1.dot (aN [i]);
						aNP [i].y = e2.dot (aN [i]);

						// re-calculate into light map coordinates
						aNP [i].x = (16384 - 1) * 0.05 * aNP [i].x;
						aNP [i].y = (16384 - 1) * 0.05 * aNP [i].y;
					}

					/*
					// simple hack to resolve bad projections
					// this needs to be done some other way though
					while ((Math.abs(
							(aNP[0].x - aNP[1].x) * (aNP[0].x - aNP[2].x) + (aNP[0].y - aNP[1].y) * (aNP[0].y - aNP[2].y)
							) > (1 - NumberUtil.TOL) *
							Point.distance(aNP[0], aNP[1]) * Point.distance(aNP[0], aNP[2])
						)
						|| (Math.abs(
							(aNP[0].x - aNP[1].x) * (aNP[2].x - aNP[1].x) + (aNP[0].y - aNP[1].y) * (aNP[2].y - aNP[1].y)
							) > (1 - NumberUtil.TOL) *
							Point.distance(aNP[0], aNP[1]) * Point.distance(aNP[2], aNP[1])
						))
					{
						aNP[0].x--; aNP[1].y++; aNP[2].x++;
					}
					*/

					// compute gradient matrix
					matrix.a = aNP[1].x - aNP[0].x;
					matrix.b = aNP[1].y - aNP[0].y;
					matrix.c = aNP[2].x - aNP[0].x;
					matrix.d = aNP[2].y - aNP[0].y;
					matrix.tx = aNP[0].x;
					matrix.ty = aNP[0].y;
					matrix.invert ();
	
					matrix.concat (matrix2);
					p_oGraphics.beginGradientFill( "radial", m_oCurrentLightMap.colors [j], m_oCurrentLightMap.alphas [j], m_oCurrentLightMap.ratios [j], matrix );
				}

				if (!backside || (j == 0))
				{
					// render the lighting
					p_oGraphics.moveTo( l_aPoints[0].sx, l_aPoints[0].sy );
					for each( l_oVertex in l_aPoints )
					{
						p_oGraphics.lineTo( l_oVertex.sx, l_oVertex.sy  );
					}
					p_oGraphics.endFill();
				}
			}
			// --
			l_aPoints = null;
		}

		// when Phong model parameters change, any light maps we had are no longer valid
		override protected function onPropertyChange ():void
		{
			m_oLightMaps = new Dictionary ();
		}

		// --
		private var _useBright:Boolean = true;

		private var aN0:Array = [new Vector (), new Vector (), new Vector ()];
		private var aN:Array  = [new Vector (), new Vector (), new Vector ()];
		private var aNP:Array = [new Point (), new Point (), new Point ()];

		private var matrix:Matrix = new Matrix();
		private var matrix2:Matrix = new Matrix();
	}
}


