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
import com.bourre.events.EventBroadcaster;
import com.bourre.events.IEvent;
import com.bourre.events.EventType;

import sandy.core.transform.Transform3D;
import sandy.core.transform.TransformType;
import sandy.events.InterpolationEvent;
import sandy.events.TransformEvent;
import sandy.core.data.Matrix4;

/**
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		16.05.2006
**/
class sandy.core.transform.BasicInterpolator 
{
	/**
	 *  The Transformation end Event. Broadcasted when the Interpolation is finished
	 */
	public static var onEndEVENT:EventType = TransformEvent.onEndEVENT;
	
	/**
	 * The Interpolation interpolation Event. It's the event broadcasted every time the interpolation is updated
	 */
	public static var onProgressEVENT:EventType = InterpolationEvent.onProgressEVENT;
	
	/**
	 *  The Interpolation resume Event. Broadcasted when the Interpolation is resumed
	 */
	public static var onResumeEVENT:EventType = InterpolationEvent.onResumeEVENT;	

	/**
	 * Make a pause in the Interpolation. You can continue the motion later with resume method.
	 * Broadcast an InterpolationEvent.
	 */
	public function pause( Void ):Void
	{
		_paused = true;
		_eOnPause['_nPercent'] = getPercent();
		broadcastEvent( _eOnPause );
	}
	
	/**
	 * Resume the motion after it was paused. Broadcast an InterpolationEvent.
	 */
	public function resume( Void ):Void
	{
		_paused = false;
		_eOnResume['_nPercent'] = getPercent();
		broadcastEvent( _eOnResume );
	}
	
	/**
	* redo
	* <p>Make the interpolation starting again</p>
	*/
	public function redo( Void ):Void
	{
		_finished = false;
	}
			
	/**
	* yoyo
	* <p>Make the interpolation going in the inversed way</p>
	*/
	public function yoyo( Void ):Void
	{
		_way = - _way;
		_finished = false;
	}	
	
	/**
	* Returns the percent of the interpolator. 0 is the beginning, and 100 is the end.
	* @param	Void
	* @return a Number between [0-100] corresponding on the percentage of the interpolation progress.
	*/
	public function getPercent( Void ):Number
	{
		return _p;
	}
	
	/**
	* Returns the type of the interpolation. 
	* @param	Void
	* @return TransformType the type of the interpolation
	*/
	public function getType(Void):TransformType 
	{
		// to implement correctly in the derivated classes
		return TransformType.NONE;
	}
	
	/**
	 * set the interpolation duration in number of frames. Could be lower than 5!
	 * @param Number the duration in number of frames
	 * @return Void
	 */
	public function setDuration ( t:Number ):Void
	{
		if( t == Number.POSITIVE_INFINITY || t > 10000 ) t = 10000;
		else if( t < 5 ) t = 5;
		_timeIncrease = 1 / t;
	}
	
	/**
	* Has to be implemented in the derivated classes.
	* @param	Void
	*/
	public function destroy(Void) : Void 
	{
		;
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
	
	public function getMatrix( Void ):Matrix4
	{
		return _t.getMatrix();
	}
	
	public function isModified( Void ):Boolean
	{
		return _t.isModified();
	}
	
	public function setModified( b:Boolean ):Void
	{
		_t.setModified( b );
	}
	
	private function __render( Void ):Void
	{
		// to implement;
	}
	
	////////////
	// PRIVATE
	////////////
	private function BasicInterpolator(f:Function, pnFrames:Number )
	{
		_way = 1;
		_t = new Transform3D();
		_timeIncrease = 1 / pnFrames;
		_f = f;
		_p = 0;
		_paused = _finished = _blocked = false;
		_oEB = new EventBroadcaster( this );
		_eOnProgress 	= new InterpolationEvent( InterpolationEvent.onProgressEVENT, 	this, getType(), 0 );
		_eOnResume 		= new InterpolationEvent( InterpolationEvent.onResumeEVENT, 	this, getType(), 0 );
		_eOnPause 		= new InterpolationEvent( InterpolationEvent.onPauseEVENT, 		this, getType(), 0 );
		_eOnStart 		= new InterpolationEvent( InterpolationEvent.onStartEVENT, 		this, getType(), 0 );
		_eOnEnd 		= new InterpolationEvent( InterpolationEvent.onEndEVENT, 		this, getType(), 1 );
	}
	
	private var _paused:Boolean;
	private var _finished:Boolean;
	private var _blocked:Boolean;
	private var _p:Number; // percentage
	private var _f:Function;// ease function
	private var _way:Number;// forward or backward
	private var _t:Transform3D;// the transformation we are going to update the transformGroup with
	private var _timeIncrease:Number;// the time between each frames
	
	private var _eOnProgress:InterpolationEvent;
	private var _eOnPause:InterpolationEvent;
	private var _eOnResume:InterpolationEvent;
	private var _eOnEnd:InterpolationEvent;
	
	private var _oEB:EventBroadcaster;
	private var _eOnStart:InterpolationEvent;
	
}