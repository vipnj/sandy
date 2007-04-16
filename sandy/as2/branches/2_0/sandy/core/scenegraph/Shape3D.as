
    
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
import sandy.events.MouseEvent;
import sandy.materials.Appearance;
import sandy.math.VectorMath;
import sandy.view.CullingState;
import sandy.view.Frustum;
import com.bourre.log.Logger;

class sandy.core.scenegraph.Shape3D extends ATransformable implements ITransformable
{ 
	public var aPolygons:Array;
	
	// Default skin for every Shape3D object.	
    public function Shape3D( p_sName:String, p_geometry:Geometry3D, p_oAppearance:Appearance )
    {
        super( p_sName );
        geometry = p_geometry;
        m_oEB = new EventBroadcaster( this );
        //
        m_bBackFaceCulling = true;
		m_bEnableForcedDepth = false;
		m_bEnableClipping = false;
		m_bClipped = false;
		m_nForcedDepth = 0;
		m_bEv = false;
		// --
		appearance = p_oAppearance;
		// -- 
		updateBoundingVolumes();
    }
    
    private function __destroy():Void
    {
    	if( aPolygons.length > 0 )
    	{
    		var i:Number, l:Number;
    		for( i=0; i<l; i++ )
	    	{
	    		Polygon( aPolygons[i] ).destroy();
	    	}
    	}
    }
    
    private function __generate( p_oGeometry:Geometry3D ):Void
    {
    	var i:Number, l:Number;
    	//
    	aPolygons = new Array( l = p_oGeometry.aFacesVertexID.length );
    	//
    	for( i=0; i<l; i++ )
    	{
    		aPolygons[i] = new Polygon( this, p_oGeometry, p_oGeometry.aFacesVertexID[i], p_oGeometry.aFacesUVCoordsID[i], i );
    	}
    }

            
    public function updateBoundingVolumes( Void ):Void
    {
        if( m_oGeometry )
        {
            _oBSphere 	= BSphere.create( m_oGeometry.aVertex );
            _oBBox 		= BBox.create( m_oGeometry.aVertex );
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
			var mt:Matrix4 = m_tmpMt;
			mt.n11 = _vSide.x; 
			mt.n12 = _vUp.x; 
			mt.n13 = _vOut.x; 
			mt.n14 = VectorMath.dot( _vSide, _p);
			
			mt.n21 = _vSide.y; 
			mt.n22 = _vUp.y; 
			mt.n23 = _vOut.y; 
			mt.n24 = VectorMath.dot( _vUp, _p);
			
			mt.n31 = _vSide.z; 
			mt.n32 = _vUp.z; 
			mt.n33 = _vOut.z; 
			mt.n34 = VectorMath.dot( _vOut, _p);
			
			transform.matrix = mt;
		}
	}
	
	
 	/**
	 * This method goal is to update the node. For node's with transformation, this method shall
	 * update the transformation taking into account the matrix cache system.
	 * FIXME: Transformable nodes shall upate their transform if necessary before calling this method.
	 */
	public function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):Void
	{
		// -- Shall be called first
		updateTransform();
		// -- we call the super update mthod
		super.update( p_oModelMatrix, p_bChanged );
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
		// -- We update the clipped property if necessary and requested by the user.
		if( culled == CullingState.INTERSECT )
		{
			if( m_bEnableClipping ) 
			{
				m_bClipped = true;
				return;
			}
		}
		// --
		m_bClipped = false;
	}
	
	public function render( p_oCamera:Camera3D ):Void
	{	
		var l_nDepth:Number;
		var l_oFace:Polygon;
		var l_oVertex:Vertex;
		var l_nLength:Number;
		//--
		var l_aPoints:Array = m_oGeometry.aVertex;
        var l_oMatrix:Matrix4 = _oViewCacheMatrix;
       	// --
       	var l_faces:Array = aPolygons;
       	var l_oFrustum:Frustum = p_oCamera.frustrum;
        // --
        var m11:Number,m21:Number,m31:Number,m41:Number;
        var m12:Number,m22:Number,m32:Number,m42:Number;
        var m13:Number,m23:Number,m33:Number,m43:Number;
        var m14:Number,m24:Number,m34:Number,m44:Number;
        m11 = l_oMatrix.n11; m21 = l_oMatrix.n21; m31 = l_oMatrix.n31; m41 = l_oMatrix.n41;
		m12 = l_oMatrix.n12; m22 = l_oMatrix.n22; m32 = l_oMatrix.n32; m42 = l_oMatrix.n42;
		m13 = l_oMatrix.n13; m23 = l_oMatrix.n23; m33 = l_oMatrix.n33; m43 = l_oMatrix.n43;
		m14 = l_oMatrix.n14; m24 = l_oMatrix.n24; m34 = l_oMatrix.n34; m44 = l_oMatrix.n44;
		// --
		// If necessary we transform the normals vectors
		if( m_bBackFaceCulling )
		{
		    var l_aNormals:Array = m_oGeometry.aFacesNormals;
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

		// -- The polygons will be clipped, we shall allocate a new array container the clipped vertex.
		if( m_bClipped ) l_aPoints = [];
		// --
		l_nLength = l_faces.length;
		while( --l_nLength > -1 )
		{
		    l_oFace = l_faces[l_nLength];
		   	// --
		    if ( l_oFace.visible || !m_bBackFaceCulling) 
			{
				// --  a necessary copy
				l_oFace.cvertices = l_oFace.vertices.concat();
				if( m_bClipped )
				{
					l_oFrustum.clipFrustum( l_oFace.cvertices );
				    if( l_oFace.cvertices.length ) 
			            l_aPoints = l_aPoints.concat( l_oFace.cvertices );
			    }
			    // --
				l_nDepth 	= (m_bEnableForcedDepth) ? m_nForcedDepth : l_oFace.getZAverage();
				if( l_nDepth )	p_oCamera.renderer.addToDisplayList( l_oFace, l_nDepth );
			}
		}
		// -- We push the vertex to project onto the viewport.
		p_oCamera.pushVerticesToRender( l_aPoints );
	}


	public function set appearance( p_oApp:Appearance )
	{
		// Now we register to the update event
		m_oAppearance = p_oApp;
		//
		if( m_oGeometry )
		{
			var l_faces:Array = aPolygons;
			var l:Number = l_faces.length;
			while( --l > -1 )
			{
				l_faces[int(l)].appearance = m_oAppearance;
				l_faces[int(l)].updateTextureMatrix();
			}
		}
	}
	
	/**
	* Returns the skin instance used by this object.
	* Be carefull, if your object faces have some skins some specific skins, this method is not able to give you this information.
	* @param	void
	* @return 	Skin the skin object
	*/
	public function get appearance():Appearance 
	{
		return m_oAppearance;
	}
	       
	
	public function set geometry( p_geometry:Geometry3D )
	{
		// TODO shall we clone the geometry?
		m_oGeometry = p_geometry;
		updateBoundingVolumes();
		// update the skin
		//skin = _s ;
		__destroy();
		__generate( m_oGeometry );
	}
	
	public function get geometry():Geometry3D
	{
		return m_oGeometry;
	}
	
	public function set enableClipping( b:Boolean )
	{
		m_bEnableClipping = b;
	}

	public function get enableClipping():Boolean
	{
		return m_bEnableClipping;
	}
		
	/**
	 * Enable (true) or disable (false) the object forced depth.
	 * Enable this feature makes the object drawn at a specific depth.
	 * When correctly used, this feature allows you to avoid some Z-sorting problems.
	 */
	public function	set enableForcedDepth( b:Boolean )
	{
		if( b != m_bEnableForcedDepth )
		{
			m_bEnableForcedDepth = b;
			changed = true;
		}
	}
	
	/**
	 * Returns a boolean value specifying if the depth is forced or not
	 */
	public function	get enableForcedDepth():Boolean
	{
		return m_bEnableForcedDepth;
	}
	
	/**
	 * Set a forced depth for this object.
	 * To make this feature working you must enable the ForcedDepth system too.
	 * The higher the depth is, the sooner the more far the object will be represented.
	 */
	public function set forcedDepth( pDepth:Number )
	{
		m_nForcedDepth = pDepth;
		changed = true;
	}
	
	/**
	 * Allows you to retrieve the forced depth value.
	 * The default value is 0.
	 */
	public function get forcedDepth():Number
	{
		return m_nForcedDepth;
	}


	/**
	 * If set to {@code false}, all Face3D of the Object3D will be draw.
	 * A true value is equivalent to enable the backface culling algorithm.
	 * Default {@code true}
	 */
	public function set enableBackFaceCulling( b:Boolean )
	{
		if( b != m_bBackFaceCulling )
		{
			m_bBackFaceCulling = b;
			changed = true;
		}
	}
	public function get enableBackFaceCulling():Boolean
	{
		return m_bBackFaceCulling;
	}
		
					
	/**
	* Represents the Object3D into a String.
	* @return	A String representing the Object3D
	*/
	public function toString ():String
	{
		return "sandy.core.scenegraph.Shape3D" + " " +  m_oGeometry.toString();
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
		var l_faces:Array = aPolygons;
		var l:Number = l_faces.length;
		// -- 
		if( b )
		{
			if( !m_bEv )
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
		else if( !b && m_bEv )
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
		m_bEv = b;
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
		
		var l_faces:Array = aPolygons;
		var l:Number = l_faces.length;
		
		for( var i:Number = 0;i < l; i++ )
		{
			l_faces[int(i)].swapCulling();
		}
		changed = true;
	}
	
				
	public function destroy():Void
	{
		// 	FIXME Fix it - it should be more like 
		//	geometry.destroy();
		// --
		var l_faces:Array = aPolygons;
		var l:Number = l_faces.length;
		while( --l > -1 )
		{
			l_faces[int(l)].destroy();
			l_faces[int(l)] = null;
		}
		// --
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
		m_oEB.addEventListener.apply( m_oEB, arguments );
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
		m_oEB.removeEventListener( t, oL );
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
		m_oEB.dispatchEvent.apply( m_oEB, arguments );
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

// ______________
// [PRIVATE] DATA________________________________________________				
	private var m_oAppearance:Appearance ; // The Appearance of this Shape3D		
    private var m_bEv:Boolean; // The event system state (enable or not)
	private var m_bBackFaceCulling:Boolean;
	private var m_bEnableClipping:Boolean;
	private var m_bClipped:Boolean;
	private var m_bEnableForcedDepth:Boolean;
	private var m_nForcedDepth:Number;
	private var m_oEB:EventBroadcaster;
	/** Geometry of this object */
	private var m_oGeometry:Geometry3D;
	
}
