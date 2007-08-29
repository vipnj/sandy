/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author Thomas PFEIFFER
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
	import flash.utils.Dictionary;
	
	import sandy.core.data.Vector;
	import sandy.core.light.Light3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.errors.SingletonError;
	import sandy.events.SandyEvent;
	
	[Event(name="containerCreated", type="sandy.events.SandyEvent")]
	[Event(name="lightAdded", type="sandy.events.SandyEvent")]
		
	/**
	 * The Sandy 3D world.
	 *
	 * <p>The World3D object is the central point of Sandy.<br/>
	 * World3D is a singleton class, which means that you can have only one World3D instance.<br/>
	 * It contains the object tree with groups, a camera, a light source and a canvas to draw on</p>
	 *
	 * @example	To create the world instance, you call the getInstance() class method.<br/>
	 * To make the world visible, you add a canvas to draw on ( normally a Sprite ), and add a camera.<br/>
	 * The rendering of the world is driven by a "heart beat", which may be a Timer or the Event.ENTER_FRAME event.
	 *
	 * <listing version="3.0">
	 *     	var world:World3D = World3D.getInstance();
	 *	world.container = this; // The document calss is a Sprite or MovieClip
	 *	world.camera = new Camera3D( 200, 200 );
	 *	world.root.addChild( world.camera );
	 *	// Go on to create the 3D objects and transforms
	 *	world.root = createScene();
	 *	// Listen for the ENTER-FRAME event. 
	 *	//The handler calls the world.render() method to render the world for each frame.
	 *	addEventListener( Event.ENTER_FRAME, enterFrameHandler );
	 *  </listing>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007	 
	 **/
	public class World3D extends EventDispatcher
	{
		public function get root():Group
		{
			return defaultScene.root;
		}
		
		public function get camera():Camera3D
		{
			return defaultScene.camera;
		}
		
		public function get container():DisplayObjectContainer
		{
			return defaultScene.container;
		}
		
		public function set root( p_oRoot:Group ):void
		{
			defaultScene.root = p_oRoot;
		}
		
		public function set camera( p_oCamera:Camera3D ):void
		{
			defaultScene.camera = p_oCamera;
		}
		
		public function set container( p_oContainer:DisplayObjectContainer ):void
		{
			defaultScene.container = p_oContainer;
		}
		
		public var defaultScene:Scene3D;
		
		private var m_oSceneMap:Dictionary = new Dictionary( true );
		
		
		/**
		 * Create a new scene instance
		 * @param p_sName The name of the scene to create. This name will be used later to get back the scene instance
		 * @param p_oContainer The scene container to use
		 * @param p_oCamera The corresponding scene camera
		 * @param p_oRootNode The root group instance
		 * 
		 * @return The scene instance that has been created, or null in case a scene already exists with the given name
		 */
		public function createScene( p_sName:String, p_oContainer:DisplayObjectContainer, p_oCamera:Camera3D, p_oRootNode:Group ):Scene3D
		{
			if( m_oSceneMap[ p_sName ] == null )
			{
				m_oSceneMap[ p_sName ] = new Scene3D( p_oContainer, p_oCamera, p_oRootNode );
				return m_oSceneMap[ p_sName ];
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * Delete the specified scene.
		 * The scene to delete must be specified by its name. If you know the scene instance, call its dispose method directly.
		 * 
		 * @param p_sName THe name of the scene to delete
		 * 
		 * @return true is the scene is correctly removed, false otherwise.
		 */
		public function deleteScene( p_sName:String ):Boolean
		{
			if( m_oSceneMap[ p_sName ] == null ) return false;
			else
			{
				( m_oSceneMap[ p_sName ] as Scene3D ).dispose();
				m_oSceneMap[ p_sName ] = null;
				return true;
			}
		}
		
		/**
		 * Creates a single instance of World3D.
		 *
		 * <p>You can have only one World3D instance in a Flash movie.</p>
		 * 
		 */
		public function World3D ()
		{
			if ( !create )
			{
				throw new SingletonError();
			}
			else
			{ 
				// default light
				_light = new Light3D( new Vector( 0, 0, 1 ), 50 );
				defaultScene = createScene("default", null, null, null );
			}
		}
		
		/**
		 * Returns an instance of World3D.
		 * 
		 * @return	The single World3D instance
		 */
		public static function getInstance() : World3D
		{
			if (instance == null)
			{
				create = true;
				instance = new World3D();
				create = false;
			}
			
			return instance;
		}
		

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

		// Developer comments go here ...	
		/**
		 * Renders all the scenes registered into the world3D.
		 * The default scene is also rendered.
		 * 
		 * <p>We loop through the scenes, and render them sequentially</p>
		 * TODO: Think about a way to specify an order of rendering in case it is usefull
		 */
		public function render():void 
		{
			for each( var l_oScene:Scene3D in m_oSceneMap )
			{
				l_oScene.render();
			}
		} // end method
	
		
		public override function toString():String
		{
			return "sandy.core.World3D";
		}
	
	
		////////////////////
		//// PRIVATE
		////////////////////
		private var _light : Light3D; //the unique light instance of the world
		private static var instance:World3D;
		private static var create:Boolean;
	}
}