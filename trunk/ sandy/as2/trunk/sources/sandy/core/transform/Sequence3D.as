import com.bourre.events.BasicEvent;
import com.bourre.events.EventBroadcaster;
import com.bourre.events.EventType;
import com.bourre.events.IEvent;

import sandy.core.data.Matrix4;
import sandy.core.transform.Interpolator3D;
import sandy.core.transform.TransformType;
import sandy.core.World3D;
import sandy.events.InterpolationEvent;
import sandy.math.Matrix4Math;

class sandy.core.transform.Sequence3D implements Interpolator3D
{
	/**
	 *  The Interpolation render Event. Broadcasted when the Sequence3D had to be rendered.
	 */
	public static var onRenderEVENT:EventType = new EventType( "onRender" );
	
	/**
	 * Create a new TranslationInterpolator.
	 * <p> This class realise an interpolation resulting in a sequence of interpolation.</p>
	 */	
	public function Sequence3D( Void ) 
	{	
		_paused = _finished = _blocked = _modified = false;
		_way = 1;
		_current_index = -1;
		_aInterpolator = new Array();
		_ci = null;

		_oEB = new EventBroadcaster( this );
		_eOnResume = new InterpolationEvent( InterpolationEvent.onResumeEVENT, this, getType(), 0 );
		_eOnPause = new InterpolationEvent( InterpolationEvent.onPauseEVENT, this, getType(), 0 );
		_eOnRender = new InterpolationEvent( Sequence3D.onRenderEVENT, this, getType(), 0 );
		_eOnProgress = new InterpolationEvent( InterpolationEvent.onProgressEVENT, this, getType(), 0 );
		_eOnEnd = new InterpolationEvent( InterpolationEvent.onEndEVENT, this, getType(), 1 );
		
		_tMatrix = _concatMatrix = null;
		_aMatrix = new Array();
		_totalDuration = 0;
		_frame = 0;
		
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __render );
	}
	
	/**
	 * Make a pause in the Interpolation. You can continue the motion later with resume method.
	 * Broadcast an InterpolationEvent.
	 */
	public function pause( Void ):Void
	{
		_paused = true;
		_eOnPause.setPercent( getPercent() );
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
	
	/*
	* Method called when the interpolation had to be rendered.
	* */
	private function __render( Void ):Void
	{
		if( false == _paused && false == _finished )
		{
			_frame += _way;
			broadcastEvent( _eOnRender );
		}
	}
	
	/**
	 * Method called when sequence received an event (onProgressEVENT) from an interpolator which is being listening.
	 */
	private function __onProgress( eventC:InterpolationEvent ):Void
	{
		_eOnProgress.setPercent(getPercent());
		
		_tMatrix = Matrix4Math.multiply( _concatMatrix, _ci.getMatrix());
		_modified = true;
		
		broadcastEvent( _eOnProgress );
	}
	
	/**
	 * Method called when sequence received an event (onEndEVENT) from an interpolator which is being listening.
	 */
	private function __onEnd( eventC:InterpolationEvent ):Void
	{
		if( ! plugOnNextInterpolator() )
		{
			_finished = true;
			broadcastEvent( _eOnEnd );
		}
	}
	
	/**
	 * Try to plug, on the next interpolator considering the direction.
	 * @param Void
	 * @return Boolean : true if the current intrepolator isn't the last of the sequence, else false.
	 */
	private function plugOnNextInterpolator( Void ) : Boolean
	{
		unplugCurrentInterpolator();
		
		if( _way == 1 )
		{
			if( _current_index == (_aInterpolator.length-1) ) return false;
			else _current_index++;
		}
		else
		{
			if( _current_index == 0 ) return false;
			else _current_index--;
		}
		
		_concatMatrix = _aMatrix[_current_index];
		plugInterpolator( _aInterpolator[_current_index] );
		
		return true;
	}
	
	/**
	* Unplug the current interpolator.
	*/
	private function unplugCurrentInterpolator() : Void 
	{
		if(_current_index != -1) unplugInterpolator( _ci );
	}
	
	
	/**
	 * Add an interpolator to the sequence.
	 * @param Interpolator3D
	 * @return Void
	 */
	public function addChild( i:Interpolator3D ) : Void 
	{
		World3D.getInstance().removeEventListener( World3D.onRenderEVENT, i );
		
		_aInterpolator.push(i);
		_totalDuration += i.getDuration();
		
		if( _aInterpolator.length == 1 )
		{
			_current_index = 0;
			plugInterpolator( _aInterpolator[_current_index] );
			_aMatrix.push( new Matrix4() );
			_concatMatrix = _aMatrix[0];
			_aMatrix.push( i.getEndMatrix()  );
		}
		else _aMatrix.push( Matrix4Math.multiply( _aMatrix[_aMatrix.length-1], i.getEndMatrix() ) );
	}
	
	/**
	 * Resize the total duration in number of frames with the one giving in parameter.
	 * @param Number the duration in number of frames
	 * @return Void
	 */
	public function setDuration ( t:Number ):Void
	{
		if( t == Number.POSITIVE_INFINITY || t > 10000 ) t = 10000;
		else if( t < 5 ) t = 5;
		
		_totalDuration = t;
		
		var sum:Number = 0;
		var l:Number = _aInterpolator.length;
		while( --l > -1 ) sum += _aInterpolator[l].getDuration();

		var coef:Number = _totalDuration / sum;
		l = _aInterpolator.length;
		while( --l > -1 ) _aInterpolator[l].setDuration( _aInterpolator[l].getDuration()*coef );
	}
	
	/**
	 * Set the interpolation duration in number of frames. Could be lower than 5!
	 * @param Void
	 * @return Number of frame corresponding to the durationoh the interpolator
	 */
	public function getDuration ( Void ):Number
	{
		return _totalDuration;
	}
	
	private function plugInterpolator( i:Interpolator3D ) : Void 
	{
		_ci = i;
		this.addEventListener( Sequence3D.onRenderEVENT, _ci, _ci['__render']);	
		_ci.addEventListener( InterpolationEvent.onProgressEVENT, this, __onProgress );
		_ci.addEventListener( InterpolationEvent.onEndEVENT, this, __onEnd );
	}
	
	private function unplugInterpolator( i:Interpolator3D ) : Void 
	{
		this.removeEventListener( Sequence3D.onRenderEVENT, i );
		i.removeEventListener( InterpolationEvent.onProgressEVENT, this );
		i.removeEventListener( InterpolationEvent.onEndEVENT, this );
	}
	
	/**
	 * Get the end matrix of the interpolator.
	 * @param Void
	 * @return Matrix4
	 */
	public function getEndMatrix( Void ):Matrix4
	{
		return _aMatrix[_aMatrix.length-1];
	}
	
	/**
	 * Get the start matrix of the interpolator.
	 * @param Void
	 * @return Matrix4
	 */
	public function getStartMatrix( Void ):Matrix4
	{
		return _aInterpolator[0].getStartMatrix();
	}

	public function getFrame(Void) : Number 
	{
		return _frame;
	}
		
	/**
	* redo
	* <p>Make the interpolation starting again</p>
	*/
	public function redo( Void ):Void
	{
		var l:Number = _aInterpolator.length;
		while( --l > -1 ) _aInterpolator[l].redo();
		
		if(_finished == false) unplugCurrentInterpolator();
		
		if(_way == 1) _current_index = 0;
		else _current_index = _aInterpolator.length-1;
		
		_concatMatrix = _aMatrix[_current_index];
		plugInterpolator( _aInterpolator[_current_index] );
		
		_tMatrix = Matrix4Math.multiply( _concatMatrix, _ci.getMatrix());
		_frame = (_way==1) ? 0 : _totalDuration;
		
		_modified = true;
		_finished = false;
	}
	
	/**
	* yoyo
	* <p>Make the interpolation going in the inversed way</p>
	*/
	public function yoyo( Void ):Void
	{
		_way = -_way;
		var l:Number = _aInterpolator.length;
		while( --l > -1 ) _aInterpolator[l].yoyo();
		
		if(_finished == false)
		{
			if(_ci.getPercent() == 0)
			{
				unplugCurrentInterpolator();
				if(_way == -1)
				{
					_current_index = (_current_index == 0)?_aInterpolator.length-1:_current_index-1;
					if(_current_index == (_aInterpolator.length-1)) _frame = _totalDuration;
				}
				else
				{
					_current_index = (_current_index + 1)%_aInterpolator.length;
					if(_current_index == 0) _frame = 0;
				}
				_concatMatrix = _aMatrix[_current_index];
				plugInterpolator( _aInterpolator[_current_index] );
			}
		}
		else
		{
			_concatMatrix = _aMatrix[_current_index];
			plugInterpolator( _aInterpolator[_current_index] );
			
			_tMatrix = Matrix4Math.multiply( _concatMatrix, _ci.getMatrix());
			_modified = true;
			
			_frame = (_way==1)?0:_totalDuration;
			_finished = false;
		}
	}	
	
	/**
	* Returns the percent of the interpolator. 0 is the beginning, and 100 is the end.
	* @param	Void
	* @return a Number between [0-1] corresponding on the percentage of the interpolation progress.
	*/
	public function getPercent( Void ) : Number
	{
		/* TODO remake this one with durations */
		var p:Number=0;
		
		if(_way == 1) 	p = _current_index + 1 + _ci.getPercent();
		else 			p = _aInterpolator.length - (_current_index + 1) + _ci.getPercent(); 
				
		return ( p / _aInterpolator.length );
	}

	/**
	* Returns the type of the interpolation. 
	* @param	Void
	* @return TransformType the type of the interpolation
	*/
	public function getType( Void ):TransformType 
	{
		return TransformType.MIXED_INTERPOLATION;
	}
	
	public function toString():String
	{
		return 'sandy.core.transform.Sequence3D';
	}
	
	public function destroy(Void) : Void 
	{
		unplugCurrentInterpolator();
		
		for(var i = 0; i < _aInterpolator.length; i++)
			_aInterpolator[i].destroy();
		
		delete _aInterpolator;
		
		_oEB.removeAllEventListeners(InterpolationEvent.onEndEVENT);
		_oEB.removeAllEventListeners(InterpolationEvent.onProgressEVENT);
		_oEB.removeAllEventListeners(InterpolationEvent.onResumeEVENT);
		_oEB.removeAllEventListeners(InterpolationEvent.onPauseEVENT);
		_oEB.removeAllEventListeners(Sequence3D.onRenderEVENT);
		_oEB.removeAllListeners();
	}
	
	public function addEventListener(t:String, oL) : Void
	{
		_oEB.addEventListener.apply( _oEB, arguments );
	}

	public function removeEventListener(t:String, oL) : Void
	{
		_oEB.removeEventListener( t, oL );
	}
	
	public function dispatchEvent(o:Object) : Void
	{
		_oEB.dispatchEvent.apply( _oEB, arguments );
	}
	
	public function broadcastEvent(e:IEvent) : Void
	{
		_oEB.broadcastEvent.apply( _oEB, arguments );
	}
	
	public function getMatrix( Void ):Matrix4
	{
		return _tMatrix;
	}
	
	public function isModified( Void ):Boolean
	{
		return _modified;
	}
	
	public function setModified( b:Boolean ):Void
	{
		_modified = b;
	}
	

	public function getDurationElapsed(Void) : Number 
	{
		var time:Number = 0;
		var l:Number = _current_index - 1;
		while( --l > -1 ) time += _aInterpolator[l].getDuration();
		
		time += _aInterpolator[_current_index].getDurationElapsed();
		
		return time;
	}

	public function getDurationRemaining(Void) : Number 
	{
		return _totalDuration - getDurationElapsed();
	}

	public function isPaused(Void) : Boolean 
	{
		return _paused;
	}

	public function isFinished(Void) : Boolean 
	{
		return _finished;
	}
	//////////////
	/// PRIVATE
	//////////////

	private var _paused:Boolean;
	private var _finished:Boolean;
	private var _blocked:Boolean;
	
	private var _eOnPause:InterpolationEvent;
	private var _eOnResume:InterpolationEvent;
	private var _eOnRender:InterpolationEvent;
	private var _eOnProgress:InterpolationEvent;
	private var _eOnEnd:InterpolationEvent;
	
	private var _oEB:EventBroadcaster;
	
	private var _totalDuration:Number;

	private var _aInterpolator:Array; 	//tableau des interpolations
	private var _ci:Interpolator3D; 	//référence sur l'interpolation courante (plus rapide)
	
	private var _current_index:Number; 	//index de l'interpolation courante (0 à n-1)
	private var _way:Number; 		//direction de parcours de l'interpolation (1:normal, -1:inverse)
	
	private var _tMatrix:Matrix4;
	private var _concatMatrix:Matrix4;
	private var _modified:Boolean;
	
	private var _aMatrix:Array; 		//les différentes matrices intermédiaires précalculées.
	
	private var _frame:Number;

}