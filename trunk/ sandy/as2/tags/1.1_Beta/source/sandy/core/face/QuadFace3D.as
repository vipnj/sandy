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

import sandy.core.face.TriFace3D;
import sandy.core.data.Vertex;
import sandy.core.Object3D;
import sandy.skin.Skin;
import sandy.skin.SkinType;

/**
* QuadFace3D
* @author		Thomas Pfeiffer - kiroukou
* @since		0.2
* @version		0.2
* @date 		12.01.2006 
**/

class sandy.core.face.QuadFace3D extends TriFace3D
{
	
	public function QuadFace3D(  oref:Object3D, pt1:Vertex, pt2:Vertex, pt3:Vertex, pt4:Vertex )
	{
		super( oref, pt1, pt2, pt3 );
		_vd = pt4;
	}
	
	/**
	* Allows you to get the vertex of the face. Very usefull when you want to make some calculation on a face after it has been clicked.
	* @param	Void
	* @return Array The array of vertex.
	*/
	public function getVertex( Void ):Array
	{
		return [ _va, _vb, _vc, _vd ];
	}
	
	/**
	 * QuadFace3D allows all the skins available in Sandy, but you must be warned that if you use a TextureSkin 
	 * (or a derivate one) the distortion will not be correct! 
	 * The only solution to be able to map an object with a bitmap correctly is to use TriFace3D.
	 * @param s	Skin object. The skin to apply to the face.
	 */
	public function setSkin( s:Skin ):Void
	{
		if( s.getType() == SkinType.TEXTURE )
		{
			trace('WARNING: Sandy::QuadFace3D The perspective bitmap distortion may not be correct');
		}
		super.setSkin( s );
	}
	
	/** 
	 * Render the face into a MovieClip.
	 *
	 * @param	{@code mc}	A {@code MovieClip}.
	 */
	public function render( mc:MovieClip ): Void
	{
		_mc = mc;
		if( _bEv) __prepareEvents( mc );
		//_s.render4( mc, _a, _b, _c, _d, aUv );
		( _bV ) ? _s.begin( this, mc ) : _sb.begin( this, mc );
		mc.moveTo( _va.sx, _va.sy );
		mc.lineTo( _vb.sx, _vb.sy);
		mc.lineTo( _vc.sx, _vc.sy );
		mc.lineTo( _vd.sx, _vd.sy );
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
		_mc.lineTo( _vd.sx, _vd.sy );
		_mc.lineTo( _va.sx, _va.sy );
		// -- we launch the rendering with the appropriate skin
		( _bV ) ? _s.end( this, _mc ) : _sb.end( this, _mc );
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
		return ( ( _va.wz + _vb.wz + _vc.wz + _vd.wz ) / 4 );
	}
	
	/**
	 * Returns the min depth of its vertex.
	 * @param Void	
	 * @return number the minimum depth of it's vertex
	 */
	public function getMinDepth ( Void ):Number
	{
		return Math.min( _vd.wz, super.getMinDepth() ) ;
	}
	
	/**
	 * Returns the max depth of its vertex.
	 * @param Void	
	 * @return number the maximum depth of it's vertex
	 */
	public function getMaxDepth ( Void ):Number
	{
		return Math.max( _vd.wz, super.getMaxDepth() ) ;
	}
	/**
	* Get a String represntation of the {@code QuadFace3D}.
	* 
	* @return	A String representing the {@code QuadFace3D}.
	*/
	public function toString( Void ): String
	{
		return new String("sandy.core.face.QuadFace3D");
	}
	
	/**
	 * Vertex representing the fourth point of the face
	 */
	private var _vd:Vertex;
}

