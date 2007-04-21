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
import sandy.math.Matrix4Math;
import sandy.view.Camera3D;

/**
* The 3D world for displaying the Objects.
* <p>World3D is a singleton class, it's the central point of Sandy :
* <br/>You can have only one World3D, which contain Groups, Cameras and Lights</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Bruce Epstein - zeusprod
* @since		1.0
* @version		1.2
* @date 		29.03.2007
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
	
	public static var onLightAddedEVENT:EventType 	= new EventType( 'onLightAdded' );
	
	public static var onContainerCreatedEVENT:EventType = new EventType( 'onContainerCreated' );
	
	/**
	 * Flag to control lighting model. If true then lit objects have full range from black to white.
	 * If its false (the default) they just range from black to their normal appearance.	 */ 
	public static var GO_BRIGHT:Boolean = false;
	
	/**
	 * Private Constructor.
	 * 
	 * <p>You can have only one World3D</p>
	 * 
	 */
	private function World3D (mc:MovieClip)
	{
		_eRender 	= new BasicEvent( World3D.onRenderEVENT );
		_eStart 	= new BasicEvent( World3D.onStartEVENT );

		_renderDelegate = new Delegate( this, __onEnterFrame );

		// init the event broadcaster
		_oEB = new EventBroadcaster( this );
		// default light
		_light = new Light3D( new Vector( 0, 0, 1 ), 50 );
		_ambientLight = 0.3;
		_isRunning = false;
		// Put the world in the _root if no other clip is specified as its parent
		if (mc == undefined) {
			mc = _root;
		}
		setContainer( mc );
	}

	/**
	 * Removes the container clip and recreates it. 
     * This is a Kludge in order to clean up screen when resetting the world - unsupported and likely buggy
	 */
	public function resetContainer( mc:MovieClip ):Void
	{
		// Kludge to delete and restart the world container
		_container.scene.removeMovieClip();
		setContainer (mc);
	}
	
	public function setContainer( mc:MovieClip ):Void
	{
		_container = mc;
		_container.createEmptyMovieClip("scene", 0);
		//trace("container.scene " + _container.scene);
		_oEB.broadcastEvent( new BasicEvent( World3D.onContainerCreatedEVENT ) ); 
	}
	
	public function getContainer( Void ):MovieClip
	{
		return _container.scene;
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
	 * Get the Singleton instance of World3D.
	 * 
	 * @return World3D, the only one instance possible
	 */
	public static function getInstance( mc:MovieClip ) : World3D
	{
		if (_inst == undefined) _inst = new World3D(mc);
		return _inst;
	}


	/**
	 * Returns a version string ("1.2"), useful for conditional code
	 */	
	public static function getVersion( Void ) : String
	{
		return _version;
	}

	/**
	 * Kills the single instance, so it can be recreated - unsupported and likely buggy
	 */
	public static function killInstance( Void ) : World3D
	{
		// This needs to be fixed. We need to clean up other stuff here
		_inst = undefined;
		return _inst;
	}
	
	/**
	 * Set the {@code Camera3D} of the world.
	 * 
	 * @param	cam	The new {@link Camera3D}
	 */	
	public function setCamera ( pCam:Camera3D ):Void
	{
		_oCamera = pCam;
	}
	
	/**
	 * Set the {@code Camera3D} of the world. Deprecated. Maintained for backward-
	 *  compatibility with Sandy 1.1, even though it just sets the only camera.
	 * @param	cam	The new {@link Camera3D}
	 */	
	public function addCamera ( pCam:Camera3D ):Void
	{
		setCamera(pCam);
	}
	

	/**
	 * Get the list of {@code Camera3D} of the world. Deprecated. Maintained for backward-
	 *  compatibility with Sandy 1.1, even though it just returns the only camera.
	 *
	 * 
	 * @return	 The {@link Camera3D} array
	 */	
	public function getCameraList ( Void ):Array/*Camera3D*/
	{
		return new Array(getCamera());
	}	
	
	/**
	 * Get the {@code Camera3D} of the world.
	 *  @param id Number The id of the camera you want. Ignored. Always assumes 0.
	 * @return	 The {@link Camera3D}
	 */	
	public function getCamera ( id:Number ):Camera3D
	{
		// Ignores the id and always returns the one and only camera
		if (id != undefined && id != 0) {
			trace ("Camera IDs other than zero are not supported.");
		}
		return _oCamera;
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
	 * Specify the lowest light level in the world
	 * @param	a	the light level	 */
	public function setAmbientLight( a:Number ):Void
	{
		_ambientLight = a;
		// TODO : send an event for the update?
	}
	
	/**
	 * Get the lowest light level setting
	 * @return	Number	light level	 */
	public function getAmbientLight( Void ):Number
	{
		return _ambientLight;
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
			FPSBeacon.getInstance().addFrameListener( _renderDelegate );
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
		FPSBeacon.getInstance().removeFrameListener( _renderDelegate );
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
	* Allows to get the current camera. Deprecated. Always returns first and only camera.
	* @param	Void
	* @return Camera3D The current camera
	*/
	public function getCurrentCamera( Void ):Camera3D
	{
		return getCamera();
	}

	////////////////////
	//// PRIVATE
	////////////////////
	/**
	 * Call the recursive rendering of all the children of this branchGroup.
	 * This is the most important method in all the engine, because the mojority of the computations are done here.
	 * This method is making the points transformations and 2D projections.
	 */
	private function __render( Void ) : Void 
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
		if( _oRoot == null )
			return;
		//-- we initialize
		_bGlbCache = false;
		_aObjects	= [];
		_aMatrix 	= [];
		_aCache 	= [];
		var aF:Array  = [];
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
		offx = cam.viewport.nW2; offy = cam.viewport.nH2; 
		// now we check if there are some modifications on that branch
		// if true something has changed and we need to compute again
		l = nbObjects = _aObjects.length;
		// If nothing has changed in the whole world
		if( _bGlbCache == false && camCache == false )
		{
			while( --l > -1 )
			{
				obj = _aObjects[ l ];
				if( obj.needRefresh() )
				{
					obj.refresh();
				}
			}
		}
		else
		{
			while( --l > -1 )
			{
				obj = _aObjects[ l ];
				if( _aCache[ l ] == true || camCache == true )
				{
					m = _aMatrix[ l ];
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
					obj.depth = 0;
					aV = obj.aPoints;
					lp = aV.length;
					while( --lp > -1 )
					{
						v = aV[lp];
						v.wx = v.x * m11 + v.y * m12 + v.z * m13 + m14;
						v.wy = v.x * m21 + v.y * m22 + v.z * m23 + m24;
						v.wz = v.x * m31 + v.y * m32 + v.z * m33 + m34;
						obj.depth += v.wz;
					}
					//
					obj.depth /= aV.length;
					// Now we clip the object and in case it is visible or patially visible, we project it
					// into the screen coordinates
					if( obj.clip( cam.frustrum ) == false )
					{
						// we add the object to the list of the rendered objects
						aF.push( obj );
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
							v = aV[lp];
							var c:Number = 	1 / ( v.wx * mp41 + v.wy * mp42 + v.wz * mp43 + mp44 );
							v.sx =  c * ( v.wx * mp11 + v.wy * mp12 + v.wz * mp13 + mp14 ) * offx + offx;
							v.sy = -c * ( v.wx * mp21 + v.wy * mp22 + v.wz * mp23 + mp24 ) * offy + offy;
						}

					}
				}// end objects loop
			}
		}
		
		aF.sortOn( "depth", Array.NUMERIC | Array.DESCENDING );
		var l_length:Number = aF.length;
		//
		for(var i:Number=0; i < l_length; i++) 
		{
			obj = aF[i];
			obj.container.swapDepths(i);
			obj.render();
		}
			
	} // end method

	
	private function __parseTree( n:INode, cache:Boolean ):Void
	{
		var a:Array = n.getChildList();
		var lCache:Boolean = n.isModified();
		_bGlbCache = _bGlbCache || lCache;
		var l:Number = a.length;
		var m:Matrix4;
		if( !l )
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
	private var _oCamera:Camera3D;
	private var _oRoot:Group;
	private var _aGroups:Array;//_aGroups : The Array of {@link Group}
	private var _aCams:Array/*Camera3D*/;	
	private static var _inst:World3D;//_inst : The only one World3D permitted
	private var _oEB:EventBroadcaster;//_oEB : The EventBroadcaster instance which manage the event system of world3D.
	private var _light : Light3D; //the unique light instance of the world
	private var _ambientLight: Number // the base light level
	private var _eRender:BasicEvent;
	private var _eStart:BasicEvent;
	private var _isRunning:Boolean;
	private var _bGlbCache:Boolean;
	private var _aObjects:Array;
	private var _aMatrix:Array;
	private var _aCache:Array;
	private var _renderDelegate:Delegate;
	
	private var _container : MovieClip;
	private static var _version:String = "1.2";
}
