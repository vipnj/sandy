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
import com.bourre.events.BasicEvent;

import sandy.core.data.BezierPath;
import sandy.core.data.Matrix4;
import sandy.core.data.Vector;
import sandy.core.transform.BasicInterpolator;
import sandy.core.transform.Interpolator3D;
import sandy.core.transform.TransformType;
import sandy.core.World3D;
import sandy.math.Matrix4Math;

/**
* PathInterpolator
*  
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		24.07.2006
*/
class sandy.core.transform.PathInterpolator
	extends BasicInterpolator implements Interpolator3D
{
	
	/**
	 * Create a new PathInterpolator.
	 * <p> This class realise a position interpolation of the group of objects it has been applied to</p>
	 *
	 * @param f Function 	The function generating the interpolation value. 
	 * 						You can use what you want even if Sandy recommends the Ease class
	 * 						The function must return a number between [0,1] and must have a parameter between [0,1] too.
	 * @param onFrames Number	The number of frames that would be used to do the interpolation. 
	 * 							The smaller the faster the interpolation will be.
	 * @param pPath BezierPath The path that objects will go throught
	 */	
	public function PathInterpolator( f:Function, pnFrames:Number, pPath:BezierPath ) 
	{
		super( f, pnFrames );	
		_pPath = pPath;
		_eOnProgress['_nType'] = _eOnStart['_nType'] = _eOnEnd['_nType'] = _eOnResume['_nType'] = _eOnPause['_nType'] = getType();
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __render );
	}
			
	private function __render( Void ):Void
	{
		if( false == _paused && false == _finished )
		{
			var current:Vector;
			// --
			if( _way == 1 )	current = _pPath.getPosition( _f ( getPercent() ) );
			else		current = _pPath.getPosition( 1.0 - _f ( getPercent() ) );
			/* TODO check the sign of the y value */
			_m = Matrix4Math.translation( current.x, current.y, current.z );
			// --
			_eOnProgress.setPercent( getPercent() );
			broadcastEvent( _eOnProgress );
			// --
			if ( (_frame == 0 && _way == -1)  || (_way == 1 && _frame == _duration) )
			{
				_finished = true;
				broadcastEvent( _eOnEnd );
			}
			else
			{
				_frame += _way;
			}
		}
	}

	public function getStartMatrix( Void ):Matrix4
	{
		return Matrix4Math.translationVector(_pPath.getPosition(0));
	}
	
	public function getEndMatrix( Void ):Matrix4
	{
		return Matrix4Math.translationVector(_pPath.getPosition(1));
	}

	/**
	* Returns the type of the interpolation. 
	* @param	Void
	* @return TransformType the type of the interpolation
	*/
	public function getType( Void ):TransformType 
	{
		return TransformType.PATH_INTERPOLATION;
	}
	
	public function toString():String
	{
		return 'sandy.core.transform.PathInterpolator';
	}

	/**
	* redo
	* <p>Make the interpolation starting again</p>
	*/
	public function redo( Void ):Void
	{
		super.redo();
		if( _way == 1 )
			_m = getStartMatrix();
		else
			_m = getEndMatrix();
	}
			
	/**
	* yoyo
	* <p>Make the interpolation going in the inversed way</p>
	*/
	public function yoyo( Void ):Void
	{
		super.yoyo();
	}	
	
	//////////////
	/// PRIVATE
	//////////////
	private var _pPath:BezierPath;	
}
