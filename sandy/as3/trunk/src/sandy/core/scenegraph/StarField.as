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

package sandy.core.scenegraph 
{	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import sandy.bounds.BSphere;
	import sandy.core.Scene3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vertex;
	import sandy.events.BubbleEvent;
	import sandy.materials.Material;
	import sandy.view.CullingState;
	import sandy.view.Frustum;
	
	/**
	 * The StarField class renders dense star field at reasonable FPS.
	 *
	 * @author		makc
	 * @version		3.0.3
	 * @date 		03.03.2008
	 */
	public class StarField extends ATransformable implements IDisplayable
	{
		/**
		 * Distance from screen where stars start to fade out
		 */
		public var fadeFrom:Number = 0;

		/**
		 * Distance from fadeFrom to the point where stars fade out completely
		 */
		public var fadeTo:Number = 1000;

		/**
		 * Array of Vertex - star coordinates data.
		 */
		public var stars:Array = [];
		
		/**
		 * Array of star colors (if not specified, white is used).
		 */
		public var starColors:Array = [];

		/**
		 * Creates a StarField.
		 *
		 * @param p_sName	A string identifier for this object
		 */	
		public function StarField( p_sName:String = "") 
		{
			super(p_sName);
			// create something
			m_oContainer = new Sprite ();
			m_oBitmapData = new BitmapData (1, 1, true, 0);
			m_oBitmap = new Bitmap (m_oBitmapData);
			m_oContainer.addChild (m_oBitmap);
		}

		/**
		 * The container of this object
		 */
		public function get container():Sprite
		{
			return m_oContainer;
		}


		/**
		 * An index in stars array; if set to valid value, depth returns distance to that star.
		 */
		public var depthIndex:int = -1;

		/**
		 * The depth to draw the starfield at. If depthIndex is set to valid value,
		 * depth returns distance to that star, otherwise value set by user (default: 1e10).
		 */
		public function get depth ():Number
		{
			var v:Vertex = stars [depthIndex] as Vertex;
			if (v != null)
				return v.wz;

			return m_nDepth;
		}

		/**
		 * @private
		 */
		public function set depth (p_nDepth:Number):void
		{
			m_nDepth = p_nDepth;
		}
		  
		/**
		 * This tests for stars visibility.
		 *
		 * @param p_oScene The current scene
		 * @param p_oFrustum	The frustum of the current camera
		 * @param p_oViewMatrix	The view martix of the curren camera
		 * @param p_bChanged
		 */
		public override function cull( p_oScene:Scene3D, p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			super.cull( p_oScene, p_oFrustum, p_oViewMatrix, p_bChanged );
			// check if we need to resize our canvas
			if ((m_oBitmapData.width  != p_oScene.camera.viewport.width)
			 || (m_oBitmapData.height != p_oScene.camera.viewport.height))
			{
				m_oBitmap.bitmapData.dispose ();
				m_oBitmapData = new BitmapData (p_oScene.camera.viewport.width,
					p_oScene.camera.viewport.height, true, 0);
				m_oBitmap.bitmapData = m_oBitmapData;
			}
		}
		
		/**
		 * Renders the starfield
		 *
		 * @param p_oScene The current scene
		 * @param p_oCamera	The current camera
		 */
		public override function render( p_oScene:Scene3D, p_oCamera:Camera3D ):void
		{
			m_oBitmapData.fillRect (m_oBitmapData.rect, 0);
			m_oBitmapData.lock();
			// --
			var i:int = 0, c32:Number, a:Number, r:Number;
			for (i = 0; i < stars.length; i++)
			{
				var _v:Vertex = stars [i];
				_v.wx = _v.x * viewMatrix.n11 + _v.y * viewMatrix.n12 + _v.z * viewMatrix.n13 + viewMatrix.n14;
				_v.wy = _v.x * viewMatrix.n21 + _v.y * viewMatrix.n22 + _v.z * viewMatrix.n23 + viewMatrix.n24;
				_v.wz = _v.x * viewMatrix.n31 + _v.y * viewMatrix.n32 + _v.z * viewMatrix.n33 + viewMatrix.n34;

				if (_v.wz >= p_oScene.camera.near)
				{
					r = Math.min(1, Math.max (0, (_v.wz - fadeFrom) / fadeTo));
					if (r < 1)
					{
						// will uint and bit shift really make a difference?
						c32 = (i < starColors.length) ? starColors [i] : 0xFFFFFFFF;
						a = c32 / 0x1000000 * (1 - r);
						p_oCamera.projectVertex (_v);
						m_oBitmapData.setPixel32 (_v.sx, _v.sy, c32 & 0xFFFFFF + Math.floor (a) * 0x1000000);
					}
				}
			}
			m_oBitmapData.unlock();

			p_oCamera.addToDisplayList (this);
		}

		/**
		 * Clearing is done in render() method.
		 */	
		public function clear():void
		{
			;
		}

		/**
		 * Provide the classical remove behaviour, plus remove the container to the display list.
		 */
		public override function remove():void
		{
			m_oBitmap.bitmapData.dispose ();
			if( m_oContainer.parent )
				m_oContainer.parent.removeChild( m_oContainer );
			super.remove();
		}
		
		/**
		 * Displays the starfield.
		 *
		 * @param p_oScene The current scene
		 * @param p_oContainer	The container to draw on
		 */
		public function display( p_oScene:Scene3D, p_oContainer:Sprite = null  ):void
		{
			// viewport upper left?
			m_oContainer.x = 0;
			m_oContainer.y = 0;
		}
		
		private var m_nDepth:Number = 1e10;
		private var m_oContainer:Sprite;
		private var m_oBitmap:Bitmap;
		private var m_oBitmapData:BitmapData;
	}
}