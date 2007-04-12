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

import sandy.primitive.Primitive3D;
import sandy.primitive.Ellipsoid;

/**
* Generates a Sphere 3D coordinates. The Sphere generated is a 3D object that can be rendered by Sandy's engine.
* You can play with the constructor's parameters to ajust it to your needs.  
* @author		Thomas Pfeiffer - kiroukou
* @author		Bruce Epstein 	- zeusprod
* @version		1.2.1
* @date 		12.04.2007 
**/
class sandy.primitive.Sphere extends Ellipsoid implements Primitive3D
{
	
	/**
	* This is the constructor to call when you nedd to create a Sphere primitive.
	* <p>This method will create a complete object with vertex, normales, texture coords and the faces.
	*    So it allows to have a custom 3D object easily </p>
	* <p>{@code radius} represents the radius of the Sphere,  {@code quality} represent its quality (between 1 and 5), more quality is up, more faces there is</p>
	* @param 	radius 	Number
	* @param 	quality	Number
	* @param mode String represent the two available modes to generates the faces.
	* "tri" is necessary to have faces with 3 points, and "quad" for 4 points.
	*/
	// A Sphere is just a special case of an Ellipsoid with equal x, y, and z radii.
	public function Sphere( radius:Number, quality:Number, mode:String )
	{
		super(radius, radius, radius, quality, mode);
		_radius = _xradius; // Inherited from Ellipsoid
	}
	
	/**
	* getPrimitiveName() returns the string "Sphere"
	*/	
	 public function getPrimitiveName (Void):String {
		 return "Sphere";
	 }
	 
	 
	 //////////////////
	///PRIVATE VARS///
	//////////////////	
	private var _radius:Number;
}

