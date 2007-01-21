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

import sandy.core.data.Matrix4;
import sandy.math.Matrix4Math;

/**
* This class stores the matrix used to render correctly the objects.
* This static class is used during the rendering, when we climb the tree hierarchy of the 3D scene.
* 
* @author		Thomas Pfeiffer - kiroukou
* @since		0.1
* @version		0.3
* @date 		28.03.2006
*/
class sandy.core.buffer.MatrixBuffer
{
	//  Array of multiplied {@code Matrix4}
	private static var _b:Array = new Array(); 
	
	//  The last pile {@code Matrix4}
	private static var _c:Matrix4 = null;
	
	/**
	* Push a {@code Matrix4} to the current.
	* <p>If there is no {@code Matrix4} already pushed,
	* nothing is done with it. In the other case, it
	* is multiplied with the current values of the pushed
	* {@code Matrix4} and saved.</p>
	* <p>The {@link #getCurrentMatrix()} method returns the
	* current {@code Matrix4} within the pushed {@code Matrix4}
	* will be multiplied.</p>
	* 
	* @param	m	The {@code Matrix4} to push
	* @return	The multiplied {@code Matrix4}
	*/ 	
	public static function push( m:Matrix4):Matrix4
	{
		// -- used to be m, _c because order is important here.
		if( _c )	_c = Matrix4Math.multiply4x3( _c, m );
		else		_c = m;
		_b.push( _c );
		return _c;
	}
	
	/**
	* Get the current {@code Matrix4} within the pushed
	* {@code Matrix4} will be multiplied.
	* <p>It returns {@code null} if no {@code Matrix4} has
	* been pushed.</p>
	* 
	* @return	The current multiplie {@code Matrix4} or {@code null}
	*/
	public static function getCurrentMatrix( Void ): Matrix4
	{
		return _c;
	}
	
	/**
	* Pop a pushed {@code Matrix4}.
	* <p>Returns the previous {@code Matrix4} (before the last push).
	* If no {@code Matrix4} has been pushed, returns {@code null}.</p>
	* 
	* @return	The last multiplied {@code Matrix4} or {@code null}
	*/ 	
	public static function pop( Void ):Matrix4
	{
		_c = _b[ _b.length - 2 ];
		return Matrix4( _b.pop() );
	}
	
	/**
	* Completely reinitialize the MatrixBuffer. Deleting all the buffered matrix, and all the public properties.
	* @param	Void
	*/
	public static function init( Void ):Void
	{
		delete _b;
		delete _c;
		_b = [];
		_c = null;
	}
}
