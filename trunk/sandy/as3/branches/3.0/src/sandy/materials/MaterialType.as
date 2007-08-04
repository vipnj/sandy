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

package sandy.materials 
{
	/**
	 * Represents the material types used in Sandy.
	 * 
	 * <p>Types are registered here as constant properties.<br/>
	 * If new materials are added to the Sandy library, they should be refistered here.</p> 
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class MaterialType
	{
		//---------//
		//Constants//
		//---------//
		/**
		 * Constant value representing the default material
		 */
		public static function get NONE():MaterialType { return __none; }
		private static var __none:MaterialType = new MaterialType( -1 );
		
		/**
		 * Constant value representing the ColorMaterial
		 */
		public static function get COLOR():MaterialType { return __simple_color; }
		private static var __simple_color:MaterialType = new MaterialType( 0 );
	
		/**
		 * Constant value representing the WireFrameMaterial
		 */
		public static function get WIREFRAME():MaterialType { return __wireframe; }
		private static var __wireframe:MaterialType = new MaterialType( 2 );
		/**
		 * Constant value representing the BitmapMaterial
		 */
		public static function get BITMAP():MaterialType { return __bitmap; }
		private static var __bitmap:MaterialType = new MaterialType( 3 );
	
		/**
		 * Constant value representing the MovieMaterial
		 */
		public static function get MOVIE():MaterialType { return __movie; }
		private static var __movie:MaterialType = new MaterialType( 5);
		/**
		 * Constant value representing the VideoMaterial
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
		 * Creates a TransformType with the associated value.
		 * 
		 * @param p_nValue	The type constant value
		 */
		public function MaterialType(p_nValue:Number)
		{
			_value = p_nValue;
		}
		
		//--------------//
		//Public methods//
		//--------------//
		/**
		 * Returns a string representation of this object.
		 *
		 * @return	The fully qualified name of this object + its numeric value
		 */
		public function toString():String
		{
			return "sandy.materials.MaterialType:"+_value;
		}
		
		/**
		 * Returns the numeric value of this TransformType.
		 * 
		 * @return	The numeric value
		 */
		public function getValue():Number
		{
			return _value;
		}
	}
}