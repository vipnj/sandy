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
package sandy.primitive 
{
	import sandy.core.data.Polygon;
	import sandy.core.data.UVCoord;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.Shape3D;

	/**
	* Plane3D
	*  
	* @author		Thomas Pfeiffer - kiroukou
	* @version		2
	* @date 		12.01.2006 
	**/
	public class Plane3D extends Shape3D implements Primitive3D
	{
		public static const XY_ALIGNED:String = "xy_aligned";
		public static const YZ_ALIGNED:String = "yz_aligned";
		public static const ZX_ALIGNED:String = "zx_aligned";
		//////////////////
		///PRIVATE VARS///
		//////////////////	
		private var _h:Number;
		private var _lg:Number;
		private var _qH:uint;
		private var _qV:uint;
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
		public function Plane3D( p_Name:String=null, h:Number = 100, lg:Number = 100, qH:uint = 1, qV:uint=1, p_sType:String = Plane3D.XY_ALIGNED, mode:String = PrimitiveMode.TRI )
		{
			super( p_Name ) ;
			_h = h;
			_lg = lg;
			_qV = qV;
			_qH = qH;
			_mode = ( mode != PrimitiveMode.TRI && mode != PrimitiveMode.QUAD ) ? PrimitiveMode.TRI : mode;
			m_sType = p_sType;
			geometry = generate() ;
		}

		/**
		* generate all is needed to construct the object. Vertex, UVCoords, Faces
		* 
		* <p>Generate the points, normales and faces of this primitive depending of tha parameters given</p>
		* <p>It can construct dynamically the object, taking care of your preferences givent in parameters. Note that for now all the faces have only three points.
		*    This point will certainly change in the future, and give to you the possibility to choose 3 or 4 points per faces</p>
		*/
		public function generate( ...arguments ):Geometry3D
		{
			var l_geometry:Geometry3D = new Geometry3D();
			//Creation of the points
			var uv1:int, uv2:int, uv3:int, uv4:int;
			var h2:Number = _h/2;
			var l2:Number = _lg/2;
			var pasH:Number = _h/_qH;
			var pasL:Number = _lg/_qV;
			
			for( var iL:Number = -l2, iTL:Number = 0; iL < l2; iL += pasL, iTL += pasL )
			{
				for( var iH:Number = -h2, iTH:Number = 0; iH < h2; iH += pasH, iTH += pasH )
				{	
					if( m_sType == Plane3D.ZX_ALIGNED )
					{
						l_geometry.setVertex( l_geometry.getNextVertexID(), iL, 0, iH );
					}
					else if( m_sType == Plane3D.YZ_ALIGNED )
					{
						l_geometry.setVertex( l_geometry.getNextVertexID(), 0, iL, iH );
					}
					else
					{
						l_geometry.setVertex( l_geometry.getNextVertexID(), iL, iH, 0 );
					}
					l_geometry.setUVCoords( l_geometry.getNextUVCoordID(), iTL/_lg, iTH/_h );
				}
			}
			
				
			for( var i:uint = 0; i < _qV-1; i++ )
			{
				for( var j:uint = 0; j < _qH-1; j++ )
				{
					//Face creation
					if( _mode == PrimitiveMode.TRI )
					{
						l_geometry.setFaceVertexIds( l_geometry.getNextFaceID(), (i*_qH)+j, (i*_qH)+j+1, (i+1)*_qH+j );
						l_geometry.setFaceUVCoordsIds( l_geometry.getNextFaceUVCoordID(), (i*_qH)+j, (i*_qH)+j+1, (i+1)*_qH+j );
						
						l_geometry.setFaceVertexIds( l_geometry.getNextFaceID(), (i*_qH)+j+1, (i+1)*_qH+j+1, (i+1)*_qH+j );
						l_geometry.setFaceUVCoordsIds( l_geometry.getNextFaceUVCoordID(), (i*_qH)+j+1, (i+1)*_qH+j+1, (i+1)*_qH+j );
					}
					else if( _mode == PrimitiveMode.QUAD )
					{
						l_geometry.setFaceVertexIds( l_geometry.getNextFaceID(), (i*_qH)+j, (i*_qH)+j+1, (i+1)*_qH+j+1, (i+1)*_qH+j );
						l_geometry.setFaceUVCoordsIds( l_geometry.getNextFaceUVCoordID(), (i*_qH)+j, (i*_qH)+j+1, (i+1)*_qH+j+1, (i+1)*_qH+j );
					}
				}
			}

			return (l_geometry);
		}
	}

}