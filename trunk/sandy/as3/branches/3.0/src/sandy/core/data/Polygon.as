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

package sandy.core.data 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.IDisplayable;
	import sandy.core.scenegraph.Shape3D;
	import sandy.events.BubbleEvent;
	import sandy.events.BubbleEventBroadcaster;
	import sandy.materials.Appearance;
	import sandy.math.VectorMath;
	import sandy.view.Frustum;
	
	/**
	* Polygon
	* @author		Thomas Pfeiffer - kiroukou
	* @author		Mirek Mencel
	* @version		1.0
	* @date 		12.01.2006 
	**/
	public final class Polygon implements IDisplayable
	{
	// _______
	// STATICS_______________________________________________________	
		private static var _ID_:uint = 0;
		/** Unique face id */
		public const id:uint = _ID_++;
	// ______
	// PUBLIC________________________________________________________		
		public var owner:Shape3D;
		public var isClipped:Boolean = false;
		public var cvertices:Array;
		public var vertices:Array;
		public var normal:Vertex;
		public var aUVCoord:Array;
		public var caUVCoord:Array;
		/** Boolean representing the state of the event activation */
		private var mouseEvents:Boolean = false;
		/** Normal backface culling side is 1. -1 means that it is the opposite side which is visible */
		public var backfaceCulling:Number;
	// _______
	// PRIVATE_______________________________________________________			
	
		/** Reference to its owner geometry */
		private var m_oGeometry:Geometry3D;
		private var m_oAppearance:Appearance;
		/** array of ID of uv coordinates in geometry object */
		private var m_aUVCoords:Array;
		private var m_bVisible:Boolean = false;
		
		protected var m_nDepth:Number;
		protected var m_oContainer:Sprite;
		protected var m_oVisibilityRef:Vertex;
		
		public var broadcaster:BubbleEventBroadcaster = new BubbleEventBroadcaster();
		
		public function Polygon( p_oOwner:Shape3D, p_geometry:Geometry3D, p_aVertexID:Array, p_aUVCoordsID:Array=null, p_nFaceNormalID:Number=0 )
		{
			owner = p_oOwner;
			m_oGeometry = p_geometry;
			// --
			backfaceCulling = 1;
			m_nDepth = 0;
			// --
			__update( p_aVertexID, p_aUVCoordsID, p_nFaceNormalID );
			m_oContainer = new Sprite();
		}
	
		/**
		 * visible 
		 * <p>Say if the face is visible or not</p>
		 * @param Void
		 * @return a Boolean, true if visible, false otherwise
		 */	
		public function get visible(): Boolean
		{
			// all normals are refreshed every loop. Face is visible is normal face to the camera
			var l_nDot:Number = ( m_oVisibilityRef.wx * normal.wx + m_oVisibilityRef.wy * normal.wy + m_oVisibilityRef.wz * normal.wz );
			m_bVisible = (( backfaceCulling ) * (l_nDot) < 0);
			return m_bVisible;
		}
		
		/**
		 * Returns an array of vertex containing the clip vertices
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
		 * Calling this method make the polygon gets its vertice and normals by reference instead of accessing them by their ID.
		 * This method shall be called once the geometry created.
		 */
		private function __update( p_aVertexID:Array, p_aUVCoordsID:Array, p_nFaceNormalID:Number ):void
		{
			var i:int=0, l:int;
			// --
			vertices = new Array();
			for each( var o:* in p_aVertexID )
			{
				vertices[i] = Vertex( m_oGeometry.aVertex[ p_aVertexID[i] ] );
				i++;
			}
			// --
			m_oVisibilityRef = vertices[0];
			// -- every polygon does not have some texture coordinates
			if( p_aUVCoordsID )
			{
				aUVCoord = new Array();
				i = 0;
				for each( var p:* in p_aVertexID )
				{
					aUVCoord[i] = UVCoord( m_oGeometry.aUVCoords[ p_aUVCoordsID[i] ] );
					i++;
				}
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
		}
		
		/**
		 * Return the depth average of the face.
		 * <p>Useful for z-sorting.</p>
		 * @return	A Number as depth average.
		 */
		public function getZAverage():Number
		{
			var l_aVert:Array = (isClipped) ? cvertices : vertices;
			m_nDepth = 0;
			for each ( var v:Vertex in l_aVert )
			{
				m_nDepth += v.wz;
			}
			// -- We normalize the sum and return it
			m_nDepth /= l_aVert.length;
			return m_nDepth;
		}

		public function getZMinimum():Number
		{
			var l_aVert:Array = (isClipped) ? cvertices : vertices;
			var lMin:Number = Number.MAX_VALUE;
			for each ( var v:Vertex in l_aVert )
			{
				if( v.wz < lMin ) lMin = v.wz;
			}
			// -- We normalize the sum and return it
			return lMin;
		}
		
		public function clear():void
		{
			m_oContainer.graphics.clear();
		}	
		
		public function display( p_oContainer:Sprite = null ):void
		{
			var lContainer:Sprite = (p_oContainer == null) ? m_oContainer : p_oContainer as Sprite; 
			// --
			if( m_bVisible ) 
			{
				m_oAppearance.frontMaterial.renderPolygon( this, lContainer );
			}
			else
			{
				m_oAppearance.backMaterial.renderPolygon( this, lContainer );
			}
		}

		public function get container():Sprite
		{return m_oContainer;}
		
		public function get depth():Number
		{return m_nDepth;}
		
		public function set depth( p_nDepth:Number ):void
		{ m_nDepth = p_nDepth; }
			
		/**
		 * Get a String representation of the {@code NFace3D}. 
		 * @return	A String representing the {@code NFace3D}.
		 */
		public function toString():String
		{
			return "sandy.core.data.Polygon::id=" +id+ " [Points: " + vertices.length + ", Clipped: " + cvertices.length + "]";
		}
	
		/**
		 * Enable or not the events onPress, onRollOver and onRollOut with this face.
		 * @param b Boolean True to enable the events, false otherwise.
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
			broadcaster.broadcastEvent( new BubbleEvent( p_oEvt.type, p_oEvt.target ) );
		}
		
		/**
		 * Create the normal vector of the face.
		 * @return	The resulting {@code Vertex} corresponding to the normal.
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
		
		public function set appearance( p_oApp:Appearance ):void
		{
			m_oAppearance = p_oApp;
			// --
			p_oApp.frontMaterial.init( this );
			p_oApp.backMaterial.init( this );
		}
		
		public function get appearance():Appearance
		{
			return m_oAppearance;
		}
		
		/**
		 * This method change the value of the "normal" clipping side.
		 * Also swap the font and back skins
		 * @param	void
		 */
		public function swapCulling():void
		{
			// -- swap backface culling 
			backfaceCulling *= -1;
		}
	
		/**
		 * Destroy the sprite attache to this polygon
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
	}
}