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
* RotationInterpolator
*  
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		23.06.2006
**/
class sandy.core.transform.RotationInterpolator extends BasicInterpolator implements Interpolator3D
{
	 /**
	 * RotationInterpolator
	 * <p> This class realise a rotation interpolation of the group of objects it has been applied to</p>
	 * @param f Function 	The function generating the interpolation value. 
	 * 						You can use what you want even if Sandy recommends the Ease class
	 * 						The function must return a number between [0,1] and must have a parameter between [0,1] too.
	 * @param onFrames Number	The number of frames that would be used to do the interpolation. 
	 * 							The smaller the faster the interpolation will be.
	 * @param pmin Number [facultative]The value containing the original rotation offset that will be applied to the object's vertex. Default value is 0.
	 * @param pmax Number [facultative]The value containing the final rotation offset to apply to the object's vertex. Default value is 360.
	 * 
	 */
	public function RotationInterpolator( f:Function, pnFrames:Number, pmin:Number, pmax:Number )
	{
		super( f, pnFrames );
		_vAxis = new Vector( 0, 1, 0 );
		_vRef = null;
		_nMin = (undefined == pmin) ? 0 : pmin;
		_nMax = (undefined == pmax) ? 360 : pmax;
		_nDiff = _nMax - _nMin;
		_eOnProgress['_nType'] = _eOnStart['_nType'] = _eOnEnd['_nType'] = _eOnResume['_nType'] = _eOnPause['_nType'] = getType();
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __render );
	}
	
	/**
	 * Allows you to change the axis of rotation. This axis will be automatically be normalized!
	 * If the axis components are very small the rotation will be paused automatically until you change the axis.
	 * @param v Vector the vector that contains the axis components.
	 * @return Nothing
	 */
	public function setAxisOfRotation ( v:Vector ):Void
	{
		if( Math.abs( v.x ) < 0.001 && Math.abs( v.y ) < 0.001 && Math.abs( v.z ) < 0.001 )
		{
			_blocked = true;
		}
		else
		{
			_blocked = false;
			_vAxis = v;
			VectorMath.normalize( _vAxis );
		}
	}
		
	/**
	 * Allows you to make your object rotate around a specific position and not anymore around its center.
	 * The value passed in argument represents an offset to the object position. It is NOT the real position of the rotation center.
	 * @param v Vector the offset to apply to change the rotation center.
	 * @return Nothing
	 */
	public function setPointOfReference ( v:Vector ):Void
	{
		_vRef = v;
	}
	
	/**
	* Allows you to change the angles of rotation during the interpolation or once it is finished.
	* If no values are given the default one will be set (0 and 360)
	* @param	start Number the angle you want to start rotating.
	* @param	end Number the angle you want your interpolation finish.
	*/
	public function setAngles( start:Number, end:Number ):Void
	{
		_nMin = (undefined == start) ? 0 : start;
		_nMax = (undefined == end) ? 360 : end;
		_nDiff = _nMax - _nMin;
	}

	/**
	* Render the current node. This interpolator makes this method being called every World3D render call.
	* @param	Void
	*/
	private function __render( Void ):Void
	{
		if( false == _paused && false == _finished )
		{
			// special condition because blocked doesn't mean stopped. It just block the rendering
			if( false == _blocked )
			{
				var current:Number;
				// --
				if( _way == 1 )	current = _nMin + _nDiff * _f ( _p );
				else			current = _nMax - _nDiff * _f ( _p );
				// --
				if( undefined == _vRef )	_t.rotAxis( _vAxis, current );
				else						_t.rotAxisWithReference( _vAxis, _vRef, current );
				// -- increasing our percentage
				if( _p < 1 && (_p + _timeIncrease) >=1 )
					_p = 1;
				else
					_p += _timeIncrease;
			}
			// --
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
		return TransformType.ROTATION_INTERPOLATION;
	}
	
	public function toString():String
	{
		return 'sandy.core.transfrom.RotationInterpolator';
	}

	////////////////
	//// PRIVATE
	////////////////
	private var _vAxis:Vector;
	private var _vRef:Vector;
	private var _nMin:Number;
	private var _nMax:Number;
	private var _nDiff:Number;
	
}
