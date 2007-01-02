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

import sandy.core.data.Matrix4;
import sandy.core.transform.Transform3D;
import sandy.core.transform.TransformType;
import sandy.events.InterpolationEvent;


/**
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		16.05.2006
**/
class sandy.core.transform.BasicInterpolator 
{
	/**
	 * Make a pause in the Interpolation. You can continue the motion later with resume method.
	 * Broadcast an InterpolationEvent.
	 */
	public function pause( Void ):Void
	{
		_paused = true;
		_eOnResume.setPercent( getPercent() );
		broadcastEvent( _eOnPause );
	}
	
	/**
	 * Resume the motion after it was paused. Broadcast an InterpolationEvent.
	 */
	public function resume( Void ):Void
	{
		_paused = false;
		_eOnResume.setPercent( getPercent() );
		broadcastEvent( _eOnResume );
	}
	
	/**
	* redo
	* <p>Make the interpolation starting again</p>
	*/
	public function redo( Void ):Void
	{
		_frame = ( _way == 1 ) ? 0 : _duration;
		_finished = false;
		_modified = true;
	}
			
	/**
	* yoyo
	* <p>Make the interpolation going in the inversed way</p>
	*/
	public function yoyo( Void ):Void
	{
		// _frame = _duration - _frame;
		_way = - _way;
		_finished = false;
		_modified = true;
	}	
	
	public function getFrame( Void ):Number
	{
		return _frame;
	}
	
	/**
	* Returns the percent of the interpolator. 0 is the beginning, and 100 is the end.
	* @param	Void
	* @return a Number between [0-100] corresponding on the percentage of the interpolation progress.
	*/
	public function getPercent( Void ):Number
	{
		if( _way == 1 ) 	return ( _frame / _duration )*100;
		else			return ( 1 - ( _frame / _duration ) )*100;
	}
	
	/**
	* Returns the type of the interpolation. 
	* @param	Void
	* @return TransformType the type of the interpolation
	*/
	public function getType( Void ):TransformType 
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
		_duration = t;
		_timeIncrease = 1 / t;
	}
	
	public function getDuration ( Void ):Number
	{
		return _duration;
	}
	
	public function getDurationElapsed(Void):Number 
	{
		return _frame;
	}

	public function getDurationRemaining(Void):Number 
	{
		return _duration - _frame;
	}
		
	/**
	* Destroy the transformation instance and remove all its listeners.
	* Shall be implemented in the derivated classes.
	* @param	Void
	*/
	public function destroy( Void ) : Void 
	{
		// TODO : are those 3 first parameters necessary?
		_oEB.removeAllEventListeners(InterpolationEvent.onEndEVENT);
		_oEB.removeAllEventListeners(InterpolationEvent.onProgressEVENT);
		_oEB.removeAllEventListeners(InterpolationEvent.onResumeEVENT);
		_oEB.removeAllListeners();
		_t.removeAllListeners();
		_t.destroy();
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

	
	/**
	* Returns the associated matrix.
	* @param	Void
	* @return Matrix4 The matrix of the transform3D associated to the interpolator.
	*/
	public function getMatrix( Void ):Matrix4
	{
		return _m;
	}
	
	/**
	* Allows you to know if the transformation has been modified.
	* @param	Void
	* @return Boolean True if the transformation has been modified, false otherwise.
	*/
	public function isModified( Void ):Boolean
	{
		return _modified;
	}
	
	/**
	* Set the transformation as modified or not. Very usefull for the cache transformation system.
	* @param	b Boolean True value means the transformation has been modified, and false the opposite.
	*/
	public function setModified( b:Boolean ):Void
	{
		_modified = b;
	}
	
	public function isFinished( Void ):Boolean
	{
		return _finished;
	}
	
	public function isPaused( Void ):Boolean
	{
		return _paused;
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
		_duration = pnFrames;
		_timeIncrease = 1 / pnFrames;
		_f = f;
		_frame = 0;
		_m = Matrix4.createIdentity();
		_paused = _finished = _blocked = _modified = false;
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
	private var _frame:Number; // percentage
	private var _f:Function;// ease function
	private var _way:Number;// forward or backward
	private var _t:Transform3D;// the transformation we are going to update the transformGroup with
	private var _timeIncrease:Number;// the time between each frames
	private var _duration:Number;//duration in frames
	
	private var _eOnProgress:InterpolationEvent;
	private var _eOnPause:InterpolationEvent;
	private var _eOnResume:InterpolationEvent;
	private var _eOnEnd:InterpolationEvent;
	
	private var _oEB:EventBroadcaster;
	private var _eOnStart:InterpolationEvent;
	private var _modified;
	private var _durationElapsed : Number;

	private var _m : Matrix4;
	
}