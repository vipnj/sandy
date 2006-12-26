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

import sandy.core.face.QuadFace3D;
import sandy.core.data.Vertex;
import sandy.core.Object3D;
import sandy.core.data.UVCoord;
import sandy.skin.Skin;
import sandy.skin.SkinType;

/**
* QuadCurvedFace3D
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		12.01.2006 
**/

class sandy.core.face.QuadCurvedFace3D extends QuadFace3D
{
	
	public function QuadCurvedFace3D(  oref:Object3D, pt1:Vertex, pt2:Vertex, pt3:Vertex, pt4:Vertex )
	{
		super( oref, pt1, pt2, pt3, pt4 );
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
	 * Render the face into a MovieClip.
	 *
	 * @param	{@code mc}	A {@code MovieClip}.
	 */
	public function render( mc:MovieClip ): Void
	{
		_mc = mc;
		( _bV ) ? _s.begin( this, mc ) : _sb.begin( this, mc );
		mc.moveTo( _va.sx, _va.sy );
		mc.curveTo( _vb.sx, _vb.sy);
		mc.curveTo( _vc.sx, _vc.sy );
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
		_mc.curveTo( _vb.sx, _vb.sy);
		_mc.curveTo( _vc.sx, _vc.sy );
		_mc.lineTo( _vd.sx, _vd.sy );
		_mc.lineTo( _va.sx, _va.sy );
		// -- we launch the rendering with the appropriate skin
		( _bV ) ? _s.end( this, _mc ) : _sb.end( this, _mc );
	}
	
	/**
	* Get a String represntation of the {@code QuadFace3D}.
	* 
	* @return	A String representing the {@code QuadFace3D}.
	*/
	public function toString( Void ): String
	{
		return new String("sandy.core.face.QuadCurvedFace3D");
	}

}

