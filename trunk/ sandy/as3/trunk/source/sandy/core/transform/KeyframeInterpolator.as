package sandy.core.transform
{
	import flash.events.Event;
	
	import sandy.core.Object3D;
	import sandy.core.World3D;
	import sandy.core.data.AnimationData;
	import sandy.core.data.Keyframer;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vector;
	import sandy.math.QuaternionMath;
	
	/**
	* VertexInterpolator
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		24.06.2006
	**/
	public class KeyframeInterpolator extends BasicInterpolator implements Interpolator3D
	{
		/**
		 * Create a new KeyframeInterpolator.
		 * <p> This class realise a interpolation of the keyframes of the object's properties it is apply to. You can animate position, rotation and scale of given object.</p>
		 * 
		 * @param o Object3D	The object3D that will be updated by the interpolator.
		 * @param f Function 	The function generating the interpolation value. 
		 * 						You can use what you want even if Sandy recommends the Ease class
		 * 						The function must return a number between [0,1] and must have a parameter between [0,1] too.
		 * @param animator Array of AnimationData	the array that contains all the animation data ie the vertex position per frame.
		 * @param loop	Boolean True if the interpolator can loop through its array of animations (default value) or not.
		 */
		public function KeyframeInterpolator( o:Object3D, f:Function, animator:Keyframer, loop:Boolean=true ) 
		{
			super( f, 0 );
			_o = o;
			_oAnim = animator;
			
			length = animator.endFrame;
			
			if (animator.track_data.pos_track_keys > 0)
			{
				_posAnimBool = true;
			} 
			if (animator.track_data.rot_track_keys > 0)
			{
				_rotAnimBool = true;
			} 
			if (animator.track_data.scl_track_keys > 0)
			{
				_sclAnimBool = true;
			} 
			_rotation = 0;
		
			_vAxis = new Vector( 0, 1, 0 );
			_vRef = null;
			
			gotoFrame( 0 );
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
			var m:Matrix4 = _t.getMatrix()
			//trace("matrix: " + m);
			return m;
		}
		
		/**
		* Get the current animation object.
		* @param	Void
		* @return	Keyframer the current animation object.
		*/
		public function getCurrentAnimation():Keyframer
		{
			return _oAnim;
		}
		
		/**
		* Allows you to go directly on a specified animation.
		* @param	id Number The animation ID you want to play.
		* @return 	Boolean true if the operation succeed, false otherwise.
		*/
		public function gotoFrame( id:uint ):Boolean
		{
			if( id >= length  )
			{
				return false;
			}
			else
			{
				//_animation = _oAnim[ id ];
				_animation = _oAnim;
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
		public function gotoNextFrame():void
		{
			/*
			if( ++_animationId >= _oAnim.length )
			{
				_animationId = 0;
			}
			gotoAnimation( _animationId );
			*/
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
				//trace("_render : " + _p + " cur: " + current);

				if( _way == -1 ) current = 1 - current;
				// we launch the animation of the moving vertices at a specific frame.
				var frame:int = length * current;
				//trace("frame: " + frame);
				
				if (_posAnimBool)
				{
					
					var posObj:Object = _animation.getFramePosition(frame);
					_o.setModified( true );
					var position:Vector = posObj.position;
					
					//trace("animate position " + position);
					
//					_t.translate( position.x, position.y, position.z );
					_t.translateVector( position );
				}
				
				if (_rotAnimBool)
				{
					//trace("animate rotation " + frame);
					var rotObj:Object = _animation.getFrameRotation(frame);
					_o.setModified( true );
					
					var m:Matrix4 = QuaternionMath.getRotationMatrix(rotObj.axis);
					_t.combineMatrix(m);
					
				}
				if (_sclAnimBool)
				{
					//trace("animate scale " + frame);
					var sclObj:Object = _animation.getFrameScale(frame);
					_o.setModified( true );
					var scale:Vector = sclObj.size;
					
					var _t2:Transform3D = new Transform3D();
					_t2.scaleVector( scale );
					_t.combineTransform(_t2);
				}
				
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
						//gotoNextFrame();
						gotoFrame(0);
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
			return TransformType.KEYFRAME_INTERPOLATION;
		}
		
		/**
		* Returns a string representation of this class.
		* @return String The equivalent string.
		*/
		public override function toString():String
		{
			return 'sandy.core.transform.KeyframeInterpolator';
		}
		
		
		public function get length():uint
		{
			return _length;
		}
		public function set length(n:uint):void
		{
			_length = n;
		}
		//////////////
		/// PRIVATE
		//////////////
		private var _o:Object3D;
		private var _oAnim:Keyframer/*Array AnimationData*/;
		private var _nFrames:uint;
		private var _animationId:uint;
		private var _animation:Keyframer;
		private var _loop:Boolean;
		private var _length:uint;
		
		
		private var _posAnimBool:Boolean = false;
		private var _rotAnimBool:Boolean = false;
		private var _sclAnimBool:Boolean = false;
		
		//for rotation
		private var _rotation:Number;
		private var _vAxis:Vector;
		private var _vRef:Vector;
	}
}