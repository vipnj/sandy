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

import sandy.core.data.Vertex;
import sandy.core.face.TriFace3D;
import sandy.core.Sprite3D;
import sandy.skin.MovieSkin;
import sandy.core.data.Vector;
/**
* Sprite3DFace
* <p>Create the face needed by the Sprite3D object. This face fits perfectly the Sprite3D needs.</p>
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		12.05.2006 
**/
class sandy.core.face.Sprite3DFace extends TriFace3D
{
	
	public function Sprite3DFace( oref:Sprite3D, pt:Vertex ) 
	{
		super( oref, pt );
	}
	
	/**
	* Allows you to get the vertex of the face. Very usefull when you want to make some calculation on a face after it has been clicked.
	* @param	Void
	* @return Array The array of vertex.
	*/
	public function getVertex( Void ):Array
	{
		return [ _va ];
	}
		
	/**
	 * isvisible 
	 * 
	 * <p>Say if the face is visible or not</p>
	 *
	 * @param Void
	 * @return a Boolean, true if visible, false otherwise
	 */	
	public function isVisible( Void ): Boolean
	{
		return true;
	}
	
	/**
	* set the frame of the movieclip
	* @param	n
	*/
	public function setFrame( n:Number ):Void
	{
		_nFrame = n;
	}
	
	
	/** 
	 * Render the face into a MovieClip.
	 *
	 * @param	{@code mc}	A {@code MovieClip}.
	 */
	public function render( mc:MovieClip ):Void
	{
		_mc = mc;
		// --
		var sv:Vector 	= Sprite3D(_o).getScaleVector();
		var s:Number 	= Sprite3D(_o).getScale();
		var cste:Number	= 100 / _va.wz;
		//
		var t:MovieSkin = MovieSkin( _s );
		t.getMovie().gotoAndStop( _nFrame );
		t.updateTexture();
		mc.attachBitmap( t.texture.clone(), 0 );
		mc._width 	= t.texture.width  * (s * sv.x * cste);
		mc._height 	= t.texture.height * (s * sv.y * cste);
		// --
		mc._x = _va.sx - mc._width/2;
		mc._y = _va.sy - mc._height/2;
		// --
		mc.filters = t.filters;
	}
	
	/** 
	 * Refresh the face
	 */
	public function refresh( Void ):Void
	{
		_mc.clear();
		// --
		var sv:Vector 	= Sprite3D(_o).getScaleVector();
		var s:Number 	= Sprite3D(_o).getScale();
		var cste:Number	= 100 / (_va.wz );
		//
		var t:MovieSkin = MovieSkin( _s );
		t.getMovie().gotoAndStop( _nFrame );
		t.updateTexture();
		_mc.attachBitmap( t.texture.clone(), 0 );
		_mc._width 	= t.texture.width  * (s * sv.x * cste);
		_mc._height = t.texture.height * (s * sv.y * cste);
		// --
		_mc._x = _va.sx - _mc._width/2;
		_mc._y = _va.sy - _mc._height/2;
		// --
		_mc.filters = t.filters;
	}
	
	/**
	* Set the skin for that Clip3DFace. This skin must be a MovieSkin. Others skins can't be applied
	* @param	s MovieSkin The movieSkin
	*/
	public function setSkin(s : MovieSkin) : Void 
	{
		if( s instanceof MovieSkin )
			_s = s;
	}
	
	/**
	* Returns the skin of this Clip3DFace which is a MovieSkin.
	* @return MovieSkin the skin of this face
	*/
	public function getSkin( Void ) : MovieSkin 
	{
		return MovieSkin( _s );
	}
	

	/**
	 * Return the depth average of the face.
	 * <p>Useful for z-sorting.</p>
	 *
	 * @return	A Number as depth average.
	 */
	public function getZAverage( Void ) : Number 
	{
		return _va.wz;
	}

	/**
	 * Returns the min depth of its vertex.
	 * @param Void	
	 * @return number the minimum depth of it's vertex
	 */
	public function getMinDepth( Void ) : Number 
	{
		return _va.wz;
	}

	/**
	 * Returns the max depth of its vertex.
	 * @param Void	
	 * @return number the maximum depth of it's vertex
	 */
	public function getMaxDepth( Void ) : Number 
	{
		return _va.wz;
	}
	
	private var _nFrame:Number;
}