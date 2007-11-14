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

import flash.geom.Matrix;

import sandy.core.data.UVCoord;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.face.IPolygon;
import sandy.core.Object3D;
import sandy.math.VectorMath;
import sandy.skin.MovieSkin;
import sandy.skin.Skin;
import sandy.skin.SkinType;
import sandy.skin.TextureSkin;
import sandy.skin.VideoSkin;
import sandy.view.Frustum;
import sandy.events.ObjectEvent;

/**
* Polygon
* @author		Thomas Pfeiffer - kiroukou
* @author		Bruce Epstein - zeusprod
* @since		1.0
* @version		1.2.2
* @date 		07.08.2007 
**/
class sandy.core.face.Polygon extends EventBroadcaster implements IPolygon
{
	public var depth:Number;
	public var clipped:Boolean;
	
	public function Polygon( oref:Object3D /* ... */ )
	{
		super( this );
		_o = oref;
		_bfc = 1;
		_id = Polygon._ID_ ++;
		_s = _sb = undefined;
		_aVertex = arguments.slice(1); 
		_aClipped = _aVertex.slice();
		_nCL = _nL = _aVertex.length;
		_aUV = new Array(3);
		depth = 0;
		clipped = false;
	}
	
	/**
	 * FIXME, the matrix is available only for front skin, the same thing shall be applied for back skins!
	 **/
	public function updateTextureMatrix( s:Skin ):Void
	{
		if( _nL > 2 )
		{
			var w:Number = 0, h:Number = 0;

			if (s.getType() == SkinType.TEXTURE)
			{
				w = TextureSkin(s).texture.width;
				h = TextureSkin(s).texture.height;
			}
			else if (s.getType() == SkinType.MOVIE)
			{
				w = MovieSkin(s).getMovie()._width;
				h = MovieSkin(s).getMovie()._height;
			}
			else if (s.getType() == SkinType.VIDEO)
			{
				w = VideoSkin(s).texture.width;
				h = VideoSkin(s).texture.height;
			}
			//
			if( w > 0 && h > 0 )
			{		
				var u0: Number = _aUV[0].u;
				var v0: Number = _aUV[0].v;
				var u1: Number = _aUV[1].u;
				var v1: Number = _aUV[1].v;
				var u2: Number = _aUV[2].u;
				var v2: Number = _aUV[2].v;
				// -- Fix perpendicular projections. Not sure it is really useful here since there's no texture prjection. This will certainly solve the freeze problem tho
				if( (u0 == u1 && v0 == v1) || (u0 == u2 && v0 == v2) )
				{
					u0 -= (u0 > 0.05)? 0.05 : -0.05;
					v0 -= (v0 > 0.07)? 0.07 : -0.07;
				}	
				if( u2 == u1 && v2 == v1 )
				{
					u2 -= (u2 > 0.05)? 0.04 : -0.04;
					v2 -= (v2 > 0.06)? 0.06 : -0.06;
				}
				_m = new Matrix( (u1 - u0), h*(v1 - v0)/w, w*(u2 - u0)/h, (v2 - v0), u0*w, v0*h );
				_m.invert();
			}
		}
	}

	public function getUVCoords( Void ):Array
	{
		return _aUV;
	}
	
	public function setUVCoords( pUv1:UVCoord, pUv2:UVCoord, pUv3:UVCoord ):Void
	{
		_aUV[0] = pUv1;
		_aUV[1] = pUv2;
		_aUV[2] = pUv3;
		updateTextureMatrix(_s);
	}
		
	/**
	* Allows you to get the vertex of the face. Very usefull when you want to make some calculation on a face after it has been clicked.
	* @param	Void
	* @return Array The array of vertex.
	*/
	public function getVertices( Void ):Array
	{
		return _aVertex;
	}
	
	public function getClippedVertices(   Void ):Array
	{
		return _aClipped;
	}
	
	public function getPosition( Void ):Vector
	{
		var v:Vertex = _aVertex[0]; // FIX - should this be an average of multiple vertices?
		return new Vector( v.wx - v.x, v.wy - v.y, v.wz - v.z );
	}
	
	/** 
	 * Render the polygon into a MovieClip.
	 *
	 * @param	{@code mc}	A {@code MovieClip}.
	 */
	public function render( mc:MovieClip, pS:Skin, pSb:Skin, faceNum:Number ): Void
	{
		var s:Skin;
		var l:Number = (clipped == true) ? _nCL : _nL;
		var a:Array = (clipped == true) ? _aClipped : _aVertex;
		
		//trace ("Rendering faceNum  " + faceNum + " for mc " + mc._name);
		if( _bEv) __prepareEvents( mc );
		//
		if( _bfc == 1 ) s = (_s == null) ? pS : _s;
		else	        s = (_sb == null) ? pSb : _sb;
		//
		s.begin( this, mc) ;
		//
		mc.moveTo( a[0].sx, a[0].sy );
		while( --l > -1 )
		{
			mc.lineTo( a[l].sx, a[l].sy);
		}
		// -- we launch the rendering with the appropriate skin
		s.end( this, mc );
	}
	
	/** 
	 * Refresh the face display
	 */
	public function refresh( mc:MovieClip, pS:Skin, pSb:Skin ):Void
	{
		var s:Skin;
		var l:Number = (clipped == true) ? _nCL : _nL;
		var a:Array = (clipped == true) ? _aClipped : _aVertex;
		//
		if( _bfc == 1 ) s = (_s == undefined) ? pS : _s;
		else	        s = (_sb == undefined) ? pSb : _sb;
		//
		s.begin( this, mc) ;
		//
		mc.lineTo( a[0].sx, a[0].sy );
		while( --l > -1 )
			mc.lineTo( a[l].sx, a[l].sy);
		// -- we launch the rendering with the appropriate skin
		s.end( this, mc );
	}

	/**
	 * NFace3D allows all the skins available in Sandy, but you must be warned that if you use a TextureSkin 
	 * (or a derivate one) the distortion will not be correct! 
	 * The only solution to be able to map an object with a bitmap correctly is to use TriFace3D.
	 * @param s	Skin object. The skin to apply to the face.
	 */
	public function setSkin( s:Skin ):Void
	{
		_s = s;
		updateTextureMatrix(s);
	}
	
	/**
	 * Return the depth average of the face.
	 * <p>Useful for z-sorting.</p>
	 *
	 * @return	A Number as depth average.
	 */
	public function getZAverage( Void ) : Number
	{
		// -- We normalize the sum and return it
		var d:Number = 0;
		var l:Number = _nCL;
		while( --l > -1 ) {
			if (d * _aClipped[l].wz < 0) {
				return 0; // Sign flipped (item is behind camera, so omit the polygon by returning 0 depth.
			}
			d += _aClipped[l].wz;
		}
			
		 
		depth = d / _nCL;
		
		//trace ("zAverage depth is " + depth);
		return depth;
	}
	
	/**
	 * Returns the min depth of its vertex.
	 * @param Void	
	 * @return number the minimum depth of its vertex
	 */
	public function getMinDepth ( Void ):Number
	{
		var l:Number = _nCL;
		var min:Number = _aClipped[0].wz;
		while( --l > 0 )
			min = Math.min( min, _aClipped[l].wz );
		return min;
	}

	/**
	 * Returns the max depth of its vertex.
	 * @param Void	
	 * @return number the maximum depth of it's vertex
	 */
	public function getMaxDepth ( Void ):Number
	{
		var l:Number = _nCL;
		var max:Number = _aClipped[0].wz;
		while( --l > 0 )
			max = Math.max( max, _aClipped[l].wz );
		return max;
	}
	
	/**
	* Get a String representation of the {@code NFace3D}.
	* 
	* @return	A String representing the {@code NFace3D}.
	*/
	public function toString( Void ): String
	{
		return new String("sandy.core.face.Polygon");
	}

	
	/**
	* Returns the array of vertices after applying clipping.
	* When the camera cuts across a triangular polygon, it does so at 2 points,
	* resulting in a quadrilateral that represents the truncated triangle. (Sketch a picture to make this clear to yourself).
	* So, if the camera intersects the poly, the Frustum.clipFrustum() method adds a vertex to the vertex list.
	* @param	frustum
	* @return	Array of vertices.
	*/
	public function clip( frustum:Frustum ):Array
	{
		delete _aClipped;
		_aClipped = _aVertex.concat();
		_aClipped = frustum.clipFrustum( _aClipped );
		_nCL = _aClipped.length;
		clipped = true;
		return _aVertex.concat(_aClipped);
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
	
	public function getName(Void):String
	{
		return ("polygon_" + _id);
	}
	
	
	/**
	* Enable or not the events onPress, onRollOver and onRollOut with this face.
	* @param b Boolean True to enable the events, false otherwise.
	*/
	public function enableEvents( b:Boolean ):Void
	{		
		_bEv = b;
		
		// If events are enabled on this poly, then tell the parent Object3D (owner) to enable separate events.
		// If _bEv is false, we can't undo this, as there may be other polys for who are setting it to true.
		// So it is the programmer's responsibility to invoke _o.setSeparatePolys(false) manually, if desired.
		if (_bEv) {
			//trace ("Enabling separate poly events for object " + _o.name);
			_o.setSeparatePolys (true);
		}
	}

	
	/**
	 * isvisible 
	 * <p>Say if the face is visible or not</p>
	 *
	 * @param Void
	 * @return a Boolean, true if visible, false otherwise
	 */	
	public function isVisible( faceNum:Number ): Boolean
	{
		/*
		var temp1:Number;
		var temp2:Number;
		var temp3:Number;
		var temp4:Number;
		var temp5:Number;
		var temp6:Number;
		var temp7:Number;
		*/
		if( _nL < 3 ) {
			_bV = true;
		} else {
			// What is the basis for this formula? How does it indicate whether the polygon is facing the camera?
			// bfc indicates "swapInside"
			_bV = ( _bfc * ((_aVertex[1].sx - _aVertex[0].sx)*(_aVertex[2].sy - _aVertex[0].sy)-(_aVertex[1].sy - _aVertex[0].sy)*(_aVertex[2].sx - _aVertex[0].sx)) < 0 );
			/*
			temp1 = (_aVertex[1].sx - _aVertex[0].sx);
			temp2 = (_aVertex[2].sy - _aVertex[0].sy);
			temp3 = (_aVertex[1].sy - _aVertex[0].sy);
			temp4 = (_aVertex[2].sx - _aVertex[0].sx);
			temp5 = temp1*temp2;
			temp6 = temp3*temp4;
			temp7 = temp1*temp2-temp3*temp4;
			_bV = ( _bfc * (temp1*temp2-temp3*temp4) < 0 );
			*/
			
		}
			
		return _bV;
	}

	/**
	 * Create the normal vector of the face.
	 *
	 * @return	The resulting {@code Vertex} corresponding to the normal.
	 */	
	public function createNormale( Void ):Vector
	{
		if( _nL > 2 )
		{
			var v:Vector, w:Vector;
			var a:Vertex = _aVertex[0], b:Vertex = _aVertex[1], c:Vertex = _aVertex[2];
			v = new Vector( b.wx - a.wx, b.wy - a.wy, b.wz - a.wz );
			w = new Vector( b.wx - c.wx, b.wy - c.wy, b.wz - c.wz );
			// -- we compute de cross product
			_vn = VectorMath.cross( v, w );//new Vector( (w.y * v.z) - (w.z * v.y) , (w.z * v.x) - (w.x * v.z) , (w.x * v.y) - (w.y * v.x) );
			// -- we normalize the resulting vector
			VectorMath.normalize( _vn ) ;
			// -- we return the resulting vector
			//trace ("Creating normal " + _vn);
			return _vn;
		}
		else
		{
			return _vn = null;
		}
	}

	/**
	 * Set the normal vector of the face.
	 *
	 * @param	Vector
	 */
	public function setNormale( n:Vector ):Void
	{
		_vn = n;
	}
	public function setNormal( n:Vector ):Void
	{
		setNormale(n);
	}
	
	public function getNormale( Void):Vector
	{
		return _vn;
	}
	public function getNormal( Void):Vector
	{
		return getNormale();
	}
	
	
	
	/**
	 * Set up the back skin of the face.
	 * It corresponds to the skin that is applied to the back of the face, so to the faces that is normally hidden to 
	 * the user but that is visible if you've set {@code Object.enableBackFaceCulling()} to false.
	 * @param	s	The Skin to set.
	 */
	public function setBackSkin( s:Skin ):Void
	{
		_sb = s;
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
	 * Returns the the skin of the back of this face.
	 * @see Face.setBackSkin
	 * @return	The Skin
	 */
	public function getBackSkin( Void ):Skin
	{
		return _sb;
	}

	/**
	* This method change the value of the "normal" clipping side.
	* Also swap the font and back skins
	* @param	Void
	*/
	public function swapCulling( Void ):Void
	{
		var tmp:Skin;
		// -- swap backface culling 
		_bfc *= -1;
		// -- swap the skins too
		tmp = _sb;
		_sb = _s;
		_s = tmp;
	}

	/**
	 * Destroy the movieclip attached to this polygon
	 */
	public function destroy( Void ):Void
	{
		delete _aClipped;
		delete _aVertex;
	}

	/**
	 * Returns the precomputed matrix for the texture algorithm.
	 */
	public function getTextureMatrix( Void ):Matrix
	{
		return _m;
	}

	//////////////
	/// PRIVATE
	//////////////
	private function __prepareEvents( mc:MovieClip ):Void
	{
		//if (!_inited) { // Can't use this, as the clips are recreated and deleted repeatedly
			//_inited = true
		
			mc.onPress = Delegate.create( this, __onPressed );
			mc.onRollOver = Delegate.create( this, __onRollOver );
			mc.onRollOut = Delegate.create( this, __onRollOut );
		//}
	}

	private function __onPressed( e:BasicEvent ):Void
	{
		//trace ("Broadcasting ObjectEvent.onPressEVENT");
		broadcastEvent( new ObjectEvent( ObjectEvent.onPressEVENT, this ) );
	}
	private function __onRollOver( e:BasicEvent ):Void
	{
		//trace ("Broadcasting ObjectEvent.onRollOverEVENT");
		broadcastEvent( new ObjectEvent( ObjectEvent.onRollOverEVENT, this ) );
	}	
	private function __onRollOut( e:BasicEvent ):Void
	{
		//trace ("Broadcasting ObjectEvent.onRollOutEVENT");
		broadcastEvent( new ObjectEvent( ObjectEvent.onRollOutEVENT, this ) );
	}	
	
	private var _inited:Boolean = false;
	private var _aUV:Array;
	private var _aVertex:Array;
	private var _aClipped:Array;
	private var _nL:Number;
	private var _nCL:Number;
	private var _o:Object3D; // reference to is owner object
	/**
	 * Vector representing the normal of the face!
	 */
	private var _vn:Vector; // Vector containing the normal of the 
	/**
	 * Skin of the face
	 */ 
	private var _s:Skin;
	/**
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
	private var _m:Matrix;
}

