
    
import com.bourre.events.BasicEvent;
import com.bourre.events.EventBroadcaster;

import sandy.bounds.BBox;
import sandy.bounds.BSphere;
import sandy.core.data.Matrix4;
import sandy.core.data.Vertex;
import sandy.core.face.Polygon;
import sandy.core.scenegraph.ATransformable;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.ITransformable;
import sandy.core.transform.TransformType;
import sandy.events.MouseEvent;
import sandy.events.SkinEvent;
import sandy.math.Matrix4Math;
import sandy.skin.SimpleLineSkin;
import sandy.skin.Skin;
import sandy.view.CullingState;
import sandy.view.Frustum;

class sandy.core.scenegraph.Shape3D extends ATransformable implements ITransformable
{ 
// _______
// STATICS_______________________________________________________

	// Default skin for every Shape3D object.
	public static var DEFAULT_SKIN:Skin = new SimpleLineSkin(); 	
	
    public function Shape3D( p_sName:String, p_geometry:Geometry3D )
    {
        super( p_sName );
        geometry = (p_geometry == null) ? new Geometry3D() : p_geometry ;
        _needRedraw = false;
        _oEB = new EventBroadcaster( this );
        //
        _backFaceCulling = true;
		_enableForcedDepth = false;
		_enableClipping = false;
		_bClipped = false;
		_forcedDepth = 0;
		_bEv = false;
		// --
		skin = DEFAULT_SKIN;
		// -- 
		updateBoundingVolumes();
    }
    
            
    public  function updateBoundingVolumes( Void ):Void
    {
        if( geometry )
        {
            _oBSphere = BSphere.create( geometry.points );
            _oBBox = BBox.create( geometry.points );
        }
    }
 
 	/**
	 * This method shall be called to update the transform matrix of the current object/node
	 * before being rendered.
	 */
	function updateTransform(Void):Void
	{
		if( changed )
		{
			var _mt:Matrix4 = transform.matrix;
			_mt.n11 = _vSide.x * _oScale.x; 
			_mt.n21 = _vSide.y; 
			_mt.n31 = _vSide.z; 
			_mt.n14 = _p.x;
			
			_mt.n12 = _vUp.x; 
			_mt.n22 = _vUp.y * _oScale.y;
			_mt.n32 = _vUp.z; 
			_mt.n24 = _p.y;
			
			_mt.n13 = _vOut.x;
			_mt.n23 = _vOut.y; 
			_mt.n33 = _vOut.z * _oScale.z;
			_mt.n34 = _p.z;
		}
	}
	
	
 	/**
	 * This method goal is to update the node. For node's with transformation, this method shall
	 * update the transformation taking into account the matrix cache system.
	 * FIXME: Transformable nodes shall upate their transform if necessary before calling this method.
	 */
	public function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):Void
	{
		// Shall be called first
		updateTransform();
		// we call the super update mthod
		super.update( p_oModelMatrix, p_bChanged );
		// we do the processing require by the cache system
		if( p_bChanged )
		{
			 if( p_oModelMatrix )
			 	_oModelCacheMatrix = (transform.matrix) ? Matrix4Math.multiply4x3( p_oModelMatrix, transform.matrix ) : p_oModelMatrix;
			 else
			 	_oModelCacheMatrix = transform.matrix;
		}
	}
	  
	/**
	 * This method test the current node on the frustum to get its visibility.
	 * If the node and its children aren't in the frustum, the node is set to cull
	 * and it would not be displayed.
	 * This method is also updating the bounding volumes to process the more accurate culling system possible.
	 * First the bounding sphere are updated, and if intersecting, the bounding box are updated to perform a more
	 * precise culling.
	 * [MANDATORY] The update method must be called first!
	 */
	public function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):Void
	{
		super.cull(p_oFrustum, p_oViewMatrix, p_bChanged );
		// We update the clipped property if necessary and requested by the user.
		if( culled == CullingState.INTERSECT )
		{
			if( _enableClipping ) 
			{
				_bClipped = true;
				return;
			}
		}
		_bClipped = false;
	}
	
	public function render( p_oCamera:Camera3D ):Void
	{	
		var l_aPoints:Array = geometry.points;
        var l_oMatrix:Matrix4 = _oViewCacheMatrix;
       	var l_faces:Array = _geometry.faces;
       	var l_oFrustum:Frustum = p_oCamera.frustrum;
		var l_nDepth:Number;
		var l_oFace:Polygon;
        var m11:Number,m21:Number,m31:Number,m41:Number,m12:Number,m22:Number,m32:Number,m42:Number,m13:Number,m23:Number,m33:Number,m43:Number,m14:Number,m24:Number,m34:Number,m44:Number;
		var l_oVertex:Vertex;
		var l_nLength:Number;
        //
        m11 = l_oMatrix.n11; m21 = l_oMatrix.n21; m31 = l_oMatrix.n31; m41 = l_oMatrix.n41;
		m12 = l_oMatrix.n12; m22 = l_oMatrix.n22; m32 = l_oMatrix.n32; m42 = l_oMatrix.n42;
		m13 = l_oMatrix.n13; m23 = l_oMatrix.n23; m33 = l_oMatrix.n33; m43 = l_oMatrix.n43;
		m14 = l_oMatrix.n14; m24 = l_oMatrix.n24; m34 = l_oMatrix.n34; m44 = l_oMatrix.n44;
		
		// If necessary we transform the normals vectors
		if( _backFaceCulling )
		{
		    var l_aNormals:Array = geometry.normals;
		    l_nLength = l_aNormals.length;
		    // Now we can transform the objet vertices into the camera coordinates	
			while( --l_nLength > -1 )
			{
				l_oVertex = l_aNormals[l_nLength];
				l_oVertex.wx = l_oVertex.x * m11 + l_oVertex.y * m12 + l_oVertex.z * m13;
				l_oVertex.wy = l_oVertex.x * m21 + l_oVertex.y * m22 + l_oVertex.z * m23;
				l_oVertex.wz = l_oVertex.x * m31 + l_oVertex.y * m32 + l_oVertex.z * m33;
			}
		}
		
		l_nLength = l_aPoints.length;
		// Now we can transform the objet vertices into the camera coordinates	
		while( --l_nLength > -1 )
		{
			l_oVertex = l_aPoints[l_nLength];
			l_oVertex.wx = l_oVertex.x * m11 + l_oVertex.y * m12 + l_oVertex.z * m13 + m14;
			l_oVertex.wy = l_oVertex.x * m21 + l_oVertex.y * m22 + l_oVertex.z * m23 + m24;
			l_oVertex.wz = l_oVertex.x * m31 + l_oVertex.y * m32 + l_oVertex.z * m33 + m34;
			l_oVertex.projected = false;
		}
		
		/////////////////////////////////////////////////////
		///////// FRUSTUM CLIPPING AND FACES TESTS //////////
		/////////////////////////////////////////////////////

		// Il the polygons will be clipped, we shall allocate a new array container the clipped vertex.
		if( _bClipped ) l_aPoints = [];
		//
		l_nLength = l_faces.length;
		while( --l_nLength > -1 )
		{	
		    l_oFace = l_faces[l_nLength];
		   	//
		    if ( l_oFace.isVisible() || !_backFaceCulling) 
			{
				l_oFace.isClipped = false;
				if( _bClipped )
				{
				    l_oFace.clip( l_oFrustum );
				    if( l_oFace.clipped != null ) 
			            l_aPoints = l_aPoints.concat( l_oFace.clipped );
			    }
				l_nDepth 	= (_enableForcedDepth) ? _forcedDepth : l_oFace.getZAverage();
				if( l_nDepth )	p_oCamera.addToDisplayList( l_oFace, l_nDepth );
			}
		}
		
		p_oCamera.pushVerticesToRender( l_aPoints );
	}

	/**
	* Set a Skin to the Object3D.
	* <p>This method will set the the new Skin to all his faces.
	* Warning : If no backface skin has benn applied, the skin will be applied to the back side of faces too!
	* </p>
	* @param	s	The new Skin to apply to faces
	* @param	bOverWrite	Boolean, overwrite or not all specific Faces's Skin
	* @return	Boolean True to apply the skin to the non default faces skins , false otherwise (default).
	*/
	public function set skin( pS:Skin )
	{
		if (_s)
		{
			_s.removeEventListener( SkinEvent.UPDATE, __onSkinUpdated );
		}
		// Now we register to the update event
		_s = pS;
		_s.addEventListener( SkinEvent.UPDATE, __onSkinUpdated );
		//
		if( geometry )
		{
			var l_faces:Array = geometry.faces;
			var l:Number = l_faces.length;
			while( --l > -1 )
			{
				l_faces[int(l)].setSkin( _s );
				l_faces[int(l)].updateTextureMatrix();
			}
		}
		//
		_needRedraw = true;
		return true;
	}
	
	/**
	* Returns the skin instance used by this object.
	* Be carefull, if your object faces have some skins some specific skins, this method is not able to give you this information.
	* @param	void
	* @return 	Skin the skin object
	*/
	public function get skin():Skin 
	{
		return _s;
	}
	       
	
	public function set geometry(p_geometry:Geometry3D)
	{
		_geometry = p_geometry;
		updateBoundingVolumes();
		// update the skin
		skin = _s ;
	}
	
	public function get geometry():Geometry3D
	{
		return _geometry;
	}
	
	public function set enableClipping( b:Boolean )
	{
		_enableClipping = b;
	}

	public function get enableClipping():Boolean
	{
		return _enableClipping;
	}
		
	/**
	 * Enable (true) or disable (false) the object forced depth.
	 * Enable this feature makes the object drawn at a specific depth.
	 * When correctly used, this feature allows you to avoid some Z-sorting problems.
	 */
	public function	set enableForcedDepth( b:Boolean )
	{
		if( b != _enableForcedDepth )
		{
			_enableForcedDepth = b;
			changed = true;
		}
	}
	
	/**
	 * Returns a boolean value specifying if the depth is forced or not
	 */
	public function	get enableForcedDepth():Boolean
	{
		return _enableForcedDepth;
	}
	
	/**
	 * Set a forced depth for this object.
	 * To make this feature working you must enable the ForcedDepth system too.
	 * The higher the depth is, the sooner the more far the object will be represented.
	 */
	public function set forcedDepth( pDepth:Number )
	{
		_forcedDepth = pDepth;
		changed = true;
	}
	
	/**
	 * Allows you to retrieve the forced depth value.
	 * The default value is 0.
	 */
	public function get forcedDepth():Number
	{
		return _forcedDepth;
	}


	/**
	 * If set to {@code false}, all Face3D of the Object3D will be draw.
	 * A true value is equivalent to enable the backface culling algorithm.
	 * Default {@code true}
	 */
	public function set enableBackFaceCulling( b:Boolean )
	{
		if( b != _backFaceCulling )
		{
			_backFaceCulling = b;
			_needRedraw = true;	
			changed = true;
		}
	}
	public function get enableBackFaceCulling():Boolean
	{
		return _backFaceCulling;
	}
		
					
	/**
	* Represents the Object3D into a String.
	* @return	A String representing the Object3D
	*/
	public function toString ():String
	{
		return "sandy.core.scenegraph.Shape3D" + " " +  geometry.toString();
	}	

	/**
	* Allows to enable the event system with onPress, onRollOver and onRollOut events.
	* Once this feature is enable this feature, the animation is more CPU intensive.
	* The default value is false.
	* This method set the argument value to all the faces of the objet.
	* As the Face object has also a enableEvents( Boolean ) method, you have the possibility to enable only
	* the faces that are interessting for you.
	* @param	b Boolean true to enable event system, false otherwise
	*/
	public function set enableEvents( b:Boolean )
	{
		var l_faces:Array = geometry.faces;
		var l:Number = l_faces.length;
		// -- 
		if( b )
		{
			if( !_bEv )
			{
				
    			while( --l > -1 )
    			{
    			    l_faces[int(l)].enableEvents( true );
					l_faces[int(l)].container.addEventListener(MouseEvent.CLICK, this, _onPress);
					l_faces[int(l)].container.addEventListener(MouseEvent.MOUSE_UP, this,_onPress); //MIGRATION GUIDE: onRelease & onReleaseOutside
					l_faces[int(l)].container.addEventListener(MouseEvent.ROLL_OVER, this,_onRollOver);	
					l_faces[int(l)].container.addEventListener(MouseEvent.ROLL_OUT, this,_onRollOut);
    			}
			}
		}
		else if( !b && _bEv )
		{
			while( --l > -1 )
    		{
    	        l_faces[int(l)].enableEvents( false );
				l_faces[int(l)].container.addEventListener(MouseEvent.CLICK, this,_onPress);
				l_faces[int(l)].container.removeEventListener(MouseEvent.MOUSE_UP, this,_onPress);
				l_faces[int(l)].container.removeEventListener(MouseEvent.ROLL_OVER, this,_onRollOver);
				l_faces[int(l)].container.removeEventListener(MouseEvent.ROLL_OUT, this,_onRollOut);
    		}
		}
		_bEv = b;
	}

	/**
	* This method allows you to change the backface culling side.
	* For example when you want to display a cube, you are actually outside the cube, and you see its external faces.
	* But in the case you are inside the cube, by default Sandy's engine make the faces invisible (because you should not be in there).
	* Now if you need to be only inside the cube, you can call the method, and after that the bue faces will be visible only from the interior of the cube.
	* The last possibility could be to make the faces visile from inside and oustside the cube. This is really easy to do, you just have to change the enableBackFaceCulling value and set it to false.
	*/
	public function swapCulling():Void
	{
		
		var l_faces:Array = geometry.faces;
		var l:Number = l_faces.length;
		
		for( var i:Number = 0;i < l; i++ )
		{
			l_faces[int(i)].swapCulling();
		}
		_needRedraw = true;	
		changed = true;
	}
	
				
	public function destroy():Void
	{
		// 	Fix it - it should be more like 
		//	geometry.destroy();
		
		// --
		var l_faces:Array = geometry.faces;
		var l:Number = l_faces.length;
		while( --l > -1 )
		{
			l_faces[int(l)].destroy();
			l_faces[int(l)] = null;
		}
		//aFaces = null;
		// --
		_s.removeEventListener( SkinEvent.UPDATE, __onSkinUpdated );
		
		super.destroy();
	}



	/**
	 * Adds passed-in {@code oL} listener for receiving passed-in {@code t} event type.
	 * 
	 * <p>Take a look at example below to see all possible method call.
	 * 
	 * <p>Example
	 * <code>
	 *   var oEB : IEventDispatcher = new EventBroadcaster(this);
	 *   oEB.addEventListener( myClass.onSometingEVENT, myFirstObject);
	 *   oEB.addEventListener( myClass.onSometingElseEVENT, this, __onSomethingElse);
	 *   oEB.addEventListener( myClass.onSometingElseEVENT, this, Delegate.create(this, __onSomething) );
	 * </code>
	 * 
	 * @param t Name of the Event.
	 * @param oL Listener object.
	 */
	public function addEventListener(t:String, oL) : Void
	{
		_oEB.addEventListener.apply( _oEB, arguments );
	}
	
	/**
	 * Removes passed-in {@code oL} listener that suscribed for passed-in {@code t} event.
	 * 
	 * <p>Example
	 * <code>
	 *   var oEB : IEventDispatcher = new EventBroadcaster(this);
	 *   oEB.removeEventListener( myClass.onSometingEVENT, myFirstObject);
	 *   oEB.removeEventListener( myClass.onSometingElseEVENT, this);
	 * </code>
	 * 
	 * @param t Name of the Event.
	 * @param oL Listener object.
	 */
	public function removeEventListener(t:String, oL) : Void
	{
		_oEB.removeEventListener( t, oL );
	}
	

	/**
	 * Wrapper for Macromedia {@code EventDispatcher} polymorphism.
	 * 
	 * <p>Example
	 * <code>
	 *   var oEB : IEventDispatcher = new EventBroadcaster(this);
	 *   oEB.dispatchEvent( {type:'onSomething', target:this, param:12} );
	 * </code>
	 * 
	 * @param o Event object.
	 */
	public function dispatchEvent(o:Object) : Void
	{
		_oEB.dispatchEvent.apply( _oEB, arguments );
	}
	
	//////////////////////
	/// PRIVATE METHODS //  
	//////////////////////
	private function _onPress(e:MouseEvent):Void
	{
		dispatchEvent(e);
	}
	
	private function _onRollOver(e:MouseEvent):Void
	{
		dispatchEvent(e);
	}
	
	private function _onRollOut(e:MouseEvent):Void
	{
		dispatchEvent(e);
	}
	/**
	* called when the skin of an object change.
	* We want this object to notify that it has changed to redrawn, so we change its modified property.
	* @param	e
	*/ 
	private function __onSkinUpdated( e:BasicEvent ):Void
	{
		_needRedraw = true;
	}	
	
// ______________
// [PRIVATE] DATA________________________________________________				
	private var _s:Skin ; // The Skin of this Object3D		
    private var _needRedraw:Boolean; //Say if the object needs to be drawn again or not. Happens when the skin is updated!
	private var _bEv:Boolean; // The event system state (enable or not)
	private var _backFaceCulling:Boolean;
	private var _enableClipping:Boolean;
	private var _bClipped:Boolean;
	private var _enableForcedDepth:Boolean;
	private var _forcedDepth:Number;
	private var _oEB:EventBroadcaster;
	/** Geometry of this object */
	private var _geometry:Geometry3D;
	
}
