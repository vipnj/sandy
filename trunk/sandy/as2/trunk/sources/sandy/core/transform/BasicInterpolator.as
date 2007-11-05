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
import sandy.core.World3D;
import sandy.core.transform.TransformType;
import sandy.events.InterpolationEvent;


/**
* @author		Thomas Pfeiffer - kiroukou
* @author		Thomas Balitout - samothtronicien
* @since		1.0
* @version		1.2.2
* @date 		26.05.2007
**/
class sandy.core.transform.BasicInterpolator
{
	/**
	* Compute the matrix for the current frame.
	* @param	Void
	* @return Void
	*/
	private function __update( Void ):Void
	{
		//to implement
	}
	
	/**
	* Render the interpolaion
	* @param	Void
	* @return Void
	*/
	private function __render( Void ):Void
	{
		if( false == _paused && false == _finished )
		{
			_framerender = _frame = (_way == -1) ? (_frame-1 >= 0) ? _frame-1 : 0 : (_frame+1 <= _duration2) ? _frame+1 : _duration2;

			__update();
				
			_eOnProgress.setPercent( getPercent() );
			broadcastEvent( _eOnProgress );
				
			if( (_frame == 0 && _way == -1) || (_way == 1 && _frame == _duration2) )
			{
				(_way == 1) ? _frame = _duration : _frame = -1;
				_finished = true;
				broadcastEvent( _eOnEnd );
			}
		}
	}
	
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
		_frame = ( _way == 1 ) ? -1 : _duration;
		_framerender = _frame + _way;
		_finished = false;
		if(_paused)
		{
			if( _way == 1 ) _m = getStartMatrix();
			else _m = getEndMatrix();
			_modified = true;
		}
	}
	
	/**
	* yoyo
	* <p>Make the interpolation going in the inversed way</p>
	*/
	public function yoyo( Void ):Void
	{
		_way = - _way;
		_finished = false;
		//_modified = true;
	}	
	
	/**
	* Returns the number of the current frame
	* @param	Void
	* @return a Number between [1 - _duration].
	*/
	public function getFrame( Void ):Number
	{
		return _framerender+1;
	}
	
	/**
	* Returns the percent of the interpolator. 0 is the beginning, and 100 is the end.
	* @param	Void
	* @return a Number between [0-100] corresponding on the percentage of the interpolation progress.
	*/
	public function getPercent( Void ):Number
	{
		return (getProgress()*100);
	}

	/**
	* Returns the progress of the interpolator. 0 is the beginning, and 1 is the end.
	* @param	Void
	* @return a Number between [0-1] corresponding on the interpolation progress.
	*/
	public function getProgress( Void ):Number
	{
		if( _way == 1 ) return ( _framerender / _duration2 );
		else		return ( 1 - ( _framerender / _duration2 ) );
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
	
	public function getName( Void ):String
	{
		return _name;
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
		
		var old_duration2:Number = _duration2;
		
		_duration = Math.floor(t);
		_duration2 = _duration - 1;
		
		var coef:Number = (_duration2) / (old_duration2);
		if(_way == 1) _framerender = (Math.round(_framerender * coef)>_duration2)?_duration2:Math.round(_framerender * coef);	
		else _framerender = (Math.round(_framerender * coef)>_duration2)?_duration2:Math.round(_framerender * coef);		
		
		if(_frame <= 0) _framerender = 0;
		else if(_frame == old_duration2)
		{
			_frame = _duration2;
			_framerender = _duration2;
		}
		else if(_frame == old_duration2+1)
		{
			_frame = _duration2+1;
			_framerender = _duration2;
		}
		else _frame = _framerender;
		
		__update();
	}
	
	/**
	 * Return the duration in number of frames
	 * @param Number the duration in number of frames
	 * @return Void
	 */
	public function getDuration ( Void ):Number
	{
		return _duration;
	}
	
	/**
	 * Return the number of frame rendered, between 1 and _duration
	 * @param Number the duration in number of frames
	 * @return Void
	 */
	public function getDurationElapsed(Void):Number 
	{
		return (_way == 1)? getFrame() : getDuration() - getFrame();
	}
	
	/**
	 * Return the number of frame which has not been rendered yet
	 * @param Number the duration in number of frames
	 * @return Void
	 */
	public function getDurationRemaining(Void):Number 
	{
		return (_way == 1)? getDuration() - getFrame() : getFrame();
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
	
	/**
	* Returns true if the interpolation is in his initial state
	* @param	Void
	* @return Boolean true if the interpolation is in her initial state
	*/
	public function isInitialState( Void ):Boolean
	{
		return _frame == -1;
	}
	
	/**
	* Returns true if the interpolation is in his final state
	* @param	Void
	* @return Boolean true if the interpolation is in her final state
	*/
	public function isFinalState( Void ):Boolean
	{
		return _frame == _duration;
	}
	
	/**
	* Set up the interpolation to final state
	* @param	Void
	* @return 	Void
	*/
	public function setFinal( Void ) : Void
	{
		_frame = _duration;
		_framerender = _duration2;
	}
	
	/**
	* Set up the interpolation to initial state
	* @param	Void
	* @return  	Void
	*/
	public function setInitial( Void ) : Void
	{
		_frame = -1;
		_framerender = 0;
	}

	public function skipNextFrame( Void ) : Void
	{
		_frame += _way;
	}
	
	/**
	* Return the matrix corresponding to the first frame of the interpolation
	* @param	Void
	* @return Matrix4
	*/
	public function getStartMatrix( Void ):Matrix4
	{
		//to implement
		return  new Matrix4();
	}
	
	/**
	* Return the matrix corresponding to the last frame of the interpolation
	* @param	Void
	* @return Matrix4
	*/
	public function getEndMatrix( Void ):Matrix4
	{
		//to implement
		return  new Matrix4();
	}
	
	////////////
	// PRIVATE
	////////////
	private function BasicInterpolator(f:Function, pnFrames:Number, n:String )
	{
		_way = 1;
		_duration = pnFrames;
		_duration2 = pnFrames-1;
		_f = f;
		_frame = -1;
		_framerender = 0;
		_name = n;
		
		_m = Matrix4.createIdentity();
		_paused = _finished = _blocked = _modified = false;
		_oEB = new EventBroadcaster( this );
		_eOnProgress 	= new InterpolationEvent( InterpolationEvent.onProgressEVENT, 	this, getType(), 0 );
		_eOnResume 		= new InterpolationEvent( InterpolationEvent.onResumeEVENT, 	this, getType(), 0 );
		_eOnPause 		= new InterpolationEvent( InterpolationEvent.onPauseEVENT, 		this, getType(), 0 );
		_eOnStart 		= new InterpolationEvent( InterpolationEvent.onStartEVENT, 		this, getType(), 0 );
		_eOnEnd 		= new InterpolationEvent( InterpolationEvent.onEndEVENT, 		this, getType(), 1 );
		
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __render );
	}
	
	private var _paused:Boolean;
	private var _finished:Boolean;
	private var _blocked:Boolean;// surement à virer car risque de foutre une merde terrible dans sequence et parallel !
	private var _modified:Boolean;
		
	private var _frame:Number; // current frame of the interpolation (just an index, cannot be the true one in some case)
	private var _framerender:Number; // TRUE current frame of the interpolation [0 <-> _duration2]
	private var _f:Function;// ease function
	private var _way:Number;// forward or backward (1:forward , -1:backward)
	private var _duration:Number;// duration in frames
	private var _duration2:Number;// max index of a frame
	
	private var _eOnProgress:InterpolationEvent;
	private var _eOnPause:InterpolationEvent;
	private var _eOnResume:InterpolationEvent;
	private var _eOnEnd:InterpolationEvent;
	
	private var _oEB:EventBroadcaster;
	private var _eOnStart:InterpolationEvent;

	private var _m:Matrix4;
	private var _name:String;
}
