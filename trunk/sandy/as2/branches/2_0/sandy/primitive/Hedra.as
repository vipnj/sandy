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


import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.primitive.Primitive3D;

	
	/**
	* Hedra
	*
	* @author		Thomas Pfeiffer - kiroukou
	* @version		2.0
	* @date 		20.04.2007 
	**/
	class sandy.primitive.Hedra extends Shape3D implements Primitive3D
	{
		//////////////////
		///PRIVATE VARS///
		//////////////////	
		private var _h:Number;
		private var _lg:Number;
		private var _radius:Number ;

		/**
		* This is the constructor to call when you nedd to create an Hedra primitive.
		* <p>This method will create a complete object with vertex, normales, texture coords and the faces.
		*    So it allows to have a custom 3D object easily </p>
		* <p>{@code h} represents the height of the Hedra, {@code lg} represent its length and {@code rad} its radius </p>
		* @param 	h	Number
		* @param 	lg	Number
		* @param 	rad Number
		*/	
		public function Hedra ( p_sName:String, p_nH : Number, p_nLg : Number, p_nRad : Number )
		{
			super (p_sName);
			_radius = (p_nRad)?p_nRad:100;
			_h = (p_nH)?p_nH:6 ;
			_lg = (p_nLg)?p_nLg:6;
			geometry = generate ();
		}
		
		/**
		* generate all is needed to construct the object. Vertex, UVCoords, Faces
		* 
		* <p>Generate the points, normales and faces of this primitive depending of tha parameters given</p>
		* <p>It can construct dynamically the object, taking care of your preferences givent in parameters. Note that for now all the faces have only three points.
		*    This point will certainly change in the future, and give to you the possibility to choose 3 or 4 points per faces</p>
		*/ 
		public function generate ():Geometry3D
		{
			var l_oGeometry3D:Geometry3D = new Geometry3D();
			//Creation des points
			_h = -_h;
			var r2:Number = _radius / 2;
			var l2:Number = _lg / 2;
			var h2:Number = _h / 2;
			/*
			3-----2
			 \ 4&5 \
			  0-----1
			*/
			l_oGeometry3D.setVertex(0, -r2 , 0  , l2 );
			l_oGeometry3D.setVertex(1,r2 , 0  , l2 );
			l_oGeometry3D.setVertex(2, r2 , 0  , -l2 );
			l_oGeometry3D.setVertex(3,-r2 , 0  , -l2 );
			l_oGeometry3D.setVertex(4, 0 , h2  , 0 );
			l_oGeometry3D.setVertex(5, 0 , -h2  , 0 );
			
			l_oGeometry3D.setUVCoords(0, 0, 0.5);//0
			l_oGeometry3D.setUVCoords(1, 0.33, 0.5);//1
			l_oGeometry3D.setUVCoords(2, 0.66, 0.5);//2
			l_oGeometry3D.setUVCoords(3, 1, 0.5);//3
			l_oGeometry3D.setUVCoords(4, 1, 1);
			l_oGeometry3D.setUVCoords(5, 0, 0);

			//Creation des faces
			//Face avant
			l_oGeometry3D.setFaceVertexIds( 0, 0, 1, 4 );
			l_oGeometry3D.setFaceUVCoordsIds(0, 0, 1, 4 );
	
			//Face derriere
			l_oGeometry3D.setFaceVertexIds( 1, 3, 4, 2 );
			l_oGeometry3D.setFaceUVCoordsIds( 1, 3, 4, 2 );
			
			l_oGeometry3D.setFaceVertexIds( 2, 1, 5, 2 );
			l_oGeometry3D.setFaceUVCoordsIds( 2, 1, 5, 2 );
			//Face gauche
			l_oGeometry3D.setFaceVertexIds( 3, 4, 3, 0 );
			l_oGeometry3D.setFaceUVCoordsIds( 3, 4, 3, 0 );
			//Face droite
			l_oGeometry3D.setFaceVertexIds( 4, 4, 1, 2 );
			l_oGeometry3D.setFaceUVCoordsIds( 4, 4, 1, 2 );
			
			l_oGeometry3D.setFaceVertexIds( 5, 0, 5, 1 );
			l_oGeometry3D.setFaceUVCoordsIds( 5, 0, 5, 1 );
			
			l_oGeometry3D.setFaceVertexIds( 6, 3, 2, 5 );
			l_oGeometry3D.setFaceUVCoordsIds( 6, 3, 2, 5 );
			
			l_oGeometry3D.setFaceVertexIds( 7, 0, 3, 5 );
			l_oGeometry3D.setFaceUVCoordsIds( 7, 0, 3, 5 );
			
			
			return l_oGeometry3D;

		}
	}