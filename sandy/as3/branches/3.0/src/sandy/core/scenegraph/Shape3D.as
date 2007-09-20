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

package sandy.core.scenegraph 
{    
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import sandy.bounds.BBox;
	import sandy.bounds.BSphere;
	import sandy.core.Scene3D;
	import sandy.core.World3D;
	import sandy.core.data.Edge3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.events.BubbleEvent;
	import sandy.materials.Appearance;
	import sandy.view.CullingState;
	import sandy.view.Frustum;

	/**
	 * The Shape3D class is the base class of all true 3D shapes.
	 *
	 * <p>It represents a node in the object tree of the world.<br/>
	 * A Shape3D is a leaf node and can not have any child nodes.</p>
	 * <p>It must be the child of a branch group or a transform group, 
	 * but transformations can be applied to the Shape directly.</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class Shape3D extends ATransformable implements IDisplayable
	{ 
		/**
		 * The array of polygons building this object.
		 */		
		public var aPolygons:Array = new Array();

		/**
		 * Creates a 3D object
		 *
		 * <p>[<b>Todo</b>: some more explanations]</p>
		 *
		 * @param p_sName		A string identifier for this object
		 * @param p_oGeometry		The geometry of this object
		 * @param p_oAppearance		The appearance of this objec
		 * @param p_bUseSingleContainer	Whether tis object should use a single container to draw on
		 */	
		public function Shape3D( p_sName:String="", p_oGeometry:Geometry3D=null, p_oAppearance:Appearance=null, p_bUseSingleContainer:Boolean=true )
		{
			super( p_sName );
			// -- Add this graphical object to the World display list
			m_oContainer = new Sprite();
			// --
	        geometry = p_oGeometry;
	        // -- HACK to make sure that the correct container system will be applied
			m_bUseSingleContainer = !p_bUseSingleContainer;
			useSingleContainer = p_bUseSingleContainer;
	        // --
	        m_bBackFaceCulling = true;
			m_bEnableForcedDepth = false;
			m_bEnableClipping = false;
			m_bClipped = false;
			m_nDepth = m_nForcedDepth = 0;
			// --
			if( p_oAppearance ) appearance = p_oAppearance;
			// -- 
			updateBoundingVolumes();
	    }
	    	
    	/**
    	 * setter that allow user to change the way to render this object.
    	 * set to true, the shape will be rendered into a single Sprite object, which is accessible through the container property.
    	 * set to false, the container property does not target anything, but all the polygons will be rendered into their own dedidated container.
    	 *
    	 * <p>If true, this object renders itself on a single container ( Sprite ),<br/>
    	 * if false, each polygon is rendered on its own container.</p>
    	 */
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
					if( l_oFace.container.parent ) 
					{
						l_oFace.container.graphics.clear();
						l_oFace.container.parent.removeChild( l_oFace.container );
						this.broadcaster.removeChild( l_oFace.broadcaster );
					}
    			}
    		}
    		else
    		{
    			if( m_oContainer.parent )
    			{
    				m_oContainer.graphics.clear();
    				m_oContainer.parent.removeChild( m_oContainer );
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
    	
		/**
		 * Updates the bounding volumes of this object.
		 */
    	public function updateBoundingVolumes():void
    	{
    	    if( m_oGeometry )
    	    {
    	        _oBSphere 	= BSphere.create( m_oGeometry.aVertex );
    	        _oBBox 		= BBox.create( m_oGeometry.aVertex );
    	    }
    	}
		  
		/**
		 * Tests this node against the camera frustum to get its visibility.
		 *
		 * <p>If this node and its children are not within the frustum, 
		 * the node is set to cull and it would not be displayed.<p/>
		 * <p>The method also updates the bounding volumes to make the more accurate culling system possible.<br/>
		 * First the bounding sphere is updated, and if intersecting, 
		 * the bounding box is updated to perform the more precise culling.</p>
		 * <p><b>[MANDATORY] The update method must be called first!</b></p>
		 *
		 * @param p_oScene The current scene
		 * @param p_oFrustum	The frustum of the current camera
		 * @param p_oViewMatrix	The view martix of the curren camera
		 * @param p_bChanged
		 */
		public override function cull( p_oScene:Scene3D, p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			super.cull( p_oScene, p_oFrustum, p_oViewMatrix, p_bChanged );

			/////////////////////////
	        //// BOUNDING SPHERE ////
	        /////////////////////////
        	_oBSphere.transform( _oViewCacheMatrix );
        	culled = p_oFrustum.sphereInFrustum( _oBSphere );
			// --
			if( culled == Frustum.INTERSECT && _oBBox )
			{
				////////////////////////
				////  BOUNDING BOX  ////
				////////////////////////
				_oBBox.transform( _oViewCacheMatrix );
				culled = p_oFrustum.boxInFrustum( _oBBox );
			}
			
			// -- We update the clipped property if necessary and requested by the user.
			m_bClipped = false;
			// -- FIXME TO SIMPLIFY THIS BECUASE IT CERTAINLY COST A LOT FOR NOTHING!
			if( culled == CullingState.INTERSECT )
			{
				if( m_bEnableClipping ) 
				{
					m_bClipped = true;
				}
			}
		}
		
		/**
		 * Renders this 3D object.
		 *
		 * @param p_oScene The current scene
		 * @param p_oCamera	The current camera
		 */		
		public override function render( p_oScene:Scene3D, p_oCamera:Camera3D ):void
		{
			var l_bVisible:Boolean;
			var l_aPoints:Array = m_oGeometry.aVertex, l_oTmp:Vertex;
	        const 	l_oMatrix:Matrix4 = _oViewCacheMatrix, l_oFrustum:Frustum = p_oCamera.frustrum, 
					l_aNormals:Array = m_oGeometry.aFacesNormals,
					l_aVertexNormals:Array = m_oGeometry.aVertexNormals,
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
			
			// -- Only is required by the apperance, we are going to transform the vertex normals
			if( m_oAppearance.useVertexNormal )
			{
				// -- Now we transform the vertex normals.
				for each( var l_oVertexNormal:Vertex in l_aVertexNormals )
				{
					l_oVertexNormal.wx = l_oVertexNormal.x * m11 + l_oVertexNormal.y * m12 + l_oVertexNormal.z * m13;
					l_oVertexNormal.wy = l_oVertexNormal.x * m21 + l_oVertexNormal.y * m22 + l_oVertexNormal.z * m23;
					l_oVertexNormal.wz = l_oVertexNormal.x * m31 + l_oVertexNormal.y * m32 + l_oVertexNormal.z * m33;
				}
			}
			
			// -- Now we can transform the objet vertices into the camera coordinates
			for each( var l_oVertex:Vertex in l_aPoints )
			{
				l_oVertex.wx = l_oVertex.x * m11 + l_oVertex.y * m12 + l_oVertex.z * m13 + m14;
				l_oVertex.wy = l_oVertex.x * m21 + l_oVertex.y * m22 + l_oVertex.z * m23 + m24;
				l_oVertex.wz = l_oVertex.x * m31 + l_oVertex.y * m32 + l_oVertex.z * m33 + m34;
				l_oVertex.projected = false;
			}
			// -- The polygons will be clipped, we shall allocate a new array container the clipped vertex.
			m_aVisiblePoly.splice( 0 );
			m_nDepth = 0;
			// --
			for each( var l_oFace:Polygon in aPolygons )
			{
				// -- lauch precomputation
				l_oFace.precompute();
				// --
				if ( l_oFace.visible || !m_bBackFaceCulling) 
				{
					// we process the frustum clipping
					if( m_bClipped )
					{
						l_oFace.clip( l_oFrustum );
						// -- We project the vertices
				 		if( l_oFace.cvertices.length > 0 )
				 		{
				 			p_oCamera.projectArray( l_oFace.vertices );  // not needed anymore exept bitmapmaterial with enableAccurateClipping set to false
							p_oCamera.projectArray( l_oFace.cvertices );
				 			if( !m_bEnableForcedDepth ) m_nDepth += l_oFace.getZAverage();
				 			
				 			// -- we manage the display list depending on the mode choosen
							if( m_bUseSingleContainer )
								m_aVisiblePoly.push( l_oFace );
							else
								p_oCamera.addToDisplayList( l_oFace );
				 		} 
					}
					else
					{
				    	l_oFace.isClipped = false;
				    	if( l_oFace.getZMinimum() > 0 )
						{	
					    	if( !m_bEnableForcedDepth ) m_nDepth += l_oFace.getZAverage();
					    	
					    	// -- We project the vertices
					 		p_oCamera.projectArray( l_oFace.vertices );
					 		// -- we manage the display list depending on the mode choosen
							if( m_bUseSingleContainer )
								m_aVisiblePoly.push( l_oFace );
							else
								p_oCamera.addToDisplayList( l_oFace );
						} 
						// otherwise we can perform a clipping against the front plane only
						else
						{
							l_oFace.clipFrontPlane( l_oFrustum );
							// -- We project the vertices
					 		if( l_oFace.cvertices.length > 0 )
					 		{
					 			p_oCamera.projectArray( l_oFace.vertices ); // not needed anymore exept bitmapmaterial with enableAccurateClipping set to false
								p_oCamera.projectArray( l_oFace.cvertices );
					 			if( !m_bEnableForcedDepth ) m_nDepth += l_oFace.getZAverage();
					 			
					 			// -- we manage the display list depending on the mode choosen
								if( m_bUseSingleContainer )
									m_aVisiblePoly.push( l_oFace );
								else
									p_oCamera.addToDisplayList( l_oFace );
					 		} 
						}
				 	}
				}
			}
			// --
			if( m_bUseSingleContainer )
			{
				if(m_bEnableForcedDepth)m_nDepth = m_nForcedDepth;
				else 					m_nDepth /= m_aVisiblePoly.length;
				p_oCamera.addToDisplayList( this );
			}
		}
		
		/**
		* Clears the graphics object of this object's container.
		*
		* <p>The the graphics that were drawn on the Graphics object is erased, 
		* and the fill and line style settings are reset.</p>
		*/
		public function clear():void
		{
			m_oContainer.graphics.clear();
		}
		
		/**
		 * Performs a z-sorting and renders the objects visible polygons.
		 *
		 * <p>The method is called only if the object renders on a single container<br/> 
		 * - ( useSignelContainer = true ).</p>
		 *
		 * @param p_oScene The current scene
		 * @param p_oContainer	The container to draw on
		 */
		public function display(  p_oScene:Scene3D, p_oContainer:Sprite = null ):void
		{
			m_aVisiblePoly.sortOn( "depth", Array.NUMERIC | Array.DESCENDING );
		    // --
			for each( var l_oPoly:Polygon in m_aVisiblePoly )
			{
				l_oPoly.display( p_oScene, m_oContainer );
			}
		}

		/**
		 * The contianer for this object.
		 * This container property exist if the useSingleContainer is set to true.
		 * It is a direct access to the Shape3D container to, for example, apply nice effects such as filters etc.
		 */
		public function get container():Sprite
		{return m_oContainer;}
		
		/**
		 * The depth of this object.
		 * In case the useSingleContainer mode is enabled (default mode), this value returns the means depth of the Shape in the camera frame.
		 * This value is mainly used as a z-sorting value.
		 */
		public function get depth():Number
		{return m_nDepth;}
		
		/**
		 * This property call allows you to get the geometryCenter offset vector of the Shape.
		 * Modifying this vector will impact the way the shape is rendered, mainly its rotation center.
		 * 
		 * @return a vector which corresponds to the 2 directions offset.
		 */
		public function get geometryCenter():Vector
		{return m_oGeomCenter;}
		
		/**
		 * Change the geometryCenter of the Shape3D.
		 * To change the geometryCenter point of a shape, simply set this geometryCenter property.
		 * The geometryCenter property requires a vector. This vector is an position offset relative to the original geometry one.
		 * For example, a Sphere primitive creates automatically a geometry which center is the 0,0,0 position. If you rotate this sphere as this,
		 * it will rotate around its center.
		 * Now if you set the geometryCenter property, this rotation center will change.
		 * 
		 * The updateBoundingVolumes method which does update the bounding volumes to enable a correct frustum culling is automatically called.
		 * 
		 * @example To change the geometryCenter center at runtime
		 * <listing version="3.0">
		 *    var l_oSphere:Sphere = new Sphere("mySphere", 50, 3 );
		 *    // Change the rotation reference to -50 offset in Y direction from the orinal one
		 *    // and that corresponds to the bottom of the sphere
		 *    l_oSphere.geometryCenter = new Vector( 0, -50, 0 ); 
		 *    l_oSphere.rotateZ = 45;
		 * </listing>
		 */
		public function set geometryCenter( p_oGeomCenter:Vector ):void
		{
			var l_oDiff:Vector = p_oGeomCenter.clone();
			l_oDiff.sub( m_oGeomCenter );
			// --
			if( m_oGeometry )
			{
				for each( var l_oVertex:Vertex in m_oGeometry.aVertex )
				{
					l_oVertex.x += l_oDiff.x;
					l_oVertex.y += l_oDiff.y;
					l_oVertex.z += l_oDiff.z;
				}
			}
			// --
			m_oGeomCenter.copy( p_oGeomCenter );	
			// --
			updateBoundingVolumes();	
		}
		
		/**
		 * The appearance of this object.
		 */
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
		
		/**
		 * @private
		 */
		public function get appearance():Appearance 
		{
			return m_oAppearance;
		}
		       
		/**
		 * The geometry of this object.
		 */
		public function set geometry( p_geometry:Geometry3D ):void
		{
			if( p_geometry == null ) return;
			// TODO shall we clone the geometry?
			m_oGeometry = p_geometry;
			updateBoundingVolumes();
			// -- we generate the possible missing normals
			m_oGeometry.generateFaceNormals();//Must be called first
			m_oGeometry.generateVertexNormals();//must be called second
			// --
			__destroyPolygons();
			__generatePolygons( m_oGeometry );
		}
		
		/**
		 * @private
		 */
		public function get geometry():Geometry3D
		{
			return m_oGeometry;
		}
		
		/**
		 * Should this object be clipped?.
		 *
		 * <p>Determins if this object should be clipped against the camrea frustum and the near and far planes.</p>
		 */
		public function set enableClipping( b:Boolean ):void
		{
			m_bEnableClipping = b;
		}
	
		/**
		 * @private
		 */
		public function get enableClipping():Boolean
		{
			return m_bEnableClipping;
		}
			
		/**
		 * Should forced depth be enable for this object?.
		 *
		 * <p>If true it is possible to force this object to be drawn at a specific depth,<br/>
		 * if false the normal Z-sorting algorithm is applied.</p>
		 * <p>When correctly used, this feature allows you to avoid some Z-sorting problems.</p>
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
		 * @private
		 */
		public function	get enableForcedDepth():Boolean
		{
			return m_bEnableForcedDepth;
		}
		
		/**
		 * The forced depth for this object.
		 *
		 * <p>To make this feature work, you must enable the ForcedDepth system too.<br/>
		 * The higher the depth is, the sooner the more far the object will be represented.</p>
		 * <p>[<b>ToDo</b>: clarify this a bit]</p>
		 */
		public function set forcedDepth( pDepth:Number ):void
		{
			m_nForcedDepth = pDepth; 
			changed = true;
		}
		
		/**
		 * @private
		 */
		public function get forcedDepth():Number
		{
			return m_nForcedDepth;
		}
	
		/**
		 * Should back face culling be enabled for this object?.
		 *
		 * <p>If set to false all faces of this object are drawn.<br/>
		 * A true value enables the back face culling algorithm - Default true</p>
		 */
		public function set enableBackFaceCulling( b:Boolean ):void
		{
			if( b != m_bBackFaceCulling )
			{
				m_bBackFaceCulling = b;
				changed = true;
			}
		}
		
		/**
		 * @private
		 */
		public function get enableBackFaceCulling():Boolean
		{
			return m_bBackFaceCulling;
		}
				
		/**
		 * Enables the event system for mouse events.
		 *
		 * <p>When set to true, the onPress, onRollOver and onRollOut events are broadcast.<br/>
		 * The event system is enabled or disabled for all faces of this object.<br/>
		 * As an alternative, you have the possibility to enable events only for specific faces.</p>
		 *
		 * <p>Once this feature is enabled, the animation is more CPU intensive.</p>
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
	    				m_oContainer.addEventListener(MouseEvent.CLICK, _onInteraction);
						m_oContainer.addEventListener(MouseEvent.MOUSE_UP, _onInteraction); //MIGRATION GUIDE: onRelease & onReleaseOutside
						m_oContainer.addEventListener(MouseEvent.ROLL_OVER, _onInteraction);	
						m_oContainer.addEventListener(MouseEvent.ROLL_OUT, _onInteraction);
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
    				m_oContainer.removeEventListener(MouseEvent.CLICK, _onInteraction);
					m_oContainer.removeEventListener(MouseEvent.MOUSE_UP, _onInteraction); //MIGRATION GUIDE: onRelease & onReleaseOutside
					m_oContainer.removeEventListener(MouseEvent.ROLL_OVER, _onInteraction);	
					m_oContainer.removeEventListener(MouseEvent.ROLL_OUT, _onInteraction);
    			}
			}
			m_bEv = b;
		}
	
		protected function _onInteraction( p_oEvt:Event ):void
		{
			m_oEB.broadcastEvent( new BubbleEvent( p_oEvt.type, this, p_oEvt ) );
		}
		
		/**
		 * Changes the backface culling side.
		 *
		 * <p>When you want to display a cube and you are the cube, you see its external faces.<br/>
		 * The internal faces are not drawn due to back face culling</p>
		 *
		 * <p>In case you are inside the cube, by default Sandy's engine still doesn't draw the internal faces
		 * (because you should not be in there).</p> 
		 *
		 * <p>If you need to be only inside the cube, you can call this method to change which side is culled.<br/>
		 * The faces will be visible only from the interior of the cube.</p>
		 *
		 * <p>If you want to be both on the inside and the outside, you want to make the faces visible from on both sides.<br/>
		 * In that case you just have to set enableBackFaceCulling to false.</p>
		 */
		public function swapCulling():void
		{
			for each( var v:Polygon in aPolygons )
			{
				v.swapCulling();
			}
			changed = true;
		}
		
		/**
		 * Destroy this object and all its faces
		 * [<b>ToDo</b>: the method has a FIXME label and may not work as expected]
		 */
		public override function destroy():void
		{
			// 	FIXME Fix it - it should be more like 
			//	geometry.destroy();
			// --
			__destroyPolygons();
			// --
			super.destroy();
		}

		/**
		 * This method returns a clone of this object
		 *
		 * @return 	The clone
		 */
		public function clone( p_sName:String="" ):Shape3D
		{
			return new Shape3D( p_sName, geometry.clone(), appearance, m_bUseSingleContainer );
		}
		
		/**
		 * Returns a string representation of this object
		 *
		 * @return	The fully qualified name of this object and its geometry
		 */
		public override function toString ():String
		{
			return "sandy.core.scenegraph.Shape3D" + " " +  m_oGeometry.toString();
		}

		///////////////////
		///// PRIVATE /////
		///////////////////
		
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
			aPolygons.splice(0);
		}
		
		private function __generatePolygons( p_oGeometry:Geometry3D ):void
		{
			var i:uint = 0;
			// --
			for each ( var o:* in p_oGeometry.aFacesVertexID )
			{
				aPolygons[i] = new Polygon( this, p_oGeometry, p_oGeometry.aFacesVertexID[i], p_oGeometry.aFacesUVCoordsID[i], i, i );
				if( m_oAppearance ) aPolygons[i].appearance = m_oAppearance;
				this.broadcaster.addChild( aPolygons[i].broadcaster );
				// If the polygon shall render with its container, we add it, otherwise we register the shape container as container of the polygon
				i++;
			}
			// -- attempt to create the neighboors relation between polygons
	        
	        var j: uint;
	        var a: uint = aPolygons.length;
	        //for( j = a - 1, i = 0 ; i < a ; j = i, i++ )
	        for( i = 0; i < a-1; i++ )
	        {
	        	for( j=i+1; j < a; j++ )
		        {
		        	var lP1:Polygon = aPolygons[i];
		        	var lP2:Polygon = aPolygons[j];
		        	// check if they share at least 2 vertices
		        	var lCount:uint = 0;
		        	for each( var l_oEdge:Edge3D in lP1.aEdges )
		        		if( lP2.aEdges.indexOf( l_oEdge ) > -1 ) lCount++;
		        	//
		        	if( lCount > 0 )
		        	{
		        		lP1.aNeighboors.push( lP2 );
		        		lP2.aNeighboors.push( lP1 );
		        	}
		        }
			}
		}
	    		
		// ______________
		// [PRIVATE] DATA________________________________________________				
		private var m_oAppearance:Appearance ; // The Appearance of this Shape3D		
	    private var m_bEv:Boolean = false; // The event system state (enable or not)
		protected var m_oGeomCenter:Vector = new Vector();
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