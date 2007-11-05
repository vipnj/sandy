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

package sandy.materials 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vertex;
	import sandy.materials.attributes.MaterialAttributes;
	
	/**
	 * <p>
	 * Experimental port of the Away3D PreciseBitmapMaterial class.
	 * 
	 * This material, even if working, is not fully stable yet. We are still trying to optimize it and may be merged in the future with the BitmapMaterial
	 * </p>
	 */
	public class PreciseBitmapMaterial extends BitmapMaterial
	{
        public var precision:Number = 1;		
		private var m_nRecLevel:int = 0;
		/**
		 * <p>Create a PreciseBitmapMaterial instance.
		 * Mind that this material is still in development.</p>
		 * @param bitmap The bitmapdata object to map the shape with
		 * @param p_oAttr Material attributes object.
		 * @param p_nPrecision : the lower, the more accurate it is !
		 */
        public function PreciseBitmapMaterial(bitmap:BitmapData, p_oAttr:MaterialAttributes=null, p_nPrecision:uint = 1 )
        {
            super(bitmap, p_oAttr);

            precision = p_nPrecision;

            precision = precision * precision * 1.4;
        }
          

		/**
		 * Renders this material on the face it dresses
		 *
		 * @param p_oScene		The current scene
		 * @param p_oPolygon	The face to be rendered
		 * @param p_mcContainer	The container to draw on
		 */
		public override function renderPolygon( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ):void 
		{
        	if( m_oTexture == null ) return;
        	// --
			var l_points:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices.slice() : p_oPolygon.vertices.slice();
			var l_uv:Array = (p_oPolygon.isClipped) ? p_oPolygon.caUVCoord.slice() : p_oPolygon.aUVCoord.slice();
			// --
			if( !l_points.length ) return;
			// --
			polygon = p_oPolygon;
        	graphics = p_mcContainer.graphics;
        	// --
        	m_nRecLevel = 0;
			// --
			if( polygon.isClipped || l_points.length > 3 )
			{
				_tesselatePolygon( l_points, l_uv );
			}
			else
			{
				map = (m_oPolygonMatrixMap[polygon] as Matrix );
				var v0:Vertex = l_points[0];
	        	var v1:Vertex = l_points[1];
	        	var v2:Vertex = l_points[2];
				renderRec(	map.a, map.b, map.c, map.d, map.tx, map.ty,
						v0.sx, v0.sy, v0.wz,
						v1.sx, v1.sy, v1.wz,
						v2.sx, v2.sy, v2.wz);
			}
			// --
			if( attributes.lineAttributes ) attributes.lineAttributes.draw( graphics, polygon, l_points );
			if( attributes.outlineAttributes ) attributes.outlineAttributes.draw( graphics, polygon, l_points );
			// --
			l_points = null;
			l_uv = null;
		}
		       
        protected override function _tesselatePolygon(p_aPoints:Array, p_aUv:Array ):void
		{
			var l_points: Array = p_aPoints.slice();
			var l_uv: Array = p_aUv.slice();
			// --
			if( l_points.length > 3 )
			{
				l_points = l_points.slice( 0, 3 );
				l_uv = l_uv.slice( 0, 3 );
				// --
				p_aPoints.splice( 1, 1 );
				p_aUv.splice( 1, 1 );
				// --
				_tesselatePolygon( p_aPoints, p_aUv );
			}
			// --
			map = _createTextureMatrix( l_uv );
	        // --
	        var v0:Vertex = l_points[0];
	        var v1:Vertex = l_points[1];
	        var v2:Vertex = l_points[2];
	        
	        renderRec(	map.a, map.b, map.c, map.d, map.tx, map.ty,
						v0.sx, v0.sy, v0.wz,
						v1.sx, v1.sy, v1.wz,
						v2.sx, v2.sy, v2.wz);
	        // --
	        l_points = null;
			l_uv = null;
		}
             
		protected function renderRec( ta:Number, tb:Number, tc:Number, td:Number, tx:Number, ty:Number, 
            ax:Number, ay:Number, az:Number, bx:Number, by:Number, bz:Number, cx:Number, cy:Number, cz:Number):void
        {
			m_nRecLevel++;
            var faz:Number = az;
            var fbz:Number = bz;
            var fcz:Number = cz;
            var mabz:Number = 2 / (faz + fbz);
            var mbcz:Number = 2 / (fbz + fcz);
            var mcaz:Number = 2 / (fcz + faz);
            var mabx:Number = (ax*faz + bx*fbz)*mabz;
            var maby:Number = (ay*faz + by*fbz)*mabz;
            var mbcx:Number = (bx*fbz + cx*fcz)*mbcz;
            var mbcy:Number = (by*fbz + cy*fcz)*mbcz;
            var mcax:Number = (cx*fcz + ax*faz)*mcaz;
            var mcay:Number = (cy*fcz + ay*faz)*mcaz;
            var dabx:Number = ax + bx - mabx;
            var daby:Number = ay + by - maby;
            var dbcx:Number = bx + cx - mbcx;
            var dbcy:Number = by + cy - mbcy;
            var dcax:Number = cx + ax - mcax;
            var dcay:Number = cy + ay - mcay;
            var dsab:Number = (dabx*dabx + daby*daby);
            var dsbc:Number = (dbcx*dbcx + dbcy*dbcy);
            var dsca:Number = (dcax*dcax + dcay*dcay);

            if ((m_nRecLevel > 5) || ((dsab <= precision) && (dsca <= precision) && (dsbc <= precision)))
            {
                renderTriangle(ta, tb, tc, td, tx, ty, ax, ay, bx, by, cx, cy);
				m_nRecLevel--; return;
            }

            if ((dsab > precision) && (dsca > precision) && (dsbc > precision) )
            {
                renderRec(ta*2, tb*2, tc*2, td*2, tx*2, ty*2,
                    ax, ay, az, mabx/2, maby/2, (az+bz)/2, mcax/2, mcay/2, (cz+az)/2);

                renderRec(ta*2, tb*2, tc*2, td*2, tx*2-1, ty*2,
                    mabx/2, maby/2, (az+bz)/2, bx, by, bz, mbcx/2, mbcy/2, (bz+cz)/2);

                renderRec(ta*2, tb*2, tc*2, td*2, tx*2, ty*2-1,
                    mcax/2, mcay/2, (cz+az)/2, mbcx/2, mbcy/2, (bz+cz)/2, cx, cy, cz);

                renderRec(-ta*2, -tb*2, -tc*2, -td*2, -tx*2+1, -ty*2+1,
                    mbcx/2, mbcy/2, (bz+cz)/2, mcax/2, mcay/2, (cz+az)/2, mabx/2, maby/2, (az+bz)/2);
                    
                m_nRecLevel--; return;
            }

            var dmax:Number = Math.max(dsab, Math.max(dsca, dsbc));

            if (dsab == dmax)
            {
                renderRec(ta*2, tb*1, tc*2, td*1, tx*2, ty*1,
                    ax, ay, az, mabx/2, maby/2, (az+bz)/2, cx, cy, cz);

                renderRec(ta*2+tb, tb*1, 2*tc+td, td*1, tx*2+ty-1, ty*1,
                    mabx/2, maby/2, (az+bz)/2, bx, by, bz, cx, cy, cz);
                    
                m_nRecLevel--; return;
            }

            if (dsca == dmax)
            {
                renderRec(ta*1, tb*2, tc*1, td*2, tx*1, ty*2,
                    ax, ay, az, bx, by, bz, mcax/2, mcay/2, (cz+az)/2);

                renderRec(ta*1, tb*2 + ta, tc*1, td*2 + tc, tx, ty*2+tx-1,
                    mcax/2, mcay/2, (cz+az)/2, bx, by, bz, cx, cy, cz);

                m_nRecLevel--; return;
            }

            renderRec(ta-tb, tb*2, tc-td, td*2, tx-ty, ty*2,
                ax, ay, az, bx, by, bz, mbcx/2, mbcy/2, (bz+cz)/2);

            renderRec(2*ta, tb-ta, tc*2, td-tc, 2*tx, ty-tx,
                ax, ay, az, mbcx/2, mbcy/2, (bz+cz)/2, cx, cy, cz);

			m_nRecLevel--;
        }

		protected function renderTriangle(a:Number, b:Number, c:Number, d:Number, tx:Number, ty:Number, 
			v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number):void
		{
			var a2:Number = v1x - v0x;
			var b2:Number = v1y - v0y;
			var c2:Number = v2x - v0x;
			var d2:Number = v2y - v0y;
								   
			matrix.a = a*a2 + b*c2;
			matrix.b = a*b2 + b*d2;
			matrix.c = c*a2 + d*c2;
			matrix.d = c*b2 + d*d2;
			matrix.tx = tx*a2 + ty*c2 + v0x;
			matrix.ty = tx*b2 + ty*d2 + v0y;

			graphics.lineStyle();
			graphics.beginBitmapFill(m_oTexture, matrix, repeat, smooth);
			graphics.moveTo(v0x, v0y);
			graphics.lineTo(v1x, v1y);
			graphics.lineTo(v2x, v2y);
			graphics.endFill();
		}
	}
}