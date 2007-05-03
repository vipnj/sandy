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

import com.bourre.commands.Delegate;
import com.bourre.events.BasicEvent;
import com.bourre.events.EventBroadcaster;

import sandy.core.buffer.ZBuffer;
import sandy.core.data.BBox;
import sandy.core.data.BSphere;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.face.IPolygon;
import sandy.core.group.Leaf;
import sandy.core.World3D;
import sandy.events.ObjectEvent;
import sandy.events.SkinEvent;
import sandy.skin.SimpleLineSkin;
import sandy.skin.Skin;
import sandy.view.Frustum;
import sandy.core.transform.ITransform3D;
import sandy.core.data.Matrix4;

/**
* <p>Represent an Object3D in a World3D</p>
* 
* @author	Thomas Pfeiffer - kiroukou
* @author	Tabin Cédric - thecaptain
* @author	Nicolas Coevoet - [ NikO ]
* @author	Bruce Epstein - zeusprod
* @author	Martin Wood-Mitrovski
* @since 	1.0
* @version	1.2.2
* @date 	20.04.2007
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
	
	public var aClipped:Array;
	
	public var depth:Number;
	
	public var container:MovieClip;
	
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
		depth = 0;
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
		//
		_oEB = new EventBroadcaster( this );
		_oOnPress = new ObjectEvent( ObjectEvent.onPressEVENT, this );
		_oOnRelease = new ObjectEvent( ObjectEvent.onReleaseEVENT, this );
		_oOnReleaseOutside = new ObjectEvent( ObjectEvent.onReleaseOutsideEVENT, this );
		_oOnRollOver = new ObjectEvent( ObjectEvent.onRollOverEVENT, this );
		_oOnRollOut = new ObjectEvent( ObjectEvent.onRollOutEVENT, this );
		// we also set skin to Default constant
		setSkin( DEFAULT_SKIN, true );
		setBackSkin( DEFAULT_SKIN, true );
		//
		container = World3D.getInstance().getContainer().createEmptyMovieClip("object_"+_id, _id);
		World3D.getInstance().addEventListener( World3D.onContainerCreatedEVENT, this, __onWorldContainer );
	}	

	public function enableClipping( b:Boolean ):Void
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
	public function setBackSkin( pSb:Skin ):Boolean
	{
		//
		_sb.removeEventListener( SkinEvent.onUpdateEVENT, this );
		// Now we register to the update event
		_sb = pSb;
		_sb.addEventListener( SkinEvent.onUpdateEVENT, this, __onSkinUpdated );
		_sb.addEventListener( SkinEvent.onInitEVENT,   this, __onSkinInited );
		//
		__updateTextureMatrices( _sb );
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
		// -- 
		if( b )
		{
			if( !_bEv )
			{
				var dpress:Delegate = new Delegate(this, __sendObjectEvent);
				dpress.setArguments( _oOnPress );
				container.onPress = dpress.getFunction();
				//
				var drollover:Delegate = new Delegate(this, __sendObjectEvent);
				drollover.setArguments( _oOnRollOver );
				container.onRollOver = drollover.getFunction();
				//
				var drollout:Delegate = new Delegate(this, __sendObjectEvent);
				drollout.setArguments( _oOnRollOut );
				container.onRollOut = drollout.getFunction();
				//
				var drelease:Delegate = new Delegate(this, __sendObjectEvent);
				drelease.setArguments( _oOnRelease );
				container.onRelease = drelease.getFunction();
				//
				var dreleaseout:Delegate = new Delegate(this, __sendObjectEvent);
				dreleaseout.setArguments( _oOnReleaseOutside );
				container.onReleaseOutside = dreleaseout.getFunction();
			}
		}
		else if( !b && _bEv )
		{
			container.onPress = null;
			container.onRollOver = null;
			container.onRollOut = null;
			container.onRelease = null;
			container.onReleaseOutside = null;
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
			aFaces[s].swapCulling();
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
		var ndepth:Number;
		// -- local copy because it's faster
		var l:Number = aFaces.length;
		var f:IPolygon;
		//
		container.clear();
		//
		_aSorted = [];
		while( --l > -1 )
		{
			f = aFaces[l];
			if ( f.isVisible() || !_backFaceCulling ) 
			{
				ndepth 	= (_enableForcedDepth) ? _forcedDepth : f.getZAverage();
				if(ndepth) _aSorted.push( f );
			}
		}
		//
		_aSorted.sortOn( "depth", Array.NUMERIC | Array.ASCENDING );
		//
		l = _aSorted.length;
		while( --l > -1 )
		{
			_aSorted[l].render( container, _s, _sb );				
		}
		// -- 
		_needRedraw = false;
	}
	
	public function refresh( Void ):Void
	{
		var a:Array = _aSorted;
		var f:IPolygon;
		var l:Number = a.length;
		//
		container.clear();
		//
		while( --l > -1 )
		{
			a[l].refresh( container, _s, _sb );
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
		return _oBBox;
	}

	/**
	* Returns  bounding sphere of the object. [ minimum  value; maximum  value]
	* @param	Void
	* @return Return the bounding sphere
	*/
	public function getBSphere( Void ):BSphere
	{
		return _oBSphere;
	}
	
	/**
	 * Add a face to the object, set the object skins to faces, and notify that there is a modification
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
	 * Return the array containing the faces of the object
	 * @return Array The array of faces instances
	 */
	public function getFaces ():Array
	{
		return aFaces;
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
		//World3D.getInstance().getObjectEventManager().removeEventListeningObject( this );
		// --
		super.destroy();
	}
	
	/**
	 * Add a transformation to the current TransformGroup. This allows to apply a transformation to all the childs of the Node.
	 * @param t		The transformation to add
	 */
	public function setTransform( t:ITransform3D ):Void
	{
		_t = t;
		setModified( true );
	}
	
	/**
	 * Get the current TransformGroup transformation. This allows to manipulate the node transformation.
	 * @return	The transformation 
	 */
	public function getTransform( Void ):ITransform3D
	{
		return _t;
	}
	
	public function getMatrix( Void ):Matrix4
	{
		return _t.getMatrix();
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
		var result:Boolean = false;
		var res:Number;
		var l:Number;
		aClipped = aPoints;
		// Is clipping enable on that object
		if( _enableClipping )
		{
			// If a polygon was intersecting previously, we need to initialize its faces at their original state.
			if( _bPolyClipped )
			{
			    l = aFaces.length;
				while( --l > -1 )
				{
				    aFaces[int(l)].clipped  = false;
				}
				_bPolyClipped = false;
			}
				
			delete _oBSphere;
			_oBSphere = new BSphere( this );
			res = frustum.sphereInFrustum( _oBSphere );
			if( res  == Frustum.OUTSIDE )
			{
				result = true;
			}
			else if( res == Frustum.INTERSECT )
			{
				// The bounding sphere is intersecting a place at least.
				// Let's check the bounding box volume
				delete _oBBox;
				_oBBox = new BBox( this );
				res = frustum.boxInFrustum( _oBBox );
				//res = frustum.isBoxInFrustum( _oBBox.min, _oBBox.max );
				if( res == Frustum.OUTSIDE )
				{
					// OUSIDE, the objet is clipped
					result =  true;
				}
				else if (res == Frustum.INTERSECT )
				{
					aClipped = new Array();
					// We are intersecting a place one more time. The object shall be at the limit
					// of the frustum volume. Let's try to clip the faces against it.
					l = aFaces.length;
					while( --l > -1 )
					{
						aClipped = aClipped.concat( aFaces[l].clip( frustum ) );
					}
					// We consider that the object is not clipped and needs to be draw.
					_bPolyClipped = true;
				}// ELSE => INSIDE
			}// ELSE => INSIDE
		}// ELSE => INSIDE
		
		if( result ) container.clear();
		return result;
	}

	/**
	 * Adds passed-in {@code oL} listener for receiving passed-in {@code t} event type.
	 * 
	 * <p>Take a look at example below to see all possible method call.
	 * 
	 * <p>Example
	 * <code>
	 *   var oEB : IEventDispatcher = new EventBroadcaster(this);
	 *   oEB.addEventListener( myClass.onSometingEVENT, myFirstObject);
	 *   oEB.addEventListener( myClass.onSometingElseEVENT, this, __onSomethingElse);
	 *   oEB.addEventListener( myClass.onSometingElseEVENT, this, Delegate.create(this, __onSomething) );
	 * </code>
	 * 
	 * @param t Name of the Event.
	 * @param oL Listener object.
	 */
	public function addEventListener(t:String, oL) : Void
	{
		_oEB.addEventListener.apply( _oEB, arguments );
	}
	
	/**
	 * Removes passed-in {@code oL} listener that suscribed for passed-in {@code t} event.
	 * 
	 * <p>Example
	 * <code>
	 *   var oEB : IEventDispatcher = new EventBroadcaster(this);
	 *   oEB.removeEventListener( myClass.onSometingEVENT, myFirstObject);
	 *   oEB.removeEventListener( myClass.onSometingElseEVENT, this);
	 * </code>
	 * 
	 * @param t Name of the Event.
	 * @param oL Listener object.
	 */
	public function removeEventListener(t:String, oL) : Void
	{
		_oEB.removeEventListener( t, oL );
	}
	
	//////////////
	/// PRIVATE
	//////////////
	private function __onWorldContainer( e:BasicEvent ):Void
	{
		container.removeMovieClip();
		container = World3D.getInstance().getContainer().createEmptyMovieClip( "object_"+_id, _id );
	}
	
	private function __sendObjectEvent( e:ObjectEvent ):Void
	{
		_oEB.broadcastEvent.apply( _oEB, arguments );
	}

	/**
	* called when the skin of an object changes.
	* We want this object to notify that it has changed to redrawn, so we change its modified property.
	* @param	e
	*/ 
	private function __onSkinUpdated( e:SkinEvent ):Void
	{
		_needRedraw = true;	
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
	private function __updateTextureMatrices(s:Skin):Void
	{
		var l:Number = aFaces.length;
		while( --l > -1 )
		{
			aFaces[l].updateTextureMatrix( s );
		}
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
	private var _enableClipping:Boolean;
	private var _visible : Boolean;
	private var _enableForcedDepth:Boolean;
	private var _forcedDepth:Number;
	private var _fCallback:Function;
	private var _aSorted:Array;
	private var _eventDelegate:Delegate;
	private var _oBBox:BBox;
	private var _oBSphere:BSphere;
	private var _t:ITransform3D;
	private var _oOnPress:ObjectEvent;
	private var _oOnRelease:ObjectEvent;
	private var _oOnReleaseOutside:ObjectEvent;
	private var _oOnRollOver:ObjectEvent;
	private var _oOnRollOut:ObjectEvent;
	private var _oEB:EventBroadcaster;	
	private var _bPolyClipped:Boolean;
}
