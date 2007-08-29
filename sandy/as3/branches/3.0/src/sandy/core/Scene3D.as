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
	
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	
	public class Scene3D
	{
		public var camera:Camera3D;
		public var root:Group;
		public var container:DisplayObjectContainer;
		
		/**
		 * Create a new Scene.
		 * Each scene has its own container where its 2D representation will be drawn.
		 * 
		 * @param p_oContainer The container that will store all the
		 */
		public function Scene3D( p_oContainer:DisplayObjectContainer, p_oCamera:Camera3D, p_oRootNode:Group )
		{
			container = p_oContainer;
			camera = p_oCamera;
			root = p_oRootNode;	
		}
		
		/**
		 * Render the scene into the container display object container. 
		 * <p></p>
		 */
		public function render():void 
		{
			if( root && camera && container )
			{
				root.update( this, null, false );
				root.cull( this, camera.frustrum, camera.modelMatrix, camera.changed );
				root.render( this, camera );
				// -- clear the polygon's container and the projection vertices list
	            camera.renderDisplayList( this );
			}
		} // end method
		
		/**
		 * Dispose all the ressources of the given scene.
		 * TODO : Test it
		 */
		public function dispose():Boolean
		{
			root.destroy();
			return true;
		}
	}
}