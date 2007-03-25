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
package sandy.skin {

	import flash.display.BitmapData;
	import flash.display.Video;
	import sandy.core.face.IPolygon;
	import sandy.core.light.Light3D;
	import sandy.core.World3D;
	import sandy.math.VectorMath;
	import sandy.skin.Skin;
	import sandy.skin.SkinType;
	import sandy.skin.TextureSkin;

	import sandy.events.SandyEvent;
	
	/**
	* VideoSkin
	* Allow you to texture a 3D Object with a movieClip wich contains animation, picture, or video.
	* @author		Thomas Pfeiffer - kiroukou
	* @since		1.0
	* @version		1.0
	* @date 		22.04.2006 
	**/
	public class VideoSkin extends TextureSkin
	{
		/**
		* Create a new VideoSkin.
		* 
		* @param video Video a video object instance
		*/
		public function VideoSkin( video:Video )
		{
			super( new BitmapData( video.width, video.height ) );
			_video = video;
			// TODO: Think again on which choice is clever, choosing the World3D framerate to update the texture
			// or to use the texture movieClip framerate as timer to update the bitmap.
			World3D.getInstance().addEventListener( SandyEvent.RENDER, __updateTexture );
		}

		/**
		 * getType, returns the type of the skin
		 * @param void
		 * @return	The appropriate SkinType
		 */
		 public function getType ():SkinType
		 {
			return SkinType.VIDEO;
		 }

		
		private function __updateTexture():void
		{
			texture.draw( _video );
			// le broadcast ne se fait pas tout seul? car pas de set texture() de réaliser?
			dispatchEvent( updateEvent );
		}
		
		// --
		private var _video:Video;
	}
}