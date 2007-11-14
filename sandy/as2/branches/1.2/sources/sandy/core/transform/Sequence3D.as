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
* Sequence3D
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Thomas Balitout - samothtronicien
* @since		1.1
* @version		1.2.2
* @date 		26.05.2007
*/

class sandy.core.transform.Sequence3D implements Interpolator3D
{
	/**
	 *  The Interpolation render Event. Broadcasted when the Sequence3D had to be rendered.
	 */
	public static var onRenderEVENT:EventType = new EventType( "onRender" );
	
	/**
	 * Create a new Sequence3D.
	 * <p> This class realise an interpolation resulting in a sequence of interpolation.</p>
	 */	
	public function Sequence3D( n:String ) 
	{	
		_name = (n == undefined)?"Sequence3D":n;
		_paused = _finished = _blocked = _modified = _plugTheNext = false;
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
		
		_originalDuration = _totalDuration = 0;
		_aIntoDur = new Array();
		_frame = -1;
		World3D.getInstance().addEventListener(World3D.onRenderEVENT, this, __render);
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
	
	public function isFinished( Void ):Boolean
	{
		return _finished;
	}
	
	public function isPaused( Void ):Boolean
	{
		return _paused;
	}
	
	/*
	* Method called when the interpolation had to be rendered.
	* */
	private function __render( Void ):Void
	{
		if( false == _paused && false == _finished )
		{
			_frame = (_way == -1) ? (_frame-1 >= 0) ? _frame-1 : 0 : (_frame+1 <= _totalDuration-1) ? _frame+1 : _totalDuration-1;
			if( _plugTheNext )
			{
				plugTheNextInterpolator();
				_plugTheNext = false;
			}
			broadcastEvent( _eOnRender );
		}
	}
	
	public function getFrame( Void ):Number
	{
		var l:Number = _current_index;
		var calculated_frame:Number = _ci.getFrame();
		while( --l > -1) 
			calculated_frame += _aInterpolator[l].getDuration();
		return calculated_frame;
	}
	
	public function getName( Void ):String
	{
		return _name;
	}
	
	/**
	 * Method called when sequence received an event (onProgressEVENT) from an interpolator which is being listening.
	 */
	private function __onProgress( eventC:InterpolationEvent )
	{
		_eOnProgress.setPercent(getPercent());
		
		_tMatrix = Matrix4Math.multiply( _concatMatrix, _ci.getMatrix());
		_modified = true;
		
		broadcastEvent( _eOnProgress );
	}
	
	/**
	 * Method called when sequence received an event (onEndEVENT) from an interpolator which is being listening.
	 */
	private function __onEnd( eventC:InterpolationEvent )
	{
		if( ! thereIsANextInterpolator() )
		{
			_finished = true;
			(_way == 1) ? _frame = _totalDuration : _frame = -1;
			broadcastEvent( _eOnEnd );
		}
		else _plugTheNext = true;
	}
	
	/**
	 * Try to plug, on the next interpolator considering the direction.
	 * @param Void
	 * @return Boolean : true if the current intrepolator isn't the last of the sequence, else false.
	 */
	private function thereIsANextInterpolator( Void ) : Boolean
	{
		if( (_way == 1 && _current_index == (_aInterpolator.length-1)) || (_way == -1 &&_current_index == 0)) return false;
		return true;
	}
	
	/**
	 * Plug the next interpolator considering the direction.
	 * @param Void
	 * @return Void
	 */
	private function plugTheNextInterpolator( Void ) : Void
	{
		unplugCurrentInterpolator();
		_current_index += _way;
		_concatMatrix = _aMatrix[_current_index];
		plugInterpolator( _aInterpolator[_current_index] );
	}
	
	/**
	* Unplug the current interpolator.
	*/
	private function unplugCurrentInterpolator( Void ) : Void
	{
		if(_current_index != -1) unplugInterpolator( _ci );
	}
	
	/**
	 * Add an interpolator to the sequence.
	 * @param Interpolator3D
	 * @return Void
	 */
	public function addChild( i:Interpolator3D )
	{
		World3D.getInstance().removeEventListener( World3D.onRenderEVENT, i );
		
		_aInterpolator.push(i);
		_originalDuration = _totalDuration += i.getDuration();
		
		_aIntoDur.push(i.getDuration());
		
		if( _aInterpolator.length == 1 ) //this is the first child
		{
			_current_index = 0;
			plugInterpolator( _aInterpolator[_current_index] );
			_aMatrix.push( new Matrix4() );
			_concatMatrix = _aMatrix[0];
			_aMatrix.push( i.getEndMatrix() );
			//after we add the child we update the sequence in case of a paused state, to ba able to render it at the right place
			_tMatrix = Matrix4Math.multiply( _concatMatrix, _ci.getMatrix());
			_modified = true;
		}
		else _aMatrix.push( Matrix4Math.multiply( _aMatrix[_aMatrix.length-1], i.getEndMatrix() ) );
	}
	
	/**
	 * Resize the total duration in number of frames with the one giving in parameter.
	 * @param Number the duration in number of frames
	 * @return Void
	 */
	public function setDuration( t:Number ):Void
	{
		if( t == Number.POSITIVE_INFINITY || t > 10000 ) t = 10000;
		else if( t < 5 ) t = 5;
		
		var previous_total_dur:Number = _totalDuration;
		
		_totalDuration = Math.floor(t);
		
		var coef:Number = _totalDuration / _originalDuration;
		var l:Number = _aInterpolator.length;
		var i:Number = 0;
		var aInt:Array = new Array();
		while( i < l ) //ici on les range dans l'ordre dans le tableau !!!
		{
			var tmp:Object = new Object();
			tmp.val = _aIntoDur[i]*coef;
			tmp.pr = 'N';
			aInt.push(tmp);
			i++;
		}
		var finished:Boolean = false;
		while(!finished)
		{
			var maxIndex:Number = -1;
			var maxValue:Number = 0;
			l = _aInterpolator.length;
			while( --l > -1 ) 
			{
				if(aInt[l].pr == 'N')
				{
					var current:Number = aInt[l].val - Math.floor(aInt[l].val);
					if(current > maxValue)
					{	
						maxValue = current;
						maxIndex = l;
					}
				}
			}
			if(maxIndex == -1) break;
			aInt[maxIndex].pr = 'O';
			var need:Number = 1-maxValue;
			var needSatisfied:Boolean = false;
			while(!needSatisfied)
			{
				var minIndex:Number = -1;
				var minValue:Number = 1;
				l = _aInterpolator.length;
				while( --l > -1) 
				{
					if(aInt[l].pr == 'N')
					{
						var current:Number = aInt[l].val - Math.floor(aInt[l].val);
						if(current < minValue) 
						{
							minValue = current;
							minIndex = l;
						}
					}
				}
				if(minIndex == -1)
				{
					aInt[maxIndex].pr = 'O';
					aInt[maxIndex].val = Math.round(aInt[maxIndex].val);
					break;
				}
				if((minValue - need) == 0) 
				{
					aInt[minIndex].pr = "O";
					aInt[minIndex].val -= minValue;
					aInt[maxIndex].val += need;
					needSatisfied = true;
				}
				else if((minValue - need) > 0)
				{
					aInt[minIndex].val -= need;
					aInt[maxIndex].val += need;
					needSatisfied = true;
				}
				else
				{
					aInt[minIndex].pr = "O";
					aInt[maxIndex].val += minValue;
					need -= minValue;
					aInt[minIndex].val -= minValue;
				}
			}
			l = _aInterpolator.length;
			finished = true;
			while( --l > -1) 
			{
				if(aInt[l].pr != "O")
				{
					finished = false;
					break;
				}
			}
		}
		l = _aInterpolator.length;
		while( --l > -1 ) 
		{
			_aInterpolator[l].setDuration( Math.round(aInt[l].val) )
		}
		
		if(_frame <= 0)
		{
			//
		}
		else if(_frame == previous_total_dur)
		{
			_frame = _totalDuration;
		}
		else if(_frame == previous_total_dur-1)
		{
			_frame = _totalDuration-1;
		}
		else _frame = getFrame()-1;
		
		_tMatrix = Matrix4Math.multiply( _concatMatrix, _ci.getMatrix());
		_modified = true;
	}
	
	public function isInitialState( Void ):Boolean
	{
		return _frame == -1;
	}
	
	public function isFinalState( Void ):Boolean
	{
		return _frame == _totalDuration;
	}
	
	public function setFinal( Void ) : Void
	{
		_frame = _totalDuration;
		_plugTheNext = false;
		var l:Number = _aInterpolator.length;
		while( --l > -1 ) _aInterpolator[l].setFinal();
		
		if( _finished == false ) unplugCurrentInterpolator();
		
		_current_index = _aInterpolator.length-1;
		
		_concatMatrix = _aMatrix[_current_index];
		plugInterpolator( _aInterpolator[_current_index] );
	}
	
	public function setInitial( Void ) : Void
	{
		_frame = -1;
		_plugTheNext = false;
		var l:Number = _aInterpolator.length;
		while( --l > -1 ) _aInterpolator[l].setInitial();
		
		if( _finished == false ) unplugCurrentInterpolator();
		
		_current_index = 0;
		
		_concatMatrix = _aMatrix[_current_index];
		plugInterpolator( _aInterpolator[_current_index] );
	}
	
	/**
	 * Get the interpolation duration in number of frames.
	 * @param Void
	 * @return Number of frame corresponding to the duration of the sequence.
	 */
	public function getDuration ( Void ):Number
	{
		return _totalDuration;
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
	
	private function plugInterpolator( i:Interpolator3D )
	{
		_ci = i;
		this.addEventListener( Sequence3D.onRenderEVENT, _ci, _ci['__render']);	
		_ci.addEventListener( InterpolationEvent.onProgressEVENT, this, __onProgress );
		_ci.addEventListener( InterpolationEvent.onEndEVENT, this, __onEnd );
	}
	
	private function unplugInterpolator( i:Interpolator3D )
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
	
	/**
	* redo
	* <p>Make the interpolation starting again</p>
	*/
	public function redo( Void ):Void
	{
		var l:Number = _aInterpolator.length;
		while( --l > -1 ) _aInterpolator[l].redo();
		
		unplugCurrentInterpolator();
		
		if(_way == 1) _current_index = 0;
		else _current_index = _aInterpolator.length-1;
		
		_concatMatrix = _aMatrix[_current_index];
		plugInterpolator( _aInterpolator[_current_index] );
		
		if(_paused)
		{
			if(_way == 1) _tMatrix = getStartMatrix();
			else _tMatrix = getEndMatrix();
			_modified = true;
		}
		
		_plugTheNext = false;
		_frame = ( _way == 1 ) ? -1 : _totalDuration;
		_finished = false;
	}
	
	public function skipNextFrame( Void ) : Void
	{
		_frame += _way;
		if( _ci.isInitialState() || _ci.isFinalState() ) _ci.skipNextFrame();
	}
	
	/**
	* yoyo
	* <p>Make the interpolation going in the inversed way</p>
	*/
	public function yoyo( Void ):Void
	{
		_plugTheNext = false;
		_way = -_way;
		var l:Number = _aInterpolator.length;
		while( --l > -1 ) _aInterpolator[l].yoyo();
		
		if(! _finished )//verifier yoyo aux extrémités de la sequence
		{
			if( ! isFinalState() && ! isInitialState() )
			{
				
				if( _ci.getProgress() == 0 )
				//ici aucun branchement, c'est uniquement quand on est a la fin et qu'on fait un yoyo, 
				//il faut donc passer les frames -1 et duration.
				{
					if( _way == 1 && _ci.isInitialState() ) _ci.skipNextFrame();
					else if( _way == -1 && _ci.isFinalState() ) _ci.skipNextFrame();
				}
				else if( _ci.getProgress() == 1 )
				//ici on va devoir se brancher sur le suivant.
				{
					var skip:Boolean = false;
					if( _way == 1 ) 
					{
						if(_ci.isFinalState()) skip = true;
						_ci.setFinal();
					}
					else
					{ 
						if(_ci.isInitialState()) skip = true;
						_ci.setInitial();
					}
					if( thereIsANextInterpolator() )//doit tjs renvoyer true car on est dans l'état "( ! isFinalState() && ! isInitialState() )"
					{
						plugTheNextInterpolator();
						if(skip) _ci.skipNextFrame();
					}
				}
			}
		}
		else if( _finished )
		{
			_frame = ( _way == 1 ) ? -1 : _totalDuration;
			_finished = false;
		}
	}
	
	/**
	* Returns the progression of the interpolator. 0 is the beginning, and 1 is the end.
	* @param	Void
	* @return a Number between [0-1] corresponding on the percentage of the interpolation progress.
	*/
	public function getProgress( Void ) : Number
	{
		var p:Number;
		
		if(_way == 1) 	p = _current_index + _ci.getProgress();
		else 		p = _aInterpolator.length - (_current_index + 1) + _ci.getProgress(); 
				
		return ( p / _aInterpolator.length );
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
	
	//////////////
	/// PRIVATE
	//////////////

	private var _paused:Boolean;
	private var _finished:Boolean;
	private var _blocked:Boolean;
	private var _modified:Boolean;
	private var _plugTheNext:Boolean;
	
	private var _eOnPause:InterpolationEvent;
	private var _eOnResume:InterpolationEvent;
	private var _eOnRender:InterpolationEvent;
	private var _eOnProgress:InterpolationEvent;
	private var _eOnEnd:InterpolationEvent;
	
	private var _oEB:EventBroadcaster;
	
	private var _totalDuration:Number; //duration of the sequence
	private var _originalDuration:Number; //original duration of the sequence
	
	private var _aIntoDur:Array; //original duration for each interpolation of the sequence
	private var _aInterpolator:Array; 	//tableau des interpolations
	private var _ci:Interpolator3D; 	//référence sur l'interpolation courante (plus rapide)
	
	private var _current_index:Number; 	//index de l'interpolation courante (0 à n-1)
	private var _way:Number; 		//direction de parcours de l'interpolation (1:normal, -1:inverse)
	private var _frame:Number;
	private var _name:String;
	
	private var _tMatrix:Matrix4;
	private var _concatMatrix:Matrix4; //matrices qui contient l'etat intermediaire courant de l'interpolation
	private var _aMatrix:Array; 		//les différentes matrices intermédiaires précalculées.
}
