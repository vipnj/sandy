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
	public class MaterialAttributes
	{
		public var lineAttributes:LineAttributes = null;
		
		public var outlineAttributes:OutlineAttributes = null;
		
		public var lightAttributes:LightAttributes = null;
		
		public function MaterialAttributes( ...args )
		{
			for each( var l_oAtt:IAttributes in args )
			{
				if( l_oAtt is LineAttributes ) lineAttributes = l_oAtt as LineAttributes;
				else if( l_oAtt is OutlineAttributes ) outlineAttributes = l_oAtt as OutlineAttributes;
				else if( l_oAtt is LightAttributes ) lightAttributes = l_oAtt as LightAttributes;
			}
		}
	}
}