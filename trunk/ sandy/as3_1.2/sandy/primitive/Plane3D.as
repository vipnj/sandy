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
	import sandy.core.data.UVCoord;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.face.IPolygon;
	import sandy.core.face.Polygon;

	import sandy.core.scenegraph.Object3D;
	import sandy.core.scenegraph.Geometry3D;
	import sandy.primitive.Primitive3D;

	/**
	* VPlane
	*  
	* @author		Thomas Pfeiffer - kiroukou
	* @since		0.1
	* @version		0.2
	* @date 		12.01.2006 
	**/

	public class Plane3D extends Object3D implements Primitive3D
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
		public function Plane3D( p_Name:String=null, h:Number = 6, lg:Number = 6, q:Number = 1, mode:String = 'tri')
		{
			super( p_Name ) ;
			_h = h;
			_lg = lg;
			_q = (q <= 0 || q > 10) ?  1 : Number(q) ;
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
		public function generate():void
		{
			
			var l_geometry:Geometry3D = new Geometry3D();
			
					//Creation of the points
			var uv1:UVCoord, uv2:UVCoord, uv3:UVCoord, uv4:UVCoord;
			var h2:Number = _h/2;
			var l2:Number = _lg/2;
			var pasH:Number = _h/_q;
			var pasL:Number = _lg/_q;
			var p:Vertex; 
			var id1:int,id2:int,id3:int,id4:int;
			var f:IPolygon;
			var i:Number = -h2;
			var created:Boolean = false;
			var n:Vector;

			do
			{
				var j:Number = -l2;
				
				do
				{
					p = new Vertex(j,0,i); id1 = l_geometry.addPoint(p);
					p = new Vertex(j+pasL,0,i); id2 = l_geometry.addPoint(p);
					p = new Vertex(j+pasL,0,i+pasH); id3 = l_geometry.addPoint(p);
					p = new Vertex(j,0,i+pasH); id4 = l_geometry.addPoint(p);
					
					//We add the texture coordinates
					uv1 = new UVCoord ((j+l2)/_lg,(i+h2)/_h);
					uv2 = new UVCoord ((j+l2+pasL)/_lg,(i+h2)/_h);
					uv3 = new UVCoord ((j+l2+pasL)/_lg,(i+h2+pasH)/_h);
					uv4 = new UVCoord ((j+l2)/_lg,(i+h2+pasH)/_h);
					
					//Face creation
					if( _mode == 'tri' )
					{
						l_geometry.createFaceByIds(id1, id2, id4 );
						l_geometry.addUVCoords( uv1, uv2, uv4 );
						
						l_geometry.createFaceByIds(id2, id3, id4 );
						l_geometry.addUVCoords( uv2, uv3, uv4 );
					}
					else if( _mode == 'quad' )
					{
						l_geometry.createFaceByIds(id1, id2, id3, id4 );
						l_geometry.addUVCoords( uv1, uv2, uv3 );
					}
				} while( (j += pasL) < (l2-1) );
			} while( (i += pasH) < (h2-1) );
			// Can't understand why I must compute -1 with 3 in quality to have the correct value!
			
			setGeometry(l_geometry);
		}
	}

}