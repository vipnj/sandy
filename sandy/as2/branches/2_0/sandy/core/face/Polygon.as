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
import com.bourre.events.EventBroadcaster;

import flash.geom.Matrix;

import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.face.IPolygon;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.World3D;
import sandy.events.MouseEvent;
import sandy.math.VectorMath;
import sandy.skin.MovieSkin;
import sandy.skin.Skin;
import sandy.skin.SkinType;
import sandy.skin.TextureSkin;
import sandy.view.Frustum;


/**
* Polygon
* @author		Thomas Pfeiffer - kiroukou
* @author		Mirek Mencel
* @version		1.0
* @date 		12.01.2006 
**/
class sandy.core.face.Polygon extends EventBroadcaster implements IPolygon 
{
// _______
// STATICS_______________________________________________________	
	private static var _ID_:Number = 0;
	
// ______
// PUBLIC________________________________________________________		
	public var depth:Number;
	public var container:MovieClip;
	public var vertices:Array;
	public var clipped:Array;
	public var isClipped:Boolean;
// _______// PRIVATE_______________________________________________________			

	/** Reference to its owner geometry */
	private var geometry:Geometry3D;
	
	/** Front & Backface Skin */
	private var skin:Skin;
	private var backSkin:Skin;
	
	/** ID of normal vector stored in geometry object */
	private var normalId:Number;
	
	/** ID of uv coordinates in geometry object */
	private var uvId:Number;
	
	/** Boolean representing the state of the event activation */
	private var mouseEvents:Boolean;
	
	/** Unique face id */
	private var id:Number;
	
	/** Normal backface culling side is 1. -1 means that it is the opposite side which is visible */
	private var backfaceCulling:Number;
	
	/** Matrix speeding up texturing */
	private var textureMatrix:Matrix;
	
	public function Polygon(p_geometry:Geometry3D)
	{
		id = Polygon._ID_ ++;
		var rest:Array = arguments.splice(1,1);
		// Check if user passed an array 
		// and if true, use it as a list of vertices
		rest = (rest[0] instanceof Array) ? rest[0]: rest;
		geometry = p_geometry;
		backfaceCulling = 1;
		vertices = rest || [];
		clipped = [];
		depth = 0;
		isClipped = false;
		// Add this graphical object to the World display list
		container = World3D.getInstance().container.createEmptyMovieClip( id.toString(), id );
	}
	
	public function getClippedVertices(Void):Array
	{
		return (isClipped) ? clipped : vertices;
	}
	
	public function getVertices(Void):Array
	{
		return vertices;
	}
	
	/** 
	 * Render the face into container with given Skin.
	 * @param	{@code mc}	A {@code MovieClip}.
	 */
	public function render(Void): Void
	{
		var l_points:Array = getClippedVertices();
		var l_skin:Skin;
		//
		if( backfaceCulling == 1 )	l_skin = skin;
		else						l_skin = backSkin;
		// -- start rendering with passed skin
		l_skin.begin( this, container) ;
		container.moveTo(	l_points[0].sx, 
							l_points[0].sy );
		//
		var l:Number = l_points.length;
		while( --l > -1 )
		{
			container.lineTo( 	l_points[(l)].sx, 
								l_points[(l)].sy);
		}
		//
		l_skin.end( this, container );
	}
	
	/**
	* 	Creates texture matrix according to UV coordintes speeding up rendering
	* 
	* @param	p_skin
	* @param	p_object
	*/
	public function updateTextureMatrix(Void):Matrix
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
	public function getZAverage(Void):Number
	{
		// We normalize the sum and return it
		var a:Array = getClippedVertices();
		var l:Number   = a.length;
		if( a == null || l <= 0 ) 
		    return 0;
		var l_nLength:Number = l;
		var d:Number = 0;
		//
		while( --l > -1 )
		{
			d += a[(l)].wz;
		}
		//
		depth = d / l_nLength;
		return depth;
	}
	
	/**
	 * Returns the min depth of its vertex.
	 * @param Void	
	 * @return number the minimum depth of it's vertex
	 */
	public function getMinDepth (Void):Number
	{
		var a:Array = getClippedVertices();
		var l:Number   = a.length;
		if( a == null || l <= 0 ) 
		    return 0;
		var min:Number = a[0].wz;
		while( --l > 0 )
		{
			min = Math.min( min, a[(l)].wz );
		}
		return min;
	}

	/**
	 * Returns the max depth of its vertex.
	 * @param Void	
	 * @return number the maximum depth of it's vertex
	 */
	public function getMaxDepth (Void):Number
	{
		var a:Array = getClippedVertices();
		var l:Number   = a.length;
		if( a == null || l <= 0 ) 
		    return 0;
		var max:Number = a[0].wz;
		while( --l > 0 )
		{
			max = Math.max( max, a[(l)].wz );
		}
		return max;
	}
	
	/**
	* Get a String represntation of the {@code NFace3D}. 
	* @return	A String representing the {@code NFace3D}.
	*/
	public function toString(Void): String
	{
		return "sandy.core.face.Polygon" + " [Points: " + vertices.length + ", Clipped: " + clipped.length + "]";
	}

	public function clip( frustum:Frustum ):Void
	{
		// TODO:	Not that nice solution I believe, as vertices are IDs
		//			and clipped array contains references but it works fine
		clipped = getClippedVertices().slice();
		//
		frustum.clipFrustum( clipped );
		isClipped = true;
	}

	/**
	* Enable or not the events onPress, onRollOver and onRollOut with this face.
	* @param b Boolean True to enable the events, false otherwise.
	*/
	public function enableEvents( b:Boolean ):Void
	{
        if( b && !mouseEvents )
        {
    		container.addEventListener(MouseEvent.CLICK, this, _onPress);
    		container.addEventListener(MouseEvent.MOUSE_UP, this, _onPress); //MIGRATION GUIDE: onRelease & onReleaseOutside
    		container.addEventListener(MouseEvent.ROLL_OVER,this,  _onRollOver);	
    		container.addEventListener(MouseEvent.ROLL_OUT, this, _onRollOut);
		}
		else if( !b && mouseEvents )
		{
			container.addEventListener(MouseEvent.CLICK, this, _onPress);
			container.removeEventListener(MouseEvent.MOUSE_UP, this, _onPress);
			container.removeEventListener(MouseEvent.ROLL_OVER, this, _onRollOver);
			container.removeEventListener(MouseEvent.ROLL_OUT, this, _onRollOut);
    	}
    	mouseEvents = b;
	}

	/**
	 * isvisible 
	 * <p>Say if the face is visible or not</p>
	 * @param Void
	 * @return a Boolean, true if visible, false otherwise
	 */	
	public function isVisible(Void): Boolean
	{
		// all normals are refreshed every loop. Face is visible is normal face to the camera
		return ( backfaceCulling * getNormal().wz ) < 0;
	}
	
	public function getNormal(Void):Vertex
	{
		return geometry.normals[normalId];
	}

	/**
	 * Create the normal vector of the face.
	 * @return	The resulting {@code Vertex} corresponding to the normal.
	 */	
	public function createNormale(Void):Vector
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
	
	public function setSkin(p_skin:Skin):Void
	{
		trace("Polygon::setSkin : "+p_skin);
		skin = p_skin;
	}
	
	public function setBackSkin(p_skin:Skin):Void
	{
		backSkin = p_skin;
		//updateTextureMatrix(Void);
	}
	
	public function getSkin(Void):Skin
	{
		return skin;
	}
	
	public function getBackSkin(Void):Skin
	{
		return backSkin;
	}
	
	public function getTextureMatrix(Void):Matrix
	{
		return textureMatrix;
	}

	/**
	 * Set the id of normal vector stored in geometry object.
	 * @param	Vertex
	 */
	public function setNormalId( p_id:Number ):Void
	{
		normalId = p_id;
	}
	
	/**
	* This method change the value of the "normal" clipping side.
	* Also swap the font and back skins
	* @param	Void
	*/
	public function swapCulling(Void):Void
	{
		// -- swap backface culling 
		backfaceCulling *= -1;
	}

	/**
	 * Destroy the movieclip attache to this polygon
	 */
	public function destroy(Void):Void
	{
		clipped = null;
		vertices = null;
	}
	
	public function getUVCoords(Void):Array
	{
		return geometry.uv[uvId];
	}
	
	public function setUVCoordsId( p_uv:Number ):Void
	{
		uvId = p_uv;
		updateTextureMatrix();
	}
	

/************************/
/***** EVENTS ***********/
/************************/
	
	private function _onPress(e:MouseEvent):Void
	{
		dispatchEvent(e);
	}
	
	private function _onRollOver(e:MouseEvent):Void
	{
		dispatchEvent(e);
	}
	
	private function _onRollOut(e:MouseEvent):Void
	{
		dispatchEvent(e);
	}

}
