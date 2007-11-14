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
import sandy.math.Matrix4Math;
import sandy.math.VectorMath;

/**
* RotationInterpolator
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Thomas Balitout - samothtronicien
* @since		1.0
* @version		1.2.2
* @date 		26.05.2007
**/
class sandy.core.transform.RotationInterpolator extends BasicInterpolator implements Interpolator3D
{
	 /**
	 * RotationInterpolator
	 * <p> This class realise a rotation interpolation of the group of objects it has been applied to</p>
	 * @param f Function 	The function generating the interpolation value. 
	 * 						You can use what you want even if Sandy recommends the Ease class
	 * 						The function must return a number between [0,1] and must have a parameter between [0,1] too.
	 * @param pnFrames Number	The number of frames that would be used to do the interpolation. 
	 * 							The smaller the faster the interpolation will be.
	 * @param pmin Number [facultative]The value containing the original rotation offset that will be applied to the object's vertex. Default value is 0.
	 * @param pmax Number [facultative]The value containing the final rotation offset to apply to the object's vertex. Default value is 360.
	 * @param n String		Name of the Object, useful for debugging.
	 */
	public function RotationInterpolator( f:Function, pnFrames:Number, pmin:Number, pmax:Number, n:String )
	{
		super( f, pnFrames, (n == undefined)?"RotationInterpolator":n );
		_vAxis = new Vector( 0, 1, 0 );
		_vRef = null;
		_nMin = (undefined == pmin) ? 0 : pmin;
		_nMax = (undefined == pmax) ? 360 : pmax;
		_nDiff = _nMax - _nMin;
		__update();
	}
	
	private function __update( Void ):Void
	{	
		var p:Number = getProgress();
		var _current:Number;
		if( _way == 1 ) _current = _nMin + _nDiff * _f ( p );
		else _current = _nMax - _nDiff * _f ( p );
		
		if( undefined == _vRef ) _m = Matrix4Math.axisRotationVector( _vAxis, _current );
		else _m = Matrix4Math.axisRotationWithReference( _vAxis, _vRef, _current );
		_modified = true;
	}
	
	/**
	 * Allows you to change the axis of rotation. This axis will be automatically be normalized!
	 * If the axis components are very small, or the axis is undefined, the rotation will be paused automatically until you change the axis.
	 * @param v Vector the vector that contains the axis components.
	 * @return Boolean false if the the given axis is not good.
	 */
	public function setAxisOfRotation ( v:Vector ):Boolean
	{
		if (v == undefined) {
			trace ("Warning: vector passed to RotationInterpolator.as was undefined.");
			return false;
		}
		
		if( Math.abs( v.x ) < 0.001 && Math.abs( v.y ) < 0.001 && Math.abs( v.z ) < 0.001 )
		{
			return false;
		}
		else
		{
			_vAxis = v;
			VectorMath.normalize( _vAxis );
			__update();
			return true;
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
		__update();
	}
	
	/**
	 * Allows you to get the point of reference of the rotation.
	 * @param Void
	 * @return Vector The point of reference
	 */
	public function getPointOfReference ( Void ):Vector
	{
		return _vRef;
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
		__update();
	}

	/**
	* Return the matrix corresponding to the first frame of the interpolation
	* @param	Void
	* @return Matrix4
	*/
	public function getStartMatrix( Void ):Matrix4
	{
		if( undefined == _vRef ) return Matrix4Math.axisRotationVector( _vAxis, _nMin );
		else return Matrix4Math.axisRotationWithReference( _vAxis, _vRef, _nMin );
	}
	
	/**
	* Return the matrix corresponding to the last frame of the interpolation
	* @param	Void
	* @return Matrix4
	*/
	public function getEndMatrix( Void ):Matrix4
	{
		if( undefined == _vRef ) return Matrix4Math.axisRotationVector( _vAxis, _nMax );
		else return Matrix4Math.axisRotationWithReference( _vAxis, _vRef, _nMax );
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
	
	/**
	* Returns the class path of the interpolation. 
	* @param	Void
	* @return String Class path
	*/
	public function toString():String
	{
		return 'sandy.core.transform.RotationInterpolatorv2';
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
