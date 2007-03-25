package sandy.core.transform 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import sandy.core.data.Matrix4;
	import sandy.core.transform.Interpolator3D;
	import sandy.core.transform.TransformType;
	import sandy.core.World3D;
	import sandy.events.SandyEvent;
	import sandy.math.Matrix4Math;

	public class Sequence3D extends Transform3D implements Interpolator3D
	{
		private var _modified:Boolean;
		
		/**
		 * Create a new TranslationInterpolator.
		 * <p> This class realise an interpolation resulting in a sequence of interpolation.</p>
		 */	
		public function Sequence3D() 
		{	
			_paused = _finished = _blocked = _modified = false;
			_way = 1;
			_current_index = -1;
			_aInterpolator = new Array();
			_ci = null;

			_tMatrix = _concatMatrix = null;
			_aMatrix = new Array();
			_totalDuration = 0;
			_frame = 0;
			
			World3D.getInstance().addEventListener( SandyEvent.RENDER, __render );
		}
		
		/**
		 * Make a pause in the Interpolation. You can continue the motion later with resume method.
		 * Broadcast an InterpolationEvent.
		 */
		public function pause():void
		{
			_paused = true;
			dispatchEvent( pauseEvent );
		}
		
		/**
		 * Resume the motion after it was paused. Broadcast an InterpolationEvent.
		 */
		public function resume():void
		{
			_paused = false;
			dispatchEvent( resumeEvent );
		}
		
		/*
		* Method called when the interpolation had to be rendered.
		* */
		private function __render(e:Event):void
		{
			trace(_frame);
			if( !_paused && !_finished )
			{
				_frame += _way;
				dispatchEvent( renderEvent );
			}
		}
		
		/**
		 * Method called when sequence received an event (onProgressEVENT) from an interpolator which is being listening.
		 */
		private function __onProgress( eventC:Event ):void
		{
			_tMatrix = Matrix4Math.multiply( _concatMatrix, _ci.getMatrix());
			_modified = true;
			
			dispatchEvent( progressEvent );
		}
		
		/**
		 * Method called when sequence received an event (onEndEVENT) from an interpolator which is being listening.
		 */
		private function __onEnd( eventC:Event):void
		{
			if( ! plugOnNextInterpolator() )
			{
				_finished = true;
				dispatchEvent( endEvent );
			}
		}
		
		/**
		 * Try to plug, on the next interpolator considering the direction.
		 * @param void
		 * @return Boolean : true if the current intrepolator isn't the last of the sequence, else false.
		 */
		private function plugOnNextInterpolator() : Boolean
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
			
			_concatMatrix = _aMatrix[int(_current_index)];
			plugInterpolator( _aInterpolator[int(_current_index)] );
			
			return true;
		}
		
		/**
		* Unplug the current interpolator.
		*/
		private function unplugCurrentInterpolator() : void 
		{
			if(_current_index != -1) unplugInterpolator( _ci );
		}
		
		
		/**
		 * Add an interpolator to the sequence.
		 * @param Interpolator3D
		 * @return void
		 */
		public function addChild( i:BasicInterpolator ) : void 
		{
			// Remove interpolator from main rendering loop 
			World3D.getInstance().removeEventListener( SandyEvent.RENDER, i.__render );
			
			_aInterpolator.push(i);
			_totalDuration += i.getDuration();
			
			if( _aInterpolator.length == 1 )
			{
				_current_index = 0;
				plugInterpolator( _aInterpolator[int(_current_index)] );
				_aMatrix.push( new Matrix4() );
				_concatMatrix = _aMatrix[0];
				_aMatrix.push( i.getEndMatrix()  );
			}
			else _aMatrix.push( Matrix4Math.multiply( _aMatrix[_aMatrix.length-1], i.getEndMatrix() ) );
		}
		
		/**
		 * Resize the total duration in number of frames with the one giving in parameter.
		 * @param Number the duration in number of frames
		 * @return void
		 */
		public function setDuration ( t:Number ):void
		{
			if( t == Number.POSITIVE_INFINITY || t > 10000 ) t = 10000;
			else if( t < 5 ) t = 5;
			
			_totalDuration = t;
			
			var sum:Number = 0;
			var l:int = _aInterpolator.length;
			while( --l > -1 ) sum += _aInterpolator[int(l)].getDuration();

			var coef:Number = _totalDuration / sum;
			l = _aInterpolator.length;
			while( --l > -1 ) _aInterpolator[l].setDuration( _aInterpolator[int(l)].getDuration()*coef );
		}
		
		/**
		 * Set the interpolation duration in number of frames. Could be lower than 5!
		 * @param void
		 * @return Number of frame corresponding to the durationoh the interpolator
		 */
		public function getDuration ():Number
		{
			return _totalDuration;
		}
		
		private function plugInterpolator( i:BasicInterpolator ) : void 
		{
			_ci = i;
			addEventListener( SandyEvent.RENDER, i.__render);	
			i.addEventListener( SandyEvent.PROGRESS, __onProgress );
			i.addEventListener( SandyEvent.END, __onEnd );
		}
		
		private function unplugInterpolator( i:BasicInterpolator ) : void 
		{
			removeEventListener( SandyEvent.RENDER, i.__render);	
			i.removeEventListener( SandyEvent.PROGRESS, __onProgress );
			i.removeEventListener( SandyEvent.END, __onEnd );
		}
		
		/**
		 * Get the end matrix of the interpolator.
		 * @param void
		 * @return Matrix4
		 */
		public function getEndMatrix():Matrix4
		{
			return _aMatrix[int(_aMatrix.length-1)];
		}
		
		/**
		 * Get the start matrix of the interpolator.
		 * @param void
		 * @return Matrix4
		 */
		public function getStartMatrix():Matrix4
		{
			return _aInterpolator[0].getStartMatrix();
		}

		public function getFrame(): Number 
		{
			return _frame;
		}
			
		/**
		* redo
		* <p>Make the interpolation starting again</p>
		*/
		public function redo():void
		{
			var l:int = _aInterpolator.length;
			while( --l > -1 ) _aInterpolator[int(l)].redo();
			
			if(!_finished) unplugCurrentInterpolator();
			
			if(_way == 1) _current_index = 0;
			else _current_index = _aInterpolator.length-1;
			
			_concatMatrix = _aMatrix[int(_current_index)];
			plugInterpolator( _aInterpolator[int(_current_index)] );
			
			_tMatrix = Matrix4Math.multiply( _concatMatrix, _ci.getMatrix());
			_frame = (_way==1) ? 0 : _totalDuration;
			
			_modified = true;
			_finished = false;
		}
		
		/**
		* yoyo
		* <p>Make the interpolation going in the inversed way</p>
		*/
		public function yoyo():void
		{
			_way = -_way;
			var l:int = _aInterpolator.length;
			while( --l > -1 ) _aInterpolator[int(l)].yoyo();
			
			if(!_finished)
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
					_concatMatrix = _aMatrix[int(_current_index)];
					plugInterpolator( _aInterpolator[int(_current_index)] );
				}
			}
			else
			{
				_concatMatrix = _aMatrix[int(_current_index)];
				plugInterpolator( _aInterpolator[int(_current_index)] );
				
				_tMatrix = Matrix4Math.multiply( _concatMatrix, _ci.getMatrix());
				_modified = true;
				
				_frame = (_way==1)?0:_totalDuration;
				_finished = false;
			}
		}	
		
		/**
		* Returns the percent of the interpolator. 0 is the beginning, and 100 is the end.
		* @param	void
		* @return a Number between [0-1] corresponding on the percentage of the interpolation progress.
		*/
		public function getPercent() : Number
		{
			return (getProgress() * 100);
		}
		
		public function getProgress() : Number
		{
			/* TODO remake this one with durations */
			var p:Number=0;
			
			if(_way == 1) 	p = _current_index + 1 + _ci.getProgress();
			else 			p = _aInterpolator.length - (_current_index + 1) + _ci.getProgress(); 
					
			return ( p / _aInterpolator.length );
		}
		
		/**
		* Returns the type of the interpolation. 
		* @param	void
		* @return TransformType the type of the interpolation
		*/
		override public function getType():TransformType 
		{
			return TransformType.MIXED_INTERPOLATION;
		}
		
		override public function toString():String
		{
			return 'sandy.core.transform.Sequence3D';
		}
		
		override public function destroy() : void 
		{
			unplugCurrentInterpolator();
			
			for(var i:int = 0; i < _aInterpolator.length; i++)
				_aInterpolator[int(i)].destroy();
			
			_aInterpolator = null;
		}
		
		override public function getMatrix():Matrix4
		{
			return _tMatrix;
		}
		
		override public function isModified():Boolean
		{
			return _modified;
		}
		
		override public function setModified( b:Boolean ):void
		{
			_modified = b;
		}
		

		public function getDurationElapsed() : Number 
		{
			var time:Number = 0;
			var l:Number = _current_index - 1;
			while( --l > -1 ) time += _aInterpolator[l].getDuration();
			
			time += _aInterpolator[_current_index].getDurationElapsed();
			
			return time;
		}

		public function getDurationRemaining() : Number 
		{
			return _totalDuration - getDurationElapsed();
		}

		public function isPaused() : Boolean 
		{
			return _paused;
		}

		public function isFinished() : Boolean 
		{
			return _finished;
		}
		//////////////
		/// PRIVATE
		//////////////

		private var _paused:Boolean;
		private var _finished:Boolean;
		private var _blocked:Boolean;
		
		private var _totalDuration:Number;

		private var _aInterpolator:Array; 	//tableau des interpolations
		private var _ci:BasicInterpolator; 	//référence sur l'interpolation courante (plus rapide)
		
		private var _current_index:Number; 	//index de l'interpolation courante (0 à n-1)
		private var _way:Number; 		//direction de parcours de l'interpolation (1:normal, -1:inverse)
		
		private var _tMatrix:Matrix4;
		private var _concatMatrix:Matrix4;
		
		private var _aMatrix:Array; 		//les différentes matrices intermédiaires précalculées.
		
		private var _frame:Number;
		
	} 
}