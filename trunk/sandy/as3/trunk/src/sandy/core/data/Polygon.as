/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author Thomas PFEIFFER
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

package sandy.core.data
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import sandy.core.Scene3D;
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.IDisplayable;
	import sandy.core.scenegraph.Shape3D;
	import sandy.events.BubbleEvent;
	import sandy.events.BubbleEventBroadcaster;
	import sandy.materials.Appearance;
	import sandy.math.VectorMath;
	import sandy.view.Frustum;

	/**
	 * Polygon's are the building blocks of visible 3D shapes.
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @author		Mirek Mencel
	 * @since		1.0
	 * @version		3.0
	 * @date 		24.08.2007
	 */
	public final class Polygon implements IDisplayable
	{
	// _______
	// STATICS_______________________________________________________
		private static var _ID_:uint = 0;

	// ______
	// PUBLIC________________________________________________________
		/**
		 * [READ-ONLY] property
		 * Unique polygon ID Number.
		 */
		public const id:uint = _ID_++;

		/**
		 * [READ-ONLY] property.
		 */
		public var owner:Shape3D;
		/**
		 * [READ-ONLY] property.
		 */
		public var isClipped:Boolean = false;
		/**
		 * [READ-ONLY] property.
		 */
		public var cvertices:Array;
		/**
		 * [READ-ONLY] property.
		 */
		public var vertices:Array;
		/**
		 * [READ-ONLY] property.
		 */
		public var vertexNormals:Array;
		/**
		 * [READ-ONLY] property.
		 */
		public var normal:Vertex;
		/**
		 * [READ-ONLY] property.
		 */
		public var aUVCoord:Array;

		/**
		 * [READ-ONLY] property.
		 */
		public var aEdges:Array;

		/**
		 * [READ-ONLY] property.
		 */
		public var caUVCoord:Array;

		/**
		 * [READ-ONLY] property.
		 * This property contains the texture bounds as a Rectangle.
		 */
		public var uvBounds:Rectangle;
		
		/**
		 *  Normal backface culling side is 1. -1 means that the opposite side is culled.
		 */
		public var backfaceCulling:Number;

		/**
		 * [READ-ONLY] property
		 * Array of polygons that share an edge with the current polygon.
		 */
		public var aNeighboors:Array = new Array();
		
		/**
		 * [READ-ONLY] property.
		 */
		public var minBounds:Vector = new Vector();
		/**
		 * [READ-ONLY] property.
		 */
		public var maxBounds:Vector = new Vector();
		/**
		 * [READ-ONLY] property.
		 */
		public var meanBounds:Vector = new Vector();

		/**
		 * Creates a new polygon.
		 *
		 * @param p_oOwner		The shape this polygon belongs to
		 * @param p_geometry		The geometry this polygon is part of
		 * @param p_aVertexID		The vertexID array of this polygon
		 * @param p_aUVCoordsID		The UVCoordsID array of this polygon
		 * @param p_nFaceNormalID	The faceNormalID of this polygon
		 * @param p_nEdgesID		The edgesID of this polygon
		 */
		public function Polygon( p_oOwner:Shape3D, p_geometry:Geometry3D, p_aVertexID:Array, p_aUVCoordsID:Array=null, p_nFaceNormalID:Number=0, p_nEdgesID:uint=0 )
		{
			owner = p_oOwner;
			m_oGeometry = p_geometry;
			// --
			backfaceCulling = 1;
			// --
			__update( p_aVertexID, p_aUVCoordsID, p_nFaceNormalID, p_nEdgesID );
			m_oContainer = new Sprite();
		}

		/**
		 * The broadcaster property.
		 *
		 * <p>The broadcaster is the property used to send events to listeners.</p>
		 */
		public function get broadcaster():BubbleEventBroadcaster
		{
			return m_oEB;
		}

		/**
		 * Adds a listener for specifical event.
		 *
		 * @param p_sEvent 	Name of the Event.
		 * @param oL 		Listener object.
		 */
		public function addEventListener(p_sEvent:String, oL:*) : void
		{
			m_oEB.addEventListener.apply(m_oEB, arguments);
		}

		/**
		 * Removes a listener for specifical event.
		 *
		 * @param p_sEvent 	Name of the Event.
		 * @param oL 		Listener object.
		 */
		public function removeEventListener(p_sEvent:String, oL:*) : void
		{
			m_oEB.removeEventListener(p_sEvent, oL);
		}

		
		/**
		 * Pre-compute several properties of the polygon in the same time.
		 * List of the computed properties :
		 *  - visibility : if the polygon is visible
		 *  - mean z depth : the mean z depth used for basic sorting
		 *  - max bounds : the maximum bounds of the polygon
		 *  - min bounds : the minimum bounds of the polygon
		 *  - mean bounds : the mean of each components of the polygon. It is center actually.
		 */
		public function precompute():void
		{
			// all normals are refreshed every loop. Face is visible is normal face to the camera
			var l_nDot:Number = ( m_oVisibilityRef.wx * normal.wx + m_oVisibilityRef.wy * normal.wy + m_oVisibilityRef.wz * normal.wz );
			m_bVisible = (( backfaceCulling ) * (l_nDot) < 0);
			// --
			const l_aVert:Array = vertices;
			// --
			meanBounds.reset();
			minBounds.resetToPositiveInfinity();
			maxBounds.resetToNegativeInfinity();
			// --
			for each ( var v:Vertex in l_aVert )
			{
				if( v.wx < minBounds.x ) minBounds.x = v.wx;
				else if( v.wx > maxBounds.x ) maxBounds.x = v.wx;
				// --
				if( v.wy < minBounds.y ) minBounds.y = v.wy;
				else if( v.wy > maxBounds.y ) maxBounds.y = v.wy;
				// --
				if( v.wz < minBounds.z ) minBounds.z = v.wz;
				else if( v.wz > maxBounds.z ) maxBounds.z = v.wz;
				// -- 
				meanBounds.x += v.wx;
				meanBounds.y += v.wy;
				meanBounds.z += v.wz;
			}
			// -- We normalize the sum and return it
			meanBounds.scale( 1 / l_aVert.length );
		}
		
		
		/**
		 * Is this face visible?.
		 * The method returns the visibility value pre computed after precompute method call. This getter shall be called afer the precompute call.
		 * @return 	true if this face is visible, false otherwise.
		 */
		public function get visible(): Boolean
		{
			return m_bVisible;
		}

		/**
		 * Returns an array containing the vertices, clipped by the camera frustum.
		 *
		 * @return 	The array of clipped vertices
		 */
		public function clip( p_oFrustum:Frustum ):Array
		{
			isClipped = true;
			cvertices = vertices.concat();
			caUVCoord = aUVCoord.concat();
			p_oFrustum.clipFrustum( cvertices, caUVCoord );
			return cvertices;
		}

		/**
		 * Perform a clipping against the near frustum plane.
		 *
		 * @return 	The array of clipped vertices
		 */
		public function clipFrontPlane( p_oFrustum:Frustum ):Array
		{
			isClipped = true;
			cvertices = vertices.concat();
			caUVCoord = aUVCoord.concat();
			p_oFrustum.clipFrontPlane( cvertices, caUVCoord );
			return cvertices;
		}
		
		/**
		 * Updates the vertices and normals for this polygon.
		 *
		 * <p>Calling this method make the polygon gets its vertice and normals by reference
		 * instead of accessing them by their ID.<br/>
		 * This method shall be called once the geometry created.</p>
		 *
		 * @param p_aVertexID		The vertexID array of this polygon
		 * @param p_aUVCoordsID		The UVCoordsID array of this polygon
		 * @param p_nFaceNormalID	The faceNormalID of this polygon
		 * @param p_nEdgesID		The edgesID of this polygon
		 */
		private function __update( p_aVertexID:Array, p_aUVCoordsID:Array, p_nFaceNormalID:uint, p_nEdgeListID:uint ):void
		{
			var i:int=0, l:int;
			// --
			vertexNormals = new Array();
			vertices = new Array();
			for each( var o:* in p_aVertexID )
			{
				vertices[i] = Vertex( m_oGeometry.aVertex[ p_aVertexID[i] ] );
				vertexNormals[i] = m_oGeometry.aVertexNormals[ p_aVertexID[i] ];
				i++;
			}
			// --
			m_oVisibilityRef = vertices[0];
			// -- every polygon does not have some texture coordinates
			if( p_aUVCoordsID )
			{
				var l_nMinU:Number = Number.POSITIVE_INFINITY, l_nMinV:Number = Number.POSITIVE_INFINITY,
									l_nMaxU:Number = Number.NEGATIVE_INFINITY, l_nMaxV:Number = Number.NEGATIVE_INFINITY;
				// --
				aUVCoord = new Array();
				i = 0;
				for each( var p:* in p_aVertexID )
				{
					var l_oUV:UVCoord = UVCoord( m_oGeometry.aUVCoords[ p_aUVCoordsID[i] ] );
					aUVCoord[i] = l_oUV;
					if( l_oUV.u < l_nMinU ) l_nMinU = l_oUV.u;
					if( l_oUV.u > l_nMaxU ) l_nMaxU = l_oUV.u;
					// --
					if( l_oUV.v < l_nMinV ) l_nMinV = l_oUV.v;
					if( l_oUV.v > l_nMaxV ) l_nMaxV = l_oUV.v;
					// --
					i++;
				}
				// --
				uvBounds = new Rectangle( l_nMinU, l_nMinV, l_nMaxU-l_nMinU, l_nMaxV-l_nMinV );
			}
			// --
			normal = Vertex( m_oGeometry.aFacesNormals[ p_nFaceNormalID ] );
			// If no normal has been given, we create it ourself.
			if( normal == null )
			{
				var l_oNormal:Vector = createNormal();
				var l_nID:Number = m_oGeometry.setFaceNormal( m_oGeometry.getNextFaceNormalID(), l_oNormal.x, l_oNormal.y, l_oNormal.z );
				normal = Vertex( m_oGeometry.aFacesNormals[ l_nID ] );
			}
			// --
			aEdges = new Array();
			for each( var l_nEdgeId:uint in  m_oGeometry.aFaceEdges[p_nEdgeListID] )
			{
				var l_oEdge:Edge3D = m_oGeometry.aEdges[ l_nEdgeId ];
				l_oEdge.vertex1 = m_oGeometry.aVertex[ l_oEdge.vertexId1 ];
				l_oEdge.vertex2 = m_oGeometry.aVertex[ l_oEdge.vertexId2 ];
				aEdges.push( l_oEdge );
			}
		}

		/**
		 * Returns the depth average of this face.
		 *
		 * <p>Useful for z-sorting.</p>
		 *
		 * @return	A number representing the depth average.
		 */
		public function getZAverage():Number
		{
			return meanBounds.z;
		}

		/**
		 * Returns the minimum depth of this face.
		 *
		 * <p>Useful for z-sorting.</p>
		 *
		 * @return	A number representing the depth minimum.
		 */
		public function getZMinimum():Number
		{
			return minBounds.z;
		}

		/**
		 * Clears the container of this polygon from graphics.
		 */
		public function clear():void
		{
			m_oContainer.graphics.clear();
		}

		/**
		 * Displays this polygon on its container if visible.
		 *
		 * @param p_oScene The current scene this polygon is rendered into
		 * @param p_oContainer	The container to draw on
		 */
		public function display( p_oScene:Scene3D, p_oContainer:Sprite = null ):void
		{
			var lContainer:Sprite = (p_oContainer == null) ? m_oContainer : p_oContainer as Sprite;
			// --
			if( m_bVisible )
			{
				m_oAppearance.frontMaterial.renderPolygon( p_oScene, this, lContainer );
			}
			else
			{
				m_oAppearance.backMaterial.renderPolygon( p_oScene, this, lContainer );
			}
		}

		/**
		 * The container for this polygon.
		 */
		public function get container():Sprite
		{
			return m_oContainer;
		}

		/**
		 * @private
		 */
		public function get depth():Number
		{
			return meanBounds.z;
		}

		/**
		 * The z depth of this polygon.
		 */
		public function set depth( p_nDepth:Number ):void
		{
			meanBounds.z = p_nDepth;
		}

		/**
		 * Returns a string representing of this polygon.
		 *
		 * @return	The string representation.
		 */
		public function toString():String
		{
			return "sandy.core.data.Polygon::id=" +id+ " [Points: " + vertices.length + ", Clipped: " + cvertices.length + "]";
		}

		/**
		 * Enables or disables object events for this polygon.
		 *
		 * <p>If a value of true is passed, the object events onPress, onRollOver and onRollOut are enabled.<br />.
		 * To use them, you have to add listeners for the events.</p>
		 *
		 * @param b 	Pass true to enable the events, false to disable.
		 */
		public function enableEvents( b:Boolean ):void
		{
	        if( b && !mouseEvents )
	        {
	        	container.addEventListener(MouseEvent.CLICK, _onInteraction);
	    		container.addEventListener(MouseEvent.MOUSE_UP, _onInteraction); //MIGRATION GUIDE: onRelease & onReleaseOutside
	    		container.addEventListener(MouseEvent.ROLL_OVER, _onInteraction);
	    		container.addEventListener(MouseEvent.ROLL_OUT, _onInteraction);
			}
			else if( !b && mouseEvents )
			{
				container.removeEventListener(MouseEvent.CLICK, _onPress);
				container.removeEventListener(MouseEvent.MOUSE_UP, _onPress);
				container.removeEventListener(MouseEvent.ROLL_OVER, _onRollOver);
				container.removeEventListener(MouseEvent.ROLL_OUT, _onRollOut);
	    	}
	    	mouseEvents = b;
		}

		protected function _onInteraction( p_oEvt:Event ):void
		{
			m_oEB.broadcastEvent( new BubbleEvent( p_oEvt.type, this, p_oEvt ) );
		}

		/**
		 * Calculates and returns the normal vector of the polygon.
		 *
		 * @return	The normal vector
		 */
		public function createNormal():Vector
		{
			if( vertices.length > 2 )
			{
				var v:Vector, w:Vector;
				var a:Vertex = vertices[0], b:Vertex = vertices[1], c:Vertex = vertices[2];
				v = new Vector( b.wx - a.wx, b.wy - a.wy, b.wz - a.wz );
				w = new Vector( b.wx - c.wx, b.wy - c.wy, b.wz - c.wz );
				// we compute de cross product
				var l_normal:Vector = VectorMath.cross( v, w );
				// we normalize the resulting vector
				VectorMath.normalize( l_normal ) ;
				// we return the resulting vertex
				return l_normal;
			}
			else
			{
				return new Vector();
			}
		}

		/**
		 * The appearance of this polygon.
		 */
		public function set appearance( p_oApp:Appearance ):void
		{
			m_oAppearance = p_oApp;
			// --
			p_oApp.frontMaterial.init( this );
			p_oApp.backMaterial.init( this );
		}

		/**
		 * @private
		 */
		public function get appearance():Appearance
		{
			return m_oAppearance;
		}

		/**
		 * Changes which side is the "normal" culling side.
		 *
		 * <p>The method also swaps the front and back skins.</p>
		 */
		public function swapCulling():void
		{
			// -- swap backface culling
			backfaceCulling *= -1;
		}

		/**
		 * Destroys the sprite attache to this polygon.
		 */
		public function destroy():void
		{
			cvertices = null;
			vertices = null;
		}

		/*
		 ***********************
		 * EVENTS
		 ***********************
		*/

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

	// _______
	// PRIVATE_______________________________________________________

		/** Reference to its owner geometry */
		private var m_oGeometry:Geometry3D;
		private var m_oAppearance:Appearance;
		/** array of ID of uv coordinates in geometry object */
		private var m_aUVCoords:Array;
		private var m_bVisible:Boolean = false;

		protected var m_oContainer:Sprite;
		protected var m_oVisibilityRef:Vertex;

		protected var m_oEB:BubbleEventBroadcaster = new BubbleEventBroadcaster();

		/** Boolean representing the state of the event activation */
		private var mouseEvents:Boolean = false;
	}
}