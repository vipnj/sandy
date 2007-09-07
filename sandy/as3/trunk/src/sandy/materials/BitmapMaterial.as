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
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vertex;
	import sandy.util.NumberUtil;
	
	/**
	 * Displays a bitmap on the faces of a 3D shape.
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class BitmapMaterial extends Material
	{
		public var matrix:Matrix = new Matrix();
		// --
		public var smooth:Boolean = false;
		
		public var enableAccurateClipping:Boolean = false;
	
		/**
		 * Creates a new BitmapMaterial.
		 *
		 * @param p_oTexture 	The bitmapdata for this material
		 * @param p_oLineAttr	The line attributes for this material
		 * @param p_oOutlineAttr The outlie attributes settings for this material
		 */
		public function BitmapMaterial( p_oTexture:BitmapData, p_oLineAttr:LineAttributes = null, p_oOutlineAttr:OutlineAttributes = null )
		{
			super();
			// --
			m_nType = MaterialType.BITMAP;
			// --
			lineAttributes = p_oLineAttr;
			outlineAttributes = p_oOutlineAttr;
			// --
			texture = p_oTexture;
			// --
			m_oCmf = new ColorMatrixFilter();
			m_oPolygonMatrixMap = new Dictionary();
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
			const lGraphics:Graphics = p_mcContainer.graphics;
			//
			if( p_oPolygon.isClipped && enableAccurateClipping )
			{
				if( p_oPolygon.cvertices.length )
					_drawPolygon( p_oPolygon, p_oPolygon.cvertices, p_oPolygon.caUVCoord, lGraphics );
			}
			else
			{
				const l_points:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;
				if( !l_points.length ) return;
				// -- we prepare the texture
				const lUv:Matrix = m_oPolygonMatrixMap[p_oPolygon];
				const x0:Number = p_oPolygon.vertices[0].sx, y0:Number = p_oPolygon.vertices[0].sy;
				//--
				m_oTmp.a = p_oPolygon.vertices[1].sx - x0;
				m_oTmp.b = p_oPolygon.vertices[1].sy - y0;
				m_oTmp.c = p_oPolygon.vertices[2].sx - x0;
				m_oTmp.d = p_oPolygon.vertices[2].sy - y0;
				m_oTmp.tx = x0;
				m_oTmp.ty = y0;
				// --
				matrix = lUv.clone();
				matrix.concat(m_oTmp);
				// --
				lGraphics.lineStyle();
				lGraphics.beginBitmapFill( m_oTexture, matrix, false, smooth );
				// --
				// --
				lGraphics.moveTo( l_points[0].sx, l_points[0].sy );
				// --
				for each( var l_oPoint:Vertex in l_points )
					lGraphics.lineTo( l_oPoint.sx, l_oPoint.sy );
				//	--
				lGraphics.endFill();
				
				if( lineAttributes ) lineAttributes.draw( lGraphics, p_oPolygon, l_points );
				if( outlineAttributes ) outlineAttributes.draw( lGraphics, p_oPolygon, l_points );
			}
		}
		

		private function _drawPolygon( p_oPolygon:Polygon, p_aPoints:Array, p_aUv:Array, p_oGraphics:Graphics ):void
		{
			var l_points: Array = p_aPoints.slice();
			var l_uv: Array = p_aUv.slice();
			if( l_points.length > 3 )
			{
				l_points = l_points.slice( 0, 3 );
				l_uv = l_uv.slice( 0, 3 );
				// --
				p_aPoints.splice( 1, 1 );
				p_aUv.splice( 1, 1 );
				// --
				_drawPolygon( p_oPolygon, p_aPoints, p_aUv, p_oGraphics );
			}

			const lUv:Matrix = _createTextureMatrix( l_uv );
			// -- we prepare the texture
			const x0:Number = l_points[0].sx, y0:Number = l_points[0].sy;
			//--
			m_oTmp.a = l_points[1].sx - x0;
			m_oTmp.b = l_points[1].sy - y0;
			m_oTmp.c = l_points[2].sx - x0;
			m_oTmp.d = l_points[2].sy - y0;
			m_oTmp.tx = x0;
			m_oTmp.ty = y0;
			// --
			matrix = lUv.clone();
			matrix.concat(m_oTmp);
			// --
			p_oGraphics.lineStyle();
			p_oGraphics.beginBitmapFill( m_oTexture, matrix, false, smooth );
			// --
			p_oGraphics.moveTo( x0, y0 );
			// --
			for each( var l_oPoint:Vertex in l_points )
				p_oGraphics.lineTo( l_oPoint.sx, l_oPoint.sy);
			// --
			p_oGraphics.endFill();
			
			if( lineAttributes ) lineAttributes.draw( p_oGraphics, p_oPolygon, l_points );
			if( outlineAttributes ) outlineAttributes.draw( p_oGraphics, p_oPolygon, l_points );
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
			m_oTexture = p_oTexture;
			m_nHeight = m_oTexture.height;
			m_nWidth = m_oTexture.width;
			m_nInvHeight = 1/m_nHeight;
			m_nInvWidth = 1/m_nWidth;
			m_oTexture.lock(); // not sure it is faster but it should....
			// FIXME do the init for all the registered polygons
		}
	
		/**
		 * Changes the transparency of the texture.
		 *
		 * <p>The passed value is the percentage of opacity.</p>
		 *
		 * @param p_nValue 	A value between 0 and 100. (automatically constrained)
		 */
		public function setTransparency( p_nValue:Number ):void
		{
			p_nValue = NumberUtil.constrain( p_nValue/100, 0, 1 );
			if( m_oCmf ) m_oCmf = null;
			var matrix:Array = [	1, 0, 0, 0, 0,
					 	0, 1, 0, 0, 0, 
					 	0, 0, 1, 0, 0, 
					 	0, 0, 0, p_nValue, 0];
	 
			m_oCmf = new ColorMatrixFilter( matrix );
			texture.applyFilter( texture, texture.rect, m_oPoint, m_oCmf );
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
				m_oPolygonMatrixMap[p_oPolygon] = m;
			}
		}

		//
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
		private var m_nInvHeight:Number;
		private var m_nInvWidth:Number;
		
		private var m_oPolygonMatrixMap:Dictionary;
		private var m_oPoint:Point = new Point();
		private var m_oCmf:ColorMatrixFilter;
		private var m_oTmp:Matrix = new Matrix();
	}
}