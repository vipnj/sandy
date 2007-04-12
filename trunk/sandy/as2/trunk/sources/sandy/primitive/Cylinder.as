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
* Cylinder
* @author		Bruce Epstein - zeusprod - modified to extend Conic class. See Conic.as
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @since		0.1
* @version		1.2.2
* @date 		12.4.2007 
**/
class sandy.primitive.Cylinder extends Conic implements Primitive3D
{
	//////////////////
	///PRIVATE VARS///
	//////////////////	
	private var _radius:Number ;
	
	/**
	* This is the constructor to call when you need to create a Cylinder primitive.
	* <p>This method will create a complete object with vertex, normales, texture coords and the faces.
	*    So it allows to have a custom 3D object easily </p>
	* <p>{@code radius} represents the radius of the cylinder, {@code height} represent its height and {@code quality} its quality (the number of faces)</p>
	* @param radius Number
	* @param height	Number
	* @param quality Number
	* @param mode String represent the two available modes to generates the faces.
	* "tri" is necessary to have faces with 3 points, and "quad" for 4 points.
	* @param noBottom Boolean If true, the bottom of the cylinder is not rendered (defaults to false).
	* @param noTop Boolean If true, the top of the cylinder is not rendered (defaults to false).
	* @param noSides Boolean If true, the sides of the cylinder are not rendered (defaults to false).
	* @param separateFaces Boolean If true, texture faces separately (defaults to false).
	*/
	// A Cylinder is just a special case of Conic section with equal top/bottom radii.
	public function Cylinder( radius:Number, height:Number, quality:Number, mode:String,
							 noTop:Boolean, noBottom:Boolean, noSides:Boolean, separateFaces:Boolean)
	{
		// Invoke the Conic constructor with the same top and bottom radius. Pass through other params
		super(radius, radius, height, quality, mode, noTop, noBottom, noSides, separateFaces);
		_radius = _radiusBottom;  // Inherited from Conic
	}
	
	 public function getPrimitiveName (Void):String {
		 return "Cylinder";
	 }
	 
}