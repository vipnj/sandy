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

import flash.display.BitmapData;
import flash.geom.Matrix;

import sandy.materials.LineAttributes;
import sandy.materials.MaterialType;

/**
 * ABSTRACT CLASS
 * <p>
 * This class is the basis of all the skins. It is abstract so that mean you can't instanciate this class.
 * </p>
 * @author		Thomas Pfeiffer - kiroukou
 * @version		2.0
 **/
class sandy.materials.Material
{
	public var lineAttributes:LineAttributes;

	public function get id():Number
	{return _id;}
	
	/**
	* Returns the type of SKin you are using.
	* For the BasicSkin class, this value is set to NONE
	* @param	Void
	* @return SkinType The type constant which represents your skin.
	*/
	public function get type():MaterialType
	{ return MaterialType.NONE; }
	
	/**
	 * setLightingEnable. Prepare the skin to use the world light or not. The default value is false.
	 * @param	bool	Boolean	true is the skin use the light of the world, false if no.
	 * @return	Void
	 */
	public function set lightingEnable ( p_bBool:Boolean )
	{
		if( _useLight != p_bBool )
		{
			_useLight = p_bBool;
			m_bModified = true;
		}		
	}
	
	/**
	* Set the value of the array of filters you want to apply to the object faces.
	* Warning : This is only available since Flash8.
	* @param	a Array the array containing the filters you want to apply, or an empty array if you want to clear the filters.
	*/
	public function set filters( a:Array )
	{ _filters = a; m_bModified = true;	}
	
	/**
	* Get the array of filters you are applying to the object faces.
	* Warning : This is only available since Flash8.
	* @return	Array the array containing the filters you are using, or an empty array if you don't apply anything
	*/
	public function get filters():Array
	{ return _filters; }
	
	public function get modified():Boolean
	{
		return (m_bModified && ((lineAttributes) ? lineAttributes.modified : true));
	}
	
	/////////////
	// SETTERS //
	/////////////	
	public function set texture( p_oBitmap:BitmapData )
	{
		m_oTexture = p_oBitmap;
		m_nWidth = p_oBitmap.width;
		m_nHeight = p_oBitmap.height;
	}
	
	/////////////
	// GETTERS //
	/////////////	
	public function get texture():BitmapData
	{ return m_oTexture; }
	
	public function get repeat():Boolean
	{return m_bRepeat;}
	
	public function get matrix():Matrix
	{return m_oMatrix;}
	
	public function set matrix( p_oMat:Matrix )
	{ m_oMatrix = p_oMat; m_bModified = true; }
	
	public function get smooth():Boolean
	{ return m_bSmooth; }
	public function set smooth( p_bValue:Boolean )
	{ m_bSmooth = p_bValue; m_bModified = true; }
	
	//////////////////
	// PRIVATE
	//////////////////	
	private function Material( Void )
	{
		_filters 	= [];
		_useLight 	= false;
		_id = _ID_++;
		lineAttributes = null;
		m_bModified = true;
		m_bRepeat = true;
		m_bSmooth = false;
		m_oMatrix = null;
		m_nWidth = m_nHeight = 0;
	}
	
	//////////////////
	// PROPERTIES
	//////////////////	
	private var m_oTexture:BitmapData;
	private var m_nWidth:Number;
	private var m_nHeight:Number;
	private var m_bModified:Boolean;
	private var m_bRepeat:Boolean;
	private var m_bSmooth:Boolean;
	private var m_oMatrix:Matrix;
	private var _filters:Array;
	private var _useLight : Boolean;
	private var _id:Number;
	private static var _ID_:Number = 0;
}