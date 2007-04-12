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

import sandy.core.data.Vertex;
import sandy.core.face.Polygon;
import sandy.core.data.AnimationData;
import sandy.core.data.UVCoord;


/**
* 	Complete description of Object3D's geometry.
* 	It contains points, faces, normals and uv coordinates.
* 	
* 	NOTE: 	For best performance, Geometry should be created in offline mode,
* 			especially all faces, as createFace() validates all points 
* 			if these points exist in points array.
* 
* 	NOTE: 	This object is going to work well _ONLY_ if arrays 
* 			wont be changed directlly [ie. push()] but _ONLY_ via accessor methods:
* 			createFace, createFaceByIds, addFace, addFaces.
* 			In the future we can make these Arrays PRIVATE but then the only 
* 			way to make them safe is to deliver additionall accessors like 
* 			getPoint(index:int), getFace(index:int) what could potentially slow 
* 			affect performance of this structure (well, we need to test it, and 
* 			if there is no problem, make arrays private and provide accessors for 
* 			_SINGLE_ array's elements to make them safe ). 
* 
* 
* 	@author		Mirek Mencel
* 	@author		Thomas PFEIFFER
* 	@version	2.0
* 	@date		07.04.2007
*/

class sandy.core.scenegraph.Geometry3D
{	
// ______
// PUBLIC________________________________________________________	
	
	/** Array of vertex */
	public var aVertex:Array;
	/** Array of faces composed from vertices */
	public var aFacesVertexID:Array;
	public var aFacesUVCoordsID:Array;
	/** Normals */
	public var aFacesNormals:Array;
	public var aVertexNormals:Array;
	/** UV Coords for faces */
	public var aUVCoords:Array;	
	
// ___________
// CONSTRUCTOR___________________________________________________
	
	/**
	 * 	Creates new 3D geometry.
	 * 
	 */
	public function Geometry3D(p_points:Array)
	{
		init();
	}
	
	public function init():Void
	{
		aVertex = new Array();
		aFacesVertexID = new Array();
		aFacesNormals = new Array();
		aFacesUVCoordsID = new Array();
		aVertexNormals = new Array();
		aUVCoords = new Array();
	}
	
	/**
	 * 	Add new point formed from passed coordinates at the specified index of the vertex list.
	 * 
	 * @param	p_x
	 * @param	p_y
	 * @param	p_z
	 */
	public function setVertex( p_nVertexID:Number, p_nX:Number, p_nY:Number, p_nZ:Number ):Boolean
	{
		if( aVertex[p_nVertexID] )
			return false;
		else
		{ aVertex[p_nVertexID] = new Vertex(p_nX, p_nY, p_nZ); return true; }
	}
		

	/**
	 * 	Add new point formed from passed coordinates at the specified index of the face normal list.
	 * 
	 * @param	p_x
	 * @param	p_y
	 * @param	p_z
	 */
	public function setFaceNormal( p_nNormalID:Number, p_nX:Number, p_nY:Number, p_nZ:Number ):Boolean
	{
		if( aFacesNormals[p_nNormalID] )
			return false;
		else
		{ aFacesNormals[p_nNormalID] = new Vertex(p_nX, p_nY, p_nZ); return true; }
	}
		
	/**
	 * 	Add new point formed from passed coordinates at the specified index of the vertex normal list.
	 * 
	 * @param	p_x
	 * @param	p_y
	 * @param	p_z
	 */
	public function setVertexNormal( p_nNormalID:Number, p_nX:Number, p_nY:Number, p_nZ:Number ):Boolean
	{
		if( aVertexNormals[p_nNormalID] )
			return false;
		else
		{ aVertexNormals[p_nNormalID] = new Vertex(p_nX, p_nY, p_nZ); return true; }
	}
	
	/**
	 * set the face vertex ID's from the 
	 * @param	...rest an array of data containing the ID's of the vertex list representing the face
	 * @return true is the face has been created, false if the faces already exist
	 */
	public function setFaceVertexIds( p_nFaceID:Number /* Arguments */ ):Boolean
	{
		if( aFacesVertexID[p_nFaceID] )
		{
			return false;
		}
		else
		{
			var rest:Array = (arguments[1] instanceof Array)? arguments[1]: arguments.splice(1);
			aFacesVertexID[p_nFaceID] = rest;
		}
	}
	
	/**
	 * set the face vertex ID's from the 
	 * @param	...rest an array of data containing the ID's of the vertex list representing the face
	 * @return true is the face has been created, false if the faces already exist
	 */
	public function setFaceUVCoordsIds( p_nFaceID:Number /* Arguments */ ):Boolean
	{
		if( aFacesUVCoordsID[p_nFaceID] )
		{
			return false;
		}
		else
		{
			var rest:Array = (arguments[1] instanceof Array)? arguments[1]: arguments.splice(1);
			aFacesUVCoordsID[p_nFaceID] = rest;
		}
	}
		
	
	
	public function getVertexId( p_point:Vertex ):Number
	{
		var j:Number = 0;
		for(j=0; 	j<aVertex.length && !(aVertex[j] == p_point); 	j++);
		
		return j == aVertex.length ? -1: j;
	}
	
	/**
	 * Adds UV coordinates for single face.
	 * 
	 * @param	...rest	Array of UV coordinates (3 UVCoords for triangles).
	 */
	public function setUVCoords( p_nID:Number, p_UValue:Number, p_nVValue:Number ):Boolean
	{
		if ( aUVCoords[p_nID] )
		{
			return false;
		}
		else
		{
			aUVCoords[p_nID] = new UVCoord( p_UValue, p_nVValue );
			return true;
		}
	}
	
	/**
	* 	Creates clone.
	* 	
	* 	NOTE: 	Because polygon keeps also instance-specific data like Skin for instance, 
	* 			on the Geomoetry level we're considering it only as a set of connections between points, 
	* 			so only coordinates and normal are copied over during the clone process.
	* 
	* @return	Geometry3D	Copy of this geometry
	*/
	public function clone():Geometry3D
	{
		var l_result:Geometry3D = new Geometry3D();
		var i:Number = 0;
		// Points
		var l:Number = aVertex.length;
		for (i = 0; i<l; i++)
		{
			l_result.aVertex[i] = Vertex( aVertex[i] ).clone();
		}
		
		// Faces
		l = aFacesVertexID.length;
		for (i = 0; i<l; i++)
		{
			l_result.aFacesVertexID[i] = Array(aFacesVertexID[i]).concat();
		}
		
		// Normals
		l = aFacesNormals.length;
		for (i = 0; i<l; i++)
		{
			l_result.aFacesNormals[i] = Vertex( aFacesNormals[i] ).clone();
		}
		
		// Normals
		l = aVertexNormals.length;
		for (i = 0; i<l; i++)
		{
			l_result.aVertexNormals[i] = Vertex( aVertexNormals[i] ).clone();
		}
		
		// UVs face
		l = aFacesUVCoordsID.length;
		for (i = 0; i<l; i++)
		{
			l_result.aFacesUVCoordsID[i] = aFacesUVCoordsID[i].concat();
		}
		
		// UVs coords
		l = aUVCoords.length;
		for (i = 0; i<l; i++)
		{
			l_result.aUVCoords[i] = UVCoord( aUVCoords[i] ).clone();
		}
		
		
		return l_result;
	}
	
	public function toString():String
	{
		return "[Geometry: " + 	aFacesVertexID.length + " faces, " + 
								aVertex.length + " points, " + 
								aFacesNormals.length + " normals, " +
	
								aUVCoords.length + " uv coords]";
	}
	
	/*public function debug():void
	{
		trace("Faces: [" + faces.length + "] " + faces);
		trace("Points: [" + points.length + "] " + points);
		trace("Unique directions: [" + uniqueDirections.length + "] " + uniqueDirections);
		trace("Normals: [" + normals.length + "] " + normals);
		trace("UVs: [" + uv.length + "] " + uv);
	}*/
	
}
