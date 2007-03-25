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
	
	/**
	* VertexInterpolator
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		24.06.2006
	**/
	public class VertexInterpolator extends BasicInterpolator implements Interpolator3D
	{
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
		public function VertexInterpolator( o:Object3D, f:Function, animator:Array/*AnimationData*/, loop:Boolean=true ) 
		{
			super( f, 0 );
			_o = o;
			_oAnim = animator;
			gotoAnimation( 0 );
			_loop = loop;
			_eOnProgress.setTransformType( getType() );
			_eOnStart.setTransformType( getType() );
			_eOnEnd.setTransformType( getType() );
			_eOnResume.setTransformType( getType() );
			_eOnPause.setTransformType( getType() );
			World3D.addEventListener( World3D.onRenderEVENT, __render );
		}
			
		/**
		* Get the ID of the current animation.
		* @param	Void
		* @return 	Number the ID of the current animation
		*/
		public function getCurrentAnimationId():uint
		{
			return _animationId;
		}
		
		public override function getMatrix():Matrix4
		{
			// NO matrix to return here!
			return null;
		}
		
		/**
		* Get the current animation object.
		* @param	Void
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
		public function gotoAnimation( id:uint ):Boolean
		{
			if( id >= _oAnim.length  )
			{
				return false;
			}
			else
			{
				_animation = _oAnim[ id ];
				_animationId = id;
				setDuration( _nFrames = _animation.getTotalFrames() );
				_finished = false;
				return true;
			}
		}
		
		/**
		* Go to the next animation.
		* @param	Void
		*/
		public function gotoNextAnimation():void
		{
			if( ++_animationId >= _oAnim.length )
			{
				_animationId = 0;
			}
			gotoAnimation( _animationId );
		}
		
		/**
		* Render the interpolator.
		* @param	Void
		*/
		private function __render(e:Event = null):void
		{
			if( false == _paused && false == _finished )
			{
				var current:Number = _f( _p );
				if( _way == -1 ) current = 1 - current;
				// we launch the animation of the moving vertices at a specific frame.
				_animation.animate( Object3D(_o), int( current * _nFrames ) );
				// increasing our percentage
				if( _p < 1 && (_p + _timeIncrease) >=1 )
				{
					_p = 1;
				}
				else
				{
					_p += _timeIncrease;
				}
				// --
				if ( _p > 1 )
				{
					_p = 0;
					if( _loop )
					{
						gotoNextAnimation();
					}
					else
					{
						_finished = true;
					}
					dispatchEvent( _eOnEnd );
				}
				else
				{
					// -- we broadcast to the listeners that we have updated our transformation matrix
					_eOnProgress.setPercent( _p );
					dispatchEvent( _eOnProgress );
				}
			}
		}
	
		/**
		* Returns the type of the interpolation. 
		* @param	Void
		* @return TransformType the type of the interpolation
		*/
		public override function getType():uint 
		{
			return TransformType.VERTEX_INTERPOLATION;
		}
		
		/**
		* Returns a string representation of this class.
		* @return String The equivalent string.
		*/
		public override function toString():String
		{
			return 'sandy.core.transform.VertexInterpolator';
		}
		
		//////////////
		/// PRIVATE
		//////////////
		private var _o:Object3D;
		private var _oAnim:Array/*AnimationData*/;
		private var _nFrames:uint;
		private var _animationId:uint;
		private var _animation:AnimationData;
		private var _loop:Boolean;
	}
}