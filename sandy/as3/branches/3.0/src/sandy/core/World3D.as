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
	import sandy.errors.SingletonError;
	import sandy.events.SandyEvent;
	
	[Event(name="containerCreated", type="sandy.events.SandyEvent")]
	[Event(name="lightAdded", type="sandy.events.SandyEvent")]
	[Event(name="render", type="sandy.events.SandyEvent")]
		
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
		public var root:Group;
		public var camera:Camera3D;
		public var container:Sprite;
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
				container = null;
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
		 * Renders all visible objects in the object tree of the world.
		 * 
		 * <p>This is the most important method in all the engine, 
		 * because the majority of the computations are done here.<br/>
		 * It takes care of all transformations and 2D projections.</p>
		 */
		public function render():void 
		{
			// we set a variable to remember the number of objects 
			// and in the same time we strop if no objects are displayable
			if( root && camera && container )
			{
				//dispatchEvent( new SandyEvent( SandyEvent.RENDER ) );
				// --
				root.update( null, false );
				root.cull( camera.frustrum, camera.modelMatrix, camera.changed );
				//root.cull( camera.frustrum, camera.transform.matrix, camera.changed );
				root.render( camera );
				// -- clear the polygon's container and the projection vertices list
	            //camera.project();
	            camera.renderDisplayList();
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