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


package sandy.core 
{
	import sandy.core.face.Polygon;
	import sandy.core.data.Vertex;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vector;
	import sandy.math.Matrix4Math;
	
	
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
	public class Geometry3D
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
		
		/**
		* 	It means that all face once created doesn't change
		* 	it's orientation against the other faces what
		* 	makes faster updating normals, when there is a lot of faces
		* 	having the same normal vector like let's say hi-res boxes.
		*/
		private var isStatic:Boolean;
	
		
		
	// ___________
	// CONSTRUCTOR___________________________________________________
		
		/**
		* 	Creates new 3D geometry.
		* 
		* @param	p_points
		* @param	p_isStatic 	If true computation of normals is faster 
		* 						for objects having many faces pointing in the same direction
		*/
		public function Geometry3D(p_points:Array = null, p_isStatic:Boolean = true)
		{
			points = p_points || new Array();
			faces = new Array();
			normals = new Array();
			uniqueDirections = new Array();
			uv = new Array();
			
			isStatic = p_isStatic;
		}
		
		
		/**
		* 	Add new point formed from passed coordinates.
		* 
		* @param	p_x
		* @param	p_y
		* @param	p_z
		*/
		public function addPointByCoords(p_x:Number, p_y:Number, p_z:Number):int
		{
			return points.push(new Vertex(p_x, p_y, p_z)) - 1;
		}
		
		
		/**
		* 	Adds array of Vertices.
		* 
		* @param	p_points
		*/
		public function addPoints(...rest):void
		{
			rest = (rest[0] is Array)? rest[0]: rest;
			
			if (rest && rest.length > 0) 
				points.concat(rest);
		}
		
		
		/**
		* 	Add new point defined as Vertex
		* 
		* @param	p_vertex
		*/
		public function addPoint(p_vertex:Vertex):int
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
		public function createFaceByIds(...rest):int
		{
			rest = (rest[0] is Array)? rest[0]: rest;
			
			var l_vertices:Array = [];
			var l_fn:int = rest.length;
			for(var i:int = 0; 	i<l_fn && 
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
		public function createFace(...rest):int
		{
			rest = (rest[0] is Array)? rest[0]: rest;
			
			// 	Check if such points already exist in points[] array and
			//	create them if not
			var l:int = rest.length;
			var l_id:int;
			for (var i:int = 0; i<l; i++)
			{
				l_id = getPointId(rest[i]);
				
				if (l_id<0)
				{
					// Add new point as it doesn't t exist in points array
					l_id = addPoint(rest[i]) - 1;
				}
			}
			
			var l_face:Polygon = new Polygon(this, rest);
			var l_faceID:int = faces.push(l_face)-1;
			
			// 1)	Create normal
			var l_normal:Vector = l_face.createNormale();
			var l:int = normals.length;
			
			// 2)	Check if such normal already exists
			for(i = 0; 	i<l && !normals[i].equals(l_normal); i++);
			
			// 3)	If yes: push into uniqueDirections array
			if(isStatic && (i==l))
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
		
		public function addFace(p_face:Polygon):int
		{
			return -1; // TODO
		}
		
		public function addFaces(p_faces:Array):int
		{
			return -1; // TODO
		}
		
		private function getPointId(p_point:Vertex):int
		{
			for(var j:int = 0; 	j<points.length && !(points[j] == p_point); j++);
			
			return j == points.length ? -1: j;
		}
		
		/**
		* 	Adds UV coordinates for single face.
		* 
		* @param	...rest	Array of UV coordinates (3 UVCoords for triangles).
		*/
		public function addUVCoords(...rest):void
		{
			rest = (rest[0] is Array)? rest[0]: rest;
			
			if (!rest || rest.length<3)
			{
				trace("#Warrning [Geometry3D] addUVCoords() Passed number of coordinates is lower then 3!");
				return;
			}
			
			var i:int = uv.push(rest)-1;
			
			if (faces[i])
				faces[i].setUVCoordsId(i);
		}
		
		
		public function updateNormals(p_matrix:Matrix4):void
		{
			// Recalculate all normals (correct only if this geometry is static)
			if (isStatic)
			{
				/*
					NOTE:	We don't have to recreate all normal vectors 
							as we can transform the old one according to 
							current view matrix.
				*/
				
				
				var l:int = normals.length;
				for( var i:int = 0; i<l; i++)
				{
					normals[int(i)] = faces[ uniqueDirections[ int(i)] ].createNormale();
				}
				
				/*var l:int = normals.length;
				for( var i:int = 0; i<l; i++)
				{
					normals[int(i)] = Matrix4Math.vectorMult3x3( p_matrix, normals[int(i)] );
				}*/
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
			
			// Points
			var l:int = points.length;
			for (var i:int = 0; i<l; i++)
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
}