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

import sandy.core.face.NFace3D;
import sandy.core.Object3D;
import sandy.core.data.UVCoord;
import sandy.skin.Skin;
import sandy.skin.SkinType;

/**
* NCurvedFace3D
* <p>Allows to create a curved face with N points. Very usefull to create complex shapes/objects.</p>
* 
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		12.05.2006 
**/

class sandy.core.face.NCurvedFace3D extends NFace3D
{
	public function NCurvedFace3D(  oref:Object3D, a:Array)
	{
		super( oref, a );
	}
	
	/**
	* Allows you to get the vertex of the face. Very usefull when you want to make some calculation on a face after it has been clicked.
	* @param	Void
	* @return Array The array of vertex.
	*/
	public function getVertex( Void ):Array
	{
		return _aVertex;
	}
	
	/** 
	 * Render the face into a MovieClip.
	 *
	 * @param	{@code mc}	A {@code MovieClip}.
	 * @param	id			A Number which is the camera identifiant
	 */
	public function render( mc:MovieClip ): Void
	{
		_mc = mc;
		var i:Number = 0;
		// --
		( _bV ) ? _s.begin( this, mc ) : _sb.begin( this, mc );
		// --
		mc.moveTo( _va.sx, _va.sy );
		for( i = 0; i < _nL; i += 2 )
		{
			mc.curveTo( _aVertex[i].sx, _aVertex[i].sy, _aVertex[i+1].sx, _aVertex[i+1].sy);
		}
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
		//
		_mc.moveTo( _va.sx, _va.sy );
		var i:Number = 0;
		for( i = 0; i < _nL; i += 2 )
		{
			_mc.curveTo( _aVertex[i].sx, _aVertex[i].sy, _aVertex[i+1].sx, _aVertex[i+1].sy);
		}
		// -- we launch the rendering with the appropriate skin
		( _bV ) ? _s.end( this, _mc ) : _sb.end( this, _mc );
	}
	
	/**
	* Get a String represntation of the {@code NFace3D}.
	* 
	* @return	A String representing the {@code NFace3D}.
	*/
	public function toString( Void ): String
	{
		return new String("sandy.core.face.NCurvedFace3D");
	}

}

