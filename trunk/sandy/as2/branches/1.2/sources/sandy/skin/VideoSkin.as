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
import sandy.core.face.IPolygon;
import sandy.core.light.Light3D;
import sandy.core.World3D;
import sandy.math.VectorMath;
import sandy.skin.Skin;
import sandy.skin.SkinType;
import sandy.skin.TextureSkin;

/**
* VideoSkin
* Allow you to texture a 3D Object with a movieClip wich contains animation, picture, or video.
* @author		Thomas Pfeiffer - kiroukou
* @author		Bruce Epstein 	- zeusprod
* @since		1.0
* @version		1.2.1
* @date 		19.04.2007 
**/
class sandy.skin.VideoSkin extends TextureSkin
{
	/**
	* Create a new VideoSkin.
	* 
	* @param video Video a video object instance
	* @param bSmooth : Boolean; if true perform smoothing (performance-intensive).
	* @param a: Number; Transparency from 0 (invisible) to 100 (opaque)
	*/
	public function VideoSkin( video:Video, bSmooth:Boolean, a:Number )
	{
		super( new BitmapData( video._width, video._height ),  bSmooth, a);
		_video = video;
		// TODO: Think again on which choice is clever, choosing the World3D framerate to update the texture
		// or to use the texture movieClip framerate as timer to update the bitmap.
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __updateTexture );
	}

	/**
	 * getType, returns the type of the skin
	 * @param Void
	 * @return	The appropriate SkinType
	 */
	 public function getType ( Void ):SkinType
	 {
	 	return SkinType.VIDEO;
	 }
	 
	 /**
	* Returns the name of the skin you are using.
	* For the VideoSkin class, this value is set to "VIDEO"
	* @param	Void
	* @return String representing your skin.
	*/
	public function getName( Void ):String
	{
		return "VIDEO";
	}

	public function toString( Void ):String
	{
		return 'sandy.skin.VideoSkin' ;
	}

	
	private function __updateTexture():Void
	{
		texture.draw( _video );  // The BitmpaData.draw() method causes a Flash Player security warning when using content from an untrusted domain.
		// le broadcast ne se fait pas tout seul? car pas de set texture() de réaliser?
		broadcastEvent( _eOnUpdate );
	}
	
	// --
	private var _video:Video;
}
