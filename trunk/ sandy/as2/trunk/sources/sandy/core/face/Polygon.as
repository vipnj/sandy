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

import flash.geom.Matrix;

import sandy.core.data.UVCoord;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.face.IPolygon;
import sandy.core.Object3D;
import sandy.core.World3D;
import sandy.math.VectorMath;
import sandy.skin.Skin;
import sandy.skin.TextureSkin;
import sandy.view.Frustum;
import com.bourre.events.BasicEvent;

/**
* Polygon
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		12.01.2006 
**/
class sandy.core.face.Polygon implements IPolygon
{
	public function Polygon(  oref:Object3D /* ... */)
	{
		_o = oref;
		_bfc = 1;
		_id = Polygon._ID_ ++;
		_aClipped = _aVertex = arguments.slice(1);
		_nCL = _nL = _aVertex.length;
		_aUV = new Array(3);
		updateTextureMatrix();
		_mc = World3D.getInstance().getContainer().createEmptyMovieClip("polygon_"+_ID_, _ID_);
		World3D.getInstance().addEventListener( World3D.onContainerCreatedEVENT, this, __onWorldContainer );
	}
	
	/**
	 * FIXME, the matrix i available only for front skin, the same thing shall be applied for back skins!
	 **/
	public function updateTextureMatrix(Void):Void
	{
		if( _nL > 2 && (_s instanceof TextureSkin) )
		{
			var w:Number, h:Number;
			w = TextureSkin(_s).texture.width;
			h = TextureSkin(_s).texture.height;
			if( w > 0 && h > 0 )
			{		
				var u0: Number = _aUV[0].u;
				var v0: Number = _aUV[0].v;
				var u1: Number = _aUV[1].u;
				var v1: Number = _aUV[1].v;
				var u2: Number = _aUV[2].u;
				var v2: Number = _aUV[2].v;
				// -- Test PAPERVISION hack ! Fix perpendicular projections. Not sure it is really useful here since there's no texture prjection. This will certainly solve the freeze problem tho
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
		updateTextureMatrix();
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

	/** 
	 * Render the face into a MovieClip.
	 *
	 * @param	{@code mc}	A {@code MovieClip}.
	 */
	public function render( Void ): Void
	{
		_mc.clear();
		var l:Number = _nL;
		//--
		if( _bV )  _s.begin( this, _mc ) ;
		else _sb.begin( this, _mc );
		//--
		_mc.moveTo( _aVertex[0].sx, _aVertex[0].sy );
		while( --l > 0 )
		{
			_mc.lineTo( _aVertex[l].sx, _aVertex[l].sy);
		}
		// -- we launch the rendering with the appropriate skin
		if( _bV ) _s.end( this, _mc );
		else _sb.end( this, _mc );
	}
	
	/** 
	 * Refresh the face display
	 */
	public function refresh( Void ):Void
	{
		_mc.clear();
		if( _bV )  _s.begin( this, _mc );
		else  _sb.begin( this, _mc );
		//
		_mc.moveTo( _aVertex[0].sx, _aVertex[0].sy );
		var l:Number = _nL;
		while( --l > 0 )
			_mc.lineTo( _aVertex[l].sx, _aVertex[l].sy);
		// -- we launch the rendering with the appropriate skin
		if( _bV ) _s.end( this, _mc );
		else _sb.end( this, _mc );
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
		updateTextureMatrix();
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
		var l:Number = _nL;
		while( --l > -1 )
			d += _aVertex[l].nz;
		return d / _nL;
	}
	
	/**
	 * Returns the min depth of its vertex.
	 * @param Void	
	 * @return number the minimum depth of it's vertex
	 */
	public function getMinDepth ( Void ):Number
	{
		var min:Number = _aVertex[0].nz;
		var l:Number = _nL;
		while( --l > 0 )
			min = Math.min( min, _aVertex[l].nz );
		return min;
	}

	/**
	 * Returns the max depth of its vertex.
	 * @param Void	
	 * @return number the maximum depth of it's vertex
	 */
	public function getMaxDepth ( Void ):Number
	{
		var max:Number = _aVertex[0].nz;
		var l:Number = _nL;
		while( --l > 0 )
			max = Math.max( max, _aVertex[l].nz );
		return max;
	}
	
	/**
	* Get a String represntation of the {@code NFace3D}.
	* 
	* @return	A String representing the {@code NFace3D}.
	*/
	public function toString( Void ): String
	{
		return new String("sandy.core.face.Polygon");
	}

	public function clip( frustum:Frustum ):Boolean
	{
		_aClipped = frustum.clipFrustum( _aVertex );
		if( (_nCL = _aClipped.length) != _nL ) return true;
		else return false;
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
	 * isvisible 
	 * <p>Say if the face is visible or not</p>
	 *
	 * @param Void
	 * @return a Boolean, true if visible, false otherwise
	 */	
	public function isVisible( Void ): Boolean
	{
		if( _nL < 3 ) return _bV = true;
		else return _bV = ( _bfc * ((_aVertex[1].sx - _aVertex[0].sx)*(_aVertex[2].sy - _aVertex[0].sy)-(_aVertex[1].sy - _aVertex[0].sy)*(_aVertex[2].sx - _aVertex[0].sx)) < 0 );
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
			v = new Vector( b.x - a.x, b.y - a.y, b.z - a.z );
			w = new Vector( b.x - c.x, b.y - c.y, b.z - c.z );
			// -- we compute de cross product
			_vn = VectorMath.cross( v, w );//new Vector( (w.y * v.z) - (w.z * v.y) , (w.z * v.x) - (w.x * v.z) , (w.x * v.y) - (w.y * v.x) );
			// -- we normalize the resulting vector
			VectorMath.normalize( _vn ) ;
			// -- we return the resulting vertex
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
	 * @param	Vertex
	 */
	public function setNormale( n:Vector ):Void
	{
		_vn = n;
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
	 * Get the skin of the face
	 *
	 * @return	The Skin
	 */
	public function getSkin( Void ):Skin
	{
		return _s;
	}

	/**
	* Get the clip where is drawn the face content
	* @param	Void
	* @return the MovieClip
	*/
	public function getClip( Void ):MovieClip
	{
		return _mc;
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
	 * Destroy the movieclip attache to this polygon
	 */
	public function destroy( Void ):Void
	{
		_mc.removeMovieClip();
	}

	/**
	 * Returns the precomputed matrix for the texture algorithm.
	 */
	public function getTextureMatrix( Void ):Matrix
	{
		return _m;
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
	
	private var _aUV:Array;
	private var _aVertex:Array;
	private var _aClipped:Array;
	private var _nL:Number;
	private var _nCL:Number;
	private var _o:Object3D; // reference to is owner object
	/**
	 * Vertex representing the normal of the face!
	 */
	private var _vn:Vector; // Vertex containing the normal of the 
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
	private var _mc:MovieClip;
	private var _m:Matrix;

}

