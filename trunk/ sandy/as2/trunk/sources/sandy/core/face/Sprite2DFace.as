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
import sandy.core.Sprite2D;
import sandy.skin.TextureSkin;
import sandy.view.Camera3D;
import sandy.core.data.Vector;
import sandy.core.World3D;

/**
* Sprite2DFace
* Create the face needed by the Sprite2D object. This face fits perfectly the Sprite2D needs.
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		12.05.2006 
**/
class sandy.core.face.Sprite2DFace extends TriFace3D
{
	
	/**
	* Create a Sprite2DFace. This constructor should be created only by the Sprite or derivated class.
	* @param	oref
	* @param	pt
	*/
	public function Sprite2DFace( oref:Sprite2D, pt:Vertex ) 
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
	 * <p>Say if the face is visible or not
	 * This methods returns always true in the Sprite2D case.</p>
	 *
	 * @param Void
	 * @return a Boolean, true if visible, false otherwise
	 */	
	public function isVisible( Void ): Boolean
	{
		return true;
	}
	
	/** 
	 * Render the face into a MovieClip.
	 *
	 * @param	{@code mc}	A {@code MovieClip}.
	 * @param	id			A Number which is the camera identifiant
	 */
	public function render( mc:MovieClip ):Void
	{
		_mc = mc;
		var t:TextureSkin = TextureSkin( _s );
		mc.attachBitmap( t.texture, 1 );
		// --
		var sv:Vector 	= Sprite2D(_o).getScaleVector();
		var s:Number 	= Sprite2D(_o).getScale();
		// --
		var cste:Number	= 100 / _va.wz;
		mc._width 	= t.texture.width  * (s * sv.x * cste);
		mc._height 	= t.texture.height * (s * sv.y * cste);
		// --
		mc._x = _va.sx - mc._width  / 2;
		mc._y = _va.sy - mc._height / 2;
		// --
		mc.filters = t.filters;
	}
	
	/** 
	 * Refresh the face display
	 */
	public function refresh( Void ):Void
	{
		_mc.clear();
		var t:TextureSkin = TextureSkin( _s );
		_mc.attachBitmap( t.texture, 1 );
		// --
		var sv:Vector 	= Sprite2D(_o).getScaleVector();
		var s:Number 	= Sprite2D(_o).getScale();
		// --
		var cste:Number	= 100 / _va.wz;
		_mc._width 	= t.texture.width  * (s * sv.x * cste);
		_mc._height = t.texture.height * (s * sv.y * cste);
		// --
		_mc._x = _va.sx - _mc._width  / 2;
		_mc._y = _va.sy - _mc._height / 2;
		// --
		_mc.filters = t.filters;
	}
	
	/**
	* Set the skin for that SpriteFace. This skin must be a TextureSkin or a derivated class. Others skins can't be applied
	* @param	s TextureSkin The skin
	*/
	public function setSkin(s : TextureSkin) : Void 
	{
		if( s instanceof TextureSkin )
			_s = s;
	}

	/**
	* Returns the skin of this SpriteFace which is a TextureSkin.
	* @return TextureSkin the skin of this face
	*/
	public function getSkin( Void ) : TextureSkin 
	{
		return TextureSkin( _s );
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

}