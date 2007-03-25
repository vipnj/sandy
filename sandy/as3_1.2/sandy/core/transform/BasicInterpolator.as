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

package sandy.core.transform {

	import sandy.core.data.Matrix4;
	import sandy.events.SandyEvent;
	import sandy.core.transform.Transform3D;
	import sandy.core.transform.TransformType;
	import flash.utils.*;

	import flash.events.Event;
	

	/**
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		16.05.2006
	**/
	public class BasicInterpolator extends Transform3D implements Interpolator3D
	{
		
	// ____________
	// PRIVATE Data________________________________________________
	//
		/** Paused */
		protected var _paused: Boolean; // + Interpolator3D
		
		/** Percentage */
		protected var _frame: Number; // + Interpolator3D
		
		/** Duration in frames */
		protected var _duration: Number; // + Interpolator3D
		
		/** Duration elapsed */
		protected var _durationElapsed: Number; // + Interpolator3D
		
		/** True if finished */
		protected var _finished:Boolean; // + Interpolator3D
		
		/** True if blocked */
		protected var _blocked:Boolean; // + Interpolator3D
		
		/** Ease function */
		protected var _f:Function;
		
		/** Forward or backward */
		protected var _way:int;
		
		/** The transformation we are going to update the transformGroup with */
		protected var _t:Transform3D;
		
		/** The time between each frames */
		protected var _timeIncrease:Number;
		
		protected var _modified:Boolean;
		
		
	
		
		
		
		
	// ___________
	// Constructor________________________________________________
	//
		// TODO: in original implementation it's private
		public function BasicInterpolator(f:Function, pnFrames:Number )
		{
			_type = TransformType.NONE;
			_way = 1;
			_duration = pnFrames;
			_timeIncrease = 1 / pnFrames;
			_f = f;
			_frame = 0;
			_m = Matrix4.createIdentity();
			_paused = _finished = _blocked = _modified = false;
			
		}

		
		
	
	// __________________
	// Interpolator3D API_________________________________________
	//
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
		
		/**
		* redo
		* <p>Make the interpolation starting again</p>
		*/
		public function redo():void
		{
			_frame = ( _way == 1 ) ? 0 : _duration;
			_finished = false;
			_modified = true;
		}
			
		/**
		* yoyo
		* <p>Make the interpolation going in the inversed way</p>
		*/
		public function yoyo():void
		{
			// _frame = _duration - _frame;
			_way = - _way;
			_finished = false;
			_modified = true;
		}	
		
		public function getFrame():Number
		{
			return _frame;
		}
		
		/**
		* Returns the percent of the interpolator. 0 is the beginning, and 100 is the end.
		* @param	void
		* @return a Number between [0-100] corresponding on the percentage of the interpolation progress.
		*/
		public function getPercent():Number
		{
			return (getProgress()*100);
		}

		/**
		* Returns the progress of the interpolator. 0 is the beginning, and 1 is the end.
		* @param	void
		* @return a Number between [0-1] corresponding on the interpolation progress.
		*/
		public function getProgress():Number
		{
			if( _way == 1 ) 
			{
				return ( _frame / _duration );
			} else {
				return ( 1 - ( _frame / _duration ) );
			}
		}
		
		/**
		 * set the interpolation duration in number of frames. Could be lower than 5!
		 * @param Number the duration in number of frames
		 * @return void
		 */
		public function setDuration ( t:Number ):void
		{
			if( t == Number.POSITIVE_INFINITY || t > 10000 )
			{
				t = 10000;
			} else {
				if( t < 5 ) t = 5;
			}
			
			_duration = t;
			_timeIncrease = 1 / t;
		}
		
		public function getDuration ():Number
		{
			return _duration;
		}
		
		public function getDurationElapsed():Number 
		{
			return _frame;
		}

		public function getDurationRemaining():Number 
		{
			return _duration - _frame;
		}
		
		public function isFinished():Boolean
		{
			return _finished;
		}
		
		public function isPaused():Boolean
		{
			return _paused;
		}
		
		public function getStartMatrix():Matrix4
		{
			return null; // has to be implemented
		}
		
		public function getEndMatrix():Matrix4
		{
			return null;
		}
		
		
		
		
	// __________________+
	// Transform3D OVERRIDEN___________________________________________________
	//	
		/**
		* Destroy the transformation instance and remove all its listeners.
		* Shall be implemented in the derivated classes.
		* @param	void
		*/
		override public function destroy() : void 
		{
			super.destroy();
			_t.destroy();
		}
		
		
		
		
	// __________________+
	// PUBLIC API______________________________________________________________
	//	
		override public function toString():String
		{
			return getQualifiedClassName(this);
		}
			
		public function __render(e:Event):void
		{
			// to implement;
		}

				
	}
}