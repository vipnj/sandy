﻿/*
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

import sandy.core.data.Polygon;
import sandy.core.data.PrimitiveFace;
import sandy.core.data.UVCoord;
import sandy.core.data.Vertex;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;	
import sandy.primitive.Primitive3D;

/**
 * The Box class is used for creating a cube or box primitive ( cuboid ).
 *
 * @author		Thomas Pfeiffer - kiroukou
 * @author		(porting) Floris - FFlasher
 * @version		2.0.2
 * @date 		26.07.2007
 *
 * @example To create a rectilinear box with ( x, y, z ) dimensions ( 50, 100, 150 )
 * with a quality of 2, use the following statement:
 *
 * <listing version="3.0">
 *     var myBox:Box = new Box( "theBox", 50, 100, 150, 2 );
 *  </listing>
 */
	
class sandy.primitive.Box extends Shape3D implements Primitive3D
{
	
	/**
	 * The index of the top face of the box.
	 */
	public static var FACE_TOP:Number		= 3;

	/**
	 * The index of the bottom face of the box.
	 */
	public static var FACE_BOTTOM:Number	= 2;

	/**
	 * The index of the back face of the box.
	 */
	public static var FACE_BACK:Number		= 0; 

	/**
	 * The index of the front face of the box.
	 */
	public static var FACE_FRONT:Number		= 1; 

	/**
	 * The index of the right face of the box.
	 */
	public static var FACE_RIGHT:Number		= 5; 

	/**
	 * The index of the left face of the box.
	 */
	public static var FACE_LEFT:Number		= 4; 

	/**
	 * height of the Box
	 */
	private var _h:Number;
		
	/**
	 * depth of the Box
	 */
	private var _lg:Number;
		
	/**
	 * width of the Box
	 */
	private var _radius:Number;
		
	/**
	 * creation quality
	 */
	private var _q:Number;

	/**
	 * faces of the cube
	 */
	private var m_aFaces:Array;

	/**
	 * Creates a Box primitive.
	 *
	 * <p>The Box is created centered at the origin of the world coordinate system,
	 * and with its edges parallel to world coordinate axes.</p>
	 *
	 * @param p_sName	A string identifier for this object.
	 * @param p_nWidth 	Width of the box (along the x-axis).
	 * @param p_nHeight	Height of the box (along the y-axis).
	 * @param p_nDepth	Depth of the box (along the z-axis).
	 * @param p_sMode	The generation mode. "tri" generates faces with 3 vertices, and "quad" generates faces with 4 vertices.
	 *
	 * @see PrimitiveMode
	 */
	public function Box( p_sName:String, p_nWidth:Number, p_nHeight:Number, p_nDepth:Number, p_nQuality:Number )
	{
		super ( p_sName );
		//
		_h = p_nHeight||6;
		_lg = p_nDepth||6;
		_radius = p_nWidth||6;
		p_nQuality = p_nQuality||1;
		_q = ( p_nQuality <= 0 || p_nQuality > 10 ) ?  1 : p_nQuality ;
		geometry = generate();
		_generateFaces();
	}
		
	/**
	 * READ-ONLY
	 * This getter allows to retrieve the original box width specified at the geometry creation
	 * @return the original box width value
	 */
	public function get boxWidth() : Number
	{
		return _radius;
	}
		
	/**
	 * READ-ONLY
	 * This getter allows to retrieve the original box height specified at the geometry creation
	 * @return the original box height value
	 */
	public function get boxHeight() : Number
	{
		return _h;
	}
		
	/**
	 * READ-ONLY
	 * This getter allows to retrieve the original box depth specified at the geometry creation
	 * IMPORTANT: This is not related with the depth value of the Shape3D class the Box inherit from, which is the 3D depth information, not the Box one.
	 * @return the original box depth value
	 */
	public function get boxDepth() : Number
	{
		return _lg;
	}

	/**
	 * Generates the geometry object for the box.
	 *
	 * @return The geometry object for the box.
	 *
	 * @see sandy.core.scenegraph.Geometry3D
	 */
	public function generate( /* Arguments */ ) : Geometry3D
	{
		// initialisation
		var l_geometry:Geometry3D = new Geometry3D();

		//we build points
		var h2 : Number = - _h / 2;
		var r2 : Number = _radius / 2;
		var l2 : Number = _lg / 2;

		var l_nID0:Number = l_geometry.getNextVertexID();
		l_geometry.setVertex( l_nID0, -r2, -h2, l2 );

		var l_nID1:Number = l_geometry.getNextVertexID();
		l_geometry.setVertex( l_nID1, r2, -h2, l2 );

		var l_nID2:Number = l_geometry.getNextVertexID();
		l_geometry.setVertex( l_nID2, r2, h2, l2 );

		var l_nID3:Number = l_geometry.getNextVertexID();
		l_geometry.setVertex( l_nID3, -r2, h2, l2 );

		var l_nID4:Number = l_geometry.getNextVertexID();
		l_geometry.setVertex( l_nID4, -r2, -h2, -l2 );

		var l_nID5:Number = l_geometry.getNextVertexID();
		l_geometry.setVertex( l_nID5, r2, -h2, -l2 );

		var l_nID6:Number = l_geometry.getNextVertexID();
		l_geometry.setVertex( l_nID6, r2, h2, -l2 );

		var l_nID7:Number = l_geometry.getNextVertexID();
		l_geometry.setVertex( l_nID7, -r2, h2, -l2 );

		// -- we setup texture coordinates
		l_geometry.setUVCoords( 0, 0, 0 );
		l_geometry.setUVCoords( 1, 1, 0 );
		l_geometry.setUVCoords( 2, 0, 1 );
		l_geometry.setUVCoords( 3, 1, 1 );
		// -- Faces creation

		//Front Face
		__tesselate( l_geometry,
					 l_nID0, l_nID1, l_nID2, l_nID3,
					 0, 2, 3, 1,
					 _q - 1 );

		//Behind Face
		__tesselate( l_geometry,
					 l_nID4, l_nID7, l_nID6, l_nID5,
					 0, 2, 3, 1,
					 _q - 1 );
		//Top Face
		__tesselate( l_geometry,
					 l_nID2, l_nID6, l_nID7, l_nID3,
					 0, 2, 3, 1,
					 _q - 1 );
		//Bottom Face
		__tesselate( l_geometry,
					 l_nID0, l_nID4, l_nID5, l_nID1,
					 0, 2, 3, 1,
					 _q - 1 );
		//Left Face
		__tesselate( l_geometry,
					 l_nID0, l_nID3, l_nID7, l_nID4,
					 0, 2, 3, 1,
					 _q - 1 );
		//Right Face
		__tesselate( l_geometry,
					 l_nID1, l_nID5, l_nID6, l_nID2,
					 0, 2, 3, 1,
					 _q - 1 );

		return l_geometry;
	}

	private function __tesselate( p_geometry:Geometry3D, 
								  p0:Number, p1:Number, p2:Number, p3:Number,
								  uv0:Number, uv1:Number, uv2:Number, uv3:Number,
								  level:Number) : Void
	{
		var l_geometry:Geometry3D = p_geometry;

		var f:Polygon;
		if( level == 0 ) // End of recurssion
		{

			// -- We have the same normal for 2 faces, be careful to don't add extra normal
			l_geometry.setFaceVertexIds( l_geometry.getNextFaceID(), p0, p1, p3 );
			l_geometry.setFaceUVCoordsIds( l_geometry.getNextFaceUVCoordID(), uv0, uv1, uv3 );

			l_geometry.setFaceVertexIds( l_geometry.getNextFaceID(), p2, p3, p1 );
			l_geometry.setFaceUVCoordsIds( l_geometry.getNextFaceUVCoordID(), uv2, uv3, uv1 );
			
		}
		else
		{
			var l_oVertex0:Vertex = l_geometry.aVertex[ p0 ];
			var l_oVertex1:Vertex = l_geometry.aVertex[ p1 ];
			var l_oVertex2:Vertex = l_geometry.aVertex[ p2 ];
			var l_oVertex3:Vertex = l_geometry.aVertex[ p3 ];
			// center of p0, p1;
			var l_nID01:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID01, ( l_oVertex0.x + l_oVertex1.x ) / 2, ( l_oVertex0.y + l_oVertex1.y ) / 2, ( l_oVertex0.z + l_oVertex1.z ) / 2 );
			// center of p1, p2
			var l_nID12:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID12, ( l_oVertex1.x + l_oVertex2.x ) / 2, ( l_oVertex1.y + l_oVertex2.y ) / 2, ( l_oVertex1.z + l_oVertex2.z ) / 2 );
			//var m12:Vertex = new Vertex( ( l_oVertex1.x + l_oVertex2.x ) / 2, ( l_oVertex1.y + l_oVertex2.y ) / 2, ( l_oVertex1.z + l_oVertex2.z ) / 2 );
			// center of p2, p3
			var l_nID23:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID23, ( l_oVertex2.x + l_oVertex3.x ) / 2, ( l_oVertex2.y + l_oVertex3.y ) / 2, ( l_oVertex2.z + l_oVertex3.z ) / 2 );
			//var m23:Vertex = new Vertex( ( l_oVertex2.x + l_oVertex3.x ) / 2, ( l_oVertex2.y + l_oVertex3.y ) / 2, ( l_oVertex2.z + l_oVertex3.z ) / 2 );
			//l_geometry.addPoint( m23 );
			// center of p3, p0
			var l_nID30:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID30, ( l_oVertex3.x + l_oVertex0.x ) / 2, ( l_oVertex3.y + l_oVertex0.y ) / 2, ( l_oVertex3.z + l_oVertex0.z ) / 2 );
			//var m30:Vertex = new Vertex( ( l_oVertex3.x + l_oVertex0.x ) / 2, ( l_oVertex3.y + l_oVertex0.y ) / 2, ( l_oVertex3.z + l_oVertex0.z ) / 2 );
			//l_geometry.addPoint( m30 );
			// center of all the uvcoords 
			var l_nIDMiddle:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nIDMiddle, ( l_oVertex0.x + l_oVertex1.x + l_oVertex2.x + l_oVertex3.x ) / 4, ( l_oVertex0.y + l_oVertex1.y + l_oVertex2.y + l_oVertex3.y ) / 4, ( l_oVertex0.z + l_oVertex1.z + l_oVertex2.z + l_oVertex3.z ) / 4 );
			//var center:Vertex = new Vertex( ( l_oVertex0.x + l_oVertex1.x + l_oVertex2.x + l_oVertex3.x ) / 4, ( l_oVertex0.y + l_oVertex1.y + l_oVertex2.y + l_oVertex3.y ) / 4, ( l_oVertex0.z + l_oVertex1.z + l_oVertex2.z + l_oVertex3.z ) / 4 );
			//l_geometry.addPoint( center );
			//l_geometry.addPoints( m01, m12, m23, m30, center );

			var l_oUV0:UVCoord = l_geometry.aUVCoords[ uv0 ];
			var l_oUV1:UVCoord = l_geometry.aUVCoords[ uv1 ];
			var l_oUV2:UVCoord = l_geometry.aUVCoords[ uv2 ];
			var l_oUV3:UVCoord = l_geometry.aUVCoords[ uv3 ];
			// center of p0, p1;
			l_geometry.setUVCoords( l_nID01, ( l_oUV0.u + l_oUV1.u ) / 2, ( l_oUV0.v + l_oUV1.v ) / 2 );
			// center of p1, p2
			l_geometry.setUVCoords( l_nID12, ( l_oUV1.u + l_oUV2.u ) / 2, ( l_oUV1.v + l_oUV2.v ) / 2 );
			// center of p2, p3
			l_geometry.setUVCoords( l_nID23, ( l_oUV2.u + l_oUV3.u ) / 2, ( l_oUV2.v + l_oUV3.v ) / 2 );
			// center of p3, p0
			l_geometry.setUVCoords( l_nID30, ( l_oUV3.u + l_oUV0.u ) / 2, ( l_oUV3.v + l_oUV0.v ) / 2 );
			// center of all the uvcoords
			l_geometry.setUVCoords( l_nIDMiddle, ( l_oUV0.u + l_oUV1.u + l_oUV2.u + l_oUV3.u ) / 4, ( l_oUV0.v + l_oUV1.v + l_oUV2.v + l_oUV3.v ) / 4 );

			__tesselate( l_geometry,
						 l_nIDMiddle, l_nID30, p0, l_nID01,
						 l_nIDMiddle, l_nID30, uv0, l_nID01,
						 level - 1 );
			__tesselate( l_geometry,
						 l_nIDMiddle, l_nID01, p1, l_nID12,
						 l_nIDMiddle, l_nID01, uv1, l_nID12,
						 level - 1 );

			__tesselate( l_geometry,
						 l_nIDMiddle, l_nID12, p2, l_nID23,
						 l_nIDMiddle, l_nID12, uv2, l_nID23,
						 level - 1 );

			__tesselate( l_geometry,
						 l_nIDMiddle, l_nID23, p3, l_nID30,
						 l_nIDMiddle, l_nID23, uv3, l_nID30,
						 level - 1 );

		}
	}

	private function _generateFaces() : Void
	{
		m_aFaces = new Array( 6 );
		var m:Number = 2;
		var multi:Number = int( m * Math.pow( 4, _q - 1 ) );
		for ( var i:Number = 0; i < 6; i++ )
		{
			m_aFaces[ i ] = new PrimitiveFace( this );
			var l:Number = ( i + 1 ) * multi;
			for ( var j:Number = i * multi; j < l; j++ )
				PrimitiveFace( m_aFaces[ i ] ).addPolygon( j );
		}
	}

	/**
	 * Returns a PrimitiveFace object ( an array of polygons ) defining the specified face.
	 *
	 * @param	p_nFace The requested face
	 * @return	The PrimitiveFace object of the specified face.
	 *
	 * @see PrimitiveFace
	 */
	public function getFace( p_nFace : Number ) : PrimitiveFace
	{
		return m_aFaces[ int( p_nFace ) ];
	}

	/**
	 * @private
	 */
	public function toString() : String
	{
		return "sandy.primitive.Box";
	}
	
}