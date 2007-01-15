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
class sandy.core.transform.VertexInterpolator
	extends BasicInterpolator implements Interpolator3D
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
	public function VertexInterpolator( o:Object3D, f:Function, animator:Array/*AnimationData*/, loop:Boolean ) 
	{
		super( f, 0 );
		_o = o;
		_oAnim = animator;
		gotoAnimation( 0 );
		_loop = (undefined == loop) ? true : loop;
		_eOnProgress['_nType'] = _eOnStart['_nType'] = _eOnEnd['_nType'] = _eOnResume['_nType'] = _eOnPause['_nType'] = getType();
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __render );
	}
		
	/**
	* Get the ID of the current animation.
	* @param	Void
	* @return 	Number the ID of the current animation
	*/
	public function getCurrentAnimationId( Void ):Number
	{
		return _animationId;
	}
	
	/**
	* Get the current animation object.
	* @param	Void
	* @return	AnimationData the currnet animation object.
	*/
	public function getCurrentAnimation( Void ):AnimationData
	{
		return _animation;
	}
	
	/**
	* Allows you to go directly on a specified animation.
	* @param	id Number The animation ID you want to play.
	* @return 	Boolean true if the operation succeed, false otherwise.
	*/
	public function gotoAnimation( id:Number ):Boolean
	{
		if( id >= _oAnim.length || id < 0 )
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
	public function gotoNextAnimation( Void ):Void
	{
		if( ++_animationId >= _oAnim.length )
		{
			_animationId = 0;
		}
		gotoAnimation( _animationId );
		_modified = true;
	}
	
	public function getMatrix( Void ):Matrix4
	{
		return _m;
	}
	
	public function getStartMatrix( Void ):Matrix4
	{
		return _m;
	}
	
	public function getEndMatrix( Void ):Matrix4
	{
		return _m;
	}
	
	/**
	* Render the interpolator.
	* @param	Void
	*/
	private function __render( Void ):Void
	{
		if( false == _paused && false == _finished )
		{
			var p:Number = getProgress();
			var current:Number = _f( p );
			if( _way == -1 ) current = 1 - current;
			// we launch the animation of the moving vertices at a specific frame.
			_animation.animate( Object3D(_o), int( current * _nFrames ) );
			// --
			_eOnProgress.setPercent( getPercent() );
			broadcastEvent( _eOnProgress );
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
				broadcastEvent( _eOnEnd );
			}
			else
			{
				_frame += _way;
			}
			_modified = true;
		}
	}


	/**
	* Returns the type of the interpolation. 
	* @param	Void
	* @return TransformType the type of the interpolation
	*/
	public function getType( Void ):TransformType 
	{
		return TransformType.VERTEX_INTERPOLATION;
	}
	
	/**
	* Returns a string representation of this class.
	* @return String The equivalent string.
	*/
	public function toString():String
	{
		return 'sandy.core.transform.VertexInterpolator';
	}
	
	//////////////
	/// PRIVATE
	//////////////
	private var _o:Object3D;
	private var _oAnim:Array/*AnimationData*/;
	private var _nFrames:Number;
	private var _animationId:Number;
	private var _animation:AnimationData;
	private var _loop:Boolean;
}
