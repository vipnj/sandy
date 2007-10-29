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
	 * Displays a bitmap on the faces of a 3D shape.
	 * Note : The lightening isn't managed by this material for the moment.
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @author		Xavier Martin - zeflasher - transparency managment
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class BitmapMaterial extends Material
	{
		public static const ORIGIN:Point = new Point();	
		
		public var matrix:Matrix = new Matrix();
		// --
		public var smooth:Boolean = false;
		
		/**
		 * Creates a new BitmapMaterial.
		 * <p>Please note that we ue internally a copy of the constructor bitmapdata. Thatea mns in case you need to access this bitmapdata, you can't just use the same reference
		 * but you shall use the BitmapMaterial#texture getter property to make it work.</p>
		 * <p>Please note that this material does not handle the lightAttributes for the moment!</p>
		 * @param p_oTexture 	The bitmapdata for this material
		 * @param p_oAttr	The attributes for this material
		 */
		public function BitmapMaterial( p_oTexture:BitmapData = null, p_oAttr:MaterialAttributes = null )
		{
			super(p_oAttr);
			// --
			m_nType = MaterialType.BITMAP;
			// --
			texture = p_oTexture.clone();
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
        	if( m_oTexture == null ) return;
        	// --
			const l_points:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;
			const l_uv:Array = (p_oPolygon.isClipped) ? p_oPolygon.caUVCoord : p_oPolygon.aUVCoord;
			// --
			if( !l_points.length ) return;
			// --
			polygon = p_oPolygon;
        	graphics = p_mcContainer.graphics;
			// --
			if( polygon.isClipped ) // or l_points.length > 3 ...
			{
				_tesselatePolygon( l_points, l_uv );
			}
			else
			{
				map = (m_oPolygonMatrixMap[polygon] as Matrix );
				drawPolygon( l_points );
			}
			// --
			if( attributes.lineAttributes ) attributes.lineAttributes.draw( graphics, polygon, l_points );
			if( attributes.outlineAttributes ) attributes.outlineAttributes.draw( graphics, polygon, l_points );
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
	        drawPolygon( l_points );
	 	}


        protected function drawPolygon( p_aPoints:Array ):void
		{
			const x0:Number = p_aPoints[0].sx, y0:Number = p_aPoints[0].sy;
			const x1:Number = p_aPoints[1].sx, y1:Number = p_aPoints[1].sy;
			const x2:Number = p_aPoints[2].sx, y2:Number = p_aPoints[2].sy;
			//--
			const a2:Number = x1 - x0;
			const b2:Number = y1 - y0;
			const c2:Number = x2 - x0;
			const d2:Number = y2 - y0;
			// --					   
			matrix.a = map.a*a2 + map.b*c2;
			matrix.b = map.a*b2 + map.b*d2;
			matrix.c = map.c*a2 + map.d*c2;
			matrix.d = map.c*b2 + map.d*d2;
			matrix.tx = map.tx*a2 + map.ty*c2 + x0;
			matrix.ty = map.tx*b2 + map.ty*d2 + y0;
			// --
			graphics.lineStyle();
			graphics.beginBitmapFill( m_oTexture, matrix, repeat, smooth );
			// --
			graphics.moveTo( x0, y0 );
			graphics.lineTo( x1, y1 );
			graphics.lineTo( x2, y2 );
			// --
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
			m_oTexture = p_oTexture;
			m_nHeight = m_oTexture.height;
			m_nWidth = m_oTexture.width;
			m_nInvHeight = 1/m_nHeight;
			m_nInvWidth = 1/m_nWidth;
			m_oTexture.lock(); // not sure it is faster but it should....
			m_orgTexture = p_oTexture.clone();
			// -- We reinitialize the precomputed matrix
			for( var l_sID:String in m_oPolygonMatrixMap )
			{
				var l_oPoly:Polygon = m_oPolygonMatrixMap[ l_sID ] as Polygon;
				init( l_oPoly );
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
			var matrix:Array = [1, 0, 0, 0, 0,
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
				m_oPolygonMatrixMap[p_oPolygon] = m;
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
		
		protected var m_oPolygonMatrixMap:Dictionary;
		private var m_oPoint:Point = new Point();
		private var m_oCmf:ColorMatrixFilter;
	}
}