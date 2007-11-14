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
import sandy.primitive.Conic;
import sandy.primitive.Primitive3D;

/**
* Cone
* @author		Bruce Epstein - zeusprod - derived from Conic class
* @since		1.2
* @version		1.2.1
* @date 		12.04.2007 
**/
class sandy.primitive.Cone extends Conic implements Primitive3D
{
	//////////////////
	///PRIVATE VARS///
	//////////////////	
	private var _radius:Number ;
	
	/**
	* This is the constructor to call when you need to create a Cone primitive.
	* <p>{@code radius} represents the radius of the cone, {@code height} represent its height and {@code quality} its quality (the number of faces)</p>
	* @param radius Number
	* @param height	Number
	* @param quality Number
	* @param noBottom Boolean If true, the bottom of the cone is not rendered (defaults to false).
	* @param noSides Boolean If true, the sides of the cone are not rendered (defaults to false).
	* @param separateFaces Boolean If true, texture faces separately (defaults to false).
	*/
	// A Cone is just a special case of Conic section with a top radius of 1.
	public function Cone( radius:Number, height:Number, quality:Number, 
							 noBottom:Boolean, noSides:Boolean, separateFaces:Boolean)
	{
		// Invoke the Conic constructor a top radius of 1. Mode is always "tri" and noTop is irrelevant.
		// Pass through other params.
		super(1, radius, height, quality, "tri", false, noBottom, noSides, separateFaces);
		_radius = _radiusBottom;  // Inherited from Conic
	}
	
	 public function getPrimitiveName (Void):String {
		 return "Cone";
	 }
	 
}