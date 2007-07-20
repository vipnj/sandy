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
	import flash.utils.Dictionary;
	
	import sandy.core.data.Polygon;
	import sandy.core.data.Vertex;
	import sandy.util.NumberUtil;
	
	/**
	 * BitmapMaterial
	 * <p>
	 * This class use a texturing method found on Papervision3D. See the original implementation of Face3D.as on Papervision3D library.
	 * Basically its method unroll the concatenation of the matrix with an initial preparation to make sure the matrix is invertible.
	 * </p>
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		2.0
	 * @date 		06.04.2007 
	 **/
	public class BitmapMaterial extends Material
	{
		public var matrix:Matrix;
		// --
		public var smooth:Boolean;
		
		public var enableAccurateClipping:Boolean = false;
	
		/**
		 * Create a new BitmapMaterial.
		 * @param t : The bitmapdata
		 */
		public function BitmapMaterial( t:BitmapData, p_oLineAttr:LineAttributes = null )
		{
			super();
			// --
			m_nType = MaterialType.BITMAP;
			// --
			lineAttributes = p_oLineAttr;
			// --
			texture = t;
			smooth = false;
			// --
			matrix = new Matrix();
			m_oCmf = new ColorMatrixFilter();
			m_oPolygonMatrixMap = new Dictionary();
		}
	
		public override function renderPolygon( p_oPolygon:Polygon, p_mcContainer:Sprite ):void 
		{
			if( p_oPolygon.isClipped && enableAccurateClipping )
			{
				if( p_oPolygon.cvertices.length )
					_drawPolygon( p_oPolygon.cvertices, p_oPolygon.caUVCoord, p_mcContainer.graphics );
			}
			else
			{
				const l_points:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;
				if( !l_points.length ) return;
				const l_graphics:Graphics = p_mcContainer.graphics;
				// -- we prepare the texture
				//prepare( p_oPolygon.vertices, m_oPolygonMatrixMap[p_oPolygon] );
				const lUv:Matrix = m_oPolygonMatrixMap[p_oPolygon];
				const 	x0:Number = l_points[0].sx, y0: Number = l_points[0].sy,			
						x1:Number = l_points[1].sx, y1:Number = l_points[1].sy, 
						x2:Number = l_points[2].sx, y2:Number = l_points[2].sy;
				m_oTmp.a = x1 - x0;
				m_oTmp.b = y1 - y0;
				m_oTmp.c = x2 - x0;
				m_oTmp.d = y2 - y0;
				m_oTmp.tx = x0;
				m_oTmp.ty = y0;
				matrix.a = lUv.a;
				matrix.b = lUv.b;
				matrix.c = lUv.c;
				matrix.d = lUv.d;
				matrix.tx = lUv.tx;
				matrix.ty = lUv.ty;
				matrix.concat( m_oTmp );
				// --
				l_graphics.beginBitmapFill( m_oTexture, matrix, true, smooth );
				// --
				if( lineAttributes )
					l_graphics.lineStyle( lineAttributes.thickness, lineAttributes.color, lineAttributes.alpha );
				// --
				l_graphics.moveTo( l_points[0].sx, l_points[0].sy );
				// --
				for each( var l_oPoint:Vertex in l_points )
					l_graphics.lineTo( l_oPoint.sx, l_oPoint.sy);
				//	
				l_graphics.endFill();
			}
		}
		
		
		private function _drawPolygon( p_aPoints:Array, p_aUv:Array, p_oGraphics:Graphics ):void
		{
			var l_points: Array = p_aPoints.slice();
			var l_uv: Array = p_aUv.slice();
			if( l_points.length > 3 )
			{
				l_points = l_points.slice( 0, 3 );
				l_uv = l_uv.slice( 0, 3 );
				//
				p_aPoints.splice( 1, 1 );
				p_aUv.splice( 1, 1 );
				//
				_drawPolygon( p_aPoints, p_aUv, p_oGraphics );
			}

			const m:Matrix = _createTextureMatrix( l_uv );
			// -- we prepare the texture
			prepare( l_points, m );
			//
			p_oGraphics.beginBitmapFill( m_oTexture, matrix, true, smooth );
			// --
			if( lineAttributes )
				p_oGraphics.lineStyle( lineAttributes.thickness, lineAttributes.color, lineAttributes.alpha );
			// --
			p_oGraphics.moveTo( l_points[0].sx, l_points[0].sy );
			// --
			for each( var l_oPoint:Vertex in l_points )
				p_oGraphics.lineTo( l_oPoint.sx, l_oPoint.sy);
		}	

		
		private function _createTextureMatrix( p_aUv:Array ):Matrix
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
		 * Start the rendering of the Skin
		 * @param f	The face which is being rendered
		 */
		private function prepare( p_aVertices:Array, m:Matrix ):void
		{
			const l_aVertices:Array = p_aVertices;
			// --
			const 	x0:Number = l_aVertices[0].sx, y0: Number = l_aVertices[0].sy,			
					a2:Number = l_aVertices[1].sx - x0, b2:Number = l_aVertices[1].sy - y0, 
					c2:Number = l_aVertices[2].sx - x0, d2:Number = l_aVertices[2].sy - y0;
			// --
			matrix.a = m.a*a2 + m.b*c2;
			matrix.b = m.a*b2 + m.b*d2;
			matrix.c = m.c*a2 + m.d*c2;
			matrix.d = m.c*b2 + m.d*d2;
			matrix.tx = m.tx*a2 + m.ty*c2 + x0;
			matrix.ty = m.tx*b2 + m.ty*d2 + y0;
		}

		
		public function get texture():BitmapData
		{
			return m_oTexture;
		}
		
		public function set texture( p_oTexture:BitmapData ):void
		{
			m_oTexture = p_oTexture;
			m_nHeight = m_oTexture.height;
			m_nWidth = m_oTexture.width;
			m_oTexture.lock(); // not sure it is faster but it should....
			// FIXME do the init for all the registered polygons
		}
	
		/**
		 * Change the transparency of the texture.
		 * A value is expected to set the transparency. This value represents the percentage of transparency.
		 * @param pValue An offset to change the transparency. A value between 0 and 100. 
		 * If the given value isn't i this interval, it will be clamped.
		 */
		public function setTransparency( pValue:Number ):void
		{
			pValue = NumberUtil.constrain( pValue/100, 0, 1 );
			if( m_oCmf ) m_oCmf = null;
			var matrix:Array = [1, 0, 0, 0, 0,
					 			0, 1, 0, 0, 0, 
					 			0, 0, 1, 0, 0, 
					 			0, 0, 0, pValue, 0];
	 
			m_oCmf = new ColorMatrixFilter( matrix );
			texture.applyFilter( texture, texture.rect, m_oPoint, m_oCmf );
		}
		
		public override function init( f:Polygon ):void
		{
			if( f.vertices.length >= 3 )
			{
				var m:Matrix = null;
				// --
				if( m_nWidth > 0 && m_nHeight > 0 )
				{		
					var l_aUV:Array = f.aUVCoord;
					if( l_aUV )
					{
						m = _createTextureMatrix( l_aUV );
					}
				}
				// --
				m_oPolygonMatrixMap[f] = m;
			}
		}

		
		/**
		 * @param
		 * @return
		 */
		private function __getBrightnessTransform( scale:Number ) : Array
		{
			var s:Number = scale;
			var o:Number = 0;
			//
			return new Array 
			(
				s	, 0.0	, 0.0	, 0.0	, o,
				0.0	, s		, 0.0	, 0.0	, o,
				0.0	, 0.0	, s		, 0.0	, o,
				0.0	, 0.0	, 0.0	, 1.0	, o
			);
		}
	

		public function toString():String
		{
			return 'sandy.materials.BitmapMaterial' ;
		}
		
		protected var m_oTexture:BitmapData;
		private var m_nHeight:Number;
		private var m_nWidth:Number;
		private var m_oPolygonMatrixMap:Dictionary;
		private var m_oPoint:Point = new Point();
		private var m_oCmf:ColorMatrixFilter;
		private var m_oTmp:Matrix = new Matrix();
	}
}