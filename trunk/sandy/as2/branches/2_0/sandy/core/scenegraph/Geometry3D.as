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
* 	@version	1.0
* 	@date		16.02.2007
*/
class sandy.core.scenegraph.Geometry3D
{
	
// ______
// PUBLIC________________________________________________________	
	
	/** Array of vertices */
	public var points:Array;
	
	/** Array of faces composed from vertices */
	public var faces:Array;
	
	/** Normals */
	public var normals:Array;
	
	/** UV Coords for faces */
	public var uv:Array;
	
	
	
// _______
// PRIVATE_______________________________________________________
	
	/** 
	* 	NOTE: 	Not in use curentlly, as we do transformation on old vectors
	* 			rather than recalculating all vectors once arain
	* 			See updateNormals(p_matrix: Matrix)
	* 
	* 	Array of faces we're using to re-calculating normal vectors */
	private var uniqueDirections:Array;
	
	
// ___________
// CONSTRUCTOR___________________________________________________
	
	/**
	* 	Creates new 3D geometry.
	* 
	* @param	p_points
	* @param	p_isStatic 	If true computation of normals is faster 
	* 						for objects having many faces pointing in the same direction
	*/
	public function Geometry3D(p_points:Array)
	{
		points = p_points || new Array();
		faces = new Array();
		normals = new Array();
		uniqueDirections = new Array();
		uv = new Array();
	}
	
	
	/**
	* 	Add new point formed from passed coordinates.
	* 
	* @param	p_x
	* @param	p_y
	* @param	p_z
	*/
	public function addPointByCoords(p_x:Number, p_y:Number, p_z:Number):Number
	{
		return points.push(new Vertex(p_x, p_y, p_z)) - 1;
	}
	
	
	/**
	* 	Adds array of Vertices.
	* 
	* @param	p_points
	*/
	public function addPoints():Number
	{
		var rest:Array = (arguments[0] instanceof Array)? arguments[0]: arguments;
		
		if (rest && rest.length > 0) 
			points.concat(rest);
			
		return points.length - 1;
	}
	
	
	/**
	* 	Add new point defined as Vertex
	* 
	* @param	p_vertex
	*/
	public function addPoint(p_vertex:Vertex):Number
	{	
		return points.push(p_vertex) - 1;
	}
	
	
	/**
	* 	Creates new face from points being pointed by passed indexes (of points array)
	* 	NOTE: Most probably this method could have better name (but I'm tired...
	* 
	* @param	...rest
	* @return
	*/
	public function createFaceByIds():Number
	{
		var rest:Array = (arguments[0] instanceof Array)? arguments[0]: arguments;
		
		var l_vertices:Array = [];
		var l_fn:Number = rest.length;
		for(var i:Number = 0; 	i<l_fn && 
							rest[i] < points.length && 
							rest[i] >= 0; i++)
		{
			l_vertices.push(points[rest[i]]);
		}
		
		if (l_vertices.length != rest.length)
		{
			trace("#Error [Geometry3D] createFace() One of passed points id's doesn't exist in this geometry!");
			return -1;
		}
		
		return createFace(l_vertices);
		
	}
	
	
	/**
	* 	Creates face from passed vertices or array of vertices.
	* 
	* @param	...rest:Array	If first element is an array all others are ommited.
	* @return
	*/
	public function createFace():Number
	{
		var rest:Array = (arguments[0] instanceof Array)? arguments[0]: arguments;
		
		// 	Check if such points already exist in points[] array and
		//	create them if not
		var l:Number = rest.length;
		var l_id:Number;
		var i:Number;
		for ( i = 0; i<l; i++)
		{
			l_id = getPointId(rest[i]);
			
			if (l_id<0)
			{
				// Add new point as it doesn't t exist in points array
				l_id = addPoint(rest[i]) - 1;
			}
		}
		
		var l_face:Polygon = new Polygon(this, rest);
		var l_faceID:Number = faces.push(l_face)-1;
		
		// 1)	Create normal
		var l_normal:Vertex = Vertex.createFromVector( l_face.createNormale() );
		l = normals.length;
		
		// 2)	Check if such normal already exists
		for(i = 0; 	i<l && !normals[i].equals(l_normal); i++);
		
		// 3)	If yes: push into uniqueDirections array
		if( i == l )
		{
			// 	Save an ID if this face as it's facing in
			// 	new, not-known yet, direction and will be 
			//	reused for updateing normals :-)
			uniqueDirections.push(l_faceID);
			
			// 	Save normal and it's index
			i = normals.push(l_normal)-1;
		}
					
		// 4)	Set proper normal's index for new face
		l_face.setNormalId(i);
		
		// 5)	Set uv mapping id if exists (was setted before the face was created)
		if (uv[i])
			l_face.setUVCoordsId(i);
			
			
		return l_faceID;
	}
	
	public function addFace(p_face:Polygon):Number
	{
		return -1; // TODO
	}
	
	public function addFaces(p_faces:Array):Number
	{
		return -1; // TODO
	}
	
	private function getPointId(p_point:Vertex):Number
	{
		var j:Number = 0;
		for(j=0; 	j<points.length && !(points[j] == p_point); j++);
		
		return j == points.length ? -1: j;
	}
	
	/**
	* 	Adds UV coordinates for single face.
	* 
	* @param	...rest	Array of UV coordinates (3 UVCoords for triangles).
	*/
	public function addUVCoords():Void
	{
		var rest:Array = (arguments[0] instanceof Array)? arguments[0]: arguments;
		
		if (!rest || rest.length<3)
		{
			trace("#Warrning [Geometry3D] addUVCoords() Passed number of coordinates is lower then 3!");
			return;
		}
		
		var i:Number = uv.push(rest)-1;
		
		if (faces[i])
			faces[i].setUVCoordsId(i);
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
		var l:Number = points.length;
		for (i = 0; i<l; i++)
		{
			l_result.addPoint(points[i].clone());
		}
		
		// Faces
		l = faces.length;
		for (i = 0; i<l; i++)
		{
			l_result.createFaceByIds(faces[i].vertices);
		}
		
		// Normals
		l = normals.length;
		for (i = 0; i<l; i++)
		{
			l_result.normals.push( normals[i].clone() );
			l_result.uniqueDirections.push( uniqueDirections[i] );
		}
		
		// UVs
		l = uv.length;
		var l_uvs:Array;
		for (i = 0; i<l; i++)
		{
			l_uvs = uv[i];
			l_result.addUVCoords( l_uvs[0].clone(), l_uvs[1].clone(), l_uvs[2].clone()  );
		}
		
		
		return l_result;
	}
	
	public function toString():String
	{
		return "[Geometry: " + 	faces.length + " faces, " + 
								points.length + " points, " + 
								normals.length + " normals, " +
								uv.length + " uv coords]";
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
