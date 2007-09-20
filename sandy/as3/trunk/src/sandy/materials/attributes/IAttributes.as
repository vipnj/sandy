/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author THOMAS PFEIFFER
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
	 * Interface for all the elements that represent a material attribute property.
	 * This interface is more for a typing purpose (kind of typedef).
	 */
	public interface IAttributes
	{
		function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_aPoints:Array ):void;		
	}
}