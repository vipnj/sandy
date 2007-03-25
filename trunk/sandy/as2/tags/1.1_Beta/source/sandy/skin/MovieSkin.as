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

import flash.display.BitmapData;
import sandy.core.World3D;
import sandy.skin.SkinType;
import sandy.skin.TextureSkin;
import sandy.util.BitmapUtil;

/**
* MovieSkin
* Allow you to texture a 3D Object with a movieClip wich contains animation, picture, or video.
* @author		Thomas Pfeiffer - kiroukou
* @since		1.0
* @version		1.0
* @date 		22.04.2006 
**/
class sandy.skin.MovieSkin extends TextureSkin
{
	/**
	* Create a new MovieSkin.
	* 
	* @param mc MovieClip a MovieClip 
	* @param b	Boolean	if true we DISABLE the automatic update of the texture property.
	*/
	public function MovieSkin( mc:MovieClip, b:Boolean )
	{
		super( new BitmapData( mc._width-2, mc._height-2 , false ) );
		_mc = mc;
		b = (undefined == b) ? false: b;
		// TODO: Think again on which choice is clever, choosing the World3D framerate to update the texture
		// or to use the texture movieClip framerate as timer to update the bitmap.
		if( false == b ) 
		{
			World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, updateTexture );
		}
		else
		{
			_mc.stop();
		}
	}

	/**
	 * getType, returns the type of the skin
	 * @param Void
	 * @return	The appropriate SkinType
	 */
	public function getType ( Void ):SkinType
	{
		return SkinType.MOVIE;
	}
	
	/**
	* Returns the MovieClip used to texture objects with.
	* Usefull for example when you need to apply a function to the movieClip, such as stop(), gotoAndPlay(), etc..
	* @param	Void
	* @return	MovieClip The movieclip which is used to texture objects
	*/
	public function getMovie( Void ):MovieClip
	{
		return _mc;
	}
	
	/**
	* Give a string representation of the class
	* @param	Void
	* @return	String the string representing the object.
	*/
	public function toString( Void ):String
	{
		return 'sandy.skin.MovieSkin' ;
	}

	/**
	* Update the texture BitmapData with the current content of the actual frame of the movieclip.
	* @param	Void
	*/
	public function updateTexture( Void ):Void
	{
		_texture.dispose();
		texture = BitmapUtil.movieToBitmap( _mc, true );
	}
	
	// --
	private var _mc:MovieClip;
}
