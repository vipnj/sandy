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

import com.bourre.events.EventType;
import com.bourre.events.EventBroadcaster;

import sandy.events.SkinEvent;
import sandy.skin.SkinType;
import com.bourre.events.BasicEvent;
import sandy.core.World3D;
import sandy.core.light.Light3D;

/**
 * ABSTRACT CLASS
 * <p>
 * This class is the basis of all the skins. It is abstract so that mean you can't instanciate this class.
 * </p>
 * @author		Thomas Pfeiffer - kiroukou
 * @since		1.0
 * @version		1.0
 * @date 		23.06.2006
 **/
class sandy.skin.BasicSkin extends EventBroadcaster
{
	
	/**
	 *  The Transformation end Event. Broadcasted when the Interpolation is finished
	 */
	public static var onUpdateEVENT:EventType = SkinEvent.onUpdateEVENT;
	

	/**
	* Returns the type of SKin you are using.
	* For the BasicSkin class, this value is set to NONE
	* @param	Void
	* @return SkinType The type constant which represents your skin.
	*/
	public function getType( Void ):SkinType
	{
		return SkinType.NONE;
	}
	
	/**
	 * setLightingEnable. Prepare the skin to use the world light or not. The default value is false.
	 * @param	bool	Boolean	true is the skin use the light of the world, false if no.
	 * @return	Void
	 */
	public function setLightingEnable ( bool:Boolean ):Void
	{
		if( _useLight != bool )
		{
			_useLight = bool;
			broadcastEvent( _eOnUpdate );
		}		
	}
	
	/**
	* Set the value of the array of filters you want to apply to the object faces.
	* Warning : This is only available since Flash8.
	* @param	a Array the array containing the filters you want to apply, or an empty array if you want to clear the filters.
	*/
	public function set filters( a:Array )
	{
		_filters = a;
		broadcastEvent( _eOnUpdate );
	}
	
	/**
	* Get the array of filters you are applying to the object faces.
	* Warning : This is only available since Flash8.
	* @return	Array the array containing the filters you are using, or an empty array if you don't apply anything
	*/
	public function get filters():Array
	{
		return _filters;
	}
	
	//////////////////
	// PRIVATE
	//////////////////	
	private function BasicSkin( Void )
	{
		super( this );
		_eOnUpdate 	= new SkinEvent( SkinEvent.onUpdateEVENT, this, getType() );
		_filters 	= [];
		_useLight 	= false;
		_id = _ID_++;
		World3D.getInstance().addEventListener( World3D.onLightAddedEVENT, this, __onLightAdded );
	}
	
	private function __onLightAdded( e:BasicEvent ):Void
	{
		World3D.getInstance().getLight().addEventListener( Light3D.onLightUpdatedEVENT, this, __onLightUpdated );
	}
	
	private function __onLightUpdated( e:BasicEvent ):Void
	{	
		if( _useLight )
			broadcastEvent( _eOnUpdate );
	}
	//////////////////
	// PROPERTIES
	//////////////////
	private var _filters:Array;
	private var _useLight : Boolean;
	private var _eOnUpdate:SkinEvent;
	private var _id:Number;
	private static var _ID_:Number = 0;
}
