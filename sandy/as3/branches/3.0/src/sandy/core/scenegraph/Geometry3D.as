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

package sandy.core.scenegraph 
{
	import flash.utils.Dictionary;
	
	import sandy.core.data.Vertex;
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
	
	public final class Geometry3D
	{	
	// ______
	// PUBLIC________________________________________________________	
		
		/** Array of vertex */
		public var aVertex:Dictionary;
		/** Array of faces composed from vertices */
		public var aFacesVertexID:Dictionary;
		public var aFacesUVCoordsID:Dictionary;
		/** Normals */
		public var aFacesNormals:Dictionary;
		public var aVertexNormals:Dictionary;
		/** UV Coords for faces */
		public var aUVCoords:Dictionary;	
		
		private var m_nLastVertexId:int = 0;
		private var m_nLastNormalId:int = 0;
		private var m_nLastFaceId:int = 0;
		private var m_nLastFaceUVId:int = 0;
		private var m_nLastUVId:int = 0;
		private var m_nLastVertexNormalId:int = 0;
	// ___________
	// CONSTRUCTOR___________________________________________________
		
		/**
		 * 	Creates new 3D geometry.
		 * 
		 */
		public function Geometry3D(p_points:Array=null)
		{
			init();
		}
		
		public function init():void
		{
			aVertex = new Dictionary();
			aFacesVertexID = new Dictionary();
			aFacesNormals = new Dictionary();
			aFacesUVCoordsID = new Dictionary();
			aVertexNormals = new Dictionary();
			aUVCoords = new Dictionary();
		}
		
		/**
		 * 	Add new point formed from passed coordinates at the specified index of the vertex list.
		 * 
		 * @param	p_x
		 * @param	p_y
		 * @param	p_z
		 */
		public function setVertex( p_nVertexID:Number, p_nX:Number, p_nY:Number, p_nZ:Number ):Number
		{
			if( aVertex[p_nVertexID] )
				return -1;
			else
			{ 
				aVertex[p_nVertexID] = new Vertex(p_nX, p_nY, p_nZ); 
				return ++m_nLastVertexId - 1;  
			}
		}
		
		/**
		 * Returns the next vertex id you can give for setVertex
		 */
		public function getNextVertexID():Number
		{
			return m_nLastVertexId;
		}	
	
		/**
		 * 	Add new point formed from passed coordinates at the specified index of the face normal list.
		 * 
		 * @param	p_x
		 * @param	p_y
		 * @param	p_z
		 */
		public function setFaceNormal( p_nNormalID:Number, p_nX:Number, p_nY:Number, p_nZ:Number ):Number
		{
			if( aFacesNormals[p_nNormalID] )
				return -1;
			else
			{ 
				aFacesNormals[p_nNormalID] = new Vertex(p_nX, p_nY, p_nZ); 
				return ++m_nLastNormalId - 1; 
			}
		}
	
		/**
		 * Returns the next vertex id you can give for setVertex
		 */
		public function getNextFaceNormalID():Number
		{
			return m_nLastNormalId;
		}
			
		/**
		 * 	Add new point formed from passed coordinates at the specified index of the vertex normal list.
		 * 
		 * @param	p_x
		 * @param	p_y
		 * @param	p_z
		 */
		public function setVertexNormal( p_nNormalID:Number, p_nX:Number, p_nY:Number, p_nZ:Number ):Number
		{
			if( aVertexNormals[p_nNormalID] )
				return -1;
			else
			{ 
				aVertexNormals[p_nNormalID] = new Vertex(p_nX, p_nY, p_nZ); 
				return ++m_nLastNormalId - 1;  
			}
		}
		
		/**
		 * Returns the next vertex id you can give for setVertex
		 */
		public function getNextVertexNormalID():Number
		{
			return m_nLastNormalId;
		}
		
		/**
		 * set the face vertex ID's from the 
		 * @param	...rest an array of data containing the ID's of the vertex list representing the face
		 * @return true is the face has been created, false if the faces already exist
		 */
		public function setFaceVertexIds( p_nFaceID:Number, ... arguments ):Number
		{
			if( aFacesVertexID[p_nFaceID] )
			{
				return -1;
			}
			else
			{
				var rest:Array = (arguments[0] is Array)? arguments[0]: arguments.splice(0);
				aFacesVertexID[p_nFaceID] = rest;
				return ++m_nLastFaceId - 1; 
			}
		}
	
		/**
		 * Returns the next vertex id you can give for setVertex
		 */
		public function getNextFaceID():Number
		{
			return m_nLastFaceId;
		}
		
		/**
		 * set the face vertex ID's from the 
		 * @param	...rest an array of data containing the ID's of the vertex list representing the face
		 * @return true is the face has been created, false if the faces already exist
		 */
		public function setFaceUVCoordsIds( p_nFaceID:Number, ... arguments /* Arguments */ ):Number
		{
			if( aFacesUVCoordsID[p_nFaceID] )
			{
				return -1;
			}
			else
			{
				var rest:Array = (arguments[0] is Array)? arguments[0]: arguments.splice(0);
				aFacesUVCoordsID[p_nFaceID] = rest;
				return ++m_nLastFaceUVId - 1; 
			}
		}
			
		/**
		 * Returns the next vertex id you can give for setVertex
		 */
		public function getNextFaceUVCoordID():Number
		{
			return m_nLastFaceUVId;
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
		public function setUVCoords( p_nID:Number, p_UValue:Number, p_nVValue:Number ):Number
		{
			if ( aUVCoords[p_nID] )
			{
				return -1;
			}
			else
			{
				aUVCoords[p_nID] = new UVCoord( p_UValue, p_nVValue );
				return ++m_nLastUVId - 1; 
			}
		}
	
		/**
		 * Returns the next vertex id you can give for setVertex
		 */
		public function getNextUVCoordID():Number
		{
			return m_nLastUVId;
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
			var i:uint = 0, l_oVertex:Vertex;
			// Points
			for each( l_oVertex in aVertex )
			{
				l_result.aVertex[i] = l_oVertex.clone();
				i++;
			}
			
			// Faces
			i = 0;
			for each( var a:Array in aFacesVertexID )
			{
				l_result.aFacesVertexID[i] = a.concat();
				i++;
			}
			
			// Normals
			i = 0;
			for each( l_oVertex in aVertex )
			{
				l_result.aFacesNormals[i] = l_oVertex.clone();
				i++;
			}
			
			// Normals
			i = 0;
			for each( l_oVertex in aVertexNormals )
			{
				l_result.aVertexNormals[i] = l_oVertex.clone();
				i++;
			}
			
			// UVs face
			i = 0;
			for each( var b:Array in aFacesUVCoordsID )
			{
				l_result.aFacesUVCoordsID[i] = b.concat();
				i++;
			}
			
			// UVs coords
			i = 0;
			for each( var u:UVCoord in aUVCoords )
			{
				l_result.aUVCoords[i] = u.clone();
				i++;
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
}
