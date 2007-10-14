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

package sandy.materials
{
	import flash.display.*;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.materials.attributes.MaterialAttributes;

	/**
	 * Displays a MovieClip on the faces of a 3D shape.
	 *
	 * <p>Based on the AS2 class VideoSkin made by kiroukou and zeusprod</p>
	 *
	 * @author		Xavier Martin - zeflasher
	 * @author		Thomas PFEIFFER - kiroukou
	 * @since		1.0
	 * @version		3.0
	 * @date 		26.06.2007
	 */
	public class MovieMaterial extends BitmapMaterial
	{
		private var m_oTimer :Timer;
		private var m_oMovie : MovieClip;
		private var m_nFillColor : uint;

		/**
		 * Creates a new MovieMaterial.
		 *
		 * <p>The MovieClip used for the material may contain animation.<br/>
		 * It is converted to a bitmap to give it a perspective distortion.<br/>
		 * To see the animation the bitmap has to be recreated from the MovieClip on a regular basis.</p>
		 *
		 * @param p_oMovie 	The Movieclip to be shown by this material
		 * @param p_nUpdateMS	The update interval
		 * @param p_nFillColor	The fill color
		 */
		public function MovieMaterial( p_oMovie:MovieClip, p_nUpdateMS:uint = 40, p_nFillColor:uint = 0xFF000000, p_oAttr:MaterialAttributes = null )
		{
			super( new BitmapData( p_oMovie.width, p_oMovie.height, false, 0xFF000000 ), p_oAttr );
			m_oMovie = p_oMovie;
			m_nType = MaterialType.MOVIE;
			m_nFillColor = p_nFillColor;
			// --
			m_oTimer = new Timer( p_nUpdateMS );
			m_oTimer.addEventListener(TimerEvent.TIMER, _update );
			m_oTimer.start();
		}


		/**
		 * Renders this material on the face it dresses.
		 *
		 * @param p_oScene		The current scene
		 * @param p_oPolygon	The face to be rendered
		 * @param p_mcContainer	The container to draw on
		 */
		public override function renderPolygon ( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ) : void
		{
			super.renderPolygon( p_oScene, p_oPolygon, p_mcContainer );
		}

		/**
		 * Updates this material each internal timer cycle.
		 */
		private function _update( p_eEvent:TimerEvent ):void
		{
			m_oTexture.fillRect( m_oTexture.rect, m_nFillColor );
			// --
			m_oTexture.draw( m_oMovie );
		}
		
		/**
		 * Call this method when you want to start the material update.
		 * This is automatically called at the material creation so basically it is used only when the MovieMaterial::stop() method has been called
		 */
		public function start():void
		{
			m_oTimer.start();
		}
		
		/**
		 * Call this method is case you would like to stop the automatic MovieMaterial texture update.
		 */
		public function stop():void
		{
			m_oTimer.stop();
		}
		
	}
}
