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
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vertex;
	import sandy.materials.Material;
	
	/**
	 * Holds all line attribute data for a material.
	 *
	 * <p>Some materials have line attributes to outline the faces of a 3D shape.<br/>
	 * In these cases a LineAttributes object holds all line attribute data</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public final class LineAttributes implements IAttributes
	{
		private var m_nThickness:Number;
		private var m_nColor:Number;
		private var m_nAlpha:Number;
		// --
		public var modified:Boolean;
		
		/**
		 * Creates a new LineAttributes object.
		 *
		 * @param p_nThickness	The line thickness - Defaoult 1
		 * @param p_nColor	The line color - Defaoult 0 ( black )
		 * @param p_nAlpha	The alpha value in percent of full opacity ( 0 - 1 )
		 */
		public function LineAttributes( p_nThickness:uint = 1, p_nColor:uint = 0, p_nAlpha:Number = 1 )
		{
			m_nThickness = p_nThickness;
			m_nAlpha = p_nAlpha;
			m_nColor = p_nColor;
			// --
			modified = true;
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
		 * @private
		 */
		public function get thickness():Number
		{
			return m_nThickness;
		}
		
		/**
		 * The alpha value for the lines ( 0 - 1 )
		 *
		 * Alpha = 0 means fully transparent, alpha = 1 fully opaque.
		 */
		public function set alpha(p_nValue:Number):void
		{
			m_nAlpha = p_nValue; 
			modified = true;
		}
		
		/**
		 * The line color
		 */
		public function set color(p_nValue:Number):void
		{
			m_nColor = p_nValue; 
			modified = true;
		}

		/**
		 * The line thickness
		 */	
		public function set thickness(p_nValue:Number):void
		{
			m_nThickness = p_nValue; 
			modified = true;
		}
		
		/**
		 * Draw the edges of the polygon into the graphics object.
		 *  
		 * @param p_oGraphics the Graphics object to draw attributes into
		 * @param p_oPolygon the polygon which is going o be drawn
		 * @param p_oMaterial the refering material
		 * @param p_oScene the scene
		 */
		public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			var l_aPoints:Array = (p_oPolygon.isClipped)?p_oPolygon.cvertices : p_oPolygon.vertices;
			var l_oVertex:Vertex;
			p_oGraphics.lineStyle( m_nThickness, m_nColor, m_nAlpha );
			// --
			p_oGraphics.moveTo( l_aPoints[0].sx, l_aPoints[0].sy );
			var lId:int = l_aPoints.length;
			while( l_oVertex = l_aPoints[ --lId ] )
				p_oGraphics.lineTo( l_oVertex.sx, l_oVertex.sy );
		}
	}
}