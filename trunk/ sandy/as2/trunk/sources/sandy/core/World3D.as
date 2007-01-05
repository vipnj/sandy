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

import com.bourre.commands.Delegate;
import com.bourre.events.BasicEvent;
import com.bourre.events.EventBroadcaster;
import com.bourre.events.EventType;
import com.bourre.transitions.FPSBeacon;

import sandy.core.buffer.MatrixBuffer;
import sandy.core.buffer.ZBuffer;
import sandy.core.data.Matrix4;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.group.Group;
import sandy.core.group.INode;
import sandy.core.group.Node;
import sandy.core.light.Light3D;
import sandy.core.Object3D;
import sandy.events.ObjectEventManager;
import sandy.view.Camera3D;
import sandy.view.IScreen;

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
class sandy.core.World3D
{
	/**
	 * The World3D rendering Event. It's the event broadcasted every time the world is rendered
	 */
	public static var onRenderEVENT:EventType 		= new EventType( 'onRender' );
	/**
	 * The World3D start Event. Broadcasted when the world start to be rendered
	 */
	public static var onStartEVENT:EventType 		= new EventType( 'onStart' );
	/**
	 * The World3D stop Event. Broadcasted when the world stop to be rendered
	 */
	public static var onStopEVENT:EventType 		= new EventType( 'onStop' );
	
	public static var onLightAddedEVENT:EventType = new EventType( 'onLightAdded' );
	/**
	 * Private Constructor.
	 * 
	 * <p>You can have only one World3D</p>
	 * 
	 */
	private function World3D ()
	{
		_eRender 	= new BasicEvent( World3D.onRenderEVENT );
		_eStart 	= new BasicEvent( World3D.onStartEVENT );
		// init the event broadcaster
		_oEB = new EventBroadcaster( this );
		// default light
		_light = new Light3D( new Vector( 0, 0, 1 ), 50 );
		_isRunning = false;
		_aCams = [];
		_oEventManager = new ObjectEventManager();
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
	* Allows to get the array of all the objects
	* @param	Void
	* @return 	Object3D array
	*/
	public function getObjects( Void ):Array
	{
		return _aObjects;
	}
	
	/**
	* Allows to get the array of objects which are listened.
	* @param	Void
	* @return Object3D array
	*/
	public function getObjectEventManager( Void ):ObjectEventManager
	{
		return _oEventManager;
	}
	
	/**
	 * Get the Singleton instance of World3D.
	 * 
	 * @return World3D, the only one instance possible
	 */
	public static function getInstance( Void ) : World3D
	{
		if (_inst == undefined) _inst = new World3D();
		return _inst;
	}
	
	/**
	 * Set the {@code Camera3D} of the world.
	 * 
	 * @param	cam	The new {@link Camera3D}
	 */	
	public function addCamera ( cam:Camera3D ):Number
	{
		return _aCams.push( cam ) - 1;
	}
	
	/**
	 * Get the list of {@code Camera3D} of the world.
	 * 
	 * @return	 The {@link Camera3D} array
	 */	
	public function getCameraList ( Void ):Array/*Camera3D*/
	{
		return _aCams;
	}	
	
	/**
	 * Get the a {@code Camera3D} of the world.
	 * @param id Number The id of the camera you want. default is 0.
	 * @return	 The {@link Camera3D}
	 */	
	public function getCamera ( id:Number ):Camera3D
	{
		if( !id || id < 0 || id >= _aCams.length ) id = 0;
		return _aCams[ id ];
	}	
	
	/**
	 * We set the unique ligth of the 3D world.
	 * @param	l	Light3D		The light instance
	 * @return	Void	nothing
	 */
	public function setLight ( l:Light3D ):Void
	{
		if( _light != null ) _light.destroy();
		// --
		_light = l;
		_oEB.broadcastEvent( new BasicEvent( World3D.onLightAddedEVENT ) ); 
	}
	
	/**
	 * Returns the world light reference.
	 * @param Void	Nothing
	 * @return	Light3D	The light reference
	 */
	public function getLight ( Void ):Light3D
	{
		return _light;
	}
	
	/**
	* Add a {@code Group} to the world.
	* 
	* @param	objGroup	The group to add. It must not be a transformGroup !
	* @return	Number		The identifier of the object in the list. With that you will be able to use getGroup method.
	*/
	public function setRootGroup( objGroup:Group ) :Void
	{
		// check if this node have a parent?!!
		_oRoot = objGroup;
	}
	
	/**
	* Get the root {@code Group} of the world.
	*
	* @return	Group	THe root group of the World3D instance.
	*/
	public function getRootGroup( Void ):Group
	{
		return _oRoot;
	}
	
	/**
	* Compute all groups, and draw them.
	* Should be call only once, or everytime after a Wordl3D.stop call.
	*/
	public function render ( Void ) : Void
	{	
		if( _isRunning == false )
		{
			_isRunning = true;
			// we broadcast the start message
			_oEB.broadcastEvent( _eStart );
			// we start the real time rendering
			FPSBeacon.getInstance().addFrameListener( new Delegate( this, __onEnterFrame ) );
			FPSBeacon.getInstance().start();
		}
	}

	/**
	 * Stop the rendering of the World3D.
	 * You can start again th rendering by calling render method.
	 */	
	public function stop( Void ):Void
	{
		FPSBeacon.getInstance().stop();
		FPSBeacon.getInstance().removeFrameListener( new Delegate( this, __onEnterFrame ) );
		_isRunning = false;
	}
	
	/**
	 * Method called every time.
	 */
	private function __onEnterFrame( Void ):Void
	{
		// we broadcast the event
		_oEB.broadcastEvent( _eRender ); 
		//-- we make the active BranchGroup render
		__render();
	}
	
	/**
	* Allows to get the current matrix projection ( usefull since there's several cameras allowed )
	* @param	Void
	* @return Matrix4 The current projection matrix
	*/
	public function getCurrentProjectionMatrix( Void ):Matrix4
	{
		return _mProj;
	}

	/**
	* Allows to get the current camera
	* @param	Void
	* @return Camera3D The current camera
	*/
	public function getCurrentCamera( Void ):Camera3D
	{
		return _oCam;
	}

	////////////////////
	//// PRIVATE
	////////////////////
	/**
	 * Call the recurssive rendering of all the children of this branchGroup.
	 * This is the most important method in all the engine, because the mojority of the computations are done here.
	 * This method is making the points transformations and 2D projections.
	 */
	private function __render( Void ) : Void 
	{
		var l:Number,lc:Number, lp:Number, vx:Number, vy:Number, vz:Number, offx:Number, offy:Number, nbObjects:Number, nbCams:Number;
		var mp11:Number,mp21:Number,mp31:Number,mp41:Number,mp12:Number,mp22:Number,mp32:Number,mp42:Number,mp13:Number,mp23:Number,mp33:Number,mp43:Number,mp14:Number,mp24:Number,mp34:Number,mp44:Number;
		var mp:Matrix4, aV:Array;
		var cam:Camera3D ;
		var obj:Object3D;
		var v:Vertex;
		var crt:Node, crtId:Number;
		// we set a variable to remember the number of objects and in the same time we strop if no objects are displayable
		if( !( nbCams =  _aCams.length ) || _oRoot == null )
			return;
		//-- we initialize
		_bGlbCache = false;
		_aObjects	= [];
		_aMatrix 	= [];
		_aCache 	= [];
		MatrixBuffer.init();
		//
		__parseTree( _oRoot, _oRoot.isModified() );
		// now we check if there are some modifications on that branch
		// if true something has changed and we need to compute again
		l = nbObjects = _aObjects.length;
		while( --l > -1 )
		{
			obj = _aObjects[ l ];
			if( _aCache[ l ] == true )
			{
				mp = _aMatrix[ l ];
				if( mp )
				{
					aV = obj.aPoints;
					//aV.push( obj.getBounds().min, obj.getBounds().max );
					mp11 = mp.n11; mp21 = mp.n21; mp31 = mp.n31;
					mp12 = mp.n12; mp22 = mp.n22; mp32 = mp.n32;
					mp13 = mp.n13; mp23 = mp.n23; mp33 = mp.n33;
					mp14 = mp.n14; mp24 = mp.n24; mp34 = mp.n34;
					// Now we can transform the objet vertices
					lp = aV.length;
					while( --lp > -1 )
					{
						v = aV[lp];	
						// computations for projection
						v.tx =	(vx = v.x) * mp11 + (vy = v.y) * mp12 + (vz = v.z) * mp13 + mp14;
						v.ty = 	vx * mp21 + vy * mp22 + vz * mp23 + mp24;
						v.tz = 	vx * mp31 + vy * mp32 + vz * mp33 + mp34;
					}			
				}
				else
				{
					// In this canse we just do a copy of the local position to the transformed
					aV = obj.aPoints;
					lp = aV.length;
					while( --lp > -1 )
					{
						v = aV[lp];	
						// computations for projection
						v.tx =	v.x;
						v.ty = 	v.y;
						v.tz = 	v.z;
					}
				}
			}
			else
			{
				;/* Object cached */
			}
		}
		
		// -- Now we check if nothing moved on the world and the camera's neither
		lc = nbCams;
		//
		while( --lc > -1 )
		{
			_oCam = cam = _aCams[ lc ];
			// Now we check if nothing moved on the world and the camera's neither
			if( _bGlbCache  || cam.isModified() )
			{
				cam.compile();
				offx = cam.getXOffset(); offy = cam.getYOffset(); 
				// Camera projection
				_mProj = mp = cam.getMatrix() ;
				//
				mp11 = mp.n11; mp21 = mp.n21; mp31 = mp.n31; mp41 = mp.n41;
				mp12 = mp.n12; mp22 = mp.n22; mp32 = mp.n32; mp42 = mp.n42;
				mp13 = mp.n13; mp23 = mp.n23; mp33 = mp.n33; mp43 = mp.n43;
				mp14 = mp.n14; mp24 = mp.n24; mp34 = mp.n34; mp44 = mp.n44;	
				// Object transformations.
				l = nbObjects;
				while( --l > -1 )
				{
					obj = Object3D( _aObjects[l] );
					aV = obj.aPoints;
					//aV.push( obj.getBounds().min, obj.getBounds().max );
					lp =  aV.length;
					while( --lp > -1 )
					{
						v = aV[lp];
						var c:Number = 	1 / ( (vx = v.tx) * mp41 + (vy = v.ty) * mp42 + (vz = v.tz) * mp43 + mp44 );
						// computations for projection
						v.sx =  (v.wx = c * (vx * mp11 + vy * mp12 + vz * mp13 + mp14) ) * offx + offx;
						v.sy = -(v.wy = c * (vx * mp21 + vy * mp22 + vz * mp23 + mp24) ) * offy + offy;
						v.wz =  (vx * mp31 + vy * mp32 + vz * mp33 + mp34) * c;
					}	
					// Is the object clipped? If not we can render it.
					if( !obj.clip( cam.frustrum ) )
					{
						// -- object rendering.
						obj.render();	
					}	
				}// end objects loop
				// we sort visibles Faces
				var aF:Array = ZBuffer.sort();
				var s:IScreen = cam.getScreen();
				// -- we draw all sorted Faces
				s.render( aF );
				// -- we clear the ZBuffer
				ZBuffer.dispose ();
			}
			else
			{
				/* Nothing has moved, so nothing to do exept if an object has a texture which has been updated! Let's see */
				l = nbObjects;
				while( --l > -1 )
				{
					obj = Object3D( _aObjects[l] );
					if( obj.needRefresh() )
					{
						obj.refresh();
					}
				}
				// That's all
			}
		} // end cameras
	} // end method

	
	private function __parseTree( n:INode, cache:Boolean ):Void
	{
		var a:Array = n.getChildList();
		var lCache:Boolean = n.isModified();
		_bGlbCache = _bGlbCache || lCache;
		var l:Number = a.length;
		
		if( !l )
		{
			if( Object3D( n ).isVisible() )
			{
				_aObjects.push( n );
				_aCache.push( cache || lCache );
				_aMatrix.push( MatrixBuffer.getCurrentMatrix() );
			}
		}
		else
		{
			n.render();
			while( --l > -1 )
			{
				__parseTree( a[l], cache || lCache );
			}
			n.dispose();
		}
		n.setModified( false );
		return;
	}
	
	public function toString( Void ):String
	{
		return "sandy.core.World3D";
	}
	
	private var _mProj:Matrix4;
	private var _oCam:Camera3D;
	private var _oRoot:Group;
	private var _aGroups:Array;//_aGroups : The Array of {@link Group}
	private var _aCams:Array/*Camera3D*/;	
	private static var _inst:World3D;//_inst : The only one World3D permit
	private var _oEB:EventBroadcaster;//_oEB : The EventBroadcaster instance which manage the event system of world3D.
	private var _light : Light3D; //the unique light instance of the world
	private var _eRender:BasicEvent;
	private var _eStart:BasicEvent;
	private var _isRunning:Boolean;
	private var _oEventManager:ObjectEventManager;
	private var _bGlbCache:Boolean;
	private var _aObjects:Array;
	private var _aMatrix:Array;
	private var _aCache:Array;
}
