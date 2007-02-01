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

package sandy.core.face {

	import flash.geom.Matrix;
	import flash.utils.getQualifiedClassName;
	import flash.display.DisplayObject;
	
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
	import sandy.view.Frustum;

	
	
	/**
	* Polygon
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		12.01.2006 
	**/
	public class Polygon implements IPolygon
	{
		public function Polygon( oref:Object3D /* ... */ )
		{
			_o = oref;
			_bfc = 1;
			_id = Polygon._ID_ ++;
			_s = _sb = undefined;
			_aVertex = arguments.slice(1);
			_aClipped = _aVertex.slice();
			_nCL = _nL = _aVertex.length;
			_aUV = new Array(3);
		}
		
		/**
		 * FIXME, the matrix i available only for front skin, the same thing shall be applied for back skins!
		 **/
		public function updateTextureMatrix( s:Skin = null ):void
		{
			if (!s) {
				s = _s;
			}
			
			if (!s) return;
			
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
					w = MovieSkin(s).getMovie().width;
					h = MovieSkin(s).getMovie().height;
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

		public function getUVCoords():Array
		{
			return _aUV;
		}
		
		public function setUVCoords( pUv1:UVCoord, pUv2:UVCoord, pUv3:UVCoord ):void
		{
			_aUV[0] = pUv1;
			_aUV[1] = pUv2;
			_aUV[2] = pUv3;
			updateTextureMatrix();
		}
			
		/**
		* Allows you to get the vertex of the face. Very usefull when you want to make some calculation on a face after it has been clicked.
		* @param	void
		* @return Array The array of vertex.
		*/
		public function getVertices():Array
		{
			return _aVertex;
		}
		
		public function getClippedVertices():Array
		{
			return _aClipped;
		}
		
		/** 
		 * Render the face into a MovieClip.
		 *
		 * @param	{@code mc}	A {@code MovieClip}.
		 */
		public function render( mc:DisplayObject, pS:Skin, pSb:Skin ): void
		{
			var s:Skin;
			var l:int = _nCL;
			
			if( l == 0 ) return;
			
			var a:Array = _aClipped;
			//
			if( _bfc == 1 ) s = (_s == null) ? pS : _s;
			else	        s = (_sb == null) ? pSb : _sb;
			
			//
			s.begin( this, mc) ;
			
			//
			mc.graphics.moveTo( a[0].sx, a[0].sy );
			while( --l > -1 )
			{
				mc.graphics.lineTo( a[int(l)].sx, a[int(l)].sy);
			}
			
			// -- we launch the rendering with the appropriate skin
			s.end( this, mc );
		}
		
		/** 
		 * Refresh the face display
		 */
		public function refresh( mc:DisplayObject, pS:Skin, pSb:Skin ):void
		{
			var s:Skin;
			var l:int = _nCL;
			
			if( l == 0 ) return;
					
			var a:Array = _aClipped;
			
			//
			if( _bfc == 1 ) 
			{
				s = _s || pS;
			} else {
				s = _sb || pSb;
			}
			
			//
			s.begin( this, mc) ;
			
			//
			mc.graphics.lineTo( a[0].sx, a[0].sy );
			
			while( --l > -1 )
			{
				mc.graphics.lineTo( a[int(l)].sx, a[int(l)].sy);
			}
			
			// -- we launch the rendering with the appropriate skin
			s.end( this, mc );
		}

		/**
		 * NFace3D allows all the skins available in Sandy, but you must be warned that if you use a TextureSkin 
		 * (or a derivate one) the distortion will not be correct! 
		 * The only solution to be able to map an object with a bitmap correctly is to use TriFace3D.
		 * @param s	Skin object. The skin to apply to the face.
		 */
		public function setSkin( s:Skin ):void
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
		public function getZAverage() : Number
		{
			// -- We normalize the sum and return it
			var d:Number = 0;
			var l:Number = _nCL;
			while( --l > -1 )
			{
				d += _aClipped[int(l)].wz;
			}
			
			return d / _nCL;
		}
		
		/**
		 * Returns the min depth of its vertex.
		 * @param void	
		 * @return number the minimum depth of it's vertex
		 */
		public function getMinDepth ():Number
		{
			var l:Number = _nCL;
			var min:Number = _aClipped[0].wz;
			
			while( --l > 0 )
			{
				min = Math.min( min, _aClipped[int(l)].wz );
			}
			
			return min;
		}

		/**
		 * Returns the max depth of its vertex.
		 * @param void	
		 * @return number the maximum depth of it's vertex
		 */
		public function getMaxDepth ():Number
		{
			var l:Number = _nCL;
			var max:Number = _aClipped[0].wz;
			
			while( --l > 0 )
			{
				max = Math.max( max, _aClipped[int(l)].wz );
			}
			
			return max;
		}
		
		/**
		* Get a String represntation of the {@code NFace3D}.
		* 
		* @return	A String representing the {@code NFace3D}.
		*/
		public function toString(): String
		{
			return getQualifiedClassName(this) + " [Points: " + _aVertex.length + ", Clipped: " + _aClipped.length + "]";
		}

		public function clip( frustum:Frustum ):Array
		{
			_aClipped = null;
			_aClipped = frustum.clipFrustum( _aVertex );
			_nCL = _aClipped.length;
			return _aClipped;
		}

		/**
		* Enable or not the events onPress, onRollOver and onRollOut with this face.
		* @param b Boolean True to enable the events, false otherwise.
		*/
		public function enableEvents( b:Boolean ):void
		{
			_bEv = b;
		}

		/**
		 * isvisible 
		 * <p>Say if the face is visible or not</p>
		 *
		 * @param void
		 * @return a Boolean, true if visible, false otherwise
		 */	
		public function isVisible(): Boolean
		{
			if( _nL < 3 ) return _bV = true;
			else return _bV = ( _bfc * ((_aVertex[1].sx - _aVertex[0].sx)*(_aVertex[2].sy - _aVertex[0].sy)-(_aVertex[1].sy - _aVertex[0].sy)*(_aVertex[2].sx - _aVertex[0].sx)) < 0 );

		}

		/**
		 * Create the normal vector of the face.
		 *
		 * @return	The resulting {@code Vertex} corresponding to the normal.
		 */	
		public function createNormale():Vector
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
		public function setNormale( n:Vector ):void
		{
			_vn = n;
		}
		
		/**
		 * Set up the back skin of the face.
		 * It corresponds to the skin that is applied to the back of the face, so to the faces that is normally hidden to 
		 * the user but that is visible if you've set {@code Object3D.drawAllFaces} to true.
		 * @param	s	The Skin to set.
		 */
		public function setBackSkin( s:Skin ):void
		{
			_sb = s;
		}

		/**
		 * Get the skin of the face
		 *
		 * @return	The Skin
		 */
		public function getSkin():Skin
		{
			return _s;
		}

		/**
		 * Returns the the skin of the back of this face.
		 * @see Face.setBackSkin
		 * @return	The Skin
		 */
		public function getBackSkin():Skin
		{
			return _sb;
		}

		/**
		* This method change the value of the "normal" clipping side.
		* Also swap the font and back skins
		* @param	void
		*/
		public function swapCulling():void
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
		public function destroy():void
		{
			_aClipped = null;
			_aVertex = null;
		}

		/**
		 * Returns the precomputed matrix for the texture algorithm.
		 */
		public function getTextureMatrix():Matrix
		{
			return _m;
		}

		
		private var _aUV:Array;
		private var _aVertex:Array;
		private var _aClipped:Array;
		private var _nL:int;
		private var _nCL:int;
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
		private var _id:int;
		/**
		* normal backface culling side is 1. -1 means that it is the opposite side which is visible
		*/
		private var _bfc:int;
		private static var _ID_:int = 0;
		/**
		* The latest movieclip used to render the face
		*/

		private var _m:Matrix;

	}
}