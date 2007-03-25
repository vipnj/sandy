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

import com.bourre.events.BasicEvent;
import com.bourre.events.EventBroadcaster;
import com.bourre.events.EventType;

import sandy.core.data.Vector;
import sandy.util.NumberUtil;
	

/**
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		02.06.2006
* 
**/
class sandy.core.light.Light3D
{
	
	/*
	* Maximum value accepted. If the default value (150) seems too big or too small for you, you can change it.
	*/
	public static var MAX_POWER:Number = 150;

	/**
	 * Create a new {@code Light3D}.
	 * 
	 * @param	p		A {@code Vector4} for the {@code Light3D} position.
	 * @param	nCol	Color of the Light3D.
	 * 
	 */
	public function Light3D ( d:Vector, pow:Number )
	{
		_dir = d;
		_oEB = new EventBroadcaster( this );
		setPower( pow );
	}
	
	/**
	 * Add a listener for a specific event.
	 * @param t EventType The type of event we want to register
	 * @param o The object listener
	 */
	public function addEventListener( e:EventType, o ) : Void
	{
		_oEB.addEventListener.apply( _oEB, arguments );
	}
	
	/**
	 * Remove a listener for a specific event.
	 * @param e EventType The type of event we want to register
	 * @param oL The object listener
	 */
	public function removeEventListener( e:EventType, oL ) : Void
	{
		_oEB.removeEventListener( e, oL );
	}
	
	/**
	 * The the power of the light. A number between 0 and MAX_POWER is necessary. 
	 * The highter the power of the light is, the less the shadows are visibles.
	 * @param n Number a Number between 0 and MAX_POWER. This number is the light intensity.
	 */
	public function setPower( n:Number )
	{
		_power =  NumberUtil.constrain( n, 0, Light3D.MAX_POWER );
		_oEB.broadcastEvent( onLightUpdatedEVENT );
	}
	
	/**
	 * Returns the power of the light.
	 * @return Number a number between 0 - MAX_POWER.
	 */
	public function getPower():Number
	{
		return _power;
	}
	
	public function getDirectionVector():Vector
	{
		return _dir;
	}
	
	/**
	 * Set the position of the {@code Light3D}.
	 * 
	 * @param	x	the x coordinate
	 * @param	y	the y coordinate
	 * @param	z	the z coordinate
	 */	
	public function setDirection( x:Number, y:Number, z:Number ):Void
	{
		_dir.x = x; _dir.y = y; _dir.z = z;
		_oEB.broadcastEvent( onLightUpdatedEVENT );
	}
	
	public function setDirectionVector( pDir:Vector ):Void
	{
		_dir = pDir;
		_oEB.broadcastEvent( onLightUpdatedEVENT );
	}
	
	public function destroy():Void
	{
		;
	}

	// Direction of the light. It is 3D vector. Please refer to the Light tutorial to learn more about Sandy's lights.
	private var _dir:Vector;	
	private var _power : Number;
	
	// Events
	public static var onLightUpdatedType:EventType =  new EventType("onLightUpdated");
	public static var onLightUpdatedEVENT:BasicEvent = new BasicEvent( onLightUpdatedType );
	private var _oEB:EventBroadcaster;//_oEB : The EventBroadcaster instance which manage the event system of world3D.
	
}
