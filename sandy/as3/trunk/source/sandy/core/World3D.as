package sandy.core
{
	/**
	 * The 3D world for displaying the Objects.
	 * <p>World3D is a singleton class, it's the central point of Sandy :
	 * <br/>You can have only one World3D, which contain Groups, Cameras and
	 * Lights</p>
	 * @author	Thomas Pfeiffer - kiroukou
	 * @version 1.0
	 * @date 	05.08.2006
	 * @created 26-VII-2006 13:46:11
	 */
	public const World3D:_World3D_ = new _World3D_();
}

import sandy.core.light.Light3D;
import sandy.core.data.Matrix4;
import sandy.view.Camera3D;
import sandy.core.group.Group;
import sandy.core.group.Node;
import sandy.core.group.INode;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.World3D;
import sandy.core.buffer.MatrixBuffer;
import sandy.core.buffer.DepthBuffer;
import sandy.view.IScreen;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.ErrorEvent;
import sandy.core.Object3D;
import flash.events.EventDispatcher;
import flash.display.Sprite;

internal class _World3D_ extends EventDispatcher
{
    /**
     * The World3D onLightUpdated Event. Broadcasted when the world light is changed
     */
    public const onInitCacheEVENT:String = 'onInitCache';
    /**
     * The World3D onLightUpdated Event. Broadcasted when the world light is changed
     */
    public const onLightUpdatedEVENT:String = 'onLightUpdated';
    /**
     * The World3D rendering Event. It's the event broadcasted every time the world is
     * rendered
     */
    public const onRenderEVENT:String = 'onRender';
    /**
     * The World3D start Event. Broadcasted when the world start to be rendered
     */
    public const onStartEVENT:String = 'onStart';
    /**
     * The World3D stop Event. Broadcasted when the world stop to be rendered
     */
    public const onStopEVENT:String = 'onStop';

	/**
     * Constructor.
     * <p>You can have only one World3D</p>
     */
    public function _World3D_()
    {
    	_eRender 	= new Event( onRenderEVENT );
		_eStart 	= new Event( onStartEVENT );
    	//init();
    }
    
    public function init( ):void
    {
		// default light
		_light = new Light3D( new Vector( 0, 0, 1 ), 50 );
		_isRunning = false;
		_aCams = [];
		_stage = null;
    }
    
    public function setStage( s:Sprite ):void
    {
    	_stage = s;
    }
    /**
     * Set the {@code Camera3D} of the world.
     * @link Camera3D}
     * 
     * @param cam    The new {
     */
    public function addCamera(cam:Camera3D):uint
    {
    	return _aCams.push( cam ) - 1;
    }
	
	public function deleteCamera( id:uint ):Boolean
	{
		if( id >= _aCams.length )
		{
			throw new Error( "Can't delete the corresponding camera" );
			return false;	
		}
		else
		{
			_aCams.splice( id, 1 );
			return true;
		}
	}
	
    /**
     * Get the a {@code Camera3D} of the world.
     * @return	 The {@link Camera3D}
     * 
     * @param id    Number The id of the camera you want. default is 0.
     */
    public function getCamera( id:uint ):Camera3D
    {
    	if( id >= _aCams.length )
    	{
    		throw new Error( "Can't get the corresponding camera" );
    		return null;
    	} 
    	else
    	{
			return _aCams[ id ];
    	}
    }

    /**
     * Get the list of {@code Camera3D} of the world.
     * @return	 The {@link Camera3D} array
     * 
     * @param Void
     */
    public function getCameraList():Array
    {
    	return _aCams;
    }

    /**
     * Allows to get the current camera
     * @return Camera3D The current camera
     * 
     * @param Void
     */
    public function getCurrentCamera():Camera3D
    {
    	return _oCam;
    }

    /**
     * Allows to get the current matrix projection ( usefull since there's several
     * cameras allowed )
     * @return Matrix4 The current projection matrix
     * 
     * @param Void
     */
    public function getCurrentProjectionMatrix():Matrix4
    {
    	return _mProj;
    }

    /**
     * Returns the world light reference.
     * @return	Light3D	The light reference
     * 
     * @param Void    Nothing
     */
    public function getLight():Light3D
    {
    	return _light;
    }

    /**
     * Get the root {@code Group} of the world.
     * @return	Group	THe root group of the World3D instance.
     * 
     * @param Void
     */
    public function getRootGroup():Group
    {
    	return _oRoot;
    }

    /**
     * Compute all groups, and draw them.
     * 
     * @param Void
     */
    public function render(s:Sprite=null):void
    {
    	if( s != null ) setStage( s );
    	if( _isRunning == false && _stage != null )
		{
			_isRunning = true;
			// we broadcast the start message
			dispatchEvent( _eStart ); 
			// we start the real time rendering
			// we add the listener
			_stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		else
		{
			//throw new Error('World3D must refer to the stage object before be rendered');
		}
    }

    /**
     * We set the unique ligth of the 3D world.
     * @return	Void	nothing
     * 
     * @param l    Light3D		The light instance
     */
    public function setLight( l:Light3D ):void
    {
    	dispatchEvent( new Event( World3D.onLightUpdatedEVENT ) ); 
		_light = l;
    }

    /**
     * Add a {@code Group} to the world.
     * @return	Number		The identifier of the object in the list. With that you will be
     * able to use getGroup method.
     * 
     * @param objGroup    The group to add. It must not be a transformGroup !
     */
    public function setRootGroup(objGroup:Group):void
    {
    	_oRoot = objGroup;
    }

    /**
     * Stop the rendering of the World3D.
     * 
     * @param Void
     */
    public function stop():void
    {
    	_isRunning = false;
    	removeEventListener( Event.ENTER_FRAME, onEnterFrame );
    }
         
    /**
     * Method called every time.
     * 
     * @param Void
     */
    private function onEnterFrame( e:Event ):void
    {
    	// we broadcast the event
		dispatchEvent( _eRender ); 
		//-- we make the active BranchGroup render
		__render();
    }

    /**
     * Call the recurssive rendering of all the children of this branchGroup. This is
     * the most important method in all the engine, because the mojority of the
     * computations are done here. This method is making the points transformations
     * and 2D projections.
     * 
     * @param Void
     */
    private function __render():void
    {
    	var l:uint,lc:uint, lp:uint, crtId:uint, nbObjects:uint, nbCams:uint;
    	var vx:Number, vy:Number, vz:Number, offx:Number, offy:Number;
		var mp11:Number,mp21:Number,mp31:Number,mp41:Number,mp12:Number,mp22:Number,mp32:Number,mp42:Number,mp13:Number,mp23:Number,mp33:Number,mp43:Number,mp14:Number,mp24:Number,mp34:Number,mp44:Number;
		var mp:Matrix4;
		var aV:Array;
		var cam:Camera3D;
		var obj:Object3D;
		var v:Vertex;
		var crt:Node;
		// we set a variable to remember the number of objects and in the same time we strop if no objects are displayable
		if( !( nbCams =  _aCams.length ) || _oRoot == null )
			return;
			//-- we initialize
		_bGlbCache 	= false;
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
				if( mp != null )
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
				_mProj = mp = cam.matrix ;
				//
				mp11 = mp.n11; mp21 = mp.n21; mp31 = mp.n31; mp41 = mp.n41;
				mp12 = mp.n12; mp22 = mp.n22; mp32 = mp.n32; mp42 = mp.n42;
				mp13 = mp.n13; mp23 = mp.n23; mp33 = mp.n33; mp43 = mp.n43;
				mp14 = mp.n14; mp24 = mp.n24; mp34 = mp.n34; mp44 = mp.n44;	
				// Object transformations.
				l = nbObjects;
				while( --l > -1 )
				{
					obj = ( _aObjects[l] as Object3D );
					aV = obj.aPoints;
					//aV.push( obj.getBounds().min, obj.getBounds().max );
					lp =  aV.length;
					while( --lp > -1 )
					{
						v = aV[lp];
						var c:Number = 	1 / ( (vx = v.tx) * mp41 + (vy = v.ty) * mp42 + (vz = v.tz) * mp43 + mp44 );
						// computations for projection
						v.sx = (v.wx =	vx * mp11 + vy * mp12 + vz * mp13 + mp14) * c + offx;
						v.sy = (v.wy = 	vx * mp21 + vy * mp22 + vz * mp23 + mp24) * c + offy;
						v.wz = 	vx * mp31 + vy * mp32 + vz * mp33 + mp34;
					}	
					// -- object rendering.
					obj.render();		
				}// end objects loop
				// we sort visibles Faces
				var aF:Array = DepthBuffer.sort();
				var s:IScreen = cam.getScreen();
				// -- we draw all sorted Faces
				s.free();
				s.render( aF );
				// -- we clear the DepthBuffer
				DepthBuffer.dispose ();
			}
			else
			{
				/* Nothing has moved, so nothing to do exept if an object has a texture which has been updated! Let's see */
				l = nbObjects;
				while( --l > -1 )
				{
					obj = ( _aObjects[l] as Object3D );
					if( obj.needRefresh() )
					{
						obj.refresh();	
					}
				}
				// That's all
			}
		} // end cameras
	} // end method
	

	private function __parseTree( n:INode, cache:Boolean ):void
	{
		var a:Array = n.getChildList();
		var lCache:Boolean = n.isModified();
		_bGlbCache = _bGlbCache || lCache;
		var l:Number = a.length;
		
		if( !l && ( n is Object3D ) )
		{
			_aObjects.push( n );
			_aCache.push( cache || lCache );
			_aMatrix.push( MatrixBuffer.getCurrentMatrix() );
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

	private var _stage:Sprite;
    private var _aCams:Array;
    private var _aGroups:Array;
    private var _aInt:Array;
    private var _eRender:Event;
    private var _eStart:Event;
    private var _light:Light3D;
    private var _mProj:Matrix4;
    private var _oCam:Camera3D;
    private var _oRoot:Group;
	private var _isRunning:Boolean;
	private var _bGlbCache:Boolean;
	private var _aObjects:Array;
	private var _aMatrix:Array;
	private var _aCache:Array;
}//end World3D