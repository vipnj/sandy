package sandy.core.scenegraph 
{    
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	
	import sandy.bounds.BBox;
	import sandy.bounds.BSphere;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vertex;
	import sandy.core.data.Polygon;
	import sandy.materials.Appearance;
	import sandy.view.CullingState;
	import sandy.view.Frustum;
	import sandy.core.World3D;

	public class Shape3D extends ATransformable implements ITransformable
	{ 
		public var aPolygons:Array;
		public var depth:Number;
		public var container:Sprite;

		private var m_aVisiblePoly:Array;
	    public function Shape3D( p_sName:String="", p_geometry:Geometry3D=null, p_oAppearance:Appearance=null )
	    {
	        super( p_sName );
	    	// Add this graphical object to the World display list
			container = new Sprite();
			//scontainer.name = this.name;
			World3D.getInstance().container.addChild( container );
			// --
	        geometry = p_geometry;
	        //
	        m_bBackFaceCulling = true;
			m_bEnableForcedDepth = false;
			m_bEnableClipping = false;
			m_bClipped = false;
			depth = m_nForcedDepth = 0;
			m_bEv = false;
			// --
			if( p_oAppearance ) appearance = p_oAppearance;
			// -- 
			updateBoundingVolumes();
	    }
	    
	    private function __destroy():void
	    {
	    	if( aPolygons != null && aPolygons.length > 0 )
	    	{
	    		var i:int, l:int = aPolygons.length;
	    		while( i<l )
		    	{
		    		Polygon( aPolygons[int(i)] ).destroy();
		    		i++;
		    	}
	    	}
	    }
	    
	    private function __generate( p_oGeometry:Geometry3D ):void
	    {
	    	var i:int, l:int;
	    	//
	    	aPolygons = new Array( l = p_oGeometry.aFacesVertexID.length );
	    	//
	    	while( i<l )
	    	{
	    		aPolygons[i] = new Polygon( this, p_oGeometry, p_oGeometry.aFacesVertexID[i], p_oGeometry.aFacesUVCoordsID[i], i );
	    		i++;
	    	}
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
		 * This method shall be called to update the transform matrix of the current object/node
		 * before being rendered.
		 */
		public function updateTransform():void
		{
			if( changed )
			{
				var mt:Matrix4 = m_tmpMt;
				mt.n11 = _vSide.x * _oScale.x; 
				mt.n12 = _vUp.x; 
				mt.n13 = _vOut.x; 
				mt.n14 = _p.x;
				
				mt.n21 = _vSide.y; 
				mt.n22 = _vUp.y * _oScale.y; 
				mt.n23 = _vOut.y; 
				mt.n24 = _p.y;
				
				mt.n31 = _vSide.z; 
				mt.n32 = _vUp.z; 
				mt.n33 = _vOut.z * _oScale.z;  
				mt.n34 = _p.z;
				
				transform.matrix = mt;
			}
		}
		
		
	 	/**
		 * This method goal is to update the node. For node's with transformation, this method shall
		 * update the transformation taking into account the matrix cache system.
		 * FIXME: Transformable nodes shall upate their transform if necessary before calling this method.
		 */
		public override function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):void
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
				;//container.visible = true;
			}
			else if( culled == CullingState.OUTSIDE )
			{
				// We clear it to avoid any ghost effect.
				container.graphics.clear();//container.visible = false;
			}
		}
		
		public override function render( p_oCamera:Camera3D ):void
		{
			var l_nDepth:Number=0, l_oMatrix:Matrix4 = _oViewCacheMatrix, 
				l_faces:Array = aPolygons, l_oFrustum:Frustum = p_oCamera.frustrum, l_aNormals:Array = m_oGeometry.aFacesNormals,
				l_aPoints:Array = m_oGeometry.aVertex,
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
			if( m_bClipped ) l_aPoints = [];
			m_aVisiblePoly = new Array();
			// --
			for each( var l_oFace:Polygon in l_faces )
			{
			    if ( l_oFace.visible || !m_bBackFaceCulling) 
				{
					m_aVisiblePoly.push( l_oFace );
					// --
					if( m_bClipped )
						l_aPoints = l_aPoints.concat( l_oFace.clip( l_oFrustum ) );
					else
				    	l_oFace.cvertices = l_oFace.vertices;		   
					// -- if the object is set at a specific depth we change it, but add a small value that makes the sorting more accurate
					if( m_bEnableForcedDepth == false ) l_nDepth += l_oFace.getZAverage();
				}
			}
			
			if(m_bEnableForcedDepth)depth = m_nForcedDepth;
			else 					depth = l_nDepth/m_aVisiblePoly.length;
			
			// -- We push the vertex to project onto the viewport.
			p_oCamera.pushVerticesToProject( l_aPoints );
			// --
			p_oCamera.addToDisplayList( this );
		}
	
		public function display():void
		{
			var l_oPoly:Polygon;
			m_aVisiblePoly.sortOn( "depth", Array.NUMERIC | Array.DESCENDING );
		    // --
		    container.graphics.clear();
		    // --
			for each( l_oPoly in m_aVisiblePoly )
			{
				l_oPoly.display( container );
			}
		}
	
		public function set appearance( p_oApp:Appearance ):void
		{
			// Now we register to the update event
			m_oAppearance = p_oApp;
			// --
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
		       
		
		public function set geometry( p_geometry:Geometry3D ):void
		{
			if( p_geometry == null ) return;
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
		
		public function set enableClipping( b:Boolean ):void
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
		{
			return m_bEnableForcedDepth;
		}
		
		/**
		 * Set a forced depth for this object.
		 * To make this feature working you must enable the ForcedDepth system too.
		 * The higher the depth is, the sooner the more far the object will be represented.
		 */
		public function set forcedDepth( pDepth:Number ):void
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
		public function set enableBackFaceCulling( b:Boolean ):void
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
						l_faces[int(l)].container.addEventListener(MouseEvent.CLICK, _onPress);
						l_faces[int(l)].container.addEventListener(MouseEvent.MOUSE_UP, _onPress); //MIGRATION GUIDE: onRelease & onReleaseOutside
						l_faces[int(l)].container.addEventListener(MouseEvent.ROLL_OVER, _onRollOver);	
						l_faces[int(l)].container.addEventListener(MouseEvent.ROLL_OUT, _onRollOut);
	    			}
				}
			}
			else if( !b && m_bEv )
			{
				while( --l > -1 )
	    		{
	    	        l_faces[int(l)].enableEvents( false );
					l_faces[int(l)].container.addEventListener(MouseEvent.CLICK, _onPress);
					l_faces[int(l)].container.removeEventListener(MouseEvent.MOUSE_UP, _onPress);
					l_faces[int(l)].container.removeEventListener(MouseEvent.ROLL_OVER, _onRollOver);
					l_faces[int(l)].container.removeEventListener(MouseEvent.ROLL_OUT, _onRollOut);
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
		public function swapCulling():void
		{
			
			var l_faces:Array = aPolygons;
			var l:Number = l_faces.length;
			
			for( var i:Number = 0;i < l; i++ )
			{
				l_faces[int(i)].swapCulling();
			}
			changed = true;
		}
		
					
		public override function destroy():void
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
	
		//////////////////////
		/// PRIVATE METHODS //  
		//////////////////////
		private function _onPress(e:MouseEvent):void
		{
			//dispatchEvent(e);
		}
		
		private function _onRollOver(e:MouseEvent):void
		{
			//dispatchEvent(e);
		}
		
		private function _onRollOut(e:MouseEvent):void
		{
			//dispatchEvent(e);
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
		
	}
}