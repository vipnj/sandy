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
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.util.NumberUtil;

	/**
	 * Displays a bitmap on the faces of a 3D shape..
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @author		Xavier Martin - zeflasher - transparency managment
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class BitmapMaterial extends Material
	{

		/**
		 * This property enable smooth bitmap rendering when set to true.
		 * The default value is set to false to have the best performance first.
		 * Enable this property have a performance impact, use it warefully
		 */
		public var smooth:Boolean = false;

		/**
		 * Precision of the bitmap mapping.
		 * This material uses an affine linear mapping. It results in a lack of accuracy at rendering time when the surface to draw is too big.
		 * An usual solution is to augment the number of polygon, but the performance cost can be quite big.
		 * An other solution is to change this property value. The lower to more accurate the perspective correction is.
		 * To disable the perspective correction, set this property to zero, which is also the default value
		 */
		public var precision:uint = 0;

		/**
		 * Creates a new BitmapMaterial.
		 * <p>Please note that we ue internally a copy of the constructor bitmapdata. Thatea mns in case you need to access this bitmapdata, you can't just use the same reference
		 * but you shall use the BitmapMaterial#texture getter property to make it work.</p>
		 * @param p_oTexture 	The bitmapdata for this material
		 * @param p_oAttr	The attributes for this material
		 * @param p_nPrecision The precision of this material. Using a precision with 0 makes the material behave as before. Then 1 as precision is very high and requires a lot of computation but proceed a the best perpective mapping correction. Bigger values are less CPU intensive but also less accurate. Usually a value of 5 is enough.
		 */
		public function BitmapMaterial( p_oTexture:BitmapData = null, p_oAttr:MaterialAttributes = null, p_nPrecision:uint = 0 )
		{
			super(p_oAttr);
			// --
			m_nType = MaterialType.BITMAP;
			// --
			var temp = new BitmapData( p_oTexture.width, p_oTexture.height, true, 0x00FFFFFF );
			temp.draw( p_oTexture );
			texture = temp;
			// --
			m_oCmf = new ColorMatrixFilter();
			m_oPolygonMatrixMap = new Dictionary();
			precision = p_nPrecision;
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
				map = (m_oPolygonMatrixMap[polygon.id] as Matrix );
				var v0:Vertex = l_points[0];
	        	var v1:Vertex = l_points[1];
	        	var v2:Vertex = l_points[2];
				if( precision == 0 )
		        {
		        	renderTriangle(map.a, map.b, map.c, map.d, map.tx, map.ty, v0.sx, v0.sy, v1.sx, v1.sy, v2.sx, v2.sy );
		        }
		        else
		        {
			        renderRec(	map.a, map.b, map.c, map.d, map.tx, map.ty,
								v0.sx, v0.sy, v0.wz,
								v1.sx, v1.sy, v1.wz,
								v2.sx, v2.sy, v2.wz);
		        }
			}
			// --
			if( attributes )  attributes.draw( graphics, polygon, this, p_oScene ) ;
			// --
			l_points = null;
			l_uv = null;
		}

		protected function _tesselatePolygon ( p_aPoints:Array, p_aUv:Array ):void
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

	        if( precision == 0 )
	        {
	        	renderTriangle(map.a, map.b, map.c, map.d, map.tx, map.ty, v0.sx, v0.sy, v1.sx, v1.sy, v2.sx, v2.sy );
	        }
	        else
	        {
		        renderRec(	map.a, map.b, map.c, map.d, map.tx, map.ty,
							v0.sx, v0.sy, v0.wz,
							v1.sx, v1.sy, v1.wz,
							v2.sx, v2.sy, v2.wz);
	        }
	        // --
	        l_points = null;
			l_uv = null;
	 	}

		protected function renderRec( ta:Number, tb:Number, tc:Number, td:Number, tx:Number, ty:Number,
            ax:Number, ay:Number, az:Number, bx:Number, by:Number, bz:Number, cx:Number, cy:Number, cz:Number):void
        {
			m_nRecLevel++;
            var mabz:Number = 2 / (az + bz);
            var mbcz:Number = 2 / (bz + cz);
            var mcaz:Number = 2 / (cz + az);
            var mabx:Number = (ax*az + bx*bz)*mabz;
            var maby:Number = (ay*az + by*bz)*mabz;
            var mbcx:Number = (bx*bz + cx*cz)*mbcz;
            var mbcy:Number = (by*bz + cy*cz)*mbcz;
            var mcax:Number = (cx*cz + ax*az)*mcaz;
            var mcay:Number = (cy*cz + ay*az)*mcaz;
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


		protected function _createTextureMatrix( p_aUv:Array ):Matrix
		{
			var u0: Number = p_aUv[0].u * m_nWidth,
				v0: Number = p_aUv[0].v * m_nHeight,
				u1: Number = p_aUv[1].u * m_nWidth,
				v1: Number = p_aUv[1].v * m_nHeight,
				u2: Number = p_aUv[2].u * m_nWidth,
				v2: Number = p_aUv[2].v * m_nHeight;
			// -- Fix perpendicular projections. Not sure it is really useful here since there's no texture prjection. This will certainly solve the freeze problem tho
			if( (u0 == u1 && v0 == v1) || (u0 == u2 && v0 == v2) )
			{
				u0 -= (u0 > 0.05)? 0.05 : -0.05;
				v0 -= (v0 > 0.07)? 0.07 : -0.07;
			}
			if( u2 == u1 && v2 == v1 )
			{
				u2 -= (u2 > 0.05)? 0.04 : -0.04;
				v2 -= (v2 > 0.06)? 0.06 : -0.06;
			}
			// --
			var m:Matrix = new Matrix( (u1 - u0), (v1 - v0), (u2 - u0), (v2 - v0), u0, v0 );
			m.invert();
			return m;
		}

		/**
		 * The texture ( bitmap ) of this material
		 */
		public function get texture():BitmapData
		{
			return m_oTexture;
		}

		/**
		 * @private
		 */
		public function set texture( p_oTexture:BitmapData ):void
		{
			var l_bReWrap:Boolean = false;
			if( m_nHeight != p_oTexture.height) l_bReWrap = true;
			else if( m_nWidth != p_oTexture.width) l_bReWrap = true;
			// --
			m_oTexture = p_oTexture;
			m_nHeight = m_oTexture.height;
			m_nWidth = m_oTexture.width;
			m_nInvHeight = 1/m_nHeight;
			m_nInvWidth = 1/m_nWidth;
			m_oTexture.lock(); // not sure it is faster but it should....
			m_orgTexture = p_oTexture.clone();
			// -- We reinitialize the precomputed matrix
			if( l_bReWrap )
			{
				for( var l_sID:String in m_oPolygonMatrixMap )
				{
					var l_oPoly:Polygon = Polygon.POLYGON_MAP[ l_sID ];
					init( l_oPoly );
				}
			}
		}

		/**
		 * Changes the transparency of the texture.
		 *
		 * <p>The passed value is the percentage of opacity.</p>
		 *
		 * @param p_nValue 	A value between 0 and 1. (automatically constrained)
		 */
		public function setTransparency( p_nValue:Number ):void
		{
			p_nValue = NumberUtil.constrain( p_nValue, 0, 1 );
			if( m_oCmf ) m_oCmf = null;
			var matrix:Array = [	1, 0, 0, 0, 0,
					    	0, 1, 0, 0, 0,
					    	0, 0, 1, 0, 0,
					    	0, 0, 0, p_nValue, 0];

			m_oCmf = new ColorMatrixFilter( matrix );
			texture.applyFilter( m_orgTexture, texture.rect, m_oPoint, m_oCmf );
		}

		/**
		 * Initiates this material.
		 *
		 * @param p_oPolygon	The face dressed by this material
		 */
		public override function init( p_oPolygon:Polygon ):void
		{
			if( p_oPolygon.vertices.length >= 3 )
			{
				var m:Matrix = null;
				var l_oRect:Rectangle = null;
				// --
				if( m_nWidth > 0 && m_nHeight > 0 )
				{
					var l_aUV:Array = p_oPolygon.aUVCoord;
					if( l_aUV )
					{
						m = _createTextureMatrix( l_aUV );
					}
				}
				// --
				m_oPolygonMatrixMap[p_oPolygon.id] = m;
			}
		}

		public function toString():String
		{
			return 'sandy.materials.BitmapMaterial' ;
		}

		internal var polygon:Polygon;
        internal var graphics:Graphics;
        internal var map:Matrix = new Matrix();

		protected var m_oTexture:BitmapData;
		protected var m_orgTexture:BitmapData;
		private var m_nHeight:Number;
		private var m_nWidth:Number;
		private var m_nInvHeight:Number;
		private var m_nInvWidth:Number;

		private var m_nRecLevel:int = 0;
		protected var m_oPolygonMatrixMap:Dictionary;
		private var m_oPoint:Point = new Point();
		private var m_oCmf:ColorMatrixFilter;
		protected var matrix:Matrix = new Matrix();
	}
}