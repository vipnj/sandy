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

package sandy.core {

	import sandy.core.buffer.MatrixBuffer;
	import sandy.core.buffer.ZBuffer;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.data.BBox;
	import sandy.core.group.Group;
	import sandy.core.group.INode;
	import sandy.core.group.Node;
	import sandy.core.light.Light3D;
	import sandy.core.Object3D;
	import sandy.math.Matrix4Math;
	import sandy.view.Camera3D;
	import sandy.view.IScreen;
	import sandy.core.light.Light3D;

	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	
	import sandy.events.SandyEvent;
	import sandy.math.FastMath;
	
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
			trace("FastMath Test: FastMath.cos(10): " + FastMath.sin(10));
			trace("FastMath Test: Math.cos(10): " + Math.sin(10));
		
			
			//setContainer(l_container);
		}
		
		public function setContainer( mc:DisplayObjectContainer):void
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
			//FPSBeacon.getInstance().stop();
			//FPSBeacon.getInstance().removeFrameListener( new Delegate( this, __onEnterFrame ) );
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
			var l:Number, lp:Number, vx:Number, vy:Number, vz:Number, offx:Number, offy:Number, nbObjects:Number;
			var mp11:Number,mp21:Number,mp31:Number,mp41:Number,mp12:Number,mp22:Number,mp32:Number,mp42:Number,mp13:Number,mp23:Number,mp33:Number,mp43:Number,mp14:Number,mp24:Number,mp34:Number,mp44:Number;
			var m11:Number,m21:Number,m31:Number,m41:Number,m12:Number,m22:Number,m32:Number,m42:Number,m13:Number,m23:Number,m33:Number,m43:Number,m14:Number,m24:Number,m34:Number,m44:Number;
			var aV:Array;
			var mp:Matrix4, m:Matrix4, mt:Matrix4;
			var cam:Camera3D ;
			var camCache:Boolean;
			var obj:Object3D;
			var v:Vertex;
			var crt:Node, crtId:Number;
			
			// we set a variable to remember the number of objects and in the same time we strop if no objects are displayable
			if( !_oRoot)
			{
				return;
			}
			
			//-- we initialize
			_bGlbCache = false;
			_aObjects	= [];
			_aMatrix 	= [];
			_aCache 	= [];
			MatrixBuffer.init();
			
			//
			__parseTree( _oRoot, _oRoot.isModified() );
			
			//		
			cam = _oCamera;
			camCache = cam.isModified();
			
			//
			mt = cam.getTransformMatrix();
			mp = _mProj = cam.getProjectionMatrix() ;
			
			//
			offx = cam.getXOffset(); offy = cam.getYOffset(); 
			
			// now we check if there are some modifications on that branch
			// if true something has changed and we need to compute again
			l = nbObjects = _aObjects.length;
			
			// If nothing has changed in the whole world
			if( !_bGlbCache && !camCache )
			{
				while( --l > -1 )
				{
					obj = _aObjects[ int(l) ];
					
					if( obj.needRefresh() )
					{
						obj.refresh();
					}
				}
			} else {
				while( --l > -1 )
				{
					obj = _aObjects[ int(l) ];
					
					if( _aCache[ int(l) ] == true || camCache == true )
					{
						m = _aMatrix[ int(l) ];
						
						if (m) 
							m = Matrix4Math.multiply(mt,m);
						else
							m = mt;	
							
						//
						m11 = m.n11; m21 = m.n21; m31 = m.n31; m41 = m.n41;
						m12 = m.n12; m22 = m.n22; m32 = m.n32; m42 = m.n42;
						m13 = m.n13; m23 = m.n23; m33 = m.n33; m43 = m.n43;
						m14 = m.n14; m24 = m.n24; m34 = m.n34; m44 = m.n44;
						
						// Now we can transform the objet vertices into the camera coordinates
						aV = obj.aPoints.slice();
						
						var l_bbox:BBox = obj.getBBox();
						if (l_bbox) {
							aV.push( l_bbox.max, l_bbox.min );
						}
						
						lp = aV.length;
						while( --lp > -1 )
						{
							v = aV[int(lp)];
							v.wx = v.x * m11 + v.y * m12 + v.z * m13 + m14;
							v.wy = v.x * m21 + v.y * m22 + v.z * m23 + m24;
							v.wz = v.x * m31 + v.y * m32 + v.z * m33 + m34;
						}
						
						
						// Now we clip the object and in case it is visible or patially visible, we project it
						// into the screen coordinates
						if( obj.clip( cam.frustrum ) == false )
						{
							
							//
							mp11 = mp.n11; mp21 = mp.n21; mp31 = mp.n31; mp41 = mp.n41;
							mp12 = mp.n12; mp22 = mp.n22; mp32 = mp.n32; mp42 = mp.n42;
							mp13 = mp.n13; mp23 = mp.n23; mp33 = mp.n33; mp43 = mp.n43;
							mp14 = mp.n14; mp24 = mp.n24; mp34 = mp.n34; mp44 = mp.n44;
							
							//
							aV = obj.aClipped;
							lp = aV.length;
							while( --lp > -1 )
							{
								//
								v = aV[int(lp)];
								var c:Number = 	1 / ( v.wx * mp41 + v.wy * mp42 + v.wz * mp43 + mp44 );
								v.sx =  c * ( v.wx * mp11 + v.wy * mp12 + v.wz * mp13 + mp14 ) * offx + offx;
								v.sy = -c * ( v.wx * mp21 + v.wy * mp22 + v.wz * mp23 + mp24 ) * offy + offy;
							}
							
							obj.render();
						}
					}// end objects loop
					else
					{
						obj.render();
					}
				}
			}
			
			// we sort visibles Faces
			var aF:Array = ZBuffer.sort();
			
			var s:IScreen = cam.getScreen();
			
			// -- we draw all sorted Faces
			s.render( aF );
			
			// -- we clear the ZBuffer
			ZBuffer.dispose ();
		} // end method

		
		private function __parseTree( n:INode, cache:Boolean ):void
		{
			if (!n) return;
			
			var lCache:Boolean = n.isModified();
			_bGlbCache = _bGlbCache || lCache;
			var m:Matrix4;
			
			var a:Array = n.getChildList();
			
			if( !a )
			{
				if( Object3D( n ).isVisible() )
				{
					_aObjects.push( n );
					_aCache.push( cache || lCache );
					m = Object3D( n ).getMatrix();
					if( m ) MatrixBuffer.push( m );
					_aMatrix.push( MatrixBuffer.getCurrentMatrix() );
					if( m ) MatrixBuffer.pop();
				}
			}
			else
			{
				var l = a.length
				
				// it'a transform
				n.render(); 
				while( --l > -1 )
				{
					__parseTree( a[int(l)], cache || lCache );
				}
				n.dispose();
			}
			n.setModified( false );
			return;
		}
		
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