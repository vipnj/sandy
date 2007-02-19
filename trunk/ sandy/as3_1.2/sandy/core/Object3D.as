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
package sandy.core 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.*;

	import sandy.core.data.BBox;
	import sandy.core.data.BSphere;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.face.IPolygon;
	import sandy.core.face.Polygon;
	import sandy.core.scenegraph.Leaf;
	import sandy.core.World3D;
	import sandy.core.transform.ITransform3D;
	import sandy.core.data.Matrix4;
	import sandy.skin.SimpleLineSkin;
	import sandy.skin.Skin ;
	import sandy.view.Frustum;
	import sandy.view.Camera3D;
	import sandy.math.Matrix4Math;
	import sandy.events.SandyEvent;

	
	/**
	* <p>Represent an Object3D in a World3D</p>
	* 
	* @author	Thomas Pfeiffer - kiroukou
	* @version	1.0
	* @date 	23.06.2006
	*/
	public class Object3D extends Leaf
	{
		
	// _______
	// STATICS_______________________________________________________
	
		/**
		* This is a constante, the default skin used by an Object3D
		*/
		private static var _DEFAUT_SKIN:Skin = new SimpleLineSkin(); 
		
		/**
		* Default Skin of the Object3D.
		*/
		public static function get DEFAULT_SKIN():Skin  { return _DEFAUT_SKIN; }
		
	// _____________
	// [PUBLIC] DATA_________________________________________________		
	
		/** Array of Vertex ( Points used in this Object3D )*/
		public var aPoints:Array;
		
		/** Array of the faces of the Object3D */ 
		public var aFaces:Array;
		
		/** Array of normals vertex. UNUSED in the current version of the engine. */
		public var aNormals:Array;

	// ______________
	// [PRIVATE] DATA________________________________________________		
	
		private var _s:Skin ; // The Skin of this Object3D
		private var _sb:Skin ; // The back Skin of this Object3D
		private var _needRedraw:Boolean; //Say if the object needs to be drawn again or not. Happens when the skin is updated!
		private var _bEv:Boolean; // The event system state (enable or not)
		private var _backFaceCulling:Boolean;
		protected var _enableClipping:Boolean;
		private var _visible : Boolean;
		private var _enableForcedDepth:Boolean;
		private var _forcedDepth:Number;
		private var _oBBox:BBox;
		private var _oBSphere:BSphere;
		private var _t:ITransform3D;
	    private var _bPolyClipped:Boolean;
	// ___________
	// CONSTRUCTOR___________________________________________________
	
		/**
		* Create a new Object3D.
		* 
		* <p>By default, a new Object3D has a {@link mb.sandy.skin#SimpleLineSkin} and
		* all the public arrays are created (as empty). The properties {@link #drawAllFaces}
		* and {@link #useNormals} are set to {@code false}. The {@code Matrix4} ({@code m})
		* is an Identity matrix. See {@link mb.sandy.core.data.Matrix4#createIdentity} for
		* more details.</p>
		* <p>You can use primitives, or xml to make a specific Object3D</p>
		*/
		public function Object3D ()
		{
			super();
			//
			aPoints		= new Array ();
			aFaces		= new Array ();
			aNormals 	= new Array ();
			//
			_backFaceCulling = true;
			_bPolyClipped    = false;
			_bEv = false;
			_needRedraw = false;
			_visible = true;
			_enableForcedDepth = false;
			_enableClipping = false;
			_forcedDepth = 0;
			_oBBox = null;
			_oBSphere = null;
			// -- We also set skin to Default constant
			setSkin( DEFAULT_SKIN );
			setBackSkin( DEFAULT_SKIN );
		}
		
		
	// __________________
	// [PUBLIC] FUNCTIONS____________________________________________
		
		public function enableClipping( b:Boolean ):void
		{
			_enableClipping = b;
			
			if( _enableClipping ) 
			{
				_oBSphere = new BSphere( this );
				_oBBox = new BBox( this );
			}
		}
		
		/**
		 * Enable (true) or disable (false) the object forced depth.
		 * Enable this feature makes the object drawn at a specific depth.
		 * When correctly used, this feature allows you to avoid some Z-sorting problems.
		 */
		public function	enableForcedDepth( b:Boolean ):void
		{
			_enableForcedDepth = b;
			setModified( true );
		}
		
		/**
		 * Returns a boolean value specifying if the depth is forced or not
		 */
		public function	isForcedDepthEnable():Boolean
		{
			return _enableForcedDepth;
		}
		
		/**
		 * Set a forced depth for this object.
		 * To make this feature working you must enable the ForcedDepth system too.
		 * The higher the depth is, the sooner the more far the object will be represented.
		 */
		public function setForcedDepth( pDepth:Number ):void
		{
			_forcedDepth = pDepth;
			setModified( true );
		}
		
		/**
		 * Allows you to retrieve the forced depth value.
		 * The default value is 0.
		 */
		public function getForcedDepth():Number
		{
			return _forcedDepth;
		}

		/**
		* Represents the Object3D into a String.
		* @return	A String representing the Object3D
		*/
		override public function toString ():String
		{
			return getQualifiedClassName(this) + " [Faces: " + aFaces.length + ", Points: " + aPoints.length + "] Position: " + getPosition();
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
		* Returns the position of the Object3D as a 3D vector.
		* The returned position in the position in the World frame, not the camera's one.
		* In case you want to get the position to a camera, you'll have to add its position to this vector with VectorMat::add eg.
		* @param	void
		* @return	Vector the 3D position of the object
		*/
		public function getPosition():Vector
		{
			var v:Vertex = aPoints[0];
			return new Vector( v.wx - v.x, v.wy - v.y, v.wz - v.z );
		}
		
		/**
		* Returns the skin used for the back faces of this object. Returns the skin instance.
		* If you gave no value for this skin, the "normal" skin will be returned as it is the default back skin.
		* @param	void
		* @return	Skin The skin object.
		*/
		public function getBackSkin():Skin 
		{
			return _sb;
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
			var l:int = aFaces.length;
			while( --l > -1 )
			{
				aFaces[int(l)].setSkin( _s );
				aFaces[int(l)].updateTextureMatrix();
			}
			//
			_needRedraw = true;
			return true;
		}
		
		/**
		* Set a Skin to the back of all the faces of the object
		* <p>This method will set the the new Skin to all his faces.</p>
		* 
		* @param	s	The new Skin
		* @param	bOverWrite	Boolean, overwrite or not all specific Faces's Skin
		* @return	Boolean True is the skin is applied, false otherwise.
		*/
		public function setBackSkin( pSb:Skin ):Boolean
		{
			if(_sb)
			{
				_sb.removeEventListener( SandyEvent.UPDATE, __onSkinUpdated  );
			}
			// Now we register to the update event
			_sb = pSb;
			_sb.addEventListener( SandyEvent.UPDATE, __onSkinUpdated );
			//
			var l:int = aFaces.length;
			while( --l > -1 )
			{
			    aFaces[int(l)].setBackSkin( pSb );
				//aFaces[int(l)].updateTextureMatrix(); FIXME not available for back skin for instance
			}
			//
			_needRedraw = true;
			return true;
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
		public function enableEvents( b:Boolean ):void
		{
			var l:int;
			// -- 
			if( b )
			{
				if( !_bEv )
				{
					l = aFaces.length;
        			while( --l > -1 )
        			{
        			    aFaces[int(l)].enableEvents( true );
    					aFaces[int(l)].container.addEventListener(MouseEvent.CLICK, _onPress);
    					aFaces[int(l)].container.addEventListener(MouseEvent.MOUSE_UP, _onPress); //MIGRATION GUIDE: onRelease & onReleaseOutside
    					aFaces[int(l)].container.addEventListener(MouseEvent.ROLL_OVER, _onRollOver);	
    					aFaces[int(l)].container.addEventListener(MouseEvent.ROLL_OUT, _onRollOut);
        			}
				}
			}
			else if( !b && _bEv )
			{
				l = aFaces.length;
        		while( --l > -1 )
        		{
        	        aFaces[int(l)].enableEvents( false );
    				aFaces[int(l)].container.addEventListener(MouseEvent.CLICK, _onPress);
    				aFaces[int(l)].container.removeEventListener(MouseEvent.MOUSE_UP, _onPress);
    				aFaces[int(l)].container.removeEventListener(MouseEvent.ROLL_OVER, _onRollOver);
    				aFaces[int(l)].container.removeEventListener(MouseEvent.ROLL_OUT, _onRollOut);
        		}
			}
			_bEv = b;
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
		 * Get the visibility of the Object3D.
		 * @return Boolean The visibility boolean, true meaning that the object is visible.
		 */
		public function isVisible():Boolean
		{
			return _visible;
		}
		
		/**
		 * If set to {@code false}, all Face3D of the Object3D will be draw.
		 * A true value is equivalent to enable the backface culling algorithm.
		 * Default {@code true}
		 */
		public function enableBackFaceCulling( b:Boolean ):void
		{
			_backFaceCulling = b;
			_needRedraw = true;	
			setModified( true );
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
			var l:int = aFaces.length;
			for( var i:int = 0;i < l; i++ )
			{
				aFaces[int(i)].swapCulling();
			}
			_needRedraw = true;	
			setModified( true );
		}
			
		/**
		* Add a Point with the specified coordinates.
		* 
		* @param	px		The x coordinate
		* @param	py		The y coordinate
		* @param	pz		The z coordinate
		* @return	The index of the new {@link Vertex} in the {@code aPoints} array
		*/
		public function addPoint (px :Number, py:Number, pz:Number ):uint
		{
			setModified( true );
			return aPoints.push ( new Vertex ( px, py, pz ) );
		}
		
		public function addVertexPoint (p_vertex:Vertex):uint
		{
			setModified( true );
			return aPoints.push ( p_vertex );
		}
		

		/**
		* Render the Object3D.
		* <p>Check Faces display visibility and store visible Faces into ZBuffer.</p>
		*/ 		
		override public function render(p_oCamera:Camera3D, p_oViewMatrix:Matrix4, p_bCache:Boolean):void
		{
			// VISIBILITY CHECK
			if( isVisible() == false ) return;
			//			
			var l_nDepth:Number;
			var l_oFace:Polygon;
			var l_oFrustum:Frustum = p_oCamera.frustrum;
			var l_bCache:Boolean = p_bCache || _modified;
			// FIXME If the cache is enabled here, take the old matrix
			var l_oModelMatrix:Matrix4;
			var l_oMatrix:Matrix4 = getMatrix();
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
			/**
             * Now we consider the camera
             * Fixme consider the possible cache system for camera.
             */           
			l_oMatrix = p_oCamera.getProjectionMatrix() ;
            // Before doing any transformation of the object geometry, we are just going to transform its bounding volumes
            // and check if it is still in the camera field of view. If yes we do the transformations and the projection.
            var res:Number;
            var l_bClipped:Boolean = false;
            /////////////////////////
            //// BOUNDING SPHERE ////
            /////////////////////////
            
            if( _oBSphere == null ) _oBSphere = new BSphere( this );
           _oBSphere.transform( l_oModelMatrix );
            res = l_oFrustum.sphereInFrustum( _oBSphere );
			//
			if( res  == Frustum.OUTSIDE )
			{
				return;
			}
			else if( res == Frustum.INTERSECT )
			{
                ////////////////////////
                ////  BOUNDING BOX  //// DISABLED FOR THE MOMENT SINCE IT IS NOT CORRECT
                ////////////////////////
                if( _oBBox == null ) _oBBox = new BBox( this );
                _oBBox.transform( l_oModelMatrix );
                res = l_oFrustum.boxInFrustum( _oBBox );
                //
				if( res == Frustum.OUTSIDE )
				{
					// OUSIDE, the objet is clipped
					return;
				}
				else if (res == Frustum.INTERSECT && _enableClipping )
				{
				    l_bClipped = true;		 
				}
			}
            
            ///////////////////////////////////
            ///// VERTICES TRANSFORMATION /////
            ///////////////////////////////////
            var l_aPoints:Array = aPoints;  // TODO, we shall transform the normals too to have a faster isVisible face computation!
            
            // If we are here, is that the object shall be displayed. So we can transform its vertices into the camera
            // view coordinates
            var m11:Number,m21:Number,m31:Number,m41:Number,m12:Number,m22:Number,m32:Number,m42:Number,m13:Number,m23:Number,m33:Number,m43:Number,m14:Number,m24:Number,m34:Number,m44:Number;
			var l_oVertex:Vertex;
			var l_lId:int;
            //
            m11 = l_oModelMatrix.n11; m21 = l_oModelMatrix.n21; m31 = l_oModelMatrix.n31; m41 = l_oModelMatrix.n41;
			m12 = l_oModelMatrix.n12; m22 = l_oModelMatrix.n22; m32 = l_oModelMatrix.n32; m42 = l_oModelMatrix.n42;
			m13 = l_oModelMatrix.n13; m23 = l_oModelMatrix.n23; m33 = l_oModelMatrix.n33; m43 = l_oModelMatrix.n43;
			m14 = l_oModelMatrix.n14; m24 = l_oModelMatrix.n24; m34 = l_oModelMatrix.n34; m44 = l_oModelMatrix.n44;
			// Now we can transform the objet vertices into the camera coordinates	
			for( l_lId = 0; l_oVertex = l_aPoints[int(l_lId)]; l_lId ++ )
			{
				l_oVertex.wx = l_oVertex.x * m11 + l_oVertex.y * m12 + l_oVertex.z * m13 + m14;
				l_oVertex.wy = l_oVertex.x * m21 + l_oVertex.y * m22 + l_oVertex.z * m23 + m24;
				l_oVertex.wz = l_oVertex.x * m31 + l_oVertex.y * m32 + l_oVertex.z * m33 + m34;
				l_oVertex.projected = false;
			}
			
			/////////////////////////////////////
			///////// FRUSTUM CLIPPING //////////
			/////////////////////////////////////
			///////////////////////////////////
            /////      FACES  DISPLAY     /////
            ///////////////////////////////////
			// TODO, set all the face visibility computation here, and avoid the projection for non visible faces !
			// This may ask to change the camera display list parameters, but that's shall be ok to receive a polygon
			
			// Il the polygons will be clipped, we shall allocate a new array container the clipped vertex.
			if( l_bClipped ) l_aPoints = [];
			
			for( l_lId = 0; l_oFace = aFaces[int(l_lId)]; l_lId++ )
			{	
			    if ( l_oFace.isVisible() || !_backFaceCulling) 
				{
					l_oFace.clipped = false;
					if( l_bClipped )
					{
					    l_oFace.clip( l_oFrustum );
					    if( l_oFace.aClipped != null ) 
				            l_aPoints = l_aPoints.concat( l_oFace.aClipped );
				    }
					l_nDepth 	= (_enableForcedDepth) ? _forcedDepth : l_oFace.getZAverage();
					if( l_nDepth > 0 )
					{		
					    p_oCamera.addToDisplayList( l_oFace );  
					}
				}
			}	
				    
			///////////////////////////////////
			///////  SCREEN PROJECTION ////////
			///////////////////////////////////
			var l_nCste:Number;
			var l_nOffx:Number = p_oCamera.viewport.w2;
			var l_nOffy:Number = p_oCamera.viewport.h2;
			var mp11:Number,mp21:Number,mp31:Number,mp41:Number,mp12:Number,mp22:Number,mp32:Number,mp42:Number,mp13:Number,mp23:Number,mp33:Number,mp43:Number,mp14:Number,mp24:Number,mp34:Number,mp44:Number;
			//
			mp11 = l_oMatrix.n11; mp21 = l_oMatrix.n21; mp31 = l_oMatrix.n31; mp41 = l_oMatrix.n41;
			mp12 = l_oMatrix.n12; mp22 = l_oMatrix.n22; mp32 = l_oMatrix.n32; mp42 = l_oMatrix.n42;
			mp13 = l_oMatrix.n13; mp23 = l_oMatrix.n23; mp33 = l_oMatrix.n33; mp43 = l_oMatrix.n43;
			mp14 = l_oMatrix.n14; mp24 = l_oMatrix.n24; mp34 = l_oMatrix.n34; mp44 = l_oMatrix.n44;
			//
			for( l_lId = 0; l_oVertex = l_aPoints[int(l_lId)]; l_lId++ )
			{
				if( l_oVertex.projected ) continue;
				l_nCste = 	1 / ( l_oVertex.wx * mp41 + l_oVertex.wy * mp42 + l_oVertex.wz * mp43 + mp44 );
				l_oVertex.sx =  l_nCste * ( l_oVertex.wx * mp11 + l_oVertex.wy * mp12 + l_oVertex.wz * mp13 + mp14 ) * l_nOffx + l_nOffx;
				l_oVertex.sy = -l_nCste * ( l_oVertex.wx * mp21 + l_oVertex.wy * mp22 + l_oVertex.wz * mp23 + mp24 ) * l_nOffy + l_nOffy;
				l_oVertex.projected = true;
			}            
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
		 * Add a face to the objet, set the object skins to faces, and notify that there is a modification
		 */
		public function addFace( f:IPolygon ):void
		{
			// -- we update its texture matrix
			f.updateTextureMatrix();
			// -- store the face
			aFaces.push( f );
			// --
			setModified( true );
		}
		
		/**
		 * Add a face to the objet, set the object skins to faces, and notify that there is a modification
		 */
		public function addFaceList( p_list:Array ):void
		{
			// TODO:	Check if updateTextureMatrix on each face is necessary here
			//			If not than just replace it by arrays concatenation		
			var l:int = p_list.length;
			var f:Polygon;
			for (var i:int = 0; i<l; i++) 
			{
				f = p_list[int(i)];
				// -- we update its texture matrix
				f.updateTextureMatrix();
				// -- store the face
				aFaces.push( f );
			}
			// --
			setModified( true );
		}

		/**
		* This method allows you to know if the object needs to be redrawn or not. It happens only when the OBJECT skin is updated!
		* That means that if you have change the skin of the faces directly with face.setSkin instead of object.setSkin, those faces will not 
		* be updated properly. This missing feature will be fixed in the near future!
		* @param	void
		* @return	Boolean True if you should call the render method to update the object.
		*/
		public function needRefresh():Boolean
		{
			return _needRedraw;
		}
		
		override public function destroy():void
		{
			// --
			var l:int = aFaces.length;
			while( --l > -1 )
			{
				aFaces[int(l)].destroy();
				aFaces[int(l)] = null;
			}
			aFaces = null;
			// --
			_s.removeEventListener( SandyEvent.UPDATE, __onSkinUpdated );
			
			super.destroy();
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
		
		//////////////
		/// PRIVATE
		//////////////

		/**
		* called when the skin of an object change.
		* We want this object to notify that it has changed to redrawn, so we change its modified property.
		* @param	e
		*/ 
		private function __onSkinUpdated( e:Event ):void
		{
			_needRedraw = true;
		}

		
		private function _onPress(e:MouseEvent):void
		{
			dispatchEvent(e);
		}
		
		private function _onRollOver(e:MouseEvent):void
		{
			dispatchEvent(e);
		}
		
		private function _onRollOut(e:MouseEvent):void
		{
			dispatchEvent(e);
		}
	}
}