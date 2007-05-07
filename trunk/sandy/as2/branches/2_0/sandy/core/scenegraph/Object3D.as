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


import sandy.core.data.Matrix4;
import sandy.core.data.Vertex;
import sandy.core.data.Vector;
import sandy.core.face.Polygon;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.events.MouseEvent;
import sandy.events.SkinEvent;
import sandy.materials.Material;
import sandy.core.scenegraph.Camera3D;
import sandy.view.Frustum;


/**
* <p>Represent an Object3D in a World3D</p>
* 
* @author	Thomas Pfeiffer - kiroukou
* @author	Tabin Cédric - thecaptain
* @author	Nicolas Coevoet - [ NikO ]
 * @author		Bruce Epstein	- zeusprod
* @author	Martin Wood-Mitrovski
 * @since		1.0
 * @version		2.0
 * @date 		07.05.2007
*/
class sandy.core.scenegraph.Object3D extends Shape3D
{
	
// ______________
// [PRIVATE] DATA________________________________________________		

	private var _sb:Material; // The back Skin of this Object3D
	private var _bEv:Boolean; // The event system state (enable or not)
	private var _backFaceCulling:Boolean;
	private var _enableClipping:Boolean;
	private var _enableForcedDepth:Boolean;
	private var _forcedDepth:Number;

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
	public function Object3D ( p_sName:String, p_geometry:Geometry3D )
	{
		super(p_sName, p_geometry);

		//
		_backFaceCulling = true;
		_bEv = false;
		//appearance = p_oAppearance;
		_enableForcedDepth = false;
		_enableClipping = false;
		_forcedDepth = 0;
	}
	
	
// __________________
// [PUBLIC] FUNCTIONS____________________________________________
	
	public function enableClipping( b:Boolean ):Void
	{
		_enableClipping = b;
	}
	
	/**
	 * Enable (true) or disable (false) the object forced depth.
	 * Enable this feature makes the object drawn at a specific depth.
	 * When correctly used, this feature allows you to avoid some Z-sorting problems.
	 */
	public function	enableForcedDepth( b:Boolean ):Void
	{
		_enableForcedDepth = b;
		changed = true;
	}
	
	/**
	 * Returns a boolean value specifying if the depth is forced or not
	 */
	public function	isForcedDepthEnable(Void):Boolean
	{
		return _enableForcedDepth;
	}
	
	/**
	 * Set a forced depth for this object.
	 * To make this feature working you must enable the ForcedDepth system too.
	 * The higher the depth is, the sooner the more far the object will be represented.
	 */
	public function setForcedDepth( pDepth:Number ):Void
	{
		_forcedDepth = pDepth;
		changed = true;
	}
	
	/**
	 * Allows you to retrieve the forced depth value.
	 * The default value is 0.
	 */
	public function getForcedDepth(Void):Number
	{
		return _forcedDepth;
	}

	
	/**
	* Represents the Object3D into a String.
	* @return	A String representing the Object3D
	*/
	public function toString ( Void ):String
	{
		return 'sandy.core.scenegraph.Object3D';
	}
	
	/**
	* Returns the Material instance used by this object.
	* Be careful, if your object have some face-specific skins, this method is not able to give you this information.
	* @param	Void
	* @return 	Skin the skin object
	*/
	public function getSkin( Void ):Material
	{
		// Deprecated
		// return _s;
	}
	
	/**
	* Returns the position of the Object3D as a 3D vector.
	* The returned position in the position in the World frame, not the camera's one.
	* In case you want to get the position to a camera, you'll have to add its position to this vector with VectorMat::add eg.
	* @param	Void
	* @return	Vector the 3D position of the object
	*/
	public function getPosition( Void ):Vector
	{
		var v:Vertex = aPoints[0];
		// Does this still need a FIX as per Petit (tx, ty, and tz instead of wx, wy, and wz)?
		return new Vector( v.wx - v.x, v.wy - v.y, v.wz - v.z );
	}

	/**
	* Returns the position of the center of the Object3D relative to the Flash stage.
	* @param	Void
	* @return	Vector with x and y properties. z property is always zero.
	*/
	public function getPositionOnStage( Void ):Vector
	{
		var centerX:Number = 0;
		var centerY:Number = 0;
		var i:Number = 0;
		for (i = 0; i < aPoints.length; i++) {
			centerX += aPoints[i].sx;
			centerY += aPoints[i].sy;
		}
		centerX = centerX / i;
		centerY = centerY / i;
		// This could return a 2D Point instead, but I went with Vector since
		// it is part of the Sandy libraries can we can control the toString(); method.
		return new Vector (centerX, centerY, 0);
	}
	
	/**
	* Returns the skin used for the back faces of this object. Returns the skin instance.
	* If you gave no value for this skin, the "normal" skin will be returned as it is the default back skin.
	* @param	Void
	* @return	Material The material (skin) object.
	*/
	public function getBackSkin(Void):Material 
	{
		return _sb;
	}

	
	/**
	* Set a Material to the Object3D.
	* <p>This method will set the the new Material to all his faces.
	* Warning : If no backface skin has benn applied, the skin will be applied to the back side of faces too!
	* </p>
	* @param	s	The new Material to apply to faces
	* @param	bOverWrite	Boolean, overwrite or not all specific Faces's Skin
	* @return	Boolean True to apply the Material to the non-default faces skins; false otherwise (default).
	*/
	public function setSkin( pS:Material ):Boolean
	{
		//
		_s.removeEventListener( SkinEvent.onUpdateEVENT, this );
		// Now we register to the update event
		_s = pS;
		_s.addEventListener( SkinEvent.onUpdateEVENT, this, __onSkinUpdated );
		_s.addEventListener( SkinEvent.onInitEVENT,   this, __onSkinInited );

		__updateTextureMatrices(_s);

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
	public function setBackSkin( pSb:Material ):Boolean
	{
		if(_sb)
		{
			_sb.removeEventListener( SkinEvent.UPDATE, __onSkinUpdated  );
		}
		// Now we register to the update event
		_sb = pSb;
		_sb.addEventListener( SkinEvent.UPDATE, __onSkinUpdated );
		//
		var l_faces:Array = geometry.faces;
		var l:Number = l_faces.length;
		while( --l > -1 )
		{
		    l_faces[int(l)].setBackSkin( pSb );
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
	public function enableEvents( b:Boolean ):Void
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
	 * Hide (false) or make visible( true)  the current object.
	 * The default state is visible (true)
	 */
	public function setVisible( b:Boolean ):Void
	{
		_visible = b;
		setModified( true );
	}
	
	/**
	 * Get the visibility of the Object3D.
	 * @return Boolean The visibility boolean, true meaning that the object is visible.
	 */
	public function isVisible( Void ):Boolean
	{
		return _visible;
	}

	/**
	 * If set to {@code false}, all Face3D of the Object3D will be draw.
	 * A true value is equivalent to enable the backface culling algorithm.
	 * Default {@code true}
	 */
	public function enableBackFaceCulling( b:Boolean ):Void
	{
		_backFaceCulling = b;
		_needRedraw = true;	
		changed = true;
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
	

	/**
	* Render the Object3D.
	* <p>Check Faces display visibility and store visible Faces into ZBuffer.</p>
	*/ 		
	public function render(p_oCamera:Camera3D, p_oViewMatrix:Matrix4, p_bCache:Boolean):Void
	{	
		super.render(p_oCamera, p_oViewMatrix, p_bCache);
		//
		var l_nDepth:Number;
		var l_oFace:Polygon;
		var l_oFrustum:Frustum = p_oCamera.frustrum;
		// 
		var l_oModelMatrix:Matrix4 = __updateLocalViewMatrix( p_oCamera, p_oViewMatrix, p_bCache );
        
        // Now we consider the camera .Fixme consider the possible cache system for camera.
		var l_oMatrix:Matrix4 = p_oCamera.getProjectionMatrix() ;
        
        // Before doing any transformation of the object geometry, we are just going to transform its bounding volumes
        // and check if it is still in the camera field of view. If yes we do the transformations and the projection.
        var l_bClipped:Boolean = false;
        var res:Number = __frustumCulling( l_oModelMatrix, p_oCamera.frustrum );
        if( res == Frustum.OUTSIDE ) return;
        else if( res == Frustum.INTERSECT && _enableClipping ) l_bClipped = true;
        
        ///////////////////////////////////
        ///// VERTICES TRANSFORMATION /////
        ///////////////////////////////////
        var l_aPoints:Array = geometry.points;  // TODO, we shall transform the normals too to have a faster isVisible face computation!
        
        // If we are here, is that the object shall be displayed. So we can transform its vertices into the camera
        // view coordinates
        var m11:Number,m21:Number,m31:Number,m41:Number,m12:Number,m22:Number,m32:Number,m42:Number,m13:Number,m23:Number,m33:Number,m43:Number,m14:Number,m24:Number,m34:Number,m44:Number;
		var l_oVertex:Vertex;
		var l_lId:Number;
        //
        m11 = l_oModelMatrix.n11; m21 = l_oModelMatrix.n21; m31 = l_oModelMatrix.n31; m41 = l_oModelMatrix.n41;
		m12 = l_oModelMatrix.n12; m22 = l_oModelMatrix.n22; m32 = l_oModelMatrix.n32; m42 = l_oModelMatrix.n42;
		m13 = l_oModelMatrix.n13; m23 = l_oModelMatrix.n23; m33 = l_oModelMatrix.n33; m43 = l_oModelMatrix.n43;
		m14 = l_oModelMatrix.n14; m24 = l_oModelMatrix.n24; m34 = l_oModelMatrix.n34; m44 = l_oModelMatrix.n44;
		// If necessary we transform the normals vectors
		if( _backFaceCulling )
		{
		    var l_aNormals:Array = geometry.normals;
		    // Now we can transform the objet vertices into the camera coordinates	
			for( l_lId = 0; l_oVertex = l_aNormals[int(l_lId)]; l_lId ++ )
			{
				l_oVertex.wx = l_oVertex.x * m11 + l_oVertex.y * m12 + l_oVertex.z * m13;
				l_oVertex.wy = l_oVertex.x * m21 + l_oVertex.y * m22 + l_oVertex.z * m23;
				l_oVertex.wz = l_oVertex.x * m31 + l_oVertex.y * m32 + l_oVertex.z * m33;
			}
		}
		// Now we can transform the objet vertices into the camera coordinates	
		for( l_lId = 0; l_oVertex = l_aPoints[int(l_lId)]; l_lId ++ )
		{
			l_oVertex.wx = l_oVertex.x * m11 + l_oVertex.y * m12 + l_oVertex.z * m13 + m14;
			l_oVertex.wy = l_oVertex.x * m21 + l_oVertex.y * m22 + l_oVertex.z * m23 + m24;
			l_oVertex.wz = l_oVertex.x * m31 + l_oVertex.y * m32 + l_oVertex.z * m33 + m34;
			l_oVertex.projected = false;
		}
		
		/////////////////////////////////////////////////////
		///////// FRUSTUM CLIPPING AND FACES TESTS //////////
		/////////////////////////////////////////////////////

        ///////////////////////////////////
		// TODO, set all the face visibility computation here, and avoid the projection for non visible faces !
		// This may ask to change the camera display list parameters, but that's shall be ok to receive a polygon
		
		// Il the polygons will be clipped, we shall allocate a new array container the clipped vertex.
		if( l_bClipped ) l_aPoints = [];
		
		var l_faces:Array = geometry.faces;
		var l_visibleFaces:Array = [];
		//
		for( l_lId = 0; l_oFace = l_faces[int(l_lId)]; l_lId++ )
		{	
		    if ( l_oFace.isVisible() || !_backFaceCulling) 
			{
				l_oFace.isClipped = false;
				if( l_bClipped )
				{
				    l_oFace.clip( l_oFrustum );
				    if( l_oFace.clipped != null ) 
			            l_aPoints = l_aPoints.concat( l_oFace.clipped );
			    }
				l_nDepth 	= (_enableForcedDepth) ? _forcedDepth : l_oFace.getZAverage();
				if( l_nDepth )	l_visibleFaces.push(l_oFace);
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
		
		// We render the visible faces and add them into the display List
		for( l_lId = 0; l_oFace = l_visibleFaces[int(l_lId)]; l_lId++ )
		{
		    l_oFace.render();
		    p_oCamera.addToDisplayList( l_oFace.container, l_oFace.depth );    
		}	    
	}

	//////////////
	/// PRIVATE
	//////////////
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
	* called when the skin of an object changes.
	* We want this object to notify that it has changed to redrawn, so we change its modified property.
	* @param	e
	*/ 
	private function __onSkinUpdated( e:SkinEvent ):Void
	{
		_needRedraw = true;
		__updateTextureMatrices(e.getTarget());	
	}
	

	/**
	* called when the skin of an object is initialized.
	* We use this to update the object's texture matrix after asynchronously loading
	*  an external SWF or JPG MovieSkin.
	* @param	e
	*/ 
	private function __onSkinInited( e:SkinEvent ):Void
	{
		_needRedraw = true;
		__updateTextureMatrices(e.getTarget());		
	}
	
	/**
	 * If the skin / texture has changed update the matrices for each face
	 * @param	s: Skin - the updated skin
	*/
	/*
	private function __updateTextureMatrices(s:Skin):Void
	{
		var l:Number = aFaces.length;
		while( --l > -1 )
		{
			aFaces[l].updateTextureMatrix( s );
		}
	}
*/
}
