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
* Contains all the types of skins that can be used in Sandy.
*  
* @author		Thomas Pfeiffer - Kiroukou
* @version		0.2
* @date 		12.01.2006
**/
class sandy.materials.MaterialType
{
	//---------//
	//Constants//
	//---------//
	/**
	* Constant value representing no skin yet
	*/
	public static function get NONE():MaterialType { return __none; }
	private static var __none:MaterialType = new MaterialType( -1 );
	
	/**
	* Constant value representing the SimpleColorSkin
	*/
	public static function get COLOR():MaterialType { return __simple_color; }
	private static var __simple_color:MaterialType = new MaterialType( 0 );

	/**
	* Constant value representing the SimpleLineSkin
	*/
	public static function get WIREFRAME():MaterialType { return __wireframe; }
	private static var __wireframe:MaterialType = new MaterialType( 2 );
	/**
	* Constant value representing the SimpleLineSkin
	*/
	public static function get TEXTURE():MaterialType { return __texture; }
	private static var __texture:MaterialType = new MaterialType( 3 );

	/**
	* Constant value representing the MovieSkin
	*/
	public static function get MOVIE():MaterialType { return __movie; }
	private static var __movie:MaterialType = new MaterialType( 5);
	/**
	* Constant value representing the VideoSkin
	*/
	public static function get VIDEO():MaterialType { return __video; }
	private static var __video:MaterialType = new MaterialType( 6);
	
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
	private function MaterialType(value:Number)
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
		return "sandy.materials.MaterialType:"+_value;
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