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
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.light.Light3D;
	import sandy.math.VectorMath;
	import sandy.util.NumberUtil;
	
	/**
	 * Displays a color with on the faces of a 3D shape.
	 *
	 * <p>Used to show colored faces, possibly with lines at the edges of the faces.</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public final class ColorMaterial extends Material 
	{
		private var m_nColor:Number;
		private var m_nAlpha:Number;
		
		/**
		 * Creates a new ColorMaterial.
		 *
		 * @param p_nColor 	The color for this material in hexadecimal notation
		 * @param p_nAlpha	The alpha value in percent of full opacity ( 0 - 100 )
		 * @param p_oLineAttr	The line attributes for this material
		 * @param p_oOutlineAttr The outlie attributes settings for this material
		 */
		public function ColorMaterial( p_nColor:uint = 0, p_nAlpha:uint = 100, p_oLineAttr:LineAttributes = null, p_oOutlineAttr:OutlineAttributes = null )
		{
			super();
			// --
			m_nType = MaterialType.COLOR;
			// --
			m_nColor = p_nColor;
			m_nAlpha = p_nAlpha/100;
			// --
			lineAttributes = p_oLineAttr;
			outlineAttributes = p_oOutlineAttr;
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
			const l_points:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;
			if( !l_points.length ) return;
			var l_oVertex:Vertex;
			var lId:int = l_points.length;
			var l_graphics:Graphics = p_mcContainer.graphics;
			
			var l_nCol:uint = m_nColor;
			if( _useLight )
			{
				var l:Light3D 	= p_oScene.light;
				var vn:Vector 	= new Vector( p_oPolygon.normal.wx, p_oPolygon.normal.wy, p_oPolygon.normal.wz );
				var vl:Vector 	= l.getDirectionVector()
				var lp:Number	= l.getPower()/100;
				// --
				var r:Number = ( l_nCol >> 16 )& 0xFF;
				var g:Number = ( l_nCol >> 8 ) & 0xFF;
				var b:Number = ( l_nCol ) 	   & 0xFF;
				// --
				var dot:Number =  - ( VectorMath.dot( vl, vn ) );
				r = NumberUtil.constrain( r*(dot+lp), 0, 255 );
				g = NumberUtil.constrain( g*(dot+lp), 0, 255 );
				b = NumberUtil.constrain( b*(dot+lp), 0, 255 );
				// --
				l_nCol =  r << 16 | g << 8 |  b;
			}
			// --
			l_graphics.lineStyle();
			l_graphics.beginFill( l_nCol, m_nAlpha );
			l_graphics.moveTo( l_points[0].sx, l_points[0].sy );
			while( l_oVertex = l_points[ --lId ] )
				l_graphics.lineTo( l_oVertex.sx, l_oVertex.sy );
			l_graphics.endFill();
			// --
			if( lineAttributes ) lineAttributes.draw( l_graphics, p_oPolygon, l_points );
			if( outlineAttributes ) outlineAttributes.draw( l_graphics, p_oPolygon, l_points );
		}

		/**
		 * @private
		 */		
		public function get alpha():Number
		{
			return m_nAlpha;
		}
		
		/**
		 * @private
		 */
		public function get color():Number
		{
			return m_nColor;
		}
	
		
		/**
		 * The alpha value for this material ( 0 - 1 )
		 *
		 * Alpha = 0 means fully transparent, alpha = 1 fully opaque.
		 */
		public function set alpha(p_nValue:Number):void
		{
			m_nAlpha = p_nValue; 
			m_bModified = true;
		}
		
		/**
		 * The color of this material
		 */
		public function set color(p_nValue:Number):void
		{
			m_nColor = p_nValue; 
			m_bModified = true;
		}
	
	}
}