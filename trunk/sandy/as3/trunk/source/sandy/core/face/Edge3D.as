package sandy.core.face
{
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
	import flash.display.Sprite;
	
	/**
	* Edge3D
	* This class allow you to draw a 3D line.
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		24.06.2006 
	**/
	
	public class Edge3D extends TriFace3D
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
		public override function getVertex( ):Array
		{
			return [ _va, _vb ];
		}
		
		/**
		* You can't enable an event on a edge face.
		* @param b Boolean True to enable the events, false otherwise.
		*/
		public override function enableEvents( b:Boolean ):void
		{
			; /* No implementation here */
		}
		
		/**
		 * Set up the skin of the edge.
		 * For a Edge3D object the only skin available is SimpleLineSkin!
		 * @param	s SimpleLineSkin The Skin to set.
		 */
		//public function setSkin( s:SimpleLineSkin ):void
		public override function setSkin( s:Skin ):void
		{
			if( s is SimpleLineSkin )
			{
				_s = s;
			}
		}
		
		/**
		 * Get the skin of the edge
		 * @return	The Skin SimpleLineSkin
		 */
		public override function getSkin( ):Skin
		{
			return SimpleLineSkin( _s );
		}
		/**
		 * No back skin can be set because an edge is always visible.
		 * @param	s	
		 */
		public override function setBackSkin( s:Skin ):void
		{
			; /* No implementation */
		}
		
		/**
		 * Returns a null value because no skin can be set to an Edge3D.
		 * @return	null
		 */
		public override function getBackSkin( ):Skin
		{
			return null;
		}
		
		/**
		 * Do nothing for a edge.
		 * @param	a	{code UVCoord}
		 * @param	b	{code UVCoord}
		 * @param	c	{code UVCoord}
		 */	
		public override function setUVCoordinates( a:UVCoord, b:UVCoord, c:UVCoord ):void
		{
			;/* Nothing to do */
		}
		
		/**
		 * You can't create a normal vector of en 3D edge since it hsa only 2 vertex in a 3D space.
		 * @return	null
		 */	
		public override function createNormale( ):Vector
		{
			return null;
		}
	
		/**
		 * Set the normal vector of the edge.
		 *
		 * @param	Vertex
		 */
		/*public override function setNormale( n:Vector ):void
		{
			_vn = n;
		}*/
		
		/**
		 * isvisible 
		 * <p>Say if the face is visible or not.
		 * Returns always true in Edge3D case</p>
		 *
		 * @param void
		 * @return a Boolean true
		 */	
		public override function isVisible( ): Boolean
		{
			return true;
		}
		
		/** 
		 * Render the face into a Sprite.
		 * @param	{@code mc}	A {@code Sprite}.
		 */
		public override function render( mc:Sprite ): void
		{
			_mc = mc;
			//
			_s.begin( this, mc );
			//
			mc.graphics.moveTo( _va.sx, _va.sy );
			mc.graphics.lineTo( _vb.sx, _vb.sy );
			// -- we launch the rendering with the appropriate skin
			_s.end( this, mc );
		}
		
		/** 
		 * Refresh the face display
		 */
		public override function refresh( ):void
		{
			_mc.graphics.clear();
			//
			_s.begin( this, _mc );
			//
			_mc.graphics.moveTo( _va.sx, _va.sy );
			_mc.graphics.lineTo( _vb.sx, _vb.sy );
			// -- we launch the rendering with the appropriate skin
			_s.end( this, _mc );
		}
		
		/**
		* Get a String represntation of the {@code TriFace3D}.
		* 
		* @return	A String representing the {@code TriFace3D}.
		*/
		public override function toString( ):String
		{
			return new String("sandy.core.face.Edge3D");
		}
	
	}
	

}