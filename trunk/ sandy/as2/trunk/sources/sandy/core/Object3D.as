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

import sandy.core.buffer.ZBuffer;
import sandy.core.data.BBox;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.face.Face;
import sandy.core.face.IPolygon;
import sandy.core.group.Leaf;
import sandy.core.World3D;
import sandy.events.SkinEvent;
import sandy.skin.SimpleLineSkin;
import sandy.skin.Skin;
import sandy.view.Frustum;
import com.bourre.events.BasicEvent;
import com.bourre.commands.Delegate;

/**
* <p>Represent an Object3D in a World3D</p>
* 
* @author	Thomas Pfeiffer - kiroukou
* @author	Tabin Cédric - thecaptain
* @author	Nicolas Coevoet - [ NikO ]
* @version	1.0
* @date 	23.06.2006
*/
class sandy.core.Object3D extends Leaf
{
	/**
	* This is a constante, the default skin used by an Object3D
	*/
	private static var _DEFAUT_SKIN:Skin = new SimpleLineSkin(); 
	/**
	* Default Skin of the Object3D.
	*/
	public static function get DEFAULT_SKIN():Skin 
	{ 
		return _DEFAUT_SKIN; 
	}
	/**
	* Array of Vertex ( Points used in this Object3D )
	*/
	public var aPoints:Array;
	/**
	* Array of the faces of the Object3D.
	*/ 
	public var aFaces:Array;
	/**
	* Array of normals vertex. UNUSED in the current version of the engine.
	*/
	public var aNormals:Array;

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
		aPoints		= new Array ();
		aFaces		= new Array ();
		_aSorted	= new Array ();
		_backFaceCulling = true;
		_bEv = false;
		_needRedraw = false;
		_visible = true;
		_enableForcedDepth = false;
		_forcedDepth = 0;
		
		var d:Delegate = new Delegate(this, __renderFaces);
		_fCallback = d.getFunction();
		// we also set skin to Default constant
		setSkin( DEFAULT_SKIN, true );
		setBackSkin( DEFAULT_SKIN, true );
		//
		_mc = World3D.getInstance().getContainer().createEmptyMovieClip("object_"+_ID_, _ID_);
		World3D.getInstance().addEventListener( World3D.onContainerCreatedEVENT, this, __onWorldContainer );
	}	

	/**
	 * Enable (true) or disable (false) the object forced depth.
	 * Enable this feature makes the object drawn at a specific depth.
	 * When correctly used, this feature allows you to avoid some Z-sorting problems.
	 */
	public function	enableForcedDepth( b:Boolean ):Void
	{
		_enableForcedDepth = b;
		setModified( true );
	}
	
	/**
	 * Returns a boolean value specifying if the depth is forced or not
	 */
	public function	isForcedDepthEnable( Void ):Boolean
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
		setModified( true );
	}
	
	/**
	 * Allows you to retrieve the forced depth value.
	 * The default value is 0.
	 */
	public function getForcedDepth( Void ):Number
	{
		return _forcedDepth;
	}

	/**
	* Represents the Object3D into a String.
	* @return	A String representing the Object3D
	*/
	public function toString ( Void ):String
	{
		return 'sandy.core.Object3D';
	}
	
	/**
	* Returns the skin instance used by this object.
	* Be carefull, if your object faces have some skins some specific skins, this method is not able to give you this information.
	* @param	Void
	* @return 	Skin the skin object
	*/
	public function getSkin( Void ):Skin
	{
		return _s;
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
		return new Vector( v.wx - v.x, v.wy - v.y, v.wz - v.z );
	}
	
	/**
	* Returns the skin used for the back faces of this object. Returns the skin instance.
	* If you gave no value for this skin, the "normal" skin will be returned as it is the default back skin.
	* @param	Void
	* @return	Skin The skin object.
	*/
	public function getBackSkin( Void ):Skin
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
		//
		_s.removeEventListener( SkinEvent.onUpdateEVENT, this );
		// Now we register to the update event
		_s = pS;
		_s.addEventListener( SkinEvent.onUpdateEVENT, this, __onSkinUpdated );
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
		//
		_sb.removeEventListener( SkinEvent.onUpdateEVENT, this );
		// Now we register to the update event
		_sb = pSb;
		_sb.addEventListener( SkinEvent.onUpdateEVENT, this, __onSkinUpdated );
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
		var l:Number = aFaces.length;
		while( --l > -1 )
		{
			Face(aFaces[l]).enableEvents( b );
		}
		// -- 
		if( b )
		{
			if( !_bEv )
			{
				World3D.getInstance().getObjectEventManager().addEventListeningObject( this );
			}
		}
		else if( !b && _bEv )
		{
			World3D.getInstance().getObjectEventManager().removeEventListeningObject( this );
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
		setModified( true );
	}
	
	/**
	* This method allows you to change the backface culling side.
	* For example when you want to display a cube, you are actually outside the cube, and you see its external faces.
	* But in the case you are inside the cube, by default Sandy's engine make the faces invisible (because you should not be in there).
	* Now if you need to be only inside the cube, you can call the method, and after that the bue faces will be visible only from the interior of the cube.
	* The last possibility could be to make the faces visile from inside and oustside the cube. This is really easy to do, you just have to change the enableBackFaceCulling value and set it to false.
	*/
	public function swapCulling( Void ):Void
	{
		var s:String;
		for( s in aFaces )
			Face(aFaces[s]).swapCulling();
		// -- swap the skins too
		/*
		var tmp:Skin;
		tmp = _sb;
		_sb = _s;
		_s = tmp;
		 */
		// --
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
	public function addPoint (px :Number, py:Number, pz:Number ):Number
	{
		setModified( true );
		return aPoints.push ( new Vertex ( px, py, pz ) );
	}
	
	/**
	* Render the Object3D.
	* <p>Check Faces display visibility and store visible Faces into ZBuffer.</p>
	*/ 
	public function render ( Void ):Void
	{
		var l:Number = aPoints.length;
		var p:Number = l;
		var lDepth:Number = 0;
		while( --l > -1 ) lDepth += aPoints[l].nz;
		ZBuffer.push( { movie:_mc, depth:(lDepth/p), callback:_fCallback } );
	}
	
	private function __renderFaces( Void ):Void
	{
		var ndepth:Number;
		// -- local copy because it's faster
		var l:Number = aFaces.length;
		var f:IPolygon;
		//
		_mc.clear();
		//
		while( --l > -1 )
		{
			f = aFaces[l];
			ndepth 	= (_enableForcedDepth) ? _forcedDepth : f.getZAverage();
			_aSorted[l] = { face:f, depth:ndepth };
		}
		//
		_aSorted.sortOn( "depth", Array.NUMERIC | Array.DESCENDING );
		//
		l = _aSorted.length;
		while( --l > -1 )
		{
			f = _aSorted[l].face;
			if ( f.isVisible() || !_backFaceCulling ) 
			{
				f.render( _mc, _s, _sb );
			}				
		}
		// -- 
		_needRedraw = false;
	}
	
	public function refresh( Void ):Void
	{
		var a:Array = _aSorted;
		var f:IPolygon;
		var l:Number = a.length;
		_mc.clear();
		while( --l > -1 )
		{
			f = a[l];
			if ( f.isVisible () || !_backFaceCulling ) 
				f.refresh( _mc, _s, _sb );
		}
		// -- 
		_needRedraw = false;
	}
	
	/**
	* Returns  bounds of the object. [ minimum  value; maximum  value]
	* @param	Void
	* @return Return the array containing the minimum  value and maximum  value of the object in the world coordinate.
	*/
	public function getBBox( Void ):BBox
	{
		return BBox.create( this );
	}

	/**
	 * Add a face to the objet, set the object skins to faces, and notify that there is a modification
	 */
	public function addFace( f:IPolygon ):Void
	{
		// -- we update its texture matrix
		f.updateTextureMatrix();	
		// -- store the face
		aFaces.push( f );
		// --
		setModified( true );
	}

	/**
	* This method allows you to know if the object needs to be redrawn or not. It happens only when the OBJECT skin is updated!
	* That means that if you have change the skin of the faces directly with face.setSkin instead of object.setSkin, those faces will not 
	* be updated properly. This missing feature will be fixed in the near future!
	* @param	Void
	* @return	Boolean True if you should call the render method to update the object.
	*/
	public function needRefresh( Void ):Boolean
	{
		return _needRedraw;
	}
	
	public function destroy( Void ):Void
	{
		// --
		var l:Number = aFaces.length;
		while( --l > -1 )
		{
			aFaces[l].destroy();
		}
		// --
		_s.removeEventListener( SkinEvent.onUpdateEVENT, this );
		// --
		World3D.getInstance().getObjectEventManager().removeEventListeningObject( this );
		// --
		super.destroy();
	}
	
	public function clip( frustum:Frustum ):Boolean
	{
		/*
		var aF:Array = aFaces;
		var l:Number = aF.length;
		var f:IPolygon;
		while( --l > -1 )
		{
			bClipped = bClipped || aF[l].clip( frustum );
		}
		*/
		if( frustum.boxInFrustum( getBBox() ) == Frustum.OUTSIDE )
			return true;
		else
			return false;
	}

	public function getContainer( Void ):MovieClip
	{
		return _mc;
	}
	
	//////////////
	/// PRIVATE
	//////////////
	private function __onWorldContainer( e:BasicEvent ):Void
	{
		_mc.removeMovieClip();
		_mc = World3D.getInstance().getContainer().createEmptyMovieClip("polygon_"+_ID_, _ID_);
	}
	/**
	* -------------------------------------------------------
	* 			PRIVATE VAR
	* -------------------------------------------------------
	*/	
	private var _s:Skin;// The Skin of this Object3D
	private var _sb:Skin;// The back Skin of this Object3D
	private var _needRedraw:Boolean;//Say if the object needs to be drawn again or not. Happens when the skin is updated!
	private var _bEv:Boolean;// The event system state (enable or not)
	private var _backFaceCulling:Boolean;
	private var _visible : Boolean;
	private var _enableForcedDepth:Boolean;
	private var _forcedDepth:Number;
	private var _fCallback:Function;
	private var _mc:MovieClip;
	private var _aSorted:Array;
	
	/**
	* called when the skin of an object change.
	* We want this object to notify that it has changed to redrawn, so we change its modified property.
	* @param	e
	*/ 
	private function __onSkinUpdated( e:SkinEvent ):Void
	{
		_needRedraw = true;
	}
}
