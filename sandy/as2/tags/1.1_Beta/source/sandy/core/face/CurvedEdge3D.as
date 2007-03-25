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
import sandy.skin.SimpleLineSkin;
import sandy.events.ObjectEvent;
import sandy.core.data.Vector;
import sandy.math.VectorMath;
import sandy.core.face.Edge3D;

/**
* Edge3D
* This class allow you to draw a 3D line.
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		24.06.2006 
**/
class sandy.core.face.CurvedEdge3D extends Edge3D
{
	
	/**
	* Create a new {@code Edge3D}.
	* 
	* @param oref A reference to its Object3D;
	* @param a first Vertex
	* @param b control point vertex
	* @param c end Vertex
	*/
	public function CurvedEdge3D( oref:Object3D, a:Vertex, b:Vertex, c:Vertex )
	{
		super( oref, a, b );
		_vc = c;
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
	 * Render the face into a MovieClip.
	 * @param	{@code mc}	A {@code MovieClip}.
	 */
	public function render( mc:MovieClip ): Void
	{
		// --
		_s.begin( this, mc );
		// --
		mc.moveTo( _va.sx, _va.sy );
		mc.curveTo( _vb.sx, _vb.sy, _vc.sx, _vc.sy);
		// -- we launch the rendering with the appropriate skin
		_s.end( this, mc );
	}
	
	/** 
	 * Refresh the face 
	 */
	public function refresh( Void ): Void
	{
		//
		_s.begin( this, _mc );
		//
		_mc.moveTo( _va.sx, _va.sy );
		_mc.curveTo( _vb.sx, _vb.sy, _vc.sx, _vc.sy);
		// -- we launch the rendering with the appropriate skin
		_s.end( this, _mc );
	}
	/**
	* Get a String represntation of the {@code TriFace3D}.
	* 
	* @return	A String representing the {@code TriFace3D}.
	*/
	public function toString( Void ):String
	{
		return new String("sandy.core.face.CurvedEdge3D");
	}

}

