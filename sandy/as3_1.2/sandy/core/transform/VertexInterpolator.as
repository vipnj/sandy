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

package sandy.core.transform 
{
	import flash.events.Event;

	import sandy.core.transform.Interpolator3D;
	import sandy.core.transform.BasicInterpolator;
	import sandy.core.Object3D;
	import sandy.core.data.AnimationData;
	import sandy.core.data.Matrix4;
	import sandy.core.World3D;
	import sandy.core.transform.TransformType;
	import sandy.events.SandyEvent;

	
	/**
	* VertexInterpolator
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		24.06.2006
	**/
	public class VertexInterpolator extends BasicInterpolator
	{
		
	// ______________
	// [PRIVATE] DATA________________________________________________		

		private var _o:Object3D;
		private var _oAnim:Array/*AnimationData*/;
		private var _nFrames:Number;
		private var _animationId:Number;
		private var _animation:AnimationData;
		private var _loop:Boolean;
	
		
		
	// ___________
	// CONSTRUCTOR___________________________________________________
		
		/**
		 * Create a new VertexInterpolator.
		 * <p> This class realise a interpolation of the vertices of the object it is apply to</p>
		 * 
		 * @param o Object3D	The object3D that will be updated by the interpolator.
		 * @param f Function 	The function generating the interpolation value. 
		 * 						You can use what you want even if Sandy recommends the Ease class
		 * 						The function must return a number between [0,1] and must have a parameter between [0,1] too.
		 * @param animator Array of AnimationData	the array that contains all the animation data ie the vertex position per frame.
		 * @param loop	Boolean True if the interpolator can loop through its array of animations (default value) or not.
		 */
		public function VertexInterpolator( o:Object3D, f:Function, animator:Array/*AnimationData*/, loop:Boolean = true ) 
		{
			super( f, 0 );
			
			_type = TransformType.VERTEX_INTERPOLATION;
			_o = o;
			_oAnim = animator;
			gotoAnimation( 0 );
			_loop = loop;
			
			World3D.getInstance().addEventListener( SandyEvent.RENDER, __render );
		}
		
		
		
		
		
	// __________________
	// [PUBLIC] FUNCTIONS____________________________________________		
		
		/**
		* Get the ID of the current animation.
		* @param	void
		* @return 	Number the ID of the current animation
		*/
		public function getCurrentAnimationId():Number
		{
			return _animationId;
		}
		
		/**
		* Get the current animation object.
		* @param	void
		* @return	AnimationData the currnet animation object.
		*/
		public function getCurrentAnimation():AnimationData
		{
			return _animation;
		}
		
		/**
		* Allows you to go directly on a specified animation.
		* @param	id Number The animation ID you want to play.
		* @return 	Boolean true if the operation succeed, false otherwise.
		*/
		public function gotoAnimation( id:int ):Boolean
		{
			if( id >= _oAnim.length || id < 0 )
			{
				return false;
			}
			else
			{
				_animation = _oAnim[ int(id) ];
				_animationId = id;
				setDuration( _nFrames = _animation.getTotalFrames() );
				_finished = false;
				return true;
			}
		}
		
		/**
		* Go to the next animation.
		* @param	void
		*/
		public function gotoNextAnimation():void
		{
			if( ++_animationId >= _oAnim.length )
			{
				_animationId = 0;
			}
			gotoAnimation( _animationId );
			_modified = true;
		}
		
		
		
		
	// ___________________________
	// [OVERRIDEN] BasicInterpolator_________________________________
		
		/**
		* Render the interpolator.
		* @param	void
		*/
		override public function __render(e:Event):void
		{
			if( !_paused && !_finished )
			{
				var p:Number = getProgress();
				var current:Number = _f( p );
				
				if( _way == -1 ) 
				{
					current = 1 - current;
				}
				
				// we launch the animation of the moving vertices at a specific frame.
				_animation.animate( Object3D(_o), int( current * _nFrames ) );
				
				// --
				dispatchEvent( progressEvent );
				
				// --
				if ( (_frame == 0 && _way == -1)  || (_way == 1 && _frame == _duration) )
				{
					if( _loop )
					{
						gotoNextAnimation();
					}
					else
					{
						_finished = true;
					}
					dispatchEvent( endEvent );
				}
				else
				{
					_frame += _way;
				}
				
				_modified = true;
			}
		}
		
		override public function getMatrix():Matrix4
		{
			return _m;
		}
		
		override public function getStartMatrix():Matrix4
		{
			return _m;
		}
		
		override public function getEndMatrix():Matrix4
		{
			return _m;
		}

	}
}