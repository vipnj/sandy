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


import com.bourre.events.BasicEvent;
import com.bourre.events.EventBroadcaster;
import com.bourre.events.EventType;

import sandy.core.data.Matrix4;
import sandy.core.data.Vector;
import sandy.core.light.Light3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
	
/**
* The 3D world for displaying the Objects.
* <p>World3D is a singleton class, it's the central point of Sandy :
* <br/>You can have only one World3D, which contain Groups, Cameras and Lights</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @see			sandy.core.Object3D
**/
class sandy.core.World3D
{
	public static var onLightAddedEVENT:EventType 	= new EventType( 'onLightAdded' );
	
	public static var onRenderEVENT:EventType 	= new EventType( 'onRender' );
	
	public static var onContainerCreatedEVENT:EventType = new EventType( 'onContainerCreated' );
	
	public var root:Group;
	public var camera:Camera3D;
			
	/**
	 * Private Constructor.
	 * <p>You can have only one World3D</p>
	 * 
	 */
	private function World3D ()
	{
		// init the event broadcaster
		_oEB = new EventBroadcaster( this );
		// default light
		_light = new Light3D( new Vector( 0, 0, 1 ), 50 );
		
		_eOnRender = new BasicEvent( onRenderEVENT );
		
		_container = null;
	}
	
	public function set container( pContainer:MovieClip )
	{
		_container = pContainer;
		_oEB.broadcastEvent( new BasicEvent( World3D.onContainerCreatedEVENT ) ); 
	}

	
	public function get container():MovieClip
	{
		return _container;
	}
	
	/**
	 * Add a listener for a specific event.
	 * @param t EventType The type of event we want to register
	 * @param o The object listener
	 */
	public function addEventListener( e:EventType, o ) : Void
	{
		_oEB.addEventListener.apply( _oEB, arguments );
	}
	
	/**
	 * Remove a listener for a specific event.
	 * @param e EventType The type of event we want to register
	 * @param oL The object listener
	 */
	public function removeEventListener( e:EventType, oL ) : Void
	{
		_oEB.removeEventListener( e, oL );
	}
	
	/**
	 * Get the Singleton instance of World3D.
	 * @return World3D, the only one instance possible
	 */
	public static function getInstance() : World3D
	{
		if (!_inst) _inst = new World3D();
		return _inst;
	}	
	
	/**
	 * We set the unique ligth of the 3D world.
	 * @param	l	Light3D		The light instance
	 * @return	Void	nothing
	 */
	public function set light ( l:Light3D )
	{
		if(_light) _light.destroy();
		// --
		_light = l;
		_oEB.broadcastEvent( new BasicEvent( World3D.onLightAddedEVENT ) ); 
	}
	
	/**
	 * Returns the world light reference.
	 * @param Void	Nothing
	 * @return	Light3D	The light reference
	 */
	public function get light():Light3D
	{
		return _light;
	}
	
	/**
	* Allows to get the current matrix projection ( usefull since there's several cameras allowed )
	* @param	Void
	* @return Matrix4 The current projection matrix
	*/
	public function getCurrentProjectionMatrix():Matrix4
	{
		if( camera ) return camera.getProjectionMatrix();
		else return null;
	}

	/**
	 * Call the recurssive rendering of all the children of this branchGroup.
	 * This is the most important method in all the engine, because the mojority of the computations are done here.
	 * This method is making the points transformations and 2D projections.
	 */
	public function render( Void ):Void 
	{
		// we set a variable to remember the number of objects 
		// and in the same time we strop if no objects are displayable
		if( root && camera && _container )
		{
			_oEB.broadcastEvent( _eOnRender );
			// -- clear the polygon's container and the projection vertices list
            camera.iRenderer.clear();
			// --
			root.update( null, false );
			root.cull( camera.frustrum, camera.transform.matrix, camera.changed );
			root.render( camera, null, false );
			// --
			camera.project();
        	}
			// -- clear the polygon's container and the projection vertices list
            camera.iRenderer.clear();
            camera.iRenderer.render();
	} // end method

	
	public function toString():String
	{
		return "sandy.core.World3D";
	}


	////////////////////
	//// PRIVATE
	////////////////////
	private var _container:MovieClip;
	private static var _inst:World3D;//_inst : The only one World3D permit
	private var _oEB:EventBroadcaster;//_oEB : The EventBroadcaster instance which manage the event system of world3D.
	private var _light : Light3D; //the unique light instance of the world
	private var _eOnRender:BasicEvent;
}
