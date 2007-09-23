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
	
	import sandy.core.data.Polygon;
	
	/**
	 * Holds all light attribute data for a material.
	 *
	 * <p>Some materials can have a light applied to them.<br />
	 * This attributes contains some parameters</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public final class LightAttributes implements IAttributes
	{
		/**
		 * Flag for lightening mode.
		 * <p>If true, the lit objects use full light range from black to white.<b />
		 * If false (the default) they just range from black to their normal appearance.</p>
		 */
		public var useBright:Boolean = false;
		
		/**
		 * Level of ambient light, added to the scene if lighting is enabled.
		 */
		public var ambient:Number = 0.3;
		// --
		public var modified:Boolean;
		
		/**
		 * Creates a new LineAttributes object.
		 *
		 * @param p_bBright	- default false - The brightness
		 * @param p_nAmbiant - default 0 - The ambiant light value
		 */
		public function LightAttributes( p_bBright:Boolean = false, p_nAmbient:Number = 0.3 )
		{
			useBright = p_bBright;
			ambient = p_nAmbient;
			// --
			modified = true;
		}
		
		public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_aPoints:Array ):void
		{
			;
		}
	}
}
