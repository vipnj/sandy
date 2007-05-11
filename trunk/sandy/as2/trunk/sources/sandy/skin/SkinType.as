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
class sandy.skin.SkinType
{
	//---------//
	//Constants//
	//---------//
	/**
	* Constant value representing no skin yet
	*/
	public static function get NONE():SkinType { return __none; }
	private static var __none:SkinType = new SkinType( -1 );
	
	/**
	* Constant value representing the SimpleColorSkin
	*/
	public static function get SIMPLE_COLOR():SkinType { return __simple_color; }
	private static var __simple_color:SkinType = new SkinType( 0 );
	/**
	* Constant value representing the MixedSkin
	*/
	public static function get MIXED():SkinType { return __mixed; }
	private static var __mixed:SkinType = new SkinType( 1 );
	/**
	* Constant value representing the SimpleLineSkin
	*/
	public static function get SIMPLE_LINE():SkinType { return __simple_line; }
	private static var __simple_line:SkinType = new SkinType( 2 );
	/**
	* Constant value representing the TextureSkin
	*/
	public static function get TEXTURE():SkinType { return __texture; }
	private static var __texture:SkinType = new SkinType( 3 );
	/**
	* Constant value representing the ZLightenSkin
	*/
	public static function get ZLIGHTEN():SkinType { return __zlighten; }
	private static var __zlighten:SkinType = new SkinType( 4 );
	/**
	* Constant value representing the MovieSkin
	*/
	public static function get MOVIE():SkinType { return __movie; }
	private static var __movie:SkinType = new SkinType( 5 );
	/**
	* Constant value representing the VideoSkin
	*/
	public static function get VIDEO():SkinType { return __video; }
	private static var __video:SkinType = new SkinType( 6 );
	
	/**
	* Constant value representing the SimplePointSkin
	*/
	public static function get SIMPLE_POINT():SkinType { return __simple_point; }
	private static var __simple_point:SkinType = new SkinType( 7 );
	
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
	private function SkinType(value:Number)
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
		return "sandy.skin.SkinType:"+_value;
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