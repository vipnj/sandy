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
import sandy.core.data.Matrix4;
import sandy.math.Matrix4Math;
import sandy.core.transform.TransformType;
import com.bourre.events.BasicEvent;

/**
* PositionInterpolator
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Thomas Balitout - samothtronicien
* @since		1.0
* @version		1.2.2
* @date 		26.05.2007
*/
class sandy.core.transform.PositionInterpolator extends BasicInterpolator implements Interpolator3D
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
	 * @param min Vector 	The vector containing the initial offset that will be applied to the object's positions.
	 * @param max Vector	The vector containing the final offset to apply to the object's positions.
	 * @param n String		Name of the Object, useful for debugging.
	 */	
	public function PositionInterpolator( f:Function, pnFrames:Number, min:Vector, max:Vector, n:String ) 
	{
		super( f, pnFrames, (n == undefined)?"PositionInterpolator":n );
		_vMin = min;
		_vMax = max;
		_vDiff = VectorMath.sub( max, min );
		__update();
	}
	
	/**
	* set the start position vector. The objects will be initialized after this method call with this offset.
	* @param	v The start position offset vector
	*/
	public function setStartPositionVector( v:Vector ):Void
	{
		_vMin = v;
		_vDiff = VectorMath.sub( _vMax, _vMin );
		__update();
	}
	
	/**
	* set the start position vector. The objects will be initialized after this method call with this offset.
	* @param	x The start X position offset value
	* @param	y The start Y position offset value
	* @param	z The start Z position offset value
	*/
	public function setStartPosition( x:Number, y:Number, z:Number ):Void
	{
		_vMin = new Vector( x, y, z );
		_vDiff = VectorMath.sub( _vMax, _vMin );
		__update();
	}
	
	/**
	* get the start position vector.
	*/
	public function getStartPosition( Void ):Vector
	{
		return _vMin;
	}
	
	/**
	* Set the end position vector.
	* The objects will be initialized after this method call with this start offset and will stop at the offset given in argument.
	* @param	v The end position offset vector
	*/
	public function setEndPositionVector( v:Vector ):Void
	{
		_vMax = v;
		_vDiff = VectorMath.sub( _vMax, _vMin );
		__update();
	}
	
	/**
	* Set the end position vector. 
	* The objects will be initialized after this method call with this start offset and will stop at the offset given in argument.
	* @param	x The end X position offset value
	* @param	y The end Y position offset value
	* @param	z The end Z position offset value
	*/
	public function setEndPosition( x:Number, y:Number, z:Number ):Void
	{
		_vMax = new Vector( x, y, z );
		_vDiff = VectorMath.sub( _vMax, _vMin );
		__update();
	}
	
	/**
	* get the start position vector.
	*/
	public function getEndPosition( Void ):Vector
	{
		return _vMax;
	}
	
	/**
	* Compute the matrix for the current frame.
	* @param	Void
	* @return Void
	*/
	private function __update( Void ):Void
	{
		var p:Number = getProgress();
		var _current:Vector;
		if( _way == 1 ) _current = VectorMath.addVector( _vMin, VectorMath.scale( _vDiff, _f ( p ) ) );
		else _current = VectorMath.sub( _vMax, VectorMath.scale( _vDiff, _f ( p ) ) );
		_m = Matrix4Math.translation( _current.x, _current.y, _current.z );
		_modified = true;
	}
	
	/**
	* Return the matrix corresponding to the first frame of the interpolation
	* @param	Void
	* @return Matrix4
	*/
	public function getStartMatrix( Void ):Matrix4
	{
		return Matrix4Math.translation(_vMin.x, _vMin.y, _vMin.z);
	}
	
	/**
	* Return the matrix corresponding to the last frame of the interpolation
	* @param	Void
	* @return Matrix4
	*/
	public function getEndMatrix( Void ):Matrix4
	{
		return Matrix4Math.translation(_vMax.x, _vMax.y, _vMax.z);
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
	
	/**
	* Returns the class path of the interpolation. 
	* @param	Void
	* @return String Class path
	*/
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
