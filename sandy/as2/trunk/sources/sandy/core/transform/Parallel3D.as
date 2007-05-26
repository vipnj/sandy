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
import sandy.core.transform.Interpolator3D;
import sandy.core.World3D;
import sandy.core.data.Matrix4;
import sandy.core.transform.TransformType;
import sandy.core.transform.Transform3D;
import sandy.math.Matrix4Math;

import sandy.events.InterpolationEvent;

import com.bourre.events.EventBroadcaster;
import com.bourre.events.IEvent;
import com.bourre.events.EventType;


/**
* Parallel3D
*  
* @author		Thomas Balitout - samothtronicien
* @since		1.1
* @version		1.2.2
* @date 		26.05.2007
*/
class sandy.core.transform.Parallel3D implements Interpolator3D
{
	/**
	 *  The Interpolation render Event. Broadcasted to his child when the Parallel3D had to be rendered.
	 */
	public static var onRenderEVENT:EventType = new EventType( "onRender" );
	
	/**
	 * Create a new TranslationInterpolator.
	 * <p> This class realise an interpolation resulting in multiple interpolation in the same time.</p>
	 */	
	public function Parallel3D( n:String ) 
	{	
		_name = (n == undefined)?"Parallel3D":n;
		_paused = _finished = _blocked = _modified = false;
		_way = 1;
		_originalDuration = _duration = _nb_render_done = _nb_ended_interpol = _nb_ended_interpol_yoyo = 0;
		_frame = -1;
		_aInterpolator = new Array();
		_longer_interpol = null;

		_oEB = new EventBroadcaster( this );
		_eOnResume = new InterpolationEvent( InterpolationEvent.onResumeEVENT, this, getType(), 0 );
		_eOnPause = new InterpolationEvent( InterpolationEvent.onPauseEVENT, this, getType(), 0 );
		_eOnRender = new InterpolationEvent( Parallel3D.onRenderEVENT, this, getType(), 0 );
		_eOnProgress = new InterpolationEvent( InterpolationEvent.onProgressEVENT, this, getType(), 0 );
		_eOnEnd = new InterpolationEvent( InterpolationEvent.onEndEVENT, this, getType(), 1 );
		
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __render );
		
		_tMatrix = null;
		_concatMatrix = new Matrix4();
		_aRenderMatrix = new Array();
		
		_aIntoDur = new Array();
		_canRender = true;
		_waitEndEventBeforeNextRender = false;
		
		_startMatrix = new Matrix4();
		_endMatrix = new Matrix4();
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
	
	public function skipNextFrame( Void ):Void
	{
		var l:Number = _aInterpolator.length;
		if( isInitialState() )
		{
			while( --l > -1 )
			{
				if( _aInterpolator[l].isInitialState() ) 
					_aInterpolator[l].skipNextFrame();
			}
		}
		else if( isFinalState() )
		{
			while( --l > -1 )
			{
				if( _aInterpolator[l].getDuration() == _frame && _aInterpolator[l].isFinalState() ) 
					_aInterpolator[l].skipNextFrame();
			}
		}
		_frame += _way;
	}
	
	public function isInitialState( Void ):Boolean
	{
		return _frame == -1;
	}
	
	public function isFinalState( Void ):Boolean
	{
		return _frame == _duration;
	}
	
	/*
	* Method called when the interpolation had to be rendered.
	* */
	private function __render( Void ):Void
	{
		if( false == _paused && false == _finished && _canRender == true)
		{
			//we set can render to false, to wait for the rendering of all the inside interpolation before to do the next.
			_canRender = false;
			if(_way == -1)
			{
				var l:Number = _aInterpolator.length;
				while( --l > -1 )
				{
					//if the length of the interpolation is equal to the current time frame, we start it in yoyo mode.
					//and we resume it because in some case we had to put it in pause.
					if( _frame <= _aInterpolator[l].getDuration() && _aInterpolator[l].isPaused())
					{
						_aInterpolator[l].resume();
						_nb_ended_interpol--;//a new interpolation is now active
					}
				}
			}
			_nb_render_done = _nb_ended_interpol;
			_frame = (_way == -1) ? (_frame-1 >= 0) ? _frame-1 : 0 : (_frame+1 <= _duration-1) ? _frame+1 : _duration-1;
			broadcastEvent( _eOnRender );
		}
	}
	
	/**
	 * Method called when parallel received an event (onProgressEVENT) from an interpolator which is being listening.
	 */
	private function __onProgress( eventC:InterpolationEvent )
	{
		//We identify the source of the event, and we get the corresponding matrix.
		var l:Number = _aInterpolator.length;
		while( --l > -1 )
		{
			if(eventC.getTarget() == _aInterpolator[l])
			{
				_aRenderMatrix[l] = _aInterpolator[l].getMatrix();
				break;
			}
		}
		
		_nb_render_done++;
		
		if(_nb_render_done == _aInterpolator.length)
		{
			var i:Number;
			for(i = 0; i < _aRenderMatrix.length; i++)
			 	_concatMatrix = Matrix4Math.multiply( _concatMatrix, _aRenderMatrix[i] );
			
			_tMatrix = _concatMatrix;
			_concatMatrix = new Matrix4();
			_modified = true;
			
			if(_aInterpolator[l].getProgress() == 1 )
				_waitEndEventBeforeNextRender = true;
			else
				_canRender = true;//rendering done for the current frame, ready for the next
			
			//we get the percent from the longer interpolation.
			_eOnProgress.setPercent(_longer_interpol.getPercent());
			broadcastEvent( _eOnProgress );
		}
	}
	
	/**
	 * Method called when parallel received an event (onEndEVENT) from an interpolator which is being listening.
	 */
	private function __onEnd( eventC:InterpolationEvent )
	{
		if(_waitEndEventBeforeNextRender)
		{
			_canRender = true;
			_waitEndEventBeforeNextRender = false;
		}
		if(_way == 1) 
		{
			_nb_ended_interpol++;
			if(_nb_ended_interpol == _aInterpolator.length)
			{
				_finished = true;
				_frame = _duration;
				broadcastEvent( _eOnEnd );
			}
		}
		else
		{
			_nb_ended_interpol_yoyo++;
			//we make a rendezvous point for all of the ending interpolation
			if(_nb_ended_interpol_yoyo == _aInterpolator.length) //we wait for the end of all of them
			{
				_finished = true;
				_frame = -1;
				broadcastEvent( _eOnEnd );
			}
		}
	}
	
	/**
	 * Add an Interpolator.
	 * @param Interpolator3D : the interpolator we want to add to the interpolation
	 * @return Void
	 */
	public function addChild( i:Interpolator3D )
	{
		World3D.getInstance().removeEventListener( World3D.onRenderEVENT, i );
		
		_aInterpolator.push(i);
		_aIntoDur.push(i.getDuration());
		//we need to know which interpolator is the longer, thus we compare.
		if( i.getDuration() > _duration)
		{
			_originalDuration = _duration = i.getDuration();
			_longer_interpol = i;
		}
		
		//we had a new matrix to the the temporary render Array
		_aRenderMatrix.push(new Matrix4());
		
		//we process the new start and end matrix.
		processStartEndMatrix();
		
		//we plug the new interpolator with parallel
		this.addEventListener( Parallel3D.onRenderEVENT, i, i['__render'] );	
		i.addEventListener( InterpolationEvent.onProgressEVENT, this, __onProgress );
		i.addEventListener( InterpolationEvent.onEndEVENT, this, __onEnd );
		
		//after the child we update the sequence in case of a paused state, to be able to render it at the right place
		_tMatrix = _startMatrix;
		_modified = true;
	}
	
	/**
	 * Process start and end matrix of the interpolator.
	 */
	private function processStartEndMatrix()
	{
		_startMatrix = Matrix4Math.multiply(_startMatrix, _aInterpolator[_aInterpolator.length-1].getStartMatrix());
		_endMatrix = Matrix4Math.multiply(_endMatrix, _aInterpolator[_aInterpolator.length-1].getEndMatrix());
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
		
		var previous_dur:Number = _duration;
		
		_duration = Math.floor(t);
		
		var coef:Number = _duration / _originalDuration;
		
		var l:Number = _aInterpolator.length;
		while( --l > -1 ) _aInterpolator[l].setDuration( Math.round(_aIntoDur[l]*coef) );
		
		if(_frame <= 0)
		{
			//
		}
		else if(_frame == previous_dur)
		{
			_frame = _duration;
		}
		else if(_frame == previous_dur-1)
		{
			_frame = _duration-1;
		}
		else _frame = _longer_interpol.getFrame()-1;
		
		_nb_ended_interpol = 0;
		l = _aInterpolator.length;
		while( --l > -1 )
		{
			if( _frame+_way >= _aInterpolator[l].getDuration() )
			{
				_aInterpolator[l].pause();
				_nb_ended_interpol++;
				_aRenderMatrix[l] = _aInterpolator[l].getEndMatrix();
				_aInterpolator[l].setFinal();
			}
			else _aInterpolator[l].resume();
		}
	}
	
	public function setFinal( Void ) : Void
	{
		_frame = _duration;
		var l:Number = _aInterpolator.length;
		while( --l > -1 ) _aInterpolator[l].setFinal();
		
		_nb_ended_interpol = _aInterpolator.length;
		_nb_ended_interpol_yoyo = 0;
		_tMatrix = _endMatrix;
		
		_concatMatrix = new Matrix4();
	}
	
	public function setInitial( Void ) : Void
	{
		_frame = -1;
		var l:Number = _aInterpolator.length;
		while( --l > -1 ) _aInterpolator[l].setInitial();
		
		_nb_ended_interpol = 0;
		_tMatrix = _startMatrix;
		
		_concatMatrix = new Matrix4();
	}
	
	/**
	 * Set the interpolation duration in number of frames. Could be lower than 5!
	 * @param Void
	 * @return Number of frame corresponding to the durationoh the interpolator
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
	 * Get the end matrix of the interpolator.
	 * @param Void
	 * @return Matrix4
	 */
	public function getEndMatrix( Void ):Matrix4
	{
		return _endMatrix;
	}
	
	/**
	 * Get the start matrix of the interpolator.
	 * @param Void
	 * @return Matrix4
	 */
	public function getStartMatrix( Void ):Matrix4
	{
		return _startMatrix;
	}
	
	public function getFrame( Void ):Number
	{
		return _longer_interpol.getFrame();
	}
	
	/**
	* redo
	* <p>Make the interpolation starting again</p>
	*/
	public function redo( Void ):Void
	{
		var l:Number = _aInterpolator.length;
		while( --l > -1 )
		{
			_aInterpolator[l].redo();
			if(_way == 1) _aInterpolator[l].resume();
			else 
			{
				_aInterpolator[l].pause();
				_aRenderMatrix[l] = _aInterpolator[l].getEndMatrix();
			}
		}
		
		_canRender = true;
		_finished = false;
		
		if(_way==1)
		{
			_nb_ended_interpol = 0;
			_frame = -1;
			_tMatrix = _startMatrix;
		}
		else
		{
			_nb_ended_interpol = _aInterpolator.length;
			_nb_ended_interpol_yoyo = 0;
			_frame = _duration;
			_tMatrix = _endMatrix;
		}
		_concatMatrix = new Matrix4();
		if( _paused ) _modified = true;
	}
	
	/**
	* yoyo
	* <p>Make the interpolation going in the inversed way</p>
	*/
	public function yoyo( Void ):Void
	{
		_way = -_way;
		var l:Number = _aInterpolator.length;
		_canRender = true;
		_nb_ended_interpol = 0;
		
		if( _finished )
		{
			if(_way == -1)
			{
				while( --l > -1 ) //on reprend l'animation sans mettre en pause la/les plus longues.
				{
					_aInterpolator[l].yoyo();
					if( _frame > _aInterpolator[l].getDuration() )
					{
						_aInterpolator[l].pause();
						_aRenderMatrix[l] = _aInterpolator[l].getEndMatrix();
						_nb_ended_interpol++;
					}
					else _aInterpolator[l].resume();
				}
				_nb_ended_interpol_yoyo = 0;
				_frame = _duration;
			}
			else
			{
				while( --l > -1 ) 
				{
					_aInterpolator[l].yoyo();
					_aInterpolator[l].resume();
				}
				_frame = -1;
			}
			
			_concatMatrix = new Matrix4();
			_tMatrix =  (_way == 1)? _startMatrix : _endMatrix;
			_finished = false;
		}
		else if( !_finished )
		{
			if( !isFinalState() && !isInitialState() )
			{
				while( --l > -1 )
				{
					_aInterpolator[l].yoyo();
					if( _way == 1)
					{
						if( _frame >= _aInterpolator[l].getDuration()-1 )
						{
							_aInterpolator[l].pause();
							if( _way == 1) _aInterpolator[l].setFinal();
							_aRenderMatrix[l] = _aInterpolator[l].getEndMatrix();
							_nb_ended_interpol++;
						}
						else _aInterpolator[l].resume();
					}
					else
					{
						if( _frame > _aInterpolator[l].getDuration()-1 )
						{
							_aInterpolator[l].pause();
							_aRenderMatrix[l] = _aInterpolator[l].getEndMatrix();
							_nb_ended_interpol++;
						}
						else _aInterpolator[l].resume();
						if(_aInterpolator[l].isFinalState() && _frame == _aInterpolator[l].getDuration()-1 )
						{
							_aInterpolator[l].skipNextFrame();
						}
					}
				}
				if(_way == -1) _nb_ended_interpol_yoyo = 0;
				_concatMatrix = new Matrix4();
			}
			else if( isFinalState() )
			{
				if( _way == 1) //CAS SPECIAL : way == 1 a la frame duration
				{
					while( --l > -1 )
					{
						_aInterpolator[l].yoyo();
						if( _frame > _aInterpolator[l].getDuration() )
						{
							_aInterpolator[l].pause();
							_aRenderMatrix[l] = _aInterpolator[l].getEndMatrix();
							_nb_ended_interpol++;
						}
						else _aInterpolator[l].resume();
					}
				}
				else
				{
					while( --l > -1 )
					{
						_aInterpolator[l].yoyo();
						_aInterpolator[l].pause();
						_aRenderMatrix[l] = _aInterpolator[l].getEndMatrix();
					}
					_nb_ended_interpol = _aInterpolator.length;
					_nb_ended_interpol_yoyo = 0;
					_frame = _duration;
				}
			}
			else if( isInitialState() )
			{
				if( _way == -1 ) //CAS SPECIAL : way == -1 a la frame -1
				{
					while( --l > -1 ) 
					{
						_aInterpolator[l].yoyo();
						_aInterpolator[l].resume();
					}
					_nb_ended_interpol_yoyo = 0;
				}
				else
				{
					while( --l > -1 ) 
					{
						_aInterpolator[l].yoyo();
						_aInterpolator[l].resume();
					}
					_frame = -1;
				}
			}
		}
	}	
	
	/**
	* Returns the percent of the interpolator. 0 is the beginning, and 100 is the end.
	* @param	Void
	* @return a Number between [0-1] corresponding on the percentage of the interpolation progress.
	*/
	public function getPercent( Void ) : Number
	{		
		return _longer_interpol.getPercent();
	}

	/**
	* Returns the progression of the interpolator. 0 is the beginning, and 1 is the end.
	* @param	Void
	* @return a Number between [0-1] corresponding on the percentage of the interpolation progress.
	*/
	public function getProgress( Void ) : Number
	{
		return _longer_interpol.getProgress();
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
		return 'sandy.core.transform.Parallel3D';
	}
	
	public function destroy(Void) : Void 
	{
		var l:Number = _aInterpolator.length;
		while( --l > -1 ) _aInterpolator[l].destroy();
			
		delete _aInterpolator;
		
		_oEB.removeAllEventListeners(InterpolationEvent.onEndEVENT);
		_oEB.removeAllEventListeners(InterpolationEvent.onProgressEVENT);
		_oEB.removeAllEventListeners(InterpolationEvent.onResumeEVENT);
		_oEB.removeAllEventListeners(InterpolationEvent.onPauseEVENT);
		_oEB.removeAllEventListeners(Parallel3D.onRenderEVENT);
		_oEB.removeAllListeners();
	}
	
	public function addEventListener(t:EventType, oL) : Void
	{
		_oEB.addEventListener.apply( _oEB, arguments );
	}

	public function removeEventListener(t:EventType, oL) : Void
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
	
	public function isFinished( Void ):Boolean
	{
		return _finished;
	}
	
	public function isPaused( Void ):Boolean
	{
		return _paused;
	}
	
	public function getName( Void ):String
	{
		return _name;
	}
	
	//////////////
	/// PRIVATE
	//////////////

	private var _paused:Boolean;
	private var _finished:Boolean;
	private var _blocked:Boolean;
	private var _modified:Boolean;
	private var _canRender:Boolean;
	private var _waitEndEventBeforeNextRender:Boolean;
	
	private var _eOnPause:InterpolationEvent;
	private var _eOnResume:InterpolationEvent;
	private var _eOnRender:InterpolationEvent;
	private var _eOnProgress:InterpolationEvent;
	private var _eOnEnd:InterpolationEvent;
	
	private var _oEB:EventBroadcaster;
	
	private var _aInterpolator:Array; 	//interpolator array
	private var _longer_interpol:Interpolator3D;
	
	private var _way:Number; 		//direction (1:normal, -1:reverse)
	
	private var _tMatrix:Matrix4;
	private var _concatMatrix:Matrix4;
	private var _aRenderMatrix:Array;
	private var _startMatrix:Matrix4;
	private var _endMatrix:Matrix4;
	
	private var _duration:Number;
	private var _originalDuration:Number;
	private var _aIntoDur:Array;
	private var _nb_render_done:Number;
	private var _nb_ended_interpol:Number;
	private var _nb_ended_interpol_yoyo:Number;
	
	private var _frame:Number;
	private var _name:String;
}