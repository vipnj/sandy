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
	import sandy.core.data.Vertex;
	import sandy.core.data.Polygon;
	/**
	 * Displays the faces of a 3D shape as a wire frame.
	 *
	 * <p>Based on the AS2 class VideoSkin made by kiroukou and zeusprod</p>
	 *
	 * @author		Xavier Martin - zeflasher
	 * @author		Thomas PFEIFFER - kiroukou
	 * @since		1.0
	 * @version		3.0
	 * @date 		26.06.2007
	 */
	public final class WireFrameMaterial extends Material
	{
		/**
		 * Creates a new WireFrameMaterial.
		 *
		 * @param p_nThickness	The thickness of the lines - Default 1
		 * @param p_nColor 	The color of the lines - Default 0
		 * @param p_nAlpha	The alpha value in percent of full opacity ( 0 - 100 )
		 */
		public function WireFrameMaterial( p_nThickness:uint=1, p_nColor:uint = 0, p_nAlpha:uint = 100 )
		{
			super();
			// --
			m_nType = MaterialType.WIREFRAME;
			// --
			lineAttributes = new LineAttributes( p_nThickness, p_nColor,p_nAlpha ) ;
		}

		/**
		 * Renders this material on the face it dresses.
		 *
		 * @param p_oPolygon	The face to be rendered
		 * @param p_mcContainer	The container to draw on
		 */		
		public override function renderPolygon( p_oPolygon:Polygon, p_mcContainer:Sprite ):void 
		{
			const l_points:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;
			var l_graphics:Graphics = p_mcContainer.graphics;
			// --
			l_graphics.lineStyle( lineAttributes.thickness, lineAttributes.color, lineAttributes.alpha );
			// --
			l_graphics.moveTo( l_points[0].sx, l_points[0].sy );
			// --
			for each (var l_oVertex:Vertex in l_points )
			{
				l_graphics.lineTo( l_oVertex.sx, l_oVertex.sy );
			}
		}

	}
}