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

import sandy.core.face.Polygon;
import sandy.materials.LineAttributes;
import sandy.materials.MaterialType;

/**
 * ABSTRACT CLASS
 * <p>
 * This class is the basis of all the skins. It is abstract so that mean you can't instanciate this class directly.
 * </p>
 * @author		Thomas Pfeiffer - kiroukou
 * @version		2.0
 **/
class sandy.materials.Material
{
	public var lineAttributes:LineAttributes;

	public function get id():Number
	{return _id;}
	

	function renderPolygon( p_oPolygon:Polygon, p_mcContainer:MovieClip ):Void
	{
		p_mcContainer.filters = _filters;
	}
		
	public function init( f:Polygon ):Void
	{
		;
	}

	
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
		needNormals = false;
	}
	
	/**
	 * Property that has to be updated when the material needs to have the normals vector in order to compute the correct effect.
	 * For example, with ligthening enabled, this property must be set to true to render correctly the light effect.
	 * 
	 * THe variable is READ ONLY unless you perfectly know what you are doing.
	 */
	public var needNormals:Boolean;
	
	public var repeat:Boolean;
	
	//////////////////
	// PROPERTIES
	//////////////////	
	private var m_bModified:Boolean;
	private var _filters:Array;
	private var _useLight : Boolean;
	private var _id:Number;
	private static var _ID_:Number = 0;
}
