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
* Contains all the types of transformation that can be used in Sandy.
*  
* @author		Tabin Cédric - thecaptain
* @author		Thomas Pfeiffer - Kiroukou
* @since		0.1
* @version		0.2
* @date 		12.01.2006
**/

class sandy.core.transform.TransformType
{
	//---------//
	//Constants//
	//---------//
	/**
	* Constant value representing no Transformation
	*/
	public static function get NONE():TransformType { return __none; }
	private static var __none:TransformType = new TransformType(0);
	
	/**
	* Constant value representing a Translation
	*/
	public static function get TRANSLATION():TransformType { return __translation; }
	private static var __translation:TransformType = new TransformType(1);
	
	/**
	* Constant value representing a Rotation
	*/
	public static function get ROTATION():TransformType { return __rotation; }
	private static var __rotation:TransformType = new TransformType(2);
	
	/**
	* Constant value representing a Scale
	*/
	public static function get SCALE():TransformType { return __scale; }
	private static var __scale:TransformType = new TransformType(3);
	
	/**
	* Constant value representing a mixed transformation(2 or more transformations combined)
	*/
	public static function get MIXED():TransformType { return __mixed; }
	private static var __mixed:TransformType = new TransformType(7);
	
	/**
	* Constant value representing a Scale Interpolation
	*/
	public static function get SCALE_INTERPOLATION():TransformType { return __scale_interpolation; }
	private static var __scale_interpolation:TransformType = new TransformType(4);
	/**
	* Constant value representing a rotation Interpolation
	*/
	public static function get ROTATION_INTERPOLATION():TransformType { return __rotation_interpolation; }
	private static var __rotation_interpolation:TransformType = new TransformType(5);
	/**
	* Constant value representing a translation Interpolation
	*/
	public static function get TRANSLATION_INTERPOLATION():TransformType { return __translation_interpolation; }
	private static var __translation_interpolation:TransformType = new TransformType(6);
	/**
	* Constant value representing a path Interpolation
	*/
	public static function get PATH_INTERPOLATION():TransformType { return __path_interpolation; }
	private static var __path_interpolation:TransformType = new TransformType(9);	
	/**
	* Constant value representing a vertex Interpolation
	*/
	public static function get VERTEX_INTERPOLATION():TransformType { return __vertex_interpolation; }
	private static var __vertex_interpolation:TransformType = new TransformType(8);	
	/**
	* Constant value representing a mixed Interpolation
	*/
	public static function get MIXED_INTERPOLATION():TransformType { return __mixed_interpolation; }
	private static var __mixed_interpolation:TransformType = new TransformType(10);	
	//---------//
	//Variables//
	//---------//
	private var		_value:Number; //value of the type
	
	//-----------//
	//Constructor//
	//-----------//
	
	/**
	* Create a new TransformType with his associated value.
	* 
	* @param	value	The value
	*/
	private function TransformType(value:Number)
	{
		_value = value;
	}
	
	//--------------//
	//Public methods//
	//--------------//
	/**
	 * Make a string representation of this object
	 * @return String the string representation
	 */
	public function toString():String
	{
		return "sandy.core.transform.TransformType:"+_value;
	}
	
	/**
	* Get the value of the TransformType.
	* 
	* @return	The value
	*/
	public function getValue(Void):Number
	{
		return _value;
	}
}