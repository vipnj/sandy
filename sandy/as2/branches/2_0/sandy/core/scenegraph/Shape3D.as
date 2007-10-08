
import com.bourre.log.Logger;

import sandy.bounds.BBox;
import sandy.bounds.BSphere;
import sandy.core.data.Matrix4;
import sandy.core.data.Vertex;
import sandy.core.face.Polygon;
import sandy.core.scenegraph.ATransformable;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.IDisplayable;
import sandy.core.scenegraph.ITransformable;
import sandy.core.World3D;
import sandy.materials.Appearance;
import sandy.view.CullingState;
import sandy.view.Frustum;
import sandy.materials.ColorMaterial;

class sandy.core.scenegraph.Shape3D extends ATransformable implements ITransformable, IDisplayable
{ 
	public var aPolygons:Array;
	// [READ-ONLY] Use this property very carefully. It shall be accessed in some very special cases, and basically never modified by the user code.
	public var container:MovieClip;
	// 	
	public var depth:Number;
	// 	
    public function Shape3D( p_sName:String, p_geometry:Geometry3D, p_oAppearance:Appearance, p_bUseSingleContainer:Boolean )
    {
        super( p_sName );
        // -- Add this graphical object to the World display list
		container = World3D.getInstance().container.createEmptyMovieClip("shape_"+id.toString(), World3D.getInstance().container.getNextHighestDepth() );
		// -- HACK to make sure that the correct container system will be applied
		p_bUseSingleContainer = (p_bUseSingleContainer)?p_bUseSingleContainer:true;
		m_bUseSingleContainer = !p_bUseSingleContainer;
		useSingleContainer = p_bUseSingleContainer;
        //
        aPolygons = null;
        m_bBackFaceCulling = true;
		m_bEnableForcedDepth = false;
		m_bEnableClipping = false;
		m_bClipped = false;
		m_nForcedDepth = depth = 0;
		m_aVisiblePoly = new Array();
		m_bEv = false;
		// -- create the geometry and the bounding volumes
        if( p_geometry) geometry = p_geometry;
        // -- attach an appearance to the shape
		appearance = (p_oAppearance == null) ? new Appearance( new ColorMaterial() ) : p_oAppearance;
    }
	
	
	public function set useSingleContainer( p_bUseSingleContainer:Boolean ):Void
    {
    	var l_oFace:Polygon, l:Number = aPolygons.length;
    	// --
    	if( p_bUseSingleContainer == m_bUseSingleContainer ) return;
    	// --
    	if( p_bUseSingleContainer )
    	{
    		while( --l > -1 )
    		{
				l_oFace = aPolygons[l];
				if( l_oFace.container ) l_oFace.container.clear();
				l_oFace.container = container;
    		}
    	}
    	else
    	{
    		if( container )
    		{
    			container.clear();
    		}
    		// --
    		while( --l > -1 )
    		{
				l_oFace = aPolygons[l];
				// we reset the polygon container to the original one, and add it to the world container
				l_oFace.container.clear();
				l_oFace.container = l_oFace.originalContainer;
    		}
    	}
    	m_bUseSingleContainer = p_bUseSingleContainer;
    }
	       
    private function __destroy():Void
    {
    	if( aPolygons.length > 0 )
    	{
    		var i:Number, l:Number;
    		for( i=0; i<l; i++ )
	    	{
	    		Polygon( aPolygons[i] ).destroy();
	    		broadcaster.removeChild( Polygon( aPolygons[i] ).broadcaster );
	    		if( m_bUseSingleContainer == false ) aPolygons[i].container.removeMovieClip();
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
    		// No need to link the broadcasters, they are alreay linked into the constructor
    		if( m_bUseSingleContainer == true )
	    			aPolygons[i].container = container;
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
		else if( culled == CullingState.OUTSIDE )
		{
			var l:Number = aPolygons.length;
			// We clear it to avoid any ghost effect.
			if( !m_bUseSingleContainer )
		    {
		    	while( --l > -1 )
    			{
					aPolygons[l].container.clear();
		    	}
		    }
		    else
		    {
		    	container.clear();
		    }
		}
		// --
		m_bClipped = false;
	}
	
	public function render( p_oCamera:Camera3D ):Void
	{	
		var l_nDepth:Number = 0, l_oFace:Polygon, l_oVertex:Vertex, l_oNormal:Vertex, l_nLength:Number, l_oMatrix:Matrix4 = _oViewCacheMatrix,
       		l_faces:Array = aPolygons, l_oFrustum:Frustum = p_oCamera.frustrum, l_aNormals:Array = m_oGeometry.aFacesNormals;
        // --
        var m11:Number,m21:Number,m31:Number,m41:Number, 
        	m12:Number,m22:Number,m32:Number,m42:Number, 
        	m13:Number,m23:Number,m33:Number,m43:Number, 
        	m14:Number,m24:Number,m34:Number,m44:Number;
        // --	
        m11 = l_oMatrix.n11; m21 = l_oMatrix.n21; m31 = l_oMatrix.n31; m41 = l_oMatrix.n41;
		m12 = l_oMatrix.n12; m22 = l_oMatrix.n22; m32 = l_oMatrix.n32; m42 = l_oMatrix.n42;
		m13 = l_oMatrix.n13; m23 = l_oMatrix.n23; m33 = l_oMatrix.n33; m43 = l_oMatrix.n43;
		m14 = l_oMatrix.n14; m24 = l_oMatrix.n24; m34 = l_oMatrix.n34; m44 = l_oMatrix.n44;
		
		// Now we can transform the objet vertices into the camera coordinates	   
	    l_nLength = l_aNormals.length;
		while( --l_nLength > -1 )
		{
			l_oNormal = l_aNormals[l_nLength];
			l_oNormal.wx = l_oNormal.x * m11 + l_oNormal.y * m12 + l_oNormal.z * m13;
			l_oNormal.wy = l_oNormal.x * m21 + l_oNormal.y * m22 + l_oNormal.z * m23;
			l_oNormal.wz = l_oNormal.x * m31 + l_oNormal.y * m32 + l_oNormal.z * m33;
		}
		
		// Now we can transform the objet vertices into the camera coordinates	
		var l_aPoints:Array = m_oGeometry.aVertex;
		l_nLength = l_aPoints.length;
		while( --l_nLength > -1 )
		{
			l_oVertex = l_aPoints[l_nLength];
			l_oVertex.wx = l_oVertex.x * m11 + l_oVertex.y * m12 + l_oVertex.z * m13 + m14;
			l_oVertex.wy = l_oVertex.x * m21 + l_oVertex.y * m22 + l_oVertex.z * m23 + m24;
			l_oVertex.wz = l_oVertex.x * m31 + l_oVertex.y * m32 + l_oVertex.z * m33 + m34;
		}
		
		/////////////////////////////////////////////////////
		///////// FRUSTUM CLIPPING AND FACES TESTS //////////
		/////////////////////////////////////////////////////

		// -- The polygons will be clipped, we shall allocate a new array container the clipped vertex.
		if( m_bClipped ) l_aPoints.splice(0);
		m_aVisiblePoly.splice( 0 );
		// --
		l_nLength = l_faces.length;
		while( --l_nLength > -1 )
		{
		    l_oFace = l_faces[l_nLength];
		   	// --
		    if ( l_oFace.visible || !m_bBackFaceCulling) 
			{
				if( m_bClipped )
					l_aPoints = l_aPoints.concat( l_oFace.clip( l_oFrustum ) );
			    else
			    	l_oFace.cvertices = l_oFace.vertices;
			    // --
			    if( l_oFace.cvertices.length )
			    {
					if( l_oFace.getZMinimum() > 0 )
					{
						// -- if the object is set at a specific depth we change it, but add a small value that makes the sorting more accurate
						if( !m_bEnableForcedDepth ) l_nDepth += l_oFace.getZAverage();
						else if( m_bUseSingleContainer ) l_oFace.depth = m_nForcedDepth;
						// --
						if( m_bUseSingleContainer )
								m_aVisiblePoly.push( l_oFace );
						else
							p_oCamera.addToDisplayList( l_oFace );
					}
			    }
			}
			else if( !m_bUseSingleContainer ) l_oFace.container.clear();
		}
		// --
		if( m_bUseSingleContainer )
		{
			if(m_bEnableForcedDepth) depth = m_nForcedDepth;
			else 					 depth = l_nDepth/m_aVisiblePoly.length;
			p_oCamera.addToDisplayList( this );
		}
		// -- We push the vertex to project onto the viewport.
		p_oCamera.pushVerticesToRender( l_aPoints );
	}

	// Called only if the useSignelContainer property is enabled!
	public function display( p_mcContainer:MovieClip ):Void
	{
		var l:Number = m_aVisiblePoly.length;
		m_aVisiblePoly.sortOn( "depth", Array.NUMERIC | Array.ASCENDING );
		// --
		while( --l > -1 )
		{
			m_aVisiblePoly[l].display( container );
		}
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
			}
		}
	}
	

	public function get appearance():Appearance 
	{
		return m_oAppearance;
	}
	       
	
	public function set geometry( p_geometry:Geometry3D )
	{
		// TODO shall we clone the geometry?
		m_oGeometry = p_geometry;
		updateBoundingVolumes();
		// --
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
		if( b != m_bEv )
		{	
			while( --l > -1 )
			{
			    l_faces[int(l)].enableEvents( true );
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

// ______________
// [PRIVATE] DATA________________________________________________				
	private var m_oAppearance:Appearance ; // The Appearance of this Shape3D		
    private var m_bEv:Boolean; // The event system state (enable or not)
	private var m_bBackFaceCulling:Boolean;
	private var m_bEnableClipping:Boolean;
	private var m_bClipped:Boolean;
	private var m_bEnableForcedDepth:Boolean;
	private var m_nForcedDepth:Number;
	/** Geometry of this object */
	private var m_oGeometry:Geometry3D;

	private var m_bUseSingleContainer:Boolean;

	//protected va
	private var m_aVisiblePoly:Array;
	
}
