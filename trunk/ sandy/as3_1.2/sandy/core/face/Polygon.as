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

package sandy.core.face 
{
	import flash.geom.Matrix;
	import flash.utils.getQualifiedClassName;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventDispatcher;
		
	import sandy.core.World3D;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.face.IPolygon;
	import sandy.core.scenegraph.Object3D;
	import sandy.math.VectorMath;
	import sandy.skin.MovieSkin;
	import sandy.skin.Skin;
	import sandy.skin.SkinType;
	import sandy.skin.TextureSkin;
	import sandy.view.Frustum;
	import sandy.core.scenegraph.Geometry3D;
	
	
	/**
	* Polygon
	* @author		Thomas Pfeiffer - kiroukou
	* @author		Mirek Mencel
	* @version		1.0
	* @date 		12.01.2006 
	**/
	public class Polygon extends EventDispatcher implements IPolygon 
	{
	// _______
	// STATICS_______________________________________________________	
		
		private static var _ID_:int = 0;
		
	// ______
	// PUBLIC________________________________________________________		
		
		public var depth:Number;
		public var container:Sprite;
		public var vertices:Array;
		public var clipped:Array;
		public var isClipped:Boolean;
		
		
	// _______
	// PRIVATE_______________________________________________________			
		
		/** Reference to its owner geometry */
		private var geometry:Geometry3D;
		
		/** Front & Backface Skin */
		private var skin:Skin;
		private var backSkin:Skin;
		
		/** ID of normal vector stored in geometry object */
		private var normalId:int;
		
		/** ID of uv coordinates in geometry object */
		private var uvId:int;
		
		/** Boolean representing the state of the event activation */
		private var mouseEvents:Boolean;
		
		/** Unique face id */
		private var id:int;
		
		/** Normal backface culling side is 1. -1 means that it is the opposite side which is visible */
		private var backfaceCulling:int;
		
		/** Matrix speeding up texturing */
		private var textureMatrix:Matrix;
		
		
		
		public function Polygon(p_geometry:Geometry3D, ...rest)
		{
			id = Polygon._ID_ ++;
			
			// Check if user passed an array 
			// and if true, use it as a list of vertices
			rest = (rest[0] is Array) ? rest[0]: rest;
			geometry = p_geometry;
			backfaceCulling = 1;
			vertices = rest || [];
			clipped = [];
			depth = 0;
			isClipped = false;
			container = new Sprite();
			
			// Add this graphical object to the World display list
			World3D.getInstance().getSceneContainer().addChild( container );
		}
		
		public function getClippedVertices():Array
		{
			return (isClipped) ? clipped : vertices;
		}
		
		public function getVertices():Array
		{
			return vertices;
		}
		
		/** 
		 * Render the face into container with given Skin.
		 * @param	{@code mc}	A {@code MovieClip}.
		 */
		public function render(): void
		{
			
			var l_points:Array = getClippedVertices();
			
			var l_skin:Skin;
			if( backfaceCulling == 1 )	l_skin = skin;
			else						l_skin = backSkin;
			
			// -- start rendering with passed skin
			l_skin.begin( this, container) ;
			
			container.graphics.moveTo(	l_points[0].sx, 
										l_points[0].sy );
			
			var l:int = l_points.length;
			while( --l > -1 )
			{
				container.graphics.lineTo( 	l_points[int(l)].sx, 
											l_points[int(l)].sy);
			}
			
			l_skin.end( this, container );
		}
		
		/**
		* 	Creates texture matrix according to UV coordintes speeding up rendering
		* 
		* @param	p_skin
		* @param	p_object
		*/
		public function updateTextureMatrix():Matrix
		{	
			if( vertices.length < 3 || !skin) return null;
			
			var w:Number = 0, h:Number = 0;
                
			if (skin.getType() == SkinType.TEXTURE)
			{
				w = TextureSkin(skin).texture.width;
				h = TextureSkin(skin).texture.height;
			}
			else if (skin.getType() == SkinType.MOVIE)
			{
				w = MovieSkin(skin).getMovie().width;
				h = MovieSkin(skin).getMovie().height;
			}
			//
			if( w > 0 && h > 0 )
			{		
				var l_uv:Array = getUVCoords();
				var u0: Number = l_uv[0].u;
				var v0: Number = l_uv[0].v;
				var u1: Number = l_uv[1].u;
				var v1: Number = l_uv[1].v;
				var u2: Number = l_uv[2].u;
				var v2: Number = l_uv[2].v;
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
				
				textureMatrix = new Matrix( (u1 - u0), h*(v1 - v0)/w, w*(u2 - u0)/h, (v2 - v0), u0*w, v0*h );
				textureMatrix.invert();
			}
			
			return textureMatrix;
		}
		
		
		/**
		 * Return the depth average of the face.
		 * <p>Useful for z-sorting.</p>
		 * @return	A Number as depth average.
		 */
		public function getZAverage():Number
		{
			// We normalize the sum and return it
			var a:Array = getClippedVertices();
			var l:int   = a.length;
			if( a == null || l <= 0 ) 
			    return 0;
			var l_nLength:int = l;
			var d:Number = 0;
			//
			while( --l > -1 )
			{
				d += a[int(l)].wz;
			}
			//
			depth = d / l_nLength;
			return depth;
		}
		
		/**
		 * Returns the min depth of its vertex.
		 * @param void	
		 * @return number the minimum depth of it's vertex
		 */
		public function getMinDepth ():Number
		{
			var a:Array = getClippedVertices();
			var l:int   = a.length;
			if( a == null || l <= 0 ) 
			    return 0;
			var min:Number = a[0].wz;
			while( --l > 0 )
			{
				min = Math.min( min, a[int(l)].wz );
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
			var a:Array = getClippedVertices();
			var l:int   = a.length;
			if( a == null || l <= 0 ) 
			    return 0;
			var max:Number = a[0].wz;
			while( --l > 0 )
			{
				max = Math.max( max, a[int(l)].wz );
			}
			return max;
		}
		
		/**
		* Get a String represntation of the {@code NFace3D}. 
		* @return	A String representing the {@code NFace3D}.
		*/
		override public function toString(): String
		{
			return getQualifiedClassName(this) + " [Points: " + vertices.length + ", Clipped: " + clipped.length + "]";
		}

		public function clip( frustum:Frustum ):void
		{
			// TODO:	Not that nice solution I believe, as vertices are IDs
			//			and clipped array contains references but it works fine
			clipped = getClippedVertices().slice();
			
			frustum.clipFrustum( clipped );
			isClipped = true;
		}

		/**
		* Enable or not the events onPress, onRollOver and onRollOut with this face.
		* @param b Boolean True to enable the events, false otherwise.
		*/
		public function enableEvents( b:Boolean ):void
		{
            if( b && !mouseEvents )
            {
        		container.addEventListener(MouseEvent.CLICK, _onPress);
        		container.addEventListener(MouseEvent.MOUSE_UP, _onPress); //MIGRATION GUIDE: onRelease & onReleaseOutside
        		container.addEventListener(MouseEvent.ROLL_OVER, _onRollOver);	
        		container.addEventListener(MouseEvent.ROLL_OUT, _onRollOut);
			}
			else if( !b && mouseEvents )
			{
    			container.addEventListener(MouseEvent.CLICK, _onPress);
    			container.removeEventListener(MouseEvent.MOUSE_UP, _onPress);
    			container.removeEventListener(MouseEvent.ROLL_OVER, _onRollOver);
    			container.removeEventListener(MouseEvent.ROLL_OUT, _onRollOut);
        	}
        	mouseEvents = b;
		}

		/**
		 * isvisible 
		 * <p>Say if the face is visible or not</p>
		 * @param void
		 * @return a Boolean, true if visible, false otherwise
		 */	
		public function isVisible(): Boolean
		{
			// all normals are resfreshed in every loop
			return getNormal().wz < 0;
		}
		
		public function getNormal():Vertex
		{
			return geometry.normals[int(normalId)];
		}

		/**
		 * Create the normal vector of the face.
		 * @return	The resulting {@code Vertex} corresponding to the normal.
		 */	
		public function createNormale():Vector
		{
			if( vertices.length > 2 )
			{
				var v:Vector, w:Vector;
				var a:Vertex = vertices[0], b:Vertex = vertices[1], c:Vertex = vertices[2];
				v = new Vector( b.wx - a.wx, b.wy - a.wy, b.wz - a.wz );
				w = new Vector( b.wx - c.wx, b.wy - c.wy, b.wz - c.wz );
				// we compute de cross product
				var l_normal:Vector = VectorMath.cross( v, w );
				// we normalize the resulting vector
				VectorMath.normalize( l_normal ) ;
				// we return the resulting vertex
				return l_normal;
			}
			else
			{
				return new Vector();
			}
		}
		
		public function setSkin(p_skin:Skin):void
		{
			skin = p_skin;
			updateTextureMatrix();
		}
		
		public function setBackSkin(p_skin:Skin):void
		{
			backSkin = p_skin;
			//updateTextureMatrix();
		}
		
		public function getSkin():Skin
		{
			return skin;
		}
		
		public function getBackSkin():Skin
		{
			return backSkin;
		}
		public function getTextureMatrix():Matrix
		{
			return textureMatrix;
		}

		/**
		 * Set the id of normal vector stored in geometry object.
		 * @param	Vertex
		 */
		public function setNormalId( p_id:int ):void
		{
			normalId = p_id;
		}
		
		/**
		* This method change the value of the "normal" clipping side.
		* Also swap the font and back skins
		* @param	void
		*/
		public function swapCulling():void
		{
			// -- swap backface culling 
			backfaceCulling *= -1;
		}

		/**
		 * Destroy the movieclip attache to this polygon
		 */
		public function destroy():void
		{
			clipped = null;
			vertices = null;
		}
		
		public function getUVCoords():Array
		{
			return geometry.uv[uvId];
		}
		
		public function setUVCoordsId( p_uv:int ):void
		{
			uvId = p_uv;
			updateTextureMatrix();
		}
		

/************************/
/***** EVENTS ***********/
/************************/
		
		private function _onPress(e:MouseEvent):void
		{
			dispatchEvent(e);
		}
		
		private function _onRollOver(e:MouseEvent):void
		{
			dispatchEvent(e);
		}
		
		private function _onRollOut(e:MouseEvent):void
		{
			dispatchEvent(e);
		}

	}
}