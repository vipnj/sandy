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

package sandy.materials.attributes
{
	import flash.display.Graphics;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Edge3D;
	import sandy.core.data.Polygon;
	import sandy.materials.Material;
	
	/**
	 * Holds all outline attributes data for a material.
	 *
	 * <p>Each material can have an outline attribute to outline the whole 3D shape.<br/>
	 * The OutlineAttributes class stores all the information to draw this outline shape</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		09.09.2007
	 */
	public final class OutlineAttributes implements IAttributes
	{
		private var m_nThickness:Number;
		private var m_nColor:Number;
		private var m_nAlpha:Number;
		// --
		public var modified:Boolean;
		
		/**
		 * Creates a new OutlineAttributes object.
		 *
		 * @param p_nThickness	The line thickness - Defaoult 1
		 * @param p_nColor	The line color - Default 0 ( black )
		 * @param p_nAlpha	The alpha value in percent of full opacity ( 0 - 1 )
		 */
		public function OutlineAttributes( p_nThickness:uint = 1, p_nColor:uint = 0, p_nAlpha:Number = 1 )
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
		 * Draw the outline edges of the polygon into the graphics object.
		 *  
		 * @param p_oGraphics the Graphics object to draw attributes into
		 * @param p_oPolygon the polygon which is going o be drawn
		 * @param p_oMaterial the refering material
		 * @param p_oScene the scene
		 */
		public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			var l_oEdge:Edge3D;
			var l_oPolygon:Polygon;
			var l_bFound:Boolean;
			// --
			p_oGraphics.lineStyle( m_nThickness, m_nColor, m_nAlpha );
			p_oGraphics.beginFill(0);
			// --
			for each( l_oEdge in p_oPolygon.aEdges )
        	{
        		l_bFound = false;
        		// --
        		for each( l_oPolygon in p_oPolygon.aNeighboors )
				{
	        		// aNeighboor not visible, does it share an edge?
					// if so, we draw it
					if( l_oPolygon.aEdges.indexOf( l_oEdge ) > -1 )
	        		{
						if( l_oPolygon.visible == false )
						{
							p_oGraphics.moveTo( l_oEdge.vertex1.sx, l_oEdge.vertex1.sy );
							p_oGraphics.lineTo( l_oEdge.vertex2.sx, l_oEdge.vertex2.sy );
						}
						l_bFound = true;
					}
	   			}
	   			// -- if not shared with any neighboor, it is an extremity edge that shall be drawn
	   			if( l_bFound == false )
	   			{
		   			p_oGraphics.moveTo( l_oEdge.vertex1.sx, l_oEdge.vertex1.sy );
					p_oGraphics.lineTo( l_oEdge.vertex2.sx, l_oEdge.vertex2.sy );
	   			}
        	}
        	
        	p_oGraphics.endFill();
        }
        
	}
}