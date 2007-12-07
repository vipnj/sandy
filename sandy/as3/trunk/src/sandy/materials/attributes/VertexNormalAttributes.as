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
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.materials.Material;
	
	/**
	 * Display the vertex normals of a given object
	 *
	 * <p>Developed originally for a debug purpose, this class allows you to create some
	 * special effects, displaying the normal of each vertex.</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public final class VertexNormalAttributes implements IAttributes
	{
		private var m_nThickness:Number;
		private var m_nColor:Number;
		private var m_nAlpha:Number;
		private var m_nLength:Number;
		// --
		public var modified:Boolean;
		
		/**
		 * Creates a new VertexNormalAttributes object.
		 * @param p_nLength The length of the segment
		 * @param p_nThickness	The line thickness - Defaoult 1
		 * @param p_nColor	The line color - Defaoult 0 ( black )
		 * @param p_nAlpha	The alpha value in percent of full opacity ( 0 - 1 )
		 */
		public function VertexNormalAttributes( p_nLength:Number = 10, p_nThickness:uint = 1, p_nColor:uint = 0, p_nAlpha:Number = 1 )
		{
			m_nLength = p_nLength;
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
		 * @private
		 */
		public function get length():Number
		{
			return m_nLength;
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
		 * The line length
		 */
		public function set length( p_nValue:Number ):void
		{
			m_nLength = p_nValue; 
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
			var l_aPoints:Array = p_oPolygon.vertices;
			var l_oVertex:Vertex;
			
			p_oGraphics.lineStyle( m_nThickness, m_nColor, m_nAlpha );
			p_oGraphics.beginFill(0);
			// --
			var lId:int = l_aPoints.length;
			while( l_oVertex = l_aPoints[ --lId ] )
			{
				var l_oDiff:Vector = p_oPolygon.vertexNormals[ lId ].getVector().clone();
				p_oPolygon.shape.viewMatrix.vectorMult3x3( l_oDiff );
				// --
				l_oDiff.scale( m_nLength );
				// --
				var l_oNormal:Vertex = Vertex.createFromVector( l_oDiff );
				l_oNormal.add( l_oVertex );
				// --
				p_oScene.camera.projectVertex( l_oNormal );
				// --
				p_oGraphics.moveTo( l_oVertex.sx, l_oVertex.sy );
				p_oGraphics.lineTo( l_oNormal.sx, l_oNormal.sy );
				// --
				l_oNormal = null;
				l_oDiff = null;
			}
			p_oGraphics.endFill();
		}
	}
}