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
import sandy.core.face.IPolygon;
import sandy.core.face.Polygon;
import sandy.core.Object3D;
import sandy.primitive.Primitive3D;

/**
* VPlane
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric 	- thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @author		Bruce Epstein 	- zeusprod
* @since		0.1
* @version		1.2.3
* @date 		03.08.2007 
**/

class sandy.primitive.Plane3D extends Object3D implements Primitive3D
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
	
	private var _mirror : Boolean; // If true, mirror the image, as was the case in old versions of Sandy 1.2 (defaults to false)
	private var _spin : Boolean; // If true, spin the UV mapping 180 degrees. (could spin the Plane3D or skin texture instead)
	
	/**
	* This is the constructor to call when you nedd to create an Vertical Plane primitive.
	* <p>This method will create a complete object with vertex, normales, texture coords and the faces.
	*    So it allows to have a custom 3D object easily </p>
	* <p>{@code h} represents the height of the Plane, {@code lg} represent its length and {@code q} the quality, so the number of parts the surface will be sliced on. The plane will be located at z coordinate set to 0</p>
	* @param 	h 	Number
	* @param 	lg 	Number
	* @param 	q 	Number Between 1 and 10
	* @param 	mode String represent the two available modes to generates the faces.
	* "tri" is necessary to have faces with 3 points, and "quad" for 4 points.
	*/
	public function Plane3D(h:Number,lg:Number,q:Number, mode:String, mirror:Boolean, spin:Boolean)
	{
		super( ) ;
		_h = (undefined == h) ? 6 : Number(h) ;
		_lg =  (undefined == lg) ?  6 : Number(lg) ;
		_q = (undefined == q || q <= 0 || q > 10) ?  1 : Number(q) ;
		_mode = ( undefined == mode || (mode != 'tri' && mode != 'quad') ) ? 'tri' : mode;
		_mirror = ( undefined == mirror ) ? false : mirror;
		_spin = ( undefined == spin ) ? false : spin;
	
		generate() ;
	}

	/**
	* generate all is needed to construct the object. Vertex, UVCoords, Faces
	* 
	* <p>Generate the points, normales and faces of this primitive depending of tha parameters given</p>
	* <p>It can construct dynamically the object, taking care of your preferences givent in parameters.</p>
	*/
	public function generate(Void):Void
	{
		//Creation of the points
		var uv1:UVCoord, uv2:UVCoord, uv3:UVCoord, uv4:UVCoord;
		var h2:Number = _h/2;
		var l2:Number = _lg/2;
		var pasH:Number = _h/_q;
		var pasL:Number = _lg/_q;
		var p:Vertex; 
		var id1:Number,id2:Number,id3:Number,id4:Number;
		var f:IPolygon;
		var i:Number = -h2;
		var created:Boolean = false;
		var n:Vector;
		do
		{
			var j:Number = -l2;
			
			do
			{
				if (_mirror) {
					
					//We add the texture coordinates
					if (_spin) {
						//trace ("Spin, mirror");
						p = new Vertex(j,0,i); id1 = aPoints.push (p) - 1;
						p = new Vertex(j+pasL,0,i); id2 = aPoints.push (p) - 1;
						p = new Vertex(j+pasL,0,i+pasH); id3 = aPoints.push (p) - 1;
						p = new Vertex(j,0,i+pasH); id4 = aPoints.push (p) - 1;
						uv4 = new UVCoord ((j+l2)/_lg,(i+h2+pasH)/_h);
						uv3 = new UVCoord ((j+l2+pasL)/_lg,(i+h2+pasH)/_h);
						uv2 = new UVCoord ((j+l2+pasL)/_lg,(i+h2)/_h);
						uv1 = new UVCoord ((j+l2)/_lg,(i+h2)/_h);
					} else {
						//trace ("no Spin, yes mirror");
						p = new Vertex(-(j+pasL),0,i); id3 = aPoints.push (p) - 1;
						p = new Vertex(-j,0,i); id4 = aPoints.push (p) - 1;
						p = new Vertex(-j,0,i+pasH); id1 = aPoints.push (p) - 1;
						p = new Vertex(-(j+pasL),0,i+pasH); id2 = aPoints.push (p) - 1;
						uv1 = new UVCoord ((j+l2)/_lg,(-i+h2-pasH)/_h);
						uv2 = new UVCoord ((j+l2+pasL)/_lg,(-i+h2-pasH)/_h);
						uv3 = new UVCoord ((j+l2+pasL)/_lg,(-i+h2)/_h);
						uv4 = new UVCoord ((j+l2)/_lg,(-i+h2)/_h);
					}
				} else {
					
					if (_spin) {
						//trace ("Spin, no mirror");
						p = new Vertex(-(j+pasL),0,i); id3 = aPoints.push (p) - 1;
						p = new Vertex(-j,0,i); id4 = aPoints.push (p) - 1;
						p = new Vertex(-j,0,i+pasH); id1 = aPoints.push (p) - 1;
						p = new Vertex(-(j+pasL),0,i+pasH); id2 = aPoints.push (p) - 1;
						uv1 = new UVCoord ((j+l2)/_lg,(i+h2+pasH)/_h);
						uv2 = new UVCoord ((j+l2+pasL)/_lg,(i+h2+pasH)/_h);
						uv3 = new UVCoord ((j+l2+pasL)/_lg,(i+h2)/_h);
						uv4 = new UVCoord ((j+l2)/_lg,(i+h2)/_h);
						
					} else {
						//trace ("No Spin, no mirror");
						
						p = new Vertex(j,0,i); id1 = aPoints.push (p) - 1;
						p = new Vertex(j+pasL,0,i); id2 = aPoints.push (p) - 1;
						p = new Vertex(j+pasL,0,i+pasH); id3 = aPoints.push (p) - 1;
						p = new Vertex(j,0,i+pasH); id4 = aPoints.push (p) - 1;
						uv1 = new UVCoord ((j+l2)/_lg,(-i+h2)/_h);
						uv2 = new UVCoord ((j+l2+pasL)/_lg,(-i+h2)/_h);
						uv3 = new UVCoord ((j+l2+pasL)/_lg,(-i+h2-pasH)/_h);
						uv4 = new UVCoord ((j+l2)/_lg,(-i+h2-pasH)/_h);
						
					}
					/*
					trace ("uv1:" + uv1.u + " : " + uv1.v);
					trace ("uv2:" +uv2.u + " : " + uv2.v);
					trace ("uv3:" +uv3.u + " : " + uv3.v);
					trace ("uv4:" +uv4.u + " : " + uv4.v);
					trace("");
					*/
				}
				//Face creation
				if( _mode == 'tri' )
				{
					f = new Polygon(this, aPoints[id1], aPoints[id2], aPoints[id4] );
					f.setUVCoords( uv1, uv2, uv4 );
					addFace( f );				
					if(!created)
					{
						n = f.createNormale ();
						aNormals.push (n );
						created = true;
					}
					else
					{
						f.setNormale (n);
					}
					
					f = new Polygon(this, aPoints[id2], aPoints[id3], aPoints[id4] );
					f.setUVCoords( uv2, uv3, uv4 );
					addFace( f );	
					f.setNormale( n );
					
				}
				else if( _mode == 'quad' )
				{
					f = new Polygon(this, aPoints[id1], aPoints[id2], aPoints[id3], aPoints[id4] );
					f.setUVCoords( uv1, uv2, uv3 );
					addFace( f );			
					
					if(!created)
					{
						n = f.createNormale ();
						
						aNormals.push (n );
						created = true;
					}
					else
					{
						f.setNormale (n);
					}
				}
			} while( (j += pasL) < (l2-1) );
			
		} while( (i += pasH) < (h2-1) );
		// Can't understand why I must compute -1 with 3 in quality to have the correct value!
	}
	
	/**
	* getSize() returns the length and height as a Vector (useful for storing an object's attributes).
	* Returns vector where x is the length, y is the height, and z is always 0.
	*/	
	public function getSize (Void):Vector {
		return new Vector (_lg, _h, 0);
	}
	
	 public function getPrimitiveName (Void):String {
		 return "Plane3D";
	 }
	 
	 public function toString (Void):String {
		 return "sandy.primitive." + getPrimitiveName();
	 }
}

