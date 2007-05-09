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

	import sandy.core.scenegraph.Shape3D;
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.face.Polygon;
	import sandy.primitive.Primitive3D;
	import sandy.core.data.Vertex;
	import sandy.core.data.UVCoord;
	import sandy.core.data.Vector;

	/**
	* Pyramid
	*
	* @author		Thomas Pfeiffer - kiroukou
	* @author		Tabin Cédric - thecaptain
	* @author		Nicolas Coevoet - [ NikO ]
	* @author		Bruce Epstein 	- zeusprod
	* @since		1.0
	* @version		2.0
	* @date 		07.05.2007 
	**/
class sandy.primitive.Pyramid extends Shape3D implements Primitive3D
	{
		//////////////////
		///PRIVATE VARS///
		//////////////////	
		private var _h:Number;
		private var _lg:Number;
		private var _radius:Number ;

		/**
		* This is the constructor to call when you nedd to create a Pyramid primitive.
		* <p>This method will create a complete object with vertex, normales, texture coords and the faces.
		*    So it allows to have a custom 3D object easily </p>
		* <p>{@code h} represents the height of the Pyramid, {@code lg} represent its length(or depth) and {@code rad} its radius(or wide)</p>
		* @param h Number
		* @param lg Number
		* @param rad Number
		*/
		public function Pyramid (h:Number, lg:Number, rad:Number)
		{
			super ();
		_radius =(undefined == rad	) ?  100 :  rad ;
		_h = (undefined == h	) ? 6 :  h ;
		_lg =(undefined == lg	) ? 6 :  lg ;
			generate ();
		}
		
		/**
		* generate all is needed to construct the object. Vertex, UVCoords, Faces
		* 
		* <p>Generate the points, normales and faces of this primitive depending of tha parameters given</p>
		* <p>It can construct dynamically the object, taking care of your preferences givent in parameters. Note that for now all the faces have only three points.
		*    This point will certainly change in the future, and give to you the possibility to choose 3 or 4 points per faces</p>
		*/
	public function generate () : Geometry3D
		{
			
			// initialization
			var l_geometry:Geometry3D = new Geometry3D();
			
			var f:Polygon;
			//Creation des points
			_h = -_h;
			var r2:Number = _radius/2;
			var l2:Number = _lg/2;
			var h2:Number = _h/2;
			/*
			3-----2
			  \ 4  \
			   0-----1
			*/
			var l_nID0:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID0, -r2, 0, l2 );

			var l_nID1:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID1, r2, 0, l2 );

			var l_nID2:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID2, r2, 0, -l2 );

			var l_nID3:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID3, -r2, 0, -l2 );

			var l_nID4:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID4, 0, h2, 0 );
			
			l_geometry.setUVCoords( 0, 0,		0.5);	//0
			l_geometry.setUVCoords( 1, 0.33,	0.5);	//1
			l_geometry.setUVCoords( 2, 0.66,	0.5);	//2
			l_geometry.setUVCoords( 3, 1,		0.5);	//3
			l_geometry.setUVCoords( 3, 1,		1);		//4
			   
			//Creation des faces
			//Face avant
			l_geometry.setFaceVertexIds  ( l_geometry.aFacesVertexID.length,   0, 1, 4 );
			l_geometry.setFaceUVCoordsIds( l_geometry.aFacesUVCoordsID.length, 0, 1, 4 );
			
			//Face derriere
			l_geometry.setFaceVertexIds  ( l_geometry.aFacesVertexID.length,   3, 2, 0 );
			l_geometry.setFaceUVCoordsIds( l_geometry.aFacesUVCoordsID.length, 3, 2, 0 );
			
			l_geometry.setFaceVertexIds  ( l_geometry.aFacesVertexID.length,   0, 2, 1 );
			l_geometry.setFaceUVCoordsIds( l_geometry.aFacesUVCoordsID.length, 0, 2, 1 );
			
			//Face gauche
			l_geometry.setFaceVertexIds  ( l_geometry.aFacesVertexID.length,   4, 3, 0 );
			l_geometry.setFaceUVCoordsIds( l_geometry.aFacesUVCoordsID.length, 4, 3, 0 );
			
			//Face droite
			l_geometry.setFaceVertexIds  ( l_geometry.aFacesVertexID.length,   3, 4, 2 );
			l_geometry.setFaceUVCoordsIds( l_geometry.aFacesUVCoordsID.length, 3, 4, 2 );
			
			l_geometry.setFaceVertexIds  ( l_geometry.aFacesVertexID.length,   4, 1, 2 );
			l_geometry.setFaceUVCoordsIds( l_geometry.aFacesUVCoordsID.length, 4, 1, 2 );
			
			return l_geometry; 
		}
	/**
	* getSize() returns the length, height, and radius as a Vector (useful for storing an object's attributes).
	* Returns vector where x is the length, y is the height, and z is the radius
	*/	
	public function getSize (Void):Vector {
		return new Vector (_lg, _h, _radius);
	}
	
	/**
	* getPrimitiveName() returns the string "Pyramid"
	*/	
	 public function getPrimitiveName (Void):String {
		 return "Pyramid";
	 }
	 
	 public function toString (Void):String {
		 return "sandy.primitive." + getPrimitiveName();
	 }
	 
	  public function getNumSurfaces (Void):Number {
		return  _numSurfaces;
	}
	 private var _numSurfaces:Number = 5;  // Five surfaces per pyramid. Differs from polygons/faces.
}