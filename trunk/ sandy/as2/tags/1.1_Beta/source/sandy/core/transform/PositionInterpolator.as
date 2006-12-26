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
import sandy.core.data.Vector;
import sandy.core.transform.BasicInterpolator;
import sandy.math.VectorMath;
import sandy.core.World3D;
import sandy.core.transform.TransformType;

/**
* PositionInterpolator
*  
* @author		Thomas Pfeiffer - kiroukou
* @since		0.1
* @version		0.3
* @date 		28.03.2006
*/
class sandy.core.transform.PositionInterpolator
	extends BasicInterpolator implements Interpolator3D
{
	
	/**
	 * Create a new TranslationInterpolator.
	 * <p> This class realise a position interpolation of the group of objects it has been applied to</p>
	 * 
	 * @param f Function 	The function generating the interpolation value. 
	 * 						You can use what you want even if Sandy recommends the Ease class
	 * 						The function must return a number between [0,1] and must have a parameter between [0,1] too.
	 * @param onFrames Number	The number of frames that would be used to do the interpolation. 
	 * 							The smaller the faster the interpolation will be.
	 * @param min Vector The vector containing the initial offset that will be applied to the object's positions.
	 * @param max Vector The vector containing the final offset to apply to the object's positions.
	 */	
	public function PositionInterpolator( f:Function, pnFrames:Number, min:Vector, max:Vector ) 
	{
		super( f, pnFrames );	
		_vMin = min;
		_vMax = max;
		_vDiff = VectorMath.sub( max, min );
		_eOnProgress['_nType'] = _eOnStart['_nType'] = _eOnEnd['_nType'] = _eOnResume['_nType'] = _eOnPause['_nType'] = getType();
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __render );
	}
	
	
	private function __render( Void ):Void
	{
		if( false == _paused && false == _finished )
		{
			var current:Vector;
			// --
			if( _way == 1 )	current = VectorMath.addVector( _vMin, VectorMath.scale( _vDiff, _f ( _p ) ) );
			else			current = VectorMath.sub( _vMax, VectorMath.scale( _vDiff, _f ( _p ) ) );
			// --
			_t.translate( current.x, current.y, current.z );
			// increasing our percentage
			if( _p < 1 && (_p + _timeIncrease) >=1 )
					_p = 1;
				else
					_p += _timeIncrease;
			if (_p > 1)
			{
				_p = 0;
				_finished = true;
				broadcastEvent( _eOnEnd );
			}
			else
			{
				// -- we broadcast to the group that we have updated our transformation vector
				_eOnProgress['_nPercent'] = _p;
				broadcastEvent( _eOnProgress );
			}
		}
	}

	/**
	* Returns the type of the interpolation. 
	* @param	Void
	* @return TransformType the type of the interpolation
	*/
	public function getType( Void ):TransformType 
	{
		return TransformType.TRANSLATION_INTERPOLATION;
	}
	
	public function toString():String
	{
		return 'sandy.core.transform.PositionInterpolator';
	}
	//////////////
	/// PRIVATE
	//////////////
	private var _vMin:Vector;
	private var _vMax:Vector;
	private var _vDiff:Vector;
	
}
