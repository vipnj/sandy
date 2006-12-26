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

import sandy.core.face.TriFace3D;
import sandy.core.Object3D;
import sandy.skin.Skin;
import sandy.skin.SkinType;

/**
* NFace3D
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		12.01.2006 
**/

class sandy.core.face.NFace3D extends TriFace3D
{
	public function NFace3D(  oref:Object3D, a:Array)
	{
		super( oref, a[0], a[1], a[2] );
		_aVertex = a;
		_nL = a.length;
	}
	
	/**
	* Allows you to get the vertex of the face. Very usefull when you want to make some calculation on a face after it has been clicked.
	* @param	Void
	* @return Array The array of vertex.
	*/
	public function getVertex( Void ):Array
	{
		return _aVertex;
	}
	
	/**
	 * Set a new texture coordinates points refers.
	 * @param	a	Array of{code UVCoord}
	 */	
	public function setUVCoordinates( a:Array/*UVCoord*/ ):Void
	{
		aUv.concat( a );
	}
	
	/** 
	 * Render the face into a MovieClip.
	 *
	 * @param	{@code mc}	A {@code MovieClip}.
	 */
	public function render( mc:MovieClip ): Void
	{
		_mc = mc;
		var l:Number = _nL;
		//
		( _bV ) ? _s.begin( this, mc ) : _sb.begin( this, mc );
		//
		mc.moveTo( _va.sx, _va.sy );
		while( --l > -1 )
			mc.lineTo( _aVertex[l].sx, _aVertex[l].sy);
		// -- we launch the rendering with the appropriate skin
		( _bV ) ? _s.end( this, mc ) : _sb.end( this, mc );
	}
	
	/** 
	 * Refresh the face display
	 */
	public function refresh( Void ):Void
	{
		_mc.clear();
		( _bV ) ? _s.begin( this, _mc ) : _sb.begin( this, _mc );
		//
		_mc.moveTo( _va.sx, _va.sy );
		var l:Number = _nL;
		while( --l > -1 )
			_mc.lineTo( _aVertex[l].sx, _aVertex[l].sy);
		// -- we launch the rendering with the appropriate skin
		( _bV ) ? _s.end( this, _mc ) : _sb.end( this, _mc );
	}

	/**
	 * NFace3D allows all the skins available in Sandy, but you must be warned that if you use a TextureSkin 
	 * (or a derivate one) the distortion will not be correct! 
	 * The only solution to be able to map an object with a bitmap correctly is to use TriFace3D.
	 * @param s	Skin object. The skin to apply to the face.
	 */
	public function setSkin( s:Skin ):Void
	{
		if( s.getType() == SkinType.TEXTURE )
		{
			trace('WARNING: Sandy::NaFace3D The perspective bitmap distortion may not be correct');
		}
		super.setSkin( s );
	}
	
	/**
	 * Return the depth average of the face.
	 * <p>Useful for z-sorting.</p>
	 *
	 * @return	A Number as depth average.
	 */
	public function getZAverage( Void ) : Number
	{
		// -- We normalize the sum and return it
		var d:Number = 0;
		var l:Number = _nL;
		while( --l > -1 )
			d += _aVertex[l].wz;
		return d / _nL;
	}
	
	/**
	 * Returns the min depth of its vertex.
	 * @param Void	
	 * @return number the minimum depth of it's vertex
	 */
	public function getMinDepth ( Void ):Number
	{
		var min:Number = _va.wz;
		var l:Number = _nL;
		while( --l > -1 )
			min = Math.min( min, _aVertex[l].wz );
		return min;
	}

	/**
	 * Returns the max depth of its vertex.
	 * @param Void	
	 * @return number the maximum depth of it's vertex
	 */
	public function getMaxDepth ( Void ):Number
	{
		var max:Number = _va.wz;
		var l:Number = _nL;
		while( --l > -1 )
			max = Math.max( max, _aVertex[l].wz );
		return max;
	}
	
	/**
	* Get a String represntation of the {@code NFace3D}.
	* 
	* @return	A String representing the {@code NFace3D}.
	*/
	public function toString( Void ): String
	{
		return new String("sandy.core.face.NFace3D");
	}

	/**
	 * Array containing the Vertex
	 */
	private var _aVertex:Array;
	private var _nL:Number;
}

