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

import sandy.core.data.UVCoord;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.core.World3D;
import sandy.events.MouseEvent;
import sandy.materials.Appearance;
import sandy.math.VectorMath;
import sandy.view.Frustum;
import com.bourre.log.Logger;


/**
* Polygon
* @author		Thomas Pfeiffer - kiroukou
* @author		Mirek Mencel
* @version		1.0
* @date 		12.01.2006 
**/
class sandy.core.face.Polygon extends EventBroadcaster
{
// _______
// STATICS_______________________________________________________	
	private static var _ID_:Number = 0;
// ______
// PUBLIC________________________________________________________		
	public var owner:Shape3D;
	public var depth:Number;
	public var container:MovieClip;
	public var cvertices:Array;
	public var vertices:Array;
	public var bClipped:Boolean;
	public var normal:Vertex;
	public var aUVCoord:Array;
	/** Normal backface culling side is 1. -1 means that it is the opposite side which is visible */
	public var backfaceCulling:Number;
// _______
// PRIVATE_______________________________________________________			
	/** Reference to its owner geometry */
	private var m_oGeometry:Geometry3D;
	private var m_oAppearance:Appearance;
	/** array of ID of uv coordinates in geometry object */
	private var m_aUVCoords:Array;
	/** Boolean representing the state of the event activation */
	private var mouseEvents:Boolean;
	/** Unique face id */
	private var id:Number;
	/** Matrix speeding up texturing */
	private var textureMatrix:Matrix;
	
	public function Polygon( p_oOwner:Shape3D, p_geometry:Geometry3D, p_aVertexID:Array, p_aUVCoordsID:Array, p_nFaceNormalID:Number )
	{
		id = Polygon._ID_ ++;
		// --
		owner = p_oOwner;
		m_oGeometry = p_geometry;
		// --
		backfaceCulling = 1;
		depth = 0;
		// --
		__update( p_aVertexID, p_aUVCoordsID, p_nFaceNormalID );
		// Add this graphical object to the World display list
		container = World3D.getInstance().container.createEmptyMovieClip( id.toString(), id );
		bClipped = false;
	}
	
	/**
	 * Calling this method make the polygon gets its vertice and normals by reference instead of accessing them by their ID.
	 * This method shall be called once the geometry created.
	 */
	private function __update( p_aVertexID:Array, p_aUVCoordsID:Array, p_nFaceNormalID:Number ):Void
	{
		var i:Number, l:Number;
		// --
		vertices = new Array( l = p_aVertexID.length );
		for( i=0; i<l; i++ )
		{
			vertices[i] = Vertex( m_oGeometry.aVertex[ p_aVertexID[i] ] );
		}
		// --
		aUVCoord = new Array( l = p_aUVCoordsID.length );
		for( i=0; i<l; i++ )
		{
			aUVCoord[i] = UVCoord( m_oGeometry.aUVCoords[ p_aUVCoordsID[i] ] );
		}
		// TODO update the texture matrix? or just when the appearance is applied.
		// Second choice because we need the picture dimensions
		// --
		normal = Vertex( m_oGeometry.aFacesNormals[ p_nFaceNormalID ] );
		// If no normal has been given, we create it ourself.
		if( normal == null )
		{
			var l_oNormal:Vector = createNormal();
			m_oGeometry.setFaceNormal( m_oGeometry.aFacesNormals.length, l_oNormal.x, l_oNormal.y, l_oNormal.z );
			normal = Vertex( m_oGeometry.aFacesNormals[ m_oGeometry.aFacesNormals.length-1 ] );
		}
	}
		
	/**
	 * 	Creates texture matrix according to UV coordintes speeding up rendering
	 * 
	 * @param	p_skin
	 * @param	p_object
	 */
	public function updateTextureMatrix( Void ):Matrix
	{	
		var w:Number = 0, h:Number = 0;
		// --
		if( w > 0 && h > 0 )
		{		
			var l_uv:Array = m_aUVCoords;
			var u0: Number = l_uv[0].u;
			var v0: Number = l_uv[0].v;
			var u1: Number = l_uv[1].u;
			var v1: Number = l_uv[1].v;
			var u2: Number = l_uv[2].u;
			var v2: Number = l_uv[2].v;
			// -- Fix perpendicular projections. This will certainly solve the freeze problem tho. From Papervision3D implementation.
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
			// --
			textureMatrix = new Matrix( (u1 - u0), h*(v1 - v0)/w, w*(u2 - u0)/h, (v2 - v0), u0*w, v0*h );
			textureMatrix.invert();
		}
		// --
		return textureMatrix;
	}
	
	
	/**
	 * Return the depth average of the face.
	 * <p>Useful for z-sorting.</p>
	 * @return	A Number as depth average.
	 */
	public function getZAverage( Void ):Number
	{
		// -- We normalize the sum and return it
		var a:Array = cvertices;
		var l:Number= a.length;
		var d:Number = 0;
		// --
		while( --l > -1 )
		{
			d += a[(l)].wz;
		}
		// --
		depth = d / a.length;
		return depth;
	}

	
	/**
	 * Get a String representation of the {@code NFace3D}. 
	 * @return	A String representing the {@code NFace3D}.
	 */
	public function toString( Void ):String
	{
		return "sandy.core.face.Polygon::id=" +id+ " [Points: " + vertices.length + ", Clipped: " + cvertices.length + "]";
	}

	public function clip( frustum:Frustum ):Void
	{
		frustum.clipFrustum( cvertices );
		bClipped = true;
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
	 * visible 
	 * <p>Say if the face is visible or not</p>
	 * @param Void
	 * @return a Boolean, true if visible, false otherwise
	 */	
	public function get visible(): Boolean
	{
		// all normals are refreshed every loop. Face is visible is normal face to the camera
		return ( backfaceCulling * normal.wz ) < 0;
	}

	/**
	 * Create the normal vector of the face.
	 * @return	The resulting {@code Vertex} corresponding to the normal.
	 */	
	public function createNormal( Void ):Vector
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
	
	public function set appearance(p_oApp:Appearance):Void
	{
		m_oAppearance = p_oApp;
	}
	
	public function get appearance():Appearance
	{
		return m_oAppearance;
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
		cvertices = null;
		vertices = null;
	}
	

	/*
	 ***********************
	 * EVENTS 
	 ***********************
	*/
	
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