package sandy.core.scenegraph 
{    
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import sandy.bounds.BBox;
	import sandy.bounds.BSphere;
	import sandy.core.World3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vertex;
	import sandy.materials.Appearance;
	import sandy.view.CullingState;
	import sandy.view.Frustum;

	public class Shape3D extends ATransformable implements IDisplayable
	{ 
		public var aPolygons:Array = new Array();
		
		//private var m_oToProject:Dictionary = new Dictionary(true);
		private var m_aTmp:Array = new Array();
		
	    public function Shape3D( p_sName:String="", p_geometry:Geometry3D=null, p_oAppearance:Appearance=null, p_bUseSingleContainer:Boolean=true )
	    {
	        super( p_sName );
	    	// -- Add this graphical object to the World display list
			m_oContainer = new Sprite();
			// -- HACK to make sure that the correct container system will be applied
			m_bUseSingleContainer = !p_bUseSingleContainer;
			useSingleContainer = p_bUseSingleContainer;
			// --
	        geometry = p_geometry;
	        // --
	        m_bBackFaceCulling = true;
			m_bEnableForcedDepth = false;
			m_bEnableClipping = false;
			m_bClipped = false;
			m_nDepth = m_nForcedDepth = 0;
			m_bEv = false;
			// --
			if( p_oAppearance ) appearance = p_oAppearance;
			// -- 
			updateBoundingVolumes();
	    }
	    
	    public function set useSingleContainer( p_bUseSingleContainer:Boolean ):void
	    {
	    	var l_oFace:Polygon;
	    	// --
	    	if( p_bUseSingleContainer == m_bUseSingleContainer ) return;
	    	// --
	    	if( p_bUseSingleContainer )
	    	{
	    		for each( l_oFace in aPolygons )
	    		{
					if( World3D.getInstance().container.contains( l_oFace.container ) ) 
					{
						l_oFace.container.graphics.clear();
						World3D.getInstance().container.removeChild( l_oFace.container );
						this.broadcaster.removeChild( l_oFace.broadcaster );
					}
	    		}
	    	}
	    	else
	    	{
	    		if( World3D.getInstance().container.contains(m_oContainer) )
	    		{
	    			m_oContainer.graphics.clear();
	    			World3D.getInstance().container.removeChild( m_oContainer );
	    		}
	    		// --
	    		for each( l_oFace in aPolygons )
	    		{
					this.broadcaster.addChild( l_oFace.broadcaster );
					// we reset the polygon container to the original one, and add it to the world container
					l_oFace.container.graphics.clear();
	    		}
	    	}
	    	m_bUseSingleContainer = p_bUseSingleContainer;
	    }

	
	            
	    public function updateBoundingVolumes():void
	    {
	        if( m_oGeometry )
	        {
	            _oBSphere 	= BSphere.create( m_oGeometry.aVertex );
	            _oBBox 		= BBox.create( m_oGeometry.aVertex );
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
		public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			super.cull(p_oFrustum, p_oViewMatrix, p_bChanged );
			// -- We update the clipped property if necessary and requested by the user.
			m_bClipped = false;
			// --
			if( culled == CullingState.INTERSECT )
			{
				if( m_bEnableClipping ) 
				{
					m_bClipped = true;
				}
			}
			else if( culled == CullingState.OUTSIDE )
			{
				// We clear it to avoid any ghost effect.
				if( !m_bUseSingleContainer )
		    	{
		    		for each( var l_oFace:Polygon in aPolygons )
		    		{
						l_oFace.container.graphics.clear();
		    		}
		    	}
		    	else
		    	{
		    		m_oContainer.graphics.clear();
		    	}
			}
		}
		
		public override function render( p_oCamera:Camera3D ):void
		{
			var l_nDepth:Number=0, l_aPoints:Array = m_oGeometry.aVertex;
	        const 	l_oMatrix:Matrix4 = _oViewCacheMatrix, l_oFrustum:Frustum = p_oCamera.frustrum, 
					l_aNormals:Array = m_oGeometry.aFacesNormals,
					m11:Number = l_oMatrix.n11, m21:Number = l_oMatrix.n21, m31:Number = l_oMatrix.n31,
					m12:Number = l_oMatrix.n12, m22:Number = l_oMatrix.n22, m32:Number = l_oMatrix.n32,
					m13:Number = l_oMatrix.n13, m23:Number = l_oMatrix.n23, m33:Number = l_oMatrix.n33,
					m14:Number = l_oMatrix.n14, m24:Number = l_oMatrix.n24, m34:Number = l_oMatrix.n34;
			
			// -- Now we transform the normals.
			for each( var l_oNormal:Vertex in l_aNormals )
			{
				l_oNormal.wx = l_oNormal.x * m11 + l_oNormal.y * m12 + l_oNormal.z * m13;
				l_oNormal.wy = l_oNormal.x * m21 + l_oNormal.y * m22 + l_oNormal.z * m23;
				l_oNormal.wz = l_oNormal.x * m31 + l_oNormal.y * m32 + l_oNormal.z * m33;
			}
			// -- Now we can transform the objet vertices into the camera coordinates
			for each( var l_oVertex:Vertex in l_aPoints )
			{
				l_oVertex.wx = l_oVertex.x * m11 + l_oVertex.y * m12 + l_oVertex.z * m13 + m14;
				l_oVertex.wy = l_oVertex.x * m21 + l_oVertex.y * m22 + l_oVertex.z * m23 + m24;
				l_oVertex.wz = l_oVertex.x * m31 + l_oVertex.y * m32 + l_oVertex.z * m33 + m34;
			}
			// -- The polygons will be clipped, we shall allocate a new array container the clipped vertex.
			m_aVisiblePoly.splice(0);
			m_aToProject.splice(0);
			// --
			for each( var l_oFace:Polygon in aPolygons )
			{
				if ( l_oFace.visible || !m_bBackFaceCulling) 
				{
					// we manage the clipping
					if( m_bClipped )
						m_aTmp = l_oFace.clip( l_oFrustum );
					else
				    	m_aTmp = l_oFace.cvertices = l_oFace.vertices;		   
					
					for each( var lV:Vertex in m_aTmp )
						if( m_aToProject.indexOf( lV ) ) m_aToProject.push( lV );
					
					// If the face is on screen, we manage some computations for a good display					
					if( l_oFace.cvertices.length )
					{
						if( l_oFace.getZMinimum() > 0 )
						{
							// -- if the object is set at a specific depth we change it, but add a small value that makes the sorting more accurate
							if( !m_bEnableForcedDepth ) l_nDepth += l_oFace.getZAverage();
							else if( m_bUseSingleContainer ) l_oFace.depth = m_nForcedDepth;
							
							// -- we manage the display list depending on the mode choosen
							if( m_bUseSingleContainer )
								m_aVisiblePoly.push( l_oFace );
							else
								p_oCamera.addToDisplayList( l_oFace );
						}
						else
						{
							trace("merde");
						}
					}
					else if( !m_bUseSingleContainer ) l_oFace.container.graphics.clear();
				}
			}
			// --
			if( m_bUseSingleContainer )
			{
				if(m_bEnableForcedDepth)m_nDepth = m_nForcedDepth;
				else 					m_nDepth = l_nDepth/m_aVisiblePoly.length;
				p_oCamera.addToDisplayList( this );
			}
			// -- We push the vertex to project onto the viewport.
			p_oCamera.addToProjectionList( m_aToProject/*l_aPoints*/ );	
		}
	
		// Called only if the useSignelContainer property is enabled!
		public function display(  p_oContainer:Sprite = null ):void
		{
			m_oContainer.graphics.clear();
			// --
			m_aVisiblePoly.sortOn( "depth", Array.NUMERIC | Array.DESCENDING );
		    // --
			for each( var l_oPoly:Polygon in m_aVisiblePoly )
			{
				l_oPoly.display( m_oContainer );
			}
		}
		
		public function get container():Sprite
		{return m_oContainer;}
		
		public function get depth():Number
		{return m_nDepth;}
		
		public function set appearance( p_oApp:Appearance ):void
		{
			// Now we register to the update event
			m_oAppearance = p_oApp;
			// --
			if( m_oGeometry )
			{
				for each( var v:Polygon in aPolygons )
					v.appearance = m_oAppearance;
			}
		}
		
	
		public function get appearance():Appearance 
		{return m_oAppearance;}
		       
		
		public function set geometry( p_geometry:Geometry3D ):void
		{
			if( p_geometry == null ) return;
			// TODO shall we clone the geometry?
			m_oGeometry = p_geometry;
			updateBoundingVolumes();
			// --
			__destroyPolygons();
			__generatePolygons( m_oGeometry );
		}
		
		public function get geometry():Geometry3D
		{return m_oGeometry;}
		
		public function set enableClipping( b:Boolean ):void
		{m_bEnableClipping = b;}
	
		public function get enableClipping():Boolean
		{return m_bEnableClipping;}
			
		/**
		 * Enable (true) or disable (false) the object forced depth.
		 * Enable this feature makes the object drawn at a specific depth.
		 * When correctly used, this feature allows you to avoid some Z-sorting problems.
		 */
		public function	set enableForcedDepth( b:Boolean ):void
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
		{return m_bEnableForcedDepth;}
		
		/**
		 * Set a forced depth for this object.
		 * To make this feature working you must enable the ForcedDepth system too.
		 * The higher the depth is, the sooner the more far the object will be represented.
		 */
		public function set forcedDepth( pDepth:Number ):void
		{m_nForcedDepth = pDepth; changed = true;}
		
		/**
		 * Allows you to retrieve the forced depth value.
		 * The default value is 0.
		 */
		public function get forcedDepth():Number
		{return m_nForcedDepth;}
	
		/**
		 * If set to {@code false}, all Face3D of the Object3D will be draw.
		 * A true value is equivalent to enable the backface culling algorithm.
		 * Default {@code true}
		 */
		public function set enableBackFaceCulling( b:Boolean ):void
		{
			if( b != m_bBackFaceCulling )
			{
				m_bBackFaceCulling = b;
				changed = true;
			}
		}
		public function get enableBackFaceCulling():Boolean
		{return m_bBackFaceCulling;}
			
						
		/**
		* Represents the Object3D into a String.
		* @return	A String representing the Object3D
		*/
		public override function toString ():String
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
		public function set enableEvents( b:Boolean ):void
		{
			// To use only when use Single container is disabled 
			var v:Polygon = null;
			
			if( b )
			{
				if( !m_bEv )
				{
	    			if( m_bUseSingleContainer == false )
	    			{
		    			for each( v in aPolygons )
						{
		    			    v.enableEvents( true );
		    			}
	    			}
	    			else
	    			{
	    				container.addEventListener(MouseEvent.CLICK, _onInteraction);
						container.addEventListener(MouseEvent.MOUSE_UP, _onInteraction); //MIGRATION GUIDE: onRelease & onReleaseOutside
						container.addEventListener(MouseEvent.ROLL_OVER, _onInteraction);	
						container.addEventListener(MouseEvent.ROLL_OUT, _onInteraction);
	    			}
				}
			}
			else if( !b && m_bEv )
			{
				if( m_bUseSingleContainer == false )
    			{
	    			for each( v in aPolygons )
					{
	    			    v.enableEvents( false );
	    			}
    			}
    			else
    			{
    				container.removeEventListener(MouseEvent.CLICK, _onInteraction);
					container.removeEventListener(MouseEvent.MOUSE_UP, _onInteraction); //MIGRATION GUIDE: onRelease & onReleaseOutside
					container.removeEventListener(MouseEvent.ROLL_OVER, _onInteraction);	
					container.removeEventListener(MouseEvent.ROLL_OUT, _onInteraction);
    			}
			}
			m_bEv = b;
		}
	
		protected function _onInteraction( p_oEvt:Event ):void
		{
			this.broadcaster.dispatchEvent(p_oEvt);
		}
		
		/**
		* This method allows you to change the backface culling side.
		* For example when you want to display a cube, you are actually outside the cube, and you see its external faces.
		* But in the case you are inside the cube, by default Sandy's engine make the faces invisible (because you should not be in there).
		* Now if you need to be only inside the cube, you can call the method, and after that the bue faces will be visible only from the interior of the cube.
		* The last possibility could be to make the faces visile from inside and oustside the cube. This is really easy to do, you just have to change the enableBackFaceCulling value and set it to false.
		*/
		public function swapCulling():void
		{
			for each( var v:Polygon in aPolygons )
			{
				v.swapCulling();
			}
			changed = true;
		}
		
					
		public override function destroy():void
		{
			// 	FIXME Fix it - it should be more like 
			//	geometry.destroy();
			// --
			__destroyPolygons();
			// --
			super.destroy();
		}

	
	    private function __destroyPolygons():void
	    {
	    	if( aPolygons != null && aPolygons.length > 0 )
	    	{
	    		var i:int, l:int = aPolygons.length;
	    		while( i<l )
		    	{
		    		this.broadcaster.removeChild( aPolygons[i].broadcaster );
		    		Polygon( aPolygons[int(i)] ).destroy();
		    		if( m_bUseSingleContainer == false ) World3D.getInstance().container.removeChild( aPolygons[i].container );
		    		i++;
		    	}
	    	}
	    }    
	    private function __generatePolygons( p_oGeometry:Geometry3D ):void
	    {
	    	var i:int = 0;
	    	//
	    	for each ( var o:* in p_oGeometry.aFacesVertexID )
	    	{
	    		aPolygons[i] = new Polygon( this, p_oGeometry, p_oGeometry.aFacesVertexID[i], p_oGeometry.aFacesUVCoordsID[i], i );
	    		this.broadcaster.addChild( aPolygons[i].broadcaster );
	    		// If the polygon shall render with its container, we add it, otherwise we register the shape container as container of the polygon
	    		i++;
	    	}
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
		
		protected var m_bUseSingleContainer:Boolean;
		protected var m_nDepth:Number;
		protected var m_oContainer:Sprite;

		private var m_aToProject:Array = new Array();
		private var m_aVisiblePoly:Array = new Array();		
	}
}