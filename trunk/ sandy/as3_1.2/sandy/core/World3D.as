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
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import sandy.core.data.BBox;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.face.Polygon;
	import sandy.core.group.Group;
	import sandy.core.group.INode;
	import sandy.core.group.Node;
	import sandy.core.light.Light3D;
	import sandy.events.SandyEvent;
	import sandy.math.FastMath;
	import sandy.math.Matrix4Math;
	import sandy.view.Camera3D;
	
	/**
	* The 3D world for displaying the Objects.
	* <p>World3D is a singleton class, it's the central point of Sandy :
	* <br/>You can have only one World3D, which contain Groups, Cameras and Lights</p>
	*
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		16.05.2006
	* @see			sandy.core.Object3D
	* 
	**/
	public class World3D extends EventDispatcher
	{
		
		/**
		 * Private Constructor.
		 * 
		 * <p>You can have only one World3D</p>
		 * 
		 */
		public function World3D (sb:SingletonBlocker)
		{
			// default light
			_light = new Light3D( new Vector( 0, 0, 1 ), 50 );
			_isRunning = false;
			
			trace("World3D start");
		}
		
		public function setContainer( mc:DisplayObjectContainer ):void
		{
			mc.cacheAsBitmap = true;
			
			_bg = new Sprite();
			_bg.cacheAsBitmap = true;
			mc.addChild(_bg);
			
			_scene = new Sprite();
			_scene.cacheAsBitmap = true;
			mc.addChild(_scene);
			
			dispatchEvent(containerCreatedEvent);
		}
		
		public function clearSceneContainer():DisplayObjectContainer
		{
			_scene.parent.removeChild(_scene);
			_scene = new Sprite();
			_bg.parent.addChild(_scene);
			
			return _scene;
		}
		
		public function getSceneContainer():DisplayObjectContainer
		{
			return _scene;
		}
		
		public function getBGContainer():DisplayObjectContainer
		{
			return _bg;
		}
		
		/**
		* Allows to get the array of all the objects
		* @param	void
		* @return 	Object3D array
		*/
		public function getObjects():Array
		{
			return _aObjects;
		}
		
		/**
		 * Get the Singleton instance of World3D.
		 * 
		 * @return World3D, the only one instance possible
		 */
		public static function getInstance() : World3D
		{
			if (!_inst) _inst = new World3D( new SingletonBlocker());
			return _inst;
		}
		
		/**
		 * Set the {@code Camera3D} of the world.
		 * 
		 * @param	cam	The new {@link Camera3D}
		 */	
		public function setCamera ( pCam:Camera3D ):void
		{
			_oCamera = pCam;
		}
		
		/**
		 * Get the {@code Camera3D} of the world.
		 * 
		 * @return	 The {@link Camera3D}
		 */	
		public function getCamera ():Camera3D
		{
			return _oCamera;
		}	
		
		/**
		 * We set the unique ligth of the 3D world.
		 * @param	l	Light3D		The light instance
		 * @return	void	nothing
		 */
		public function setLight ( l:Light3D ):void
		{
			if(_light) _light.destroy();
			// --
			_light = l;
			dispatchEvent( lightAddedEvent ); 
		}
		
		/**
		 * Returns the world light reference.
		 * @param void	Nothing
		 * @return	Light3D	The light reference
		 */
		public function getLight ():Light3D
		{
			return _light;
		}
		
		/**
		* Add a {@code Group} to the world.
		* 
		* @param	objGroup	The group to add. It must not be a transformGroup !
		* @return	Number		The identifier of the object in the list. With that you will be able to use getGroup method.
		*/
		public function setRootGroup( objGroup:Group ) :void
		{
			// check if this node have a parent?!!
			_oRoot = objGroup;
		}
		
		/**
		* Get the root {@code Group} of the world.
		*
		* @return	Group	THe root group of the World3D instance.
		*/
		public function getRootGroup():Group
		{
			return _oRoot;
		}
		
		/**
		* Compute all groups, and draw them.
		* Should be call only once, or everytime after a Wordl3D.stop call.
		*/
		public function render () : void
		{	
			if( !_isRunning)
			{
				_isRunning = true;
				dispatchEvent( startEvent )
				getSceneContainer().addEventListener(Event.ENTER_FRAME, __onEnterFrame);
			}
		}

		/**
		 * Stop the rendering of the World3D.
		 * You can start again th rendering by calling render method.
		 */	
		public function stop():void
		{
			_isRunning = false;
		}
		
		/**
		 * Method called every time.
		 */
		public function __onEnterFrame(e:Event):void
		{
			//-- we broadcast the event
			dispatchEvent( renderEvent );
			//-- we make the active BranchGroup render
			__render();
		}
		
		/**
		* Allows to get the current matrix projection ( usefull since there's several cameras allowed )
		* @param	void
		* @return Matrix4 The current projection matrix
		*/
		public function getCurrentProjectionMatrix():Matrix4
		{
			return _mProj;
		}

		////////////////////
		//// PRIVATE
		////////////////////
		/**
		 * Call the recurssive rendering of all the children of this branchGroup.
		 * This is the most important method in all the engine, because the mojority of the computations are done here.
		 * This method is making the points transformations and 2D projections.
		 */
		private function __render() : void 
		{
			// we set a variable to remember the number of objects and in the same time we strop if no objects are displayable
			if( _oRoot)
			{
    			_oCamera.compile();
    			_oCamera.clearDisplayList();
    			_oRoot.render( _oCamera, null, false );
                _oCamera.renderDisplayList( _scene );
            }
   
		} // end method

		
		override public function toString():String
		{
			return "sandy.core.World3D";
		}
		
		private var _mProj:Matrix4;
		private var _oCamera:Camera3D;
		private var _oRoot:Group;
		private var _aGroups:Array;//_aGroups : The Array of {@link Group}
		private var _aCams:Array/*Camera3D*/;	
		private static var _inst:World3D;//_inst : The only one World3D permit
		private var _light : Light3D; //the unique light instance of the world
		private var _isRunning:Boolean;
		private var _bGlbCache:Boolean;
		private var _aObjects:Array;
		private var _aMatrix:Array;
		private var _aCache:Array;
		
		private var containerCreatedEvent:Event = new Event(SandyEvent.CONTAINER_CREATED);
		private var lightAddedEvent:Event = new Event(SandyEvent.LIGHT_ADDED);
		private var startEvent:Event = new Event(SandyEvent.START);
		private var renderEvent:Event = new Event(SandyEvent.RENDER);
		
		private var _scene : Sprite;
		private var _bg : Sprite;
	}
}

class SingletonBlocker {}