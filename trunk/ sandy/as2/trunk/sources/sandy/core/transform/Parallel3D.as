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
import sandy.util.NumberUtil;
import sandy.events.InterpolationEvent;

import com.bourre.events.EventBroadcaster;
import com.bourre.events.IEvent;
import com.bourre.events.EventType;
import com.bourre.log.*;
import com.bourre.events.BasicEvent;


/**
* @author		Samothtronicien
* @version		1.0
* @date 		05.11.2006
**/
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
	public function Parallel3D( Void ) 
	{	
		_paused = _finished = _blocked = _modified = false;
		_way = 1;

		_aInterpolator = new Array();
		_longer_interpol = null;

		_oEB = new EventBroadcaster( this );
		_eOnResume = new InterpolationEvent( InterpolationEvent.onResumeEVENT, this, getType(), 0 );
		_eOnPause = new InterpolationEvent( InterpolationEvent.onPauseEVENT, this, getType(), 0 );
		_eOnRender = new InterpolationEvent( Parallel3D.onRenderEVENT, this, getType(), 0 );
		_eOnProgress = new InterpolationEvent( InterpolationEvent.onProgressEVENT, this, getType(), 0 );
		_eOnEnd = new InterpolationEvent( InterpolationEvent.onEndEVENT, this, getType(), 1 );
	
		_tMatrix = null;
		_concatMatrix = new Matrix4();
		_aRenderMatrix = new Array();
		
		_duration = _nb_render_done = _nb_ended_interpol = _frame = 0;
		_startMatrix = new Matrix4();
		_endMatrix = new Matrix4();
	
		World3D.getInstance().addEventListener(World3D.onStartEVENT, this, __onWorldStart );
		World3D.getInstance().addEventListener(World3D.onStopEVENT, this, __onWorldStop );
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __render );
	}
	
	private function __onWorldStart( e:BasicEvent ):Void
	{
		//World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __render );
	}
	
	private function __onWorldStop( e:BasicEvent ):Void
	{
		//World3D.getInstance().removeEventListener( World3D.onRenderEVENT, this );
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
		var iInt:Interpolator3D;
		if( false == _paused && false == _finished)
		{
			delete _concatMatrix;
			_concatMatrix = Matrix4.createIdentity();
			var i:Number, l:Number = _aInterpolator.length;
			for( i = 0; i < l; i++ )
			{
			 	iInt = _aInterpolator[i];
			 	if( iInt.isPaused() )
			 	{
			 		Logger.LOG(i+" en pause a la frame : "+_frame+" de durée:"+iInt.getDuration() );
			 		if( _way == 1 || ( _way == -1 && _frame == iInt.getDuration() ) )
			 		{
			 			Logger.LOG("On reveille l'interpolateur a la frame : "+_frame);
			 			iInt.resume();
			 		}
			 	}
			 	// -- 
			 	iInt['__render']();
			 	_concatMatrix = Matrix4Math.multiply( _concatMatrix, iInt.getMatrix() );
			}
			// --
			_tMatrix = _concatMatrix;
			_concatMatrix = new Matrix4();
			//  --
			_frame = _longer_interpol.getFrame();
			_modified = true;
			// --
			_eOnProgress.setPercent(_longer_interpol.getPercent());
			broadcastEvent( _eOnProgress );
		}
	}
	
	/**
	 * Method called when parallel received an event (onEndEVENT) from an interpolator which is being listening.
	 */
	private function __onEnd( eventC:InterpolationEvent ):Void
	{
		_nb_ended_interpol ++;
		//we make a rendezvous point for all of the ending interpolation
		if(_nb_ended_interpol == _aInterpolator.length) //we wait for the end of all of them
		{
			//NumberUtil.constrain(_frame + _way, 0, _duration );
			_finished = true;
			broadcastEvent( _eOnEnd );
			Logger.LOG("Animation finie, de durée : "+_duration);
		}
	}
	
	/**
	 * Add an Interpolator.
	 * @param Interpolator3D : the interpolator we want to add to the interpolation
	 * @return Void
	 */
	public function addChild( i:Interpolator3D ):Void
	{
		_aInterpolator.push(i);
		//we need to know which interpolator is the longer, thus we compare.
		if( i.getDuration() > _duration)
		{
			_duration = i.getDuration();
			_longer_interpol = i;
		}
		//we had a new matrix to the the temporary render Array
		_aRenderMatrix.push(new Matrix4());
		//we process the new start and end matrix.
		processStartEndMatrix();
		//we plug the new interpolator with parallel
		World3D.getInstance().removeEventListener( World3D.onRenderEVENT, i );
		i.addEventListener( InterpolationEvent.onEndEVENT, this, __onEnd );
	}
	
	/**
	 * Process start and end matrix of the interpolator.
	 */
	private function processStartEndMatrix(Void):Void
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
		
		var old_duration:Number = _duration ;
		_duration = 1 / t;
		
		var coef:Number = _duration / old_duration;
		
		var l:Number = _aInterpolator.length;
		while( --l > -1 ) _aInterpolator[l].setDuration( _aInterpolator[l].getDuration()*coef );
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
	
	public function getDurationElapsed(Void):Number 
	{
		return _longer_interpol.getDurationElapsed();
	}

	public function getDurationRemaining(Void):Number 
	{
		return _longer_interpol.getDurationRemaining();
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
	
	public function getMatrix( Void ):Matrix4
	{
		return _tMatrix;
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
			_aInterpolator[l].pause();
		}
		// --
		_concatMatrix = new Matrix4();
		_nb_ended_interpol = 0;
		// --
		if( _way == -1 )  _frame = _duration;
		else _frame = 0;
		// --
		_finished = false;
	}
	
	/**
	* yoyo
	* <p>Make the interpolation going in the inversed way</p>
	*/
	public function yoyo( Void ):Void
	{
		var l:Number = _aInterpolator.length;		
		while( --l > -1 )
		{
			if( _aInterpolator[l].isFinished() ) 
			{
				_aInterpolator[l].pause();
			}
			_aInterpolator[l].yoyo();
		}
		// --
		_way = -_way;
		_concatMatrix = new Matrix4();
		_nb_ended_interpol = 0;
		_finished = false;
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

	public function getFrame(Void) : Number 
	{
		return _longer_interpol.getFrame();
	}
	
	public function isPaused(Void) : Boolean 
	{
		return _paused;
	}

	public function isFinished(Void) : Boolean
	{
		
		return _finished;
	}
	
	public function isModified( Void ):Boolean
	{
		return _modified;
	}
	
	public function setModified( b:Boolean ):Void
	{
		_modified = b;
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
	
	private var _aInterpolator:Array; 	//interpolator array
	private var _longer_interpol:Interpolator3D;
	
	private var _way:Number; 		//direction (1:normal, -1:reverse)
	
	private var _tMatrix:Matrix4;
	private var _concatMatrix:Matrix4;
	
	private var _aRenderMatrix:Array;
	
	private var _modified:Boolean;

	private var _startMatrix:Matrix4;
	private var _endMatrix:Matrix4;
	
	private var _duration:Number;
	
	private var _nb_render_done:Number;
	private var _nb_ended_interpol:Number;
	
	private var _frame:Number;
}