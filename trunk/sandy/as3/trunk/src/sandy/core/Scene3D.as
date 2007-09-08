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

package sandy.core
{
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	
	import sandy.core.data.Vector;
	import sandy.core.light.Light3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.events.SandyEvent;

	public class Scene3D extends EventDispatcher
	{
		public var camera:Camera3D;
		public var root:Group;
		public var container:DisplayObjectContainer;
		
		/**
		 * Flag to control lighting model. If true then lit objects have full range from black to white.
		 * If its false (the default) they just range from black to their normal appearance.
		 */ 
		public var useBright:Boolean = false;
	
		/**
		 * Ambient light that will be added to the scene light once added to a material
		 */
		public var ambientLight:Number = 0.3;

		private var _light:Light3D; 	//the unique light instance of the world

		/**
		 * Create a new Scene.
		 * Each scene has its own container where its 2D representation will be drawn.
		 *
		 * @param p_oContainer The container that will store all the
		 */
		public function Scene3D( 	p_sName : String, p_oContainer:DisplayObjectContainer,
					 				p_oCamera:Camera3D, p_oRootNode:Group )
		{
			if ( p_sName != null )
			{
				if ( SceneLocator.getInstance().registerScene( p_sName, this ) )
				{
					container = p_oContainer;
					camera = p_oCamera;
					root = p_oRootNode;
					if ( root != null && camera != null ) root.addChild( camera );
				}
			}
			// --
			_light = new Light3D( new Vector( 0, 0, 1 ), 50 );
		}


		/**
		 * Render the scene into the display object container.
		 * <p></p>
		 */
		public function render( e : SandyEvent = null ):void
		{
			if( root && camera && container )
			{
				dispatchEvent( new SandyEvent( SandyEvent.SCENE_UPDATE ) );
				root.update( this, null, false );
				// --
				dispatchEvent( new SandyEvent( SandyEvent.SCENE_CULL ) );
				root.cull( this, camera.frustrum, camera.modelMatrix, camera.changed );
				// --
				dispatchEvent( new SandyEvent( SandyEvent.SCENE_RENDER ) );
				root.render( this, camera );
				// -- clear the polygon's container and the projection vertices list
				dispatchEvent( new SandyEvent( SandyEvent.SCENE_RENDER_DISPLAYLIST ) );
	            		camera.renderDisplayList( this );
			}
		} // end method

		/**
		 * @private
		 */
		public function set light ( l:Light3D ):void
		{
			if(_light) _light.destroy();
			// --
			_light = l;
			dispatchEvent( new SandyEvent( SandyEvent.LIGHT_ADDED ) );
		}

		/**
		 * The simple light of this world.
		 *
		 * @see sandy.core.light.Light3D
		 */
		public function get light():Light3D
		{
			return _light;
		}

		/**
		 * Dispose all the resources of this given scene.
		 * TODO : Test it
		 */
		public function dispose():Boolean
		{
			root.destroy();
			return true;
		}
	}
}