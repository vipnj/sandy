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

package
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.MaterialType;
	import sandy.materials.attributes.MaterialAttributes;

	public class UIMaterial extends BitmapMaterial
	{
		private var m_oTimer :Timer;
		private var m_oMovie : UIComponent;
		private var m_bUpdate : Boolean;

		/**
		 * Creates a new MovieMaterial.
		 *
		 * <p>The MovieClip used for the material may contain animation.<br/>
		 * It is converted to a bitmap to give it a perspective distortion.<br/>
		 * To see the animation the bitmap has to be recreated from the MovieClip on a regular basis.</p>
		 *
		 * @param p_oMovie 	The Movieclip to be shown by this material
		 * @param p_nUpdateMS	The update interval
		 * @param p_oAttr	The material attributes
		 * @param p_bRemoveTransparentBorder	Remove the transparent border
		 * @param p_nWidth	desired width ( chunk the movieclip )
		 * @param p_nHeight	desired height ( chunk the movieclip )
		 */
		public function UIMaterial( p_oMovie:UIComponent, p_nUpdateMS:uint = 40, p_oAttr:MaterialAttributes = null, p_bRemoveTransparentBorder:Boolean = false, p_nHeight:Number=0, p_nWidth:Number=0 )
		{
			var w : Number;
			var h : Number;
			
			if ( p_bRemoveTransparentBorder )
			{
				var tmpBmp : BitmapData = new BitmapData(  p_oMovie.width, p_oMovie.height, true, 0x00FF0000 );
				tmpBmp.draw( p_oMovie );
				var rect : Rectangle = tmpBmp.getColorBoundsRect( 0xFF000000, 0x00000000, false );
				w = rect.width;
				h = rect.height;
			}
			else 
			{
				w = p_nWidth ? p_nWidth :  p_oMovie.width;
				h = p_nHeight ? p_nHeight : p_oMovie.height;				
			}

			super( new BitmapData( w, h ), p_oAttr );	
			m_oMovie = p_oMovie;
			m_nType = MaterialType.MOVIE;
			// --
			m_bUpdate = true;
			m_oTimer = new Timer( p_nUpdateMS );
			m_oTimer.addEventListener(TimerEvent.TIMER, _update );
			m_oTimer.start();
			
			tmpBmp = null;
			rect = null;
			w = undefined;
			h = undefined;
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
			m_bUpdate = true;
			super.renderPolygon( p_oScene, p_oPolygon, p_mcContainer );
		}

		/**
		 * Updates this material each internal timer cycle.
		 */
		private function _update( p_eEvent:Event ):void
		{
			if ( m_bUpdate )
			{
				m_oTexture.fillRect( m_oTexture.rect, 0x00FFFFFF );
				// --
				m_oTexture.draw( m_oMovie );
			}
			m_bUpdate = false;
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
		
		/**
		 * Get the movieclip used for the material
		 */
		public function get movie() : UIComponent
		{
			return m_oMovie;
		}
		
	}
}
