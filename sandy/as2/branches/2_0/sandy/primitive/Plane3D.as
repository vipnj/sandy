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

import sandy.core.data.UVCoord;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.face.Polygon;

import sandy.core.scenegraph.Shape3D;
import sandy.core.scenegraph.Geometry3D;
import sandy.primitive.Primitive3D;

	/**
	* Plane3D
	*  
	* @author		Thomas Pfeiffer - kiroukou
	* @author		Bruce Epstein 	- zeusprod
	* @since		0.1
	* @version		2.0
	* @date 		07.05.2007 
	**/

class sandy.primitive.Plane3D extends Shape3D implements Primitive3D
	{
		//////////////////
		///PRIVATE VARS///
		//////////////////	
		private var _h:Number;
		private var _lg:Number;
		private var _q:Number;
		/*
		 * Mode with 3 or 4 points per face
		 */
		private var _mode : String;
		
		/**
		* This is the constructor to call when you nedd to create an Vertical Plane primitive.
		* <p>This method will create a complete object with vertex, normales, texture coords and the faces.
		*    So it allows to have a custom 3D object easily </p>
		* <p>{@code h} represents the height of the Plane, {@code lg} represent its length and {@code q} the quality, so the number of parts the surface will be sliced on. The plane will be located at z coordinate set to 0</p>
		* @param 	w 	Number
		* @param 	lg 	Number
		* @param 	q 	Number Between 1 and 10
		* @param 	mode String represent the two available modes to generates the faces.
		* "tri" is necessary to have faces with 3 points, and "quad" for 4 points.
		*/
		public function Plane3D( p_Name:String, h:Number, lg:Number, q:Number, mode:String)
		{
			//if (p_Name == undefined) 	{p_Name = null};
			super( p_Name ) ;
			_h  = (h == undefined) ? 6 : h;
			_lg = (lg == undefined) ? 6 : lg;
			_q  = (q <= 0 || q > 10) ?  1 : Number(q) ;
			_mode = ( mode != 'tri' && mode != 'quad' ) ? 'tri' : mode;
			generate() ;
		}

		/**
		* generate all is needed to construct the object. Vertex, UVCoords, Faces
		* 
		* <p>Generate the points, normales and faces of this primitive depending of tha parameters given</p>
		* <p>It can construct dynamically the object, taking care of your preferences givent in parameters. Note that for now all the faces have only three points.
		*    This point will certainly change in the future, and give to you the possibility to choose 3 or 4 points per faces</p>
		*/
		public function generate():Geometry3D
		{
			//Creation of the points
			var h2:Number = _h/2;
			var l2:Number = _lg/2;
			var pasH:Number = _h/_q;
			var pasL:Number = _lg/_q;
			var i:Number = -h2;
			var created:Boolean = false;
			var n:Vector;

			var l_geometry:Geometry3D = new Geometry3D();
			
			do
			{
				var j:Number = -l2;
				
				do
				{
					l_geometry.setVertex(0, j,		0, i); 
					l_geometry.setVertex(1, j+pasL,	0, i); 
					l_geometry.setVertex(2, j+pasL,	0, i+pasH);
					l_geometry.setVertex(3, j,		0, i+pasH);
					
					//We add the texture coordinates
					l_geometry.setUVCoords(0, (j+l2)/_lg,		(i+h2)/_h);
					l_geometry.setUVCoords(1, (j+l2+pasL)/_lg,	(i+h2)/_h);
					l_geometry.setUVCoords(2, (j+l2+pasL)/_lg,	(i+h2+pasH)/_h);
					l_geometry.setUVCoords(3, (j+l2)/_lg,		(i+h2+pasH)/_h);
					
					//Face creation
					if( _mode == 'tri' )
					{
						l_geometry.setFaceVertexIds  (0, 0, 1, 3 );
						l_geometry.setFaceUVCoordsIds(0, 0, 1, 3 );
						
						l_geometry.setFaceVertexIds  (1, 1, 2, 3 );
						l_geometry.setFaceUVCoordsIds(1, 1, 2, 3 );
					}
					else if( _mode == 'quad' )
					{
						l_geometry.setFaceVertexIds  (0, 0, 1, 2, 3 );
						l_geometry.setFaceUVCoordsIds(0, 0, 1, 2 );
					}
				} while( (j += pasL) < (l2-1) );
			} while( (i += pasH) < (h2-1) );
			// Can't understand why I must compute -1 with 3 in quality to have the correct value!
			
			return l_geometry;
		}
	}