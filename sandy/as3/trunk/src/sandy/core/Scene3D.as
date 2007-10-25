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
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	import sandy.core.data.Vector;
	import sandy.core.light.Light3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.events.SandyEvent;

	/**
	 * The Scene3D object is the central point of a Sandy world.
	 *
	 * <p>You can have multiple Scene3D objects in the same application.<br/>
	 * The older World3D is a singleton special case of Scene3D.<br />
	 * The scene contains the object tree with groups, a camera, a light source and a canvas to draw on.</p>
	 *
	 * @example	To create a scene, you pass a container, a camera and a root group to its constructor.<br/>
	 * The rendering of the world is driven by a "heart beat", which may be a Timer or the Event.ENTER_FRAME event.
	 *
	 * <listing version="3.0">
	 * 	var camera:Camera3D = new Camera3D( 400, 300 );
	 * 	camera.z = -200;
	 * 	// The call to createScene() will create the root Group of this scene
	 * 	var scene:Scene3D = new Scene3D('Scene 1',this, camera, createScene());
	 * 	scene.root.addChild( camera );
	 * 	//The handler calls the world.render() method to render the world for each frame.
	 * 	addEventListener( Event.ENTER_FRAME, enterFrameHandler );
	 * </listing>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		07.09.2007
	 */
	public class Scene3D extends EventDispatcher
	{
		/**
		 * The camera looking at this scene.
		 */
		public var camera:Camera3D;

		/**
		 * The root of the scene graph for this scene.
		 */
		public var root:Group;

		/**
		 * The container that stores all displayabel objects for this scene.
		 */
		public var container:Sprite;

		
		/**
		 * Creates a new Scene.
		 *
		 * <p>Each scene has its own container where its 2D representation will be drawn.<br />
		 * The scene is automatically registered with the SceneLocator.</p>
		 * <p>Remember to give the scenes different names if you want to use the SceneLocator registry</p>
		 *
		 * @param p_sName	The name of this scene
		 * @param p_oContainer 	The container that will store all displayable objects for this scene
		 * @param p_oCamera	The single camera for this scene
		 * @param p_oRootNode	The root group of the object tree for this scene
		 */
		public function Scene3D( p_sName : String, p_oContainer:Sprite,
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
			_light = new Light3D( new Vector( 0, 0, 1 ), 100 );
		}


		public function get rectClipping():Boolean
		{return m_bRectClipped;}
		
		/**
		 * Enable this property (default value is false) to perfectly clip your 3D scene to the viewport dimension.
		 * Once enabled, even if you don't have enableClipping set to true for each of your objects, nothing will be drawn outside
		 */
		public function set rectClipping( p_bEnableClipping:Boolean ):void
		{ 
			m_bRectClipped = p_bEnableClipping;
			// -- we force the new state of the rectClipping property to be applied
			if( camera ) camera.viewport.hasChanged = true;
		}

		/**
		 * Renders this scene into its display object container.
		 *
		 * @param p_oEvt	An eventual event - defaults to null
		 */
		public function render( p_oEvt : SandyEvent = null ):void
		{
			if( root && camera && container )
			{
				//container.stage.frameRate *= 1.5;
				
				dispatchEvent( new SandyEvent( SandyEvent.SCENE_UPDATE ) );
				root.update( this, null, false );
				// --
				dispatchEvent( new SandyEvent( SandyEvent.SCENE_CULL ) );
				root.cull( this, camera.frustrum, camera.invModelMatrix, camera.changed );
				// --
				dispatchEvent( new SandyEvent( SandyEvent.SCENE_RENDER ) );
				root.render( this, camera );
				
				//container.stage.frameRate /= 1.5;
				
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
		 * The simple light of this scene.
		 *
		 * @see sandy.core.light.Light3D
		 */
		public function get light():Light3D
		{
			return _light;
		}

		/**
		 * Dispose all the resources of this given scene.
		 *
		 * <p>[<strong>ToDo</strong>: Test it ]</p>
		 */
		public function dispose():Boolean
		{
			root.destroy();
			return true;
		}
		
		private var m_bRectClipped:Boolean = false;
		private var _light:Light3D; 	//the unique light instance of the world
	}
}