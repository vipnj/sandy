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

import com.bourre.log.Logger;

import sandy.core.data.Vector;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.primitive.Primitive3D;
import sandy.primitive.PrimitiveMode;

	/**
	* Plane3D
	*  
	* @author		Thomas Pfeiffer - kiroukou
	* @version		2
	* @date 		12.01.2006 
	**/
	class sandy.primitive.Plane3D extends Shape3D implements Primitive3D
	{
		public static var XY_ALIGNED:String = "xy_aligned";
		public static var YZ_ALIGNED:String = "yz_aligned";
		public static var XZ_ALIGNED:String = "xz_aligned";
		//////////////////
		///PRIVATE VARS///
		//////////////////	
		private var _h:Number;
		private var _lg:Number;
		private var _q:Number;
		private var m_sType:String;
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
		public function Plane3D( p_Name:String, h:Number, lg:Number, q:Number, p_sType:String, mode:String )
		{
			super( p_Name ) ;
			_h = h||6;
			_lg = lg||6;
			_q = q||1;
			_mode = ( mode != PrimitiveMode.TRI && mode != PrimitiveMode.QUAD ) ? PrimitiveMode.TRI : mode;
			m_sType = p_sType||Plane3D.XY_ALIGNED;
			geometry = generate() ;
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
			var l_geometry:Geometry3D = new Geometry3D();
			//Creation of the points
			var uv1:Number, uv2:Number, uv3:Number, uv4:Number;
			var h2:Number = _h/2;
			var l2:Number = _lg/2;
			var pasH:Number = _h/_q;
			var pasL:Number = _lg/_q;
			var id1:Number,id2:Number,id3:Number,id4:Number;
			var i:Number = -h2;
			var created:Boolean = false;
			var n:Vector;
			// --
			do
			{
				var j:Number = -l2;
				do
				{
					if( m_sType == Plane3D.XZ_ALIGNED )
					{
						id1 = l_geometry.setVertex( l_geometry.getNextVertexID(), j, 0, i );
						id2 = l_geometry.setVertex( l_geometry.getNextVertexID(), j+pasL, 0, i ); 
						id3 = l_geometry.setVertex( l_geometry.getNextVertexID(), j+pasL, 0, i+pasH );
						id4 = l_geometry.setVertex( l_geometry.getNextVertexID(), j, 0, i+pasH );
					}
					else if( m_sType == Plane3D.YZ_ALIGNED )
					{
						id1 = l_geometry.setVertex( l_geometry.getNextVertexID(), j, i, 0 );
						id2 = l_geometry.setVertex( l_geometry.getNextVertexID(), j+pasL, i, 0 ); 
						id3 = l_geometry.setVertex( l_geometry.getNextVertexID(), j+pasL, i+pasH, 0 );
						id4 = l_geometry.setVertex( l_geometry.getNextVertexID(), j, i+pasH, 0 );
					}
					else
					{
						id1 = l_geometry.setVertex( l_geometry.getNextVertexID(), 0, j, i );
						id2 = l_geometry.setVertex( l_geometry.getNextVertexID(), 0, j+pasL, i ); 
						id3 = l_geometry.setVertex( l_geometry.getNextVertexID(), 0, j+pasL, i+pasH);
						id4 = l_geometry.setVertex( l_geometry.getNextVertexID(), 0, j, i+pasH);
					}
					
					//We add the texture coordinates
					uv1 = l_geometry.setUVCoords( l_geometry.getNextUVCoordID(), (j+l2)/_lg, 1-(i+h2)/_h );
					uv2 = l_geometry.setUVCoords( l_geometry.getNextUVCoordID(), (j+l2+pasL)/_lg, 1-(i+h2)/_h);
					uv3 = l_geometry.setUVCoords( l_geometry.getNextUVCoordID(), (j+l2+pasL)/_lg, 1-(i+h2+pasH)/_h);
					uv4 = l_geometry.setUVCoords( l_geometry.getNextUVCoordID(), (j+l2)/_lg, 1-(i+h2+pasH)/_h);
					
					//Face creation
					if( _mode == PrimitiveMode.TRI )
					{
						l_geometry.setFaceVertexIds( l_geometry.getNextFaceID(), id1, id2, id4 );
						l_geometry.setFaceUVCoordsIds( l_geometry.getNextFaceUVCoordID(), uv1, uv2, uv4 );
						
						l_geometry.setFaceVertexIds( l_geometry.getNextFaceID(), id2, id3, id4 );
						l_geometry.setFaceUVCoordsIds( l_geometry.getNextFaceUVCoordID(), uv2, uv3, uv4 );
					}
					else if( _mode == PrimitiveMode.QUAD )
					{
						l_geometry.setFaceVertexIds( l_geometry.getNextFaceID(), id1, id2, id3, id4 );
						l_geometry.setFaceUVCoordsIds( l_geometry.getNextFaceUVCoordID(), uv1, uv2, uv3 );
					}
				} while( (j += pasL) < (l2-1) );
			} while( (i += pasH) < (h2-1) );
			// Can't understand why I must compute -1 with 3 in quality to have the correct value!
			
			return (l_geometry);
		}
	}