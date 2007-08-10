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
	import flash.display.Sprite;
	
	import sandy.core.data.Polygon;
	/**
	 * Displays the faces of a 3D shape as a wire frame.
	 *
	 * <p>Material which draws only the external edges of the shape</p>
	 *
	 * @author		Thomas PFEIFFER - kiroukou
	 * @version		3.0
	 * @date 		10.08.2007
	 */
	public final class OutlineMaterial extends Material
	{
		
		/**
		 * Creates a new WireFrameMaterial.
		 *
		 * @param p_nThickness	The thickness of the lines - Default 1
		 * @param p_nColor 	The color of the lines - Default 0
		 * @param p_nAlpha	The alpha value in percent of full opacity ( 0 - 100 )
		 * @param p_oLineAttr The line attributes object
		 */
		public function OutlineMaterial( p_nThickness:uint = 1, p_nColor:uint = 0, p_nAlpha:uint = 100, p_oLineAttr:LineAttributes = null )
		{
			super();
			// --
			m_nType = MaterialType.OUTLINE;
			// --
			outlineAttributes = new OutlineAttributes( p_nThickness, p_nColor, p_nAlpha );
			lineAttributes = p_oLineAttr;
		}

		/**
		 * Renders this material on the face it dresses.
		 *
		 * @param p_oPolygon	The face to be rendered
		 * @param p_mcContainer	The container to draw on
		 */		
		public override function renderPolygon( p_oPolygon:Polygon, p_mcContainer:Sprite ):void 
		{
			outlineAttributes.draw( p_mcContainer.graphics, p_oPolygon, p_oPolygon.vertices );
			if( lineAttributes ) lineAttributes.draw( p_mcContainer.graphics, p_oPolygon, p_oPolygon.vertices );
		}

	}
}