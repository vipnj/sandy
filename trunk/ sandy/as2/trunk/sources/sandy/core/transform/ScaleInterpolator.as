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

import sandy.core.data.Matrix4;
import sandy.core.data.Vector;
import sandy.core.transform.BasicInterpolator;
import sandy.core.transform.Interpolator3D;
import sandy.core.transform.TransformType;
import sandy.core.World3D;
import sandy.math.Matrix4Math;
import sandy.math.VectorMath;

/**
* ScaleInterpolator
*  
* @author		Thomas Pfeiffer - kiroukou
* @version		1.2
* @date 		28.03.2006
**/
class sandy.core.transform.ScaleInterpolator
	extends BasicInterpolator implements Interpolator3D
{
	/**
	 * Create a new ScaleInterpolator.
	 * <p> This class realise a scale interpolation of the group of objects it has been applied to</p>
	 * @param f Function 	The function generating the interpolation value. 
	 * 						You can use what you want even if Sandy recommends the Ease class
	 * 						The function must return a number between [0,1] and must have a parameter between [0,1] too.
	 * @param onFrames Number	The number of frames that would be used to do the interpolation. 
	 * 							The smaller the faster the interpolation will be.
	 * @param min Vector The vector containing the initial scale values.
	 * @param max Vector The vector containing the final scale values.
	 */
	public function ScaleInterpolator( f:Function, pnFrames:Number, min:Vector, max:Vector ) 
	{
		super( f, pnFrames );	
		_vMin = min;
		_vMax = max;
		_current = 0;
		_vDiff = VectorMath.sub( _vMax, _vMin );
		_eOnProgress['_nType'] = _eOnStart['_nType'] = _eOnEnd['_nType'] = _eOnResume['_nType'] = _eOnPause['_nType'] = getType();
		__updateScale();
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __render );
	}
	
	/**
	* Set the start scale vector. The objects will be initialized after this method call with this value.
	* @param	v The vector containing the initial scale properties
	*/
	public function setMinScaleVector( v:Vector ):Void
	{
		_vMin = v;
		_current = 0;
		_vDiff = VectorMath.sub( _vMax, _vMin );
		__updateScale();
	}
	/**
	* Set the start scale vector. The objects will be initialized after this method call with this value.
	* @param	x The X axis initial scale value
	* @param	y The Y axis initial scale value
	* @param	z The Z axis initial scale value
	*/
	public function setMinScale( x:Number, y:Number, z:Number ):Void
	{
		_vMin = new Vector( x, y, z );
		_current = 0;
		_vDiff = VectorMath.sub( _vMax, _vMin );
		__updateScale();
	}
	/**
	* Set the end scale vector. The objects will be initialized after this method call.
	* @param	v The vector containing the end scale properties.
	*/
	public function setMaxScaleVector( v:Vector ):Void
	{
		_vMax = v;
		_current = 0;
		_vDiff = VectorMath.sub( _vMax, _vMin );
		__updateScale();
	}
	/**
	* Set the end scale vector. The objects will be initialized after this method call.
	* @param	x The X axis end scale value
	* @param	y The Y axis end scale value
	* @param	z The Z axis end scale value
	*/	
	public function setMaxScale( x:Number, y:Number, z:Number ):Void
	{
		_vMax = new Vector( x, y, z );
		_current = 0;
		_vDiff = VectorMath.sub( _vMax, _vMin );
		__updateScale();
	}
	
	public function getStartMatrix( Void ):Matrix4
	{
		return  Matrix4Math.scaleVector( _vMin );
	}
	
	public function getEndMatrix( Void ):Matrix4
	{
		return  Matrix4Math.scaleVector( _vMax );
	}
	
	private function __updateScale( Void ):Void
	{
		var c:Number = _current;
		var v:Vector;
		if( _way == -1 ) c = 1 - _current;
		// -- computing the new position
		v = VectorMath.scale( _vDiff, c );
		v = VectorMath.addVector( _vMin, v );
		_m = Matrix4Math.scaleVector( v );
		_modified = true;
	}
	
	private function __render( Void ):Void
	{
		if( false == _paused && false == _finished )
		{
			var p:Number = getProgress();
			_current = _f( p );
			// --
			__updateScale();
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
	
	/**
	* Returns the type of the interpolation. 
	* @param	Void
	* @return TransformType the type of the interpolation
	*/
	public function getType( Void ):TransformType 
	{
		return TransformType.SCALE_INTERPOLATION;
	}
	
	public function toString():String
	{
		return 'sandy.core.transfrom.ScaleInterpolator';
	}
	//////////////
	/// PRIVATE
	//////////////
	private var _vMin:Vector;
	private var _vMax:Vector;
	private var _vDiff:Vector;
	private var _current:Number;
}
