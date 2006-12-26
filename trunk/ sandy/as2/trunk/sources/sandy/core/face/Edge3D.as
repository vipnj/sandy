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
import sandy.core.Object3D;
import sandy.skin.Skin;
import sandy.skin.SimpleLineSkin;
import sandy.core.data.Vector;
import sandy.core.face.TriFace3D;

/**
* Edge3D
* This class allow you to draw a 3D line.
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		24.06.2006 
**/

class sandy.core.face.Edge3D extends TriFace3D
{
	
	/**
	* Create a new {@code Edge3D}.
	* 
	* @param oref A reference to its Object3D;
	* @param a the starting vertex
	* @param b the ending vertex
	*/
	public function Edge3D( oref:Object3D, a:Vertex, b:Vertex )
	{
		super( oref, a, b, b );
	}

	/**
	* Allows you to get the vertex of the face. Very usefull when you want to make some calculation on a face after it has been clicked.
	* @param	Void
	* @return Array The array of vertex.
	*/
	public function getVertex( Void ):Array
	{
		return [ _va, _vb ];
	}
	
	/**
	* You can't enable an event on a edge face.
	* @param b Boolean True to enable the events, false otherwise.
	*/
	public function enableEvents( b:Boolean ):Void
	{
		; /* No implementation here */
	}
	
	/**
	 * Set up the skin of the edge.
	 * For a Edge3D object the only skin available is SimpleLineSkin!
	 * @param	s SimpleLineSkin The Skin to set.
	 */
	public function setSkin( s:SimpleLineSkin ):Void
	{
		if( s instanceof SimpleLineSkin )
			_s = s;
	}
	
	/**
	 * Get the skin of the edge
	 * @return	The Skin SimpleLineSkin
	 */
	public function getSkin( Void ):SimpleLineSkin
	{
		return SimpleLineSkin( _s );
	}
	/**
	 * No back skin can be set because an edge is always visible.
	 * @param	s	
	 */
	public function setBackSkin( s:Skin ):Void
	{
		; /* No implementation */
	}
	
	/**
	 * Returns a null value because no skin can be set to an Edge3D.
	 * @return	null
	 */
	public function getBackSkin( Void ):Skin
	{
		return null;
	}
	
	/**
	 * Do nothing for a edge.
	 * @param	a	{code UVCoord}
	 * @param	b	{code UVCoord}
	 * @param	c	{code UVCoord}
	 */	
	public function setUVCoordinates( a:UVCoord, b:UVCoord, c:UVCoord ):Void
	{
		;/* Nothing to do */
	}
	
	/**
	 * You can't create a normal vector of en 3D edge since it hsa only 2 vertex in a 3D space.
	 * @return	null
	 */	
	public function createNormale( Void ):Vector
	{
		return null;
	}

	/**
	 * Set the normal vector of the edge.
	 *
	 * @param	Vertex
	 */
	public function setNormale( n:Vector ):Void
	{
		_vn = n;
	}
	
	/**
	 * isvisible 
	 * <p>Say if the face is visible or not.
	 * Returns always true in Edge3D case</p>
	 *
	 * @param Void
	 * @return a Boolean true
	 */	
	public function isVisible( Void ): Boolean
	{
		return true;
	}
	
	/** 
	 * Render the face into a MovieClip.
	 * @param	{@code mc}	A {@code MovieClip}.
	 */
	public function render( mc:MovieClip ): Void
	{
		_mc = mc;
		//
		_s.begin( this, mc );
		//
		mc.moveTo( _va.sx, _va.sy );
		mc.lineTo( _vb.sx, _vb.sy );
		// -- we launch the rendering with the appropriate skin
		_s.end( this, mc );
	}
	
	/** 
	 * Refresh the face display
	 */
	public function refresh( Void ):Void
	{
		_mc.clear();
		//
		_s.begin( this, _mc );
		//
		_mc.moveTo( _va.sx, _va.sy );
		_mc.lineTo( _vb.sx, _vb.sy );
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
		return new String("sandy.core.face.Edge3D");
	}

}

