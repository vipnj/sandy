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
	
	[Event(name="containerCreated", type="sandy.core.SandyEvent")]
	[Event(name="lightAdded", type="sandy.core.SandyEvent")]
	[Event(name="render", type="sandy.core.SandyEvent")]
		
	/**
	* The 3D world for displaying the Objects.
	* <p>World3D is a singleton class, it's the central point of Sandy :
	* <br/>You can have only one World3D, which contain Groups, Cameras and Lights</p>
	*
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @see			sandy.core.Object3D
	**/
	public class World3D extends EventDispatcher
	{
		public var root:Group;
		public var camera:Camera3D;
		public var container:Sprite;
		/**
		 * Constructor.
		 * <p>You can have only one World3D</p>
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
		 * Get the Singleton instance of World3D.
		 * @return World3D, the only one instance possible
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
		 * We set the unique ligth of the 3D world.
		 * @param	l	Light3D		The light instance
		 * @return	void	nothing
		 */
		public function set light ( l:Light3D ):void
		{
			if(_light) _light.destroy();
			// --
			_light = l;
			dispatchEvent( new SandyEvent( SandyEvent.LIGHT_ADDED ) );
		}
		
		/**
		 * Returns the world light reference.
		 * @param void	Nothing
		 * @return	Light3D	The light reference
		 */
		public function get light():Light3D
		{
			return _light;
		}
	
		/**
		 * Call the recurssive rendering of all the children of this branchGroup.
		 * This is the most important method in all the engine, because the mojority of the computations are done here.
		 * This method is making the points transformations and 2D projections.
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