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

import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.face.Face;
import sandy.core.face.QuadFace3D;
import sandy.core.face.TriFace3D;
import sandy.core.Object3D;
import sandy.primitive.Primitive3D;

/**
* VPlane
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @since		0.1
* @version		0.2
* @date 		12.01.2006 
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
	public function Plane3D(h:Number,lg:Number,q:Number, mode:String)
	{
		super( ) ;
		_h = (undefined == h) ? 6 : Number(h) ;
		_lg =  (undefined == lg) ?  6 : Number(lg) ;
		_q = (undefined == q || q <= 0 || q > 10) ?  1 : Number(q) ;
		_mode = ( undefined == mode || (mode != 'tri' && mode != 'quad') ) ? 'tri' : mode;
		generate() ;
	}

	/**
	* generate all is needed to construct the object. Vertex, UVCoords, Faces
	* 
	* <p>Generate the points, normales and faces of this primitive depending of tha parameters given</p>
	* <p>It can construct dynamically the object, taking care of your preferences givent in parameters. Note that for now all the faces have only three points.
	*    This point will certainly change in the future, and give to you the possibility to choose 3 or 4 points per faces</p>
	*/
	public function generate(Void):Void
	{
		//Creation of the points
		var h2:Number = _h/2;
		var l2:Number = _lg/2;
		var pasH:Number = _h/_q;
		var pasL:Number = _lg/_q;
		var p:Vertex; 
		var id1:Number,id2:Number,id3:Number,id4:Number;
		var f:Face;
		var i:Number = -h2;
		var created:Boolean = false;
		var n:Vector;
		do
		{
			var j:Number = -l2;
			do
			{
				p = new Vertex(j,0,i); id1 = aPoints.push (p) - 1;
				p = new Vertex(j+pasL,0,i); id2 = aPoints.push (p) - 1;
				p = new Vertex(j+pasL,0,i+pasH); id3 = aPoints.push (p) - 1;
				p = new Vertex(j,0,i+pasH); id4 = aPoints.push (p) - 1;
				//We add the texture coordinates
				addUVCoordinate ((j+l2)/_lg,(i+h2)/_h);
				addUVCoordinate ((j+l2+pasL)/_lg,(i+h2)/_h);
				addUVCoordinate ((j+l2+pasL)/_lg,(i+h2+pasH)/_h);
				addUVCoordinate ((j+l2)/_lg,(i+h2+pasH)/_h);
				//Face creation
				if( _mode == 'tri' )
				{
					f = new TriFace3D(this, aPoints[id1], aPoints[id4], aPoints[id2] );
					f.setUVCoordinates( _aUv[id1], _aUv[id4], _aUv[id2] );
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
					
					f = new TriFace3D(this, aPoints[id4], aPoints[id3], aPoints[id2] );
					f.setUVCoordinates( _aUv[id4], _aUv[id3], _aUv[id2] );
					addFace( f );	
					f.setNormale( n );
					
				}
				else if( _mode == 'quad' )
				{
					f = new QuadFace3D(this, aPoints[id1], aPoints[id4], aPoints[id3], aPoints[id2] );
					f.setUVCoordinates( _aUv[id1], _aUv[id4], _aUv[id3], _aUv[id2] );
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
}

