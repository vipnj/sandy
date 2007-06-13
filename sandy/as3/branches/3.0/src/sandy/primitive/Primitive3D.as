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
package sandy.primitive 
{
	/**
	* Primitive3D
	* <p>This is only an interface, to be sure all primitives Object have implements needed methods</p>
	* @author		Thomas Pfeiffer - kiroukou
	* @version		3.0
	* @date 		10/05/2007 
	**/
	import sandy.core.scenegraph.Geometry3D;
	
	public interface Primitive3D
	{
		function generate(... arguments):Geometry3D;
	}
}