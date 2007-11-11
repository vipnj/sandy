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
	import sandy.materials.Material;
	
	public class MaterialAttributes
	{
		public var attributes:Array = new Array();
		
		public function MaterialAttributes( ...args )
		{
			for( var i:int = 0; i < args.length; i++ )
			{
				if( args[i] is IAttributes )
					attributes.push( args[i] );
			}
		}
		
		public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			for each( var l_oAttr:IAttributes in attributes )
				l_oAttr.draw( p_oGraphics, p_oPolygon, p_oMaterial, p_oScene );
		}
	}
}