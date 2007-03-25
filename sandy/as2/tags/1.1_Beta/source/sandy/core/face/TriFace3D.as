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

import sandy.core.data.UVCoord;
import sandy.core.data.Vertex;
import sandy.core.face.Face;
import sandy.core.Object3D;
import sandy.skin.Skin;
import com.bourre.events.EventBroadcaster;
import com.bourre.commands.Delegate;
import sandy.events.ObjectEvent;
import com.bourre.events.BasicEvent;
import sandy.core.data.Vector;
import sandy.math.VectorMath;


/**
* TriFace3D
* This class is the origin to all the faces. It represents the face of the object, so the visible part of it.
* Without faces objects an object isn't displayable.
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @since		0.1
* @version		0.2
* @date 		12.01.2006 
**/

class sandy.core.face.TriFace3D extends EventBroadcaster implements Face
{

	/**
	 * Array containing UV coordinates.
	 */
	public var aUv:Array;
	
	/**
	* Create a new {@code TriFace3D}.
	* 
	* @param oref A reference to his Object3D;
	* @param pt1 a Vertex;
	* @param pt2 a Vertex;
	* @param pt3 a Vertex;
	*/
	public function TriFace3D( oref:Object3D, pt1:Vertex, pt2:Vertex, pt3:Vertex )
	{
		super( this );
		_o = oref;
		_va = pt1;
		_vb = pt2;
		_vc = pt3;
		aUv = new Array();
		_bfc = 1;
		_id = TriFace3D._ID_ ++;
	}
	
	/**
	* Allows you to get the vertex of the face. Very usefull when you want to make some calculation on a face after it has been clicked.
	* @param	Void
	* @return Array The array of vertex.
	*/
	public function getVertex( Void ):Array
	{
		return [ _va, _vb, _vc ];
	}
	
	/**
	* Returns the ID of the current face. This ID is an unique number.
	* @param	Void
	* @return	Number The ID of the face.
	*/
	public function getId(Void):Number
	{
		return _id;
	}
	
	/**
	* Enable or not the events onPress, onRollOver and onRollOut with this face.
	* @param b Boolean True to enable the events, false otherwise.
	*/
	public function enableEvents( b:Boolean ):Void
	{
		_bEv = b;
	}
	
	/**
	 * Create a clone of the face.
	 * <p>A clone is a perfect copy of the current {@code TriFace3D}.</p>
	 *
	 * @return	A copy of the current {@code TriFace3D}
	 */	
	public function clone( Void ):TriFace3D
	{
		return new TriFace3D( _o, _va, _vb, _vc );
	}
	
	/**
	 * Set up the skin of the face.
	 *
	 * @param	s	The Skin to set.
	 */
	public function setSkin( s:Skin ):Void
	{
		_s = s;
	}
	
	/**
	 * Get the skin of the face
	 *
	 * @return	The Skin
	 */
	public function getSkin( Void ):Skin
	{
		return _s;
	}
	/**
	 * Set up the back skin of the face.
	 * It corresponds to the skin that is applied to the back of the face, so to the faces that is normally hidden to 
	 * the user but that is visible if you've set {@code Object3D.drawAllFaces} to true.
	 * @param	s	The Skin to set.
	 */
	public function setBackSkin( s:Skin ):Void
	{
		_sb = s;
	}
	
	/**
	 * Returns the the skin of the back of this face.
	 * @see Face.setBackSkin
	 * @return	The Skin
	 */
	public function getBackSkin( Void ):Skin
	{
		return _sb;
	}
	
	/**
	 * Set a new texture coordinates points refers.
	 * @param	a	{code UVCoord}
	 * @param	b	{code UVCoord}
	 * @param	c	{code UVCoord}
	 */	
	public function setUVCoordinates( a:UVCoord, b:UVCoord, c:UVCoord ):Void
	{
		aUv.push(a, b, c);
	}
	
	/**
	 * Create the normal vector of the face.
	 *
	 * @return	The resulting {@code Vertex} corresponding to the normal.
	 */	
	public function createNormale( Void ):Vector
	{
		var v:Vector, w:Vector;
		var a:Vertex = _va, b:Vertex = _vb, c:Vertex = _vc;
		v = new Vector( b.tx - a.tx, b.ty - a.ty, b.tz - a.tz );
		w = new Vector( b.tx - c.tx, b.ty - c.ty, b.tz - c.tz );
		// -- we compute de cross product
		_vn = VectorMath.cross( v, w );//new Vector( (w.y * v.z) - (w.z * v.y) , (w.z * v.x) - (w.x * v.z) , (w.x * v.y) - (w.y * v.x) );
		// -- we normalize the resulting vector
		VectorMath.normalize( _vn ) ;
		// -- we return the resulting vertex
		return _vn;
	}

	/**
	 * Set the normal vector of the face.
	 *
	 * @param	Vertex
	 */
	public function setNormale( n:Vector ):Void
	{
		_vn = n;
	}
	
	/**
	 * isvisible 
	 * <p>Say if the face is visible or not</p>
	 *
	 * @param Void
	 * @return a Boolean, true if visible, false otherwise
	 */	
	public function isVisible( Void ): Boolean
	{
		return _bV = (  _bfc * ((_vb.sx - _va.sx)*(_vc.sy - _va.sy)-(_vb.sy - _va.sy)*(_vc.sx - _va.sx)) > 0 );
	}
	
	/** 
	 * Render the face into a MovieClip.
	 *
	 * @param	{@code mc}	A {@code MovieClip}.
	 */
	public function render( mc:MovieClip ):Void
	{
		_mc = mc;
		if( _bEv) __prepareEvents( mc );
		// -- we launch the rendering with the appropriate skin
		( _bV ) ? _s.begin( this, mc ) : _sb.begin( this, mc );
		mc.moveTo( _va.sx, _va.sy );
		mc.lineTo( _vb.sx, _vb.sy);
		mc.lineTo( _vc.sx, _vc.sy );
		mc.lineTo( _va.sx, _va.sy );
		// -- we launch the rendering with the appropriate skin
		( _bV ) ? _s.end( this, mc ) : _sb.end( this, mc );
	}

	/** 
	 * Refresh the face display
	 */
	public function refresh( Void ):Void
	{
		_mc.clear();
		( _bV ) ? _s.begin( this, _mc ) : _sb.begin( this, _mc );
		_mc.moveTo( _va.sx, _va.sy );
		_mc.lineTo( _vb.sx, _vb.sy);
		_mc.lineTo( _vc.sx, _vc.sy );
		_mc.lineTo( _va.sx, _va.sy );
		( _bV ) ? _s.end( this, _mc ) : _sb.end( this, _mc );
	}
	
	/**
	 * Return the depth average of the face.
	 * <p>Useful for z-sorting.</p>
	 *
	 * @return	A Number as depth average.
	 */
	public function getZAverage( Void ):Number
	{
		// -- We normalize the sum and return it
		return ( ( _va.wz+_vb.wz+_vc.wz ) / 3 );
	}
	
	/**
	 * Returns the min depth of its vertex.
	 * @param Void	
	 * @return number the minimum depth of it's vertex
	 */
	public function getMinDepth ( Void ):Number
	{
		return Math.min( _va.wz, Math.min( _vb.wz, _vc.wz ) ) ;
	}

	/**
	 * Returns the max depth of its vertex.
	 * @param Void	
	 * @return number the maximum depth of it's vertex
	 */
	public function getMaxDepth ( Void ):Number
	{
		return Math.max( _va.wz, Math.max( _vb.wz, _vc.wz ) ) ;
	}
	
	/**
	* Get a String represntation of the {@code TriFace3D}.
	* 
	* @return	A String representing the {@code TriFace3D}.
	*/
	public function toString( Void ):String
	{
		return new String("sandy.core.face.TriFace3D");
	}
	
	/**
	* This method change the value of the "normal" clipping side.
	* @param	Void
	*/
	public function swapCulling( Void ):Void
	{
		_bfc *= -1;
	}
	
	//////////////
	/// PRIVATE
	//////////////
	private function __prepareEvents( mc:MovieClip ):Void
	{
		mc.onPress = Delegate.create( this, __onPressed );
		mc.onRollOver = Delegate.create( this, __onRollOver );
		mc.onRollOut = Delegate.create( this, __onRollOut );
	}

	private function __onPressed( e:BasicEvent ):Void
	{
		broadcastEvent( new ObjectEvent( ObjectEvent.onPressEVENT, this ) );
	}
	private function __onRollOver( e:BasicEvent ):Void
	{
		broadcastEvent( new ObjectEvent( ObjectEvent.onRollOverEVENT, this ) );
	}	
	private function __onRollOut( e:BasicEvent ):Void
	{
		broadcastEvent( new ObjectEvent( ObjectEvent.onRollOutEVENT, this ) );
	}	
	
	private var _o:Object3D; // reference to is owner object
	/**
	 * Vertex representing the first point of the face
	 */
	private var _va:Vertex;
	/**
	 * Vertex representing the second point of the face
	 */
	private var _vb:Vertex;
	/**
	 * Vertex corresponding to the third point of the face
	 */
	private var _vc:Vertex;
	/**
	 * Vertex representing the normal of the face!
	 */
	private var _vn:Vector; // Vertex containing the normal of the 
	/*
	 * Skin of the face
	 */ 
	private var _s:Skin;
	/*
	 * Skin of the back the face
	 */ 
	private var _sb:Skin;	
	/**
	* Boolean that privide a fast information about the visibility of the face
	*/
	private var _bV:Boolean;
	/**
	* Boolean representing the state of the event activation
	*/
	private var _bEv:Boolean;
	
	/**
	* Unique face id
	*/
	private var _id:Number;
	
	/**
	* normal backface culling side is 1. -1 means that it is the opposite side which is visible
	*/
	private var _bfc:Number;
	
	private static var _ID_:Number = 0;
	
	/**
	* The latest movieclip used to render the face
	*/
	private var _mc:MovieClip;
}

