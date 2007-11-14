import sandy.core.data.Vector;

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

/**
* Primitive3D
* 
* <p>This is only an interface, to be sure all primitives Object have implements needed methods</p>
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @author		Bruce Epstein 	- zeusprod
* @since		0.1
* @version		1.2.1
* @date 		11.04.2007
**/
interface sandy.primitive.Primitive3D
{
	/**
	* generate
	* 
	* <p>generate all is needed to construct the Object3D : </p>
	* <ul>
	* 	<li>{@link Vertex}</li>
	* 	<li>{@link UVCoords}</li>
	* 	<li>{@link TriFace3D}</li>
	* 	<li>{@link NFace3D} not implemented yet</li>
	* </ul>
	* <p>It can construct dynamically the object, taking care of your preferences given in arguments. <br/>
	*    Note in Sandy 0.1 all faces have only three points.
	*    This will change in the future version, 
	*    and give to you the possibility to choose n points per faces</p> 
	*/
	public function generate( Void ):Void ;
	public function getPrimitiveName (Void):String;
	public function toString (Void):String;
	public function getSize (Void):Vector;
}
