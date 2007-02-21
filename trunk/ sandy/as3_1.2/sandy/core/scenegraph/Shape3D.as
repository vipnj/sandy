package sandy.core.scenegraph
{
    import flash.events.Event;
    import flash.utils.*;
    
    import sandy.math.Matrix4Math;
    import sandy.core.scenegraph.Leaf;
    import sandy.core.scenegraph.Geometry3D;
    import sandy.bounds.BBox;
    import sandy.bounds.BSphere;
    import sandy.core.data.Vector;
    import sandy.core.data.Vertex;
    import sandy.core.transform.ITransform3D;
    import sandy.skin.Skin;
    import sandy.skin.SimpleLineSkin;
    import sandy.core.data.Matrix4;
    import sandy.view.Camera3D;
    import sandy.view.Frustum;
    import sandy.events.SandyEvent;
    
    public class Shape3D extends Leaf
    {
        
	// _______
	// STATICS_______________________________________________________
	
		/**
		* This is a constante, the default skin used by an Object3D
		*/
		public static const DEFAULT_SKIN:Skin = new SimpleLineSkin(); 

 	// _____________
	// [PUBLIC] DATA_________________________________________________		
	
		/** Geometry of this object */
		public var geometry:Geometry3D;

	// ______________
	// [PRIVATE] DATA________________________________________________				
		private var _s:Skin ; // The Skin of this Object3D
		private var _visible : Boolean;		
		private var _oBBox:BBox;
		private var _oBSphere:BSphere;
		private var _t:ITransform3D;				
        protected var _needRedraw:Boolean; //Say if the object needs to be drawn again or not. Happens when the skin is updated!
		

        public function Shape3D( p_sName:String, p_geometry:Geometry3D = null )
        {
            super( p_sName );
            geometry = p_geometry;
            _visible = true;
            _needRedraw = false;
			// --
			setSkin( DEFAULT_SKIN );
			// -- 
			__updateBoundingVolumes();
        }
        
        private final function __updateBoundingVolumes():void
        {
            if( geometry )
            {
                _oBSphere = BSphere.create( geometry.points );
                _oBBox = BBox.create( geometry.points );
            }
            else
            {
                _oBBox = new BBox();
			    _oBSphere = new BSphere();
            }
        }
        
 		/**
		* Returns the position of the Object3D as a 3D vector.
		* The returned position in the position in the World frame, not the camera's one.
		* In case you want to get the position to a camera, you'll have to add its position to this vector with VectorMat::add eg.
		* @param	void
		* @return	Vector the 3D position of the object
		*/
		public function getPosition():Vector
		{
			var v:Vertex = geometry.points[0];
			return new Vector( v.wx - v.x, v.wy - v.y, v.wz - v.z );
		}
		
		/**
		 * Hide (false) or make visible( true)  the current object.
		 * The default state is visible (true)
		 */
		public function setVisible( b:Boolean ):void
		{
			_visible = b;
			setModified( true );
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
		public function setSkin( pS:Skin ):Boolean
		{
			if (_s)
			{
				_s.removeEventListener( SandyEvent.UPDATE, __onSkinUpdated );
			}
			// Now we register to the update event
			_s = pS;
			_s.addEventListener( SandyEvent.UPDATE, __onSkinUpdated );
			//
			if( geometry )
			{
    			var l_faces:Array = geometry.faces;
    			var l:int = l_faces.length;
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
		       
		
		public function setGeometry(p_geometry:Geometry3D):void
		{
			geometry = p_geometry;
			__updateBoundingVolumes();
		}
		
		public function getGeometry():Geometry3D
		{
			return geometry;
		}
		
		/**
		 * Get the visibility of the Mesh3D.
		 * @return Boolean The visibility boolean, true meaning that the object is visible.
		 */
		public function isVisible():Boolean
		{
			return _visible;
		}
		
		public function prerender(p_oCamera:Camera3D, p_oViewMatrix:Matrix4, p_bCache:Boolean):void
		{
		    // VISIBILITY CHECK
		    // TODO do the frustum culling here
			if( isVisible() == false ) return;
		}
		
		override public function render(p_oCamera:Camera3D, p_oViewMatrix:Matrix4, p_bCache:Boolean):void
		{
		    // VISIBILITY CHECK
			if( isVisible() == false ) return;;
		}

        protected final function __frustumCulling( p_oMatrix:Matrix4, p_oFrustum:Frustum ):int
        {
            var l_bClipped:Boolean = false;
            var res:int;
            /////////////////////////
            //// BOUNDING SPHERE ////
            /////////////////////////
           _oBSphere.transform( p_oMatrix );
            res = p_oFrustum.sphereInFrustum( _oBSphere );
			//
			if( res == Frustum.INTERSECT )
			{
                ////////////////////////
                ////  BOUNDING BOX  ////
                ////////////////////////
                _oBBox.transform( p_oMatrix );
                res = p_oFrustum.boxInFrustum( _oBBox );
			}
			return res;
        }
        
		protected final function __updateLocalViewMatrix( p_oCamera:Camera3D, p_oViewMatrix:Matrix4, p_bCache:Boolean ):Matrix4
		{
		    var l_bCache:Boolean = p_bCache || _modified;
			// FIXME If the cache is enabled here, take the old matrix
			var l_oModelMatrix:Matrix4;
		    var l_oMatrix:Matrix4 = getMatrix();
		    // --
			if( l_oMatrix == null && p_oViewMatrix == null)
			{
			   l_oModelMatrix = p_oCamera.getTransformMatrix();
			}
			else if( l_oMatrix == null )
			{
			    l_oModelMatrix = Matrix4Math.multiply4x3( p_oCamera.getTransformMatrix(), p_oViewMatrix );
			}
			else if ( p_oViewMatrix == null )
			{
			    l_oModelMatrix = Matrix4Math.multiply4x3( p_oCamera.getTransformMatrix(), l_oMatrix );
			}
			else
			{
			    l_oModelMatrix = Matrix4Math.multiply4x3( p_oViewMatrix, l_oMatrix );
			    l_oModelMatrix = Matrix4Math.multiply4x3( p_oCamera.getTransformMatrix(), l_oModelMatrix );
			}
			return l_oModelMatrix;
		}	
				
		/**
		* Returns  bounds of the object. [ minimum  value; maximum  value]
		* @param	void
		* @return Return the array containing the minimum  value and maximum  value of the object in the world coordinate.
		*/
		public function getBBox():BBox
		{
			return _oBBox;
		}

		/**
		* Returns  bounding sphere of the object. [ minimum  value; maximum  value]
		* @param	void
		* @return Return the bounding sphere
		*/
		public function getBSphere():BSphere
		{
			return _oBSphere;
		}
				
		/**
		* Represents the Object3D into a String.
		* @return	A String representing the Object3D
		*/
		override public function toString ():String
		{
			return getQualifiedClassName(this) + " " +  geometry.toString();
		}

		/**
		* Returns the skin instance used by this object.
		* Be carefull, if your object faces have some skins some specific skins, this method is not able to give you this information.
		* @param	void
		* @return 	Skin the skin object
		*/
		public function getSkin():Skin 
		{
			return _s;
		}	

		
		/**
		 * Add a transformation to the current TransformGroup. This allows to apply a transformation to all the childs of the Node.
		 * @param t		The transformation to add
		 */
		public function setTransform( t:ITransform3D ):void
		{
			_t = t;
			setModified( true );
		}
		
		/**
		 * Get the current TransformGroup transformation. This allows to manipulate the node transformation.
		 * @return	The transformation 
		 */
		public function getTransform():ITransform3D
		{
			return _t;
		}
		
		public function getMatrix():Matrix4
		{
			return _t ? _t.getMatrix():null;
		}
		
				
		override public function destroy():void
		{
			// 	Fix it - it should be more like 
			//	geometry.destroy();
			
			// --
			var l_faces:Array = geometry.faces;
			var l:int = l_faces.length;
			while( --l > -1 )
			{
				l_faces[int(l)].destroy();
				l_faces[int(l)] = null;
			}
			//aFaces = null;
			// --
			_s.removeEventListener( SandyEvent.UPDATE, __onSkinUpdated );
			
			super.destroy();
		}
		
		

		/**
		* called when the skin of an object change.
		* We want this object to notify that it has changed to redrawn, so we change its modified property.
		* @param	e
		*/ 
		protected function __onSkinUpdated( e:Event ):void
		{
			_needRedraw = true;
		}
        
    }
}