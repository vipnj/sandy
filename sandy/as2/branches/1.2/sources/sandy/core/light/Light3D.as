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

import sandy.core.data.Vector;
import sandy.util.NumberUtil;
import sandy.math.VectorMath;
import com.bourre.events.EventBroadcaster;
import com.bourre.events.IEvent;
import com.bourre.events.EventType;
import com.bourre.events.BasicEvent;

/**
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		02.06.2006
* 
**/
class sandy.core.light.Light3D
{
	/**
	 * The Light3D onLightUpdated Event. Broadcasted when the light properties have changed
	 */
	public static var onLightUpdatedEVENT:EventType = new EventType( 'onLightUpdated' );
	
	/**
	* Maximum value accepted. If the default value (150) seems too big or too small for you, you can change it.
	* But be aware that the actual lighting calculations are normalised i.e. 0 -> MAX_POWER becomes 0 -> 1 
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
		VectorMath.normalize(_dir);
		setPower( pow );
		_event = new BasicEvent( Light3D.onLightUpdatedEVENT );
		_oEB = new EventBroadcaster( this );
	}
	
	/**
	 * The the power of the light. A number between 0 and MAX_POWER is necessary. 
	 * The highter the power of the light is, the less the shadows are visibles.
	 * @param n Number a Number between 0 and MAX_POWER. This number is the light intensity.
	 */
	public function setPower( n:Number )
	{
		_power =  NumberUtil.constrain( n, 0, Light3D.MAX_POWER );
		_nPower = _power / MAX_POWER;
		broadcastEvent( _event );
	}
	
	/**
	 * Returns the power of the light.
	 * @return Number a number between 0 - MAX_POWER.
	 */
	public function getPower( Void ):Number
	{
		return _power;
	}
	
	/**
	 * Returns the power of the light normalized to the range 0 -> 1
	 * @return Number a number between 0 and 1	 */
	public function getNormalizedPower():Number
	{
		return _nPower;
	}
	
	public function getDirectionVector( Void ):Vector
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
		VectorMath.normalize(_dir);
		broadcastEvent( _event );
	}
	
	public function setDirectionVector( pDir:Vector ):Void
	{
		_dir = pDir;
		VectorMath.normalize(_dir);		
		broadcastEvent( _event );
	}
	
	/**
	 * Calculate the strength of this light based on the supplied normal
	 * @return Number	the strength between 0 and 1	 */
	public function calculate( normal:Vector ):Number
	{
		var DP:Number = VectorMath.dot( _dir, normal);
		// if DP is less than 0 then the face is facing away from the light
		// so set it to zero
		if(DP < 0) DP = 0;
		return _nPower * DP;
	}
	
	public function destroy( Void ):Void
	{
		_oEB.removeAllListeners();
	}

	/**
	 * Adds passed-in {@code oL} listener for receiving passed-in {@code t} event type.
	 * 
	 * <p>Take a look at example below to see all possible method call.
	 * 
	 * <p>Example
	 * <code>
	 *   var oEB : IEventDispatcher = new EventBroadcaster(this);
	 *   oEB.addEventListener( myClass.onSometingEVENT, myFirstObject);
	 *   oEB.addEventListener( myClass.onSometingElseEVENT, this, __onSomethingElse);
	 *   oEB.addEventListener( myClass.onSometingElseEVENT, this, Delegate.create(this, __onSomething) );
	 * </code>
	 * 
	 * @param t Name of the Event.
	 * @param oL Listener object.
	 */
	public function addEventListener(t:String, oL) : Void
	{
		_oEB.addEventListener.apply( _oEB, arguments );
	}
	
	/**
	 * Removes passed-in {@code oL} listener that suscribed for passed-in {@code t} event.
	 * 
	 * <p>Example
	 * <code>
	 *   var oEB : IEventDispatcher = new EventBroadcaster(this);
	 *   oEB.removeEventListener( myClass.onSometingEVENT, myFirstObject);
	 *   oEB.removeEventListener( myClass.onSometingElseEVENT, this);
	 * </code>
	 * 
	 * @param t Name of the Event.
	 * @param oL Listener object.
	 */
	public function removeEventListener(t:String, oL) : Void
	{
		_oEB.removeEventListener( t, oL );
	}
	

	/**
	 * Wrapper for Macromedia {@code EventDispatcher} polymorphism.
	 * 
	 * <p>Example
	 * <code>
	 *   var oEB : IEventDispatcher = new EventBroadcaster(this);
	 *   oEB.dispatchEvent( {type:'onSomething', target:this, param:12} );
	 * </code>
	 * 
	 * @param o Event object.
	 */
	public function dispatchEvent(o:Object) : Void
	{
		_oEB.dispatchEvent.apply( _oEB, arguments );
	}
	
	/**
	 * Broadcasts event to suscribed listeners.
	 * 
	 * <p>Example using full Pixlib API
	 * <code>
	 *   var oEB : IEventDispatcher = new EventBroadcaster(this);
	 *   var e : IEvent = new BasicEvent( myClass.onSomeThing, this);
	 *   
	 *   oEB.addEventListener( myClass.onSomeThing, this);
	 *   oEB.broadcastEvent( e );
	 * </code>
	 * 
	 * @param e an {@link IEvent} instance
	 */
	public function broadcastEvent(e:IEvent) : Void
	{
		_oEB.broadcastEvent.apply( _oEB, arguments );
	}


	private var _oEB:EventBroadcaster;
	// Direction of the light. It is 3D vector. Please refer to the Light tutorial to learn more about Sandy's lights.
	private var _dir:Vector;	
	private var _power : Number;
	private var _nPower : Number
	private var _event:BasicEvent;
	
}