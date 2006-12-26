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

import sandy.core.data.BBox;
import sandy.core.buffer.ZBuffer;
import sandy.core.data.UVCoord;
import sandy.core.data.Vertex;
import sandy.core.data.Vector;
import sandy.core.face.Face;
import sandy.events.ObjectEvent;
import sandy.skin.SimpleLineSkin;
import sandy.skin.Skin;
import sandy.events.SkinEvent;
import sandy.core.group.Leaf;

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
	public static function get DEFAULT_SKIN() : Skin 
	{ 
		return _DEFAUT_SKIN; 
	}
	
	/**
	 * If set to {@code true}, all Face3D of the Object3D will be draw.
	 * A false value is equivalent to enable the backface culling algorithm.
	 * Default {@code false}
	 */
	public var enableBackFaceCulling : Boolean;
	
	/**
	* Array of Vertex ( Points used in this Object3D )
	*/
	public var aPoints : Array;
	/**
	* Array of normals vertex. UNUSED in the current version of the engine.
	*/
	public var aNormals: Array;
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
		_aFaces		= new Array ();
		_aUv 		= new Array ();
		enableBackFaceCulling = true;
		_bEv = false;
		_needRedraw = false;
		// we also set skin to Default constant
		setSkin( DEFAULT_SKIN, true );
		setBackSkin( DEFAULT_SKIN, true );
	}		
	
	/**
	* Represents the Object3D into a String.
	* @return	A String representing the Object3D
	*/
	public function toString (Void):String
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
	public function setSkin( s:Skin, bOverWrite:Boolean ):Boolean
	{
		_s.removeEventListener( SkinEvent.onUpdateEVENT, this );
		
		bOverWrite = (bOverWrite == undefined ) ? false : bOverWrite;
		// set the skin to all the faces
		var aF : Array = _aFaces;
		var lf : Number = aF.length;
		while ( --lf > -1 ) 
		{
			var face:Face = aF[ lf ];
			if ( bOverWrite || face.getSkin() == _s )
			{
 				face.setSkin( s );
			} 
		}
		_s = s;
		// Now we register to the update event
		_s.addEventListener( SkinEvent.onUpdateEVENT, this, __onSkinUpdated );

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
	public function setBackSkin( s:Skin, bOverWrite:Boolean ):Boolean
	{
		_s.removeEventListener( SkinEvent.onUpdateEVENT, this );
		bOverWrite = (bOverWrite == undefined ) ? false : bOverWrite;
		// set the skin to all the faces
		var aF : Array = _aFaces;
		var lf : Number = aF.length;
		while ( --lf > -1 ) 
		{
			var face:Face = aF[ lf ];
			if ( bOverWrite || face.getBackSkin() == _sb )
			{
				face.setBackSkin( s );
			} 
		}
		_sb = s;
		// Now we register to the update event
		_s.addEventListener( SkinEvent.onUpdateEVENT, this, __onSkinUpdated );
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
		_bEv = b;
		var s:String;
		for( s in _aFaces )
			Face(_aFaces[s]).enableEvents( b );
	}

	/**
	* This method allows you to change the backface culling side.
	* For example when you want ot display a cube, you are actually outside the cube, and you see its external faces.
	* But in the case you are inside the cube, by default Sandy's engine make the faces invisible (because you should not be in there).
	* Now if you need to be only inside the cube, you can call the method, and after that the bue faces will be visible only from the interior of the cube.
	* The last possibility could be to make the faces visile from inside and oustside the cube. THis is really easy to do, you just have to change the enableBackFaceCulling value and set it to false.
	*/
	public function swapCulling( Void ):Void
	{
		var s:String;
		for( s in _aFaces )
			Face(_aFaces[s]).swapCulling();
	}
	
	/**
	* Add an UVCoordinate to the Object3D.
	* 
	* @param	x	The x coordinate
	* @param	y	The y coordinate
	* @return	UVCoord The created object.
	*/
	public function addUVCoordinate( x:Number, y:Number ):UVCoord
	{
		setModified( true );
		var o:UVCoord = new UVCoord( x, y );
		_aUv.push( o );
		return o;
	}
		
	/**
	* Add a Point with the specified coordinates.
	* 
	* @param	px		The x coordinate
	* @param	py		The y coordinate
	* @param	pz		The z coordinate
	* @return	The index of the new {@link Vertex} in the {@code aPoints} array
	*/
	public function addPoint (px : Number, py : Number, pz : Number ) : Number
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
		var ndepth:Number, min:Number;
		// -- local copy because it's faster
		var aF:Array = _aFaces;
		var s:String;
		var f:Face;
		for( s in aF )
		{
			f 		= aF [s];
			ndepth 	= f.getZAverage();
			// CLIPPING Now is the object behind the camera?
			if ( f.getMinDepth() > 100 )
			{
				// if face is visible or enableBackFaceCulling is set to false
				if ( f.isVisible () || !enableBackFaceCulling ) 
				{
					ZBuffer.push( {face : f, depth : ndepth} );
				}
			}				
		}
		// -- 
		_needRedraw = false;
	}
	
	public function refresh( Void ):Void
	{
		var s:String;
		var aF:Array = _aFaces;
		for( s in aF )
		{
			aF [s].refresh();
		}
		// -- 
		_needRedraw = false;
	}
	
	/**
	* Returns  bounds of the object. [ minimum  value; maximum  value]
	* @param	Void
	* @return Return the array containing the minimum  value and maximum  value of the object in the world coordinate.
	*/
	public function getBounds( Void ):BBox
	{
		return BBox.create( this );
	}
	
	
	public function addFace( f:Face ):Void
	{
		// set Default Skin
		f.setSkin( _s );
		f.setBackSkin( _sb );		
		//store the face
		_aFaces.push( f );
		// the object listen the face events
		f.addEventListener( ObjectEvent.onPressEVENT, this, __onPressed );
		f.addEventListener( ObjectEvent.onRollOverEVENT, this, __onRollOver );
		f.addEventListener( ObjectEvent.onRollOutEVENT, this, __onRollOut );
		//
		setModified( true );
	}

	/**
	 * Return the array containing the faces of the object
	 * @return Array The array of faces instances
	 */
	public function getFaces ():Array
	{
		return _aFaces;
	}
	
	/**
	* This method allows you to know if the object needs to be redrawn or not. It happens when it skins is updated!
	* TODO : This feature doesn't work when multiples skins are applied to the faces of the object directly!
	* @param	Void
	* @return	Boolean True if you should call the render method to update the object.
	*/
	public function needRefresh( Void ):Boolean
	{
		return _needRedraw;
	}
	
	/**
	* -------------------------------------------------------
	* 			PRIVATE VAR
	* -------------------------------------------------------
	*/ 
	
	/**
	* Array of the faces of the Object3D.
	*/ 
	private var _aFaces:Array;
	
	/**
	* Array of UVCoords, represents textures position, for this Object3D
	*/ 	
	private var _aUv:Array;
		
	/**
	* The Skin of this Object3D
	*/ 	
	private var _s:Skin;
	
	/**
	* The back Skin of this Object3D
	*/ 	
	private var _sb:Skin;
	
	/**
	* Say if the object needs to be drawn again or not. Happens when the skin is updated!
	*/
	private var _needRedraw:Boolean;
		
	/**
	* The event system state (enable or not)
	*/ 	
	private var _bEv:Boolean;
	
	
	private function __onPressed( e:ObjectEvent ):Void
	{
		broadcastEvent( new ObjectEvent( ObjectEvent.onPressEVENT, this ) );
	}
	private function __onRollOver( e:ObjectEvent ):Void
	{
		broadcastEvent( new ObjectEvent( ObjectEvent.onRollOverEVENT, this ) );
	}
	private function __onRollOut( e:ObjectEvent ):Void
	{
		broadcastEvent( new ObjectEvent( ObjectEvent.onRollOutEVENT, this ) );
	}	
	
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
