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
	 * The PrimitiveMode class defines modes of creation for some primitives.
	 * 
	 *<p>Some of the Sandy primitives are created in one of two modes,
	 * the TRI mode and the QUAD mode.<br/>
	 * In QUAD mode the surfaces of the object is built up by rectangular polygons,
	 * in TRI mode they are triangles.<p> 
	 * <p>The TRI mode makes for a better perspective distortion for textures,
	 * while the QUAD mode gives better performance.</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 *
	 */
	public final class PrimitiveMode
	{
		public static const QUAD:String = "quad";
	 	public static const TRI:String = "tri";
	}
}