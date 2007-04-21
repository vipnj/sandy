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

import sandy.core.data.Vertex;
import sandy.core.data.Vector;
import sandy.core.data.UVCoord;
import sandy.core.Object3D;
import sandy.primitive.Primitive3D;
import sandy.core.face.IPolygon;
import sandy.core.face.Polygon;
import sandy.skin.Skin;

/**
* Box
*
* <p>Box is a primitiv Object3D, to easy build a Cube/Box.</p>
* 
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		12.07.2006 
**/
class sandy.primitive.Box extends Object3D implements Primitive3D
{
	/**
	* Constructor
	*
	* <p>This is the constructor to call when you nedd to create a Box primitiv.</p>
	*
	* <p>This method will create a complete object with vertex,
	*    normales, texture coords and the faces.
	*    So it allows to have a custom 3D object easily</p>
	*
	* @param rad a Number represent the wide of the Box
	* @param h a Number represent the height of the Box
	* @param lg a Number represent the depth of the Box
	* @param mode String represent the two available modes to generates the faces.
	* "tri" is necessary to have faces with 3 points, and "quad" for 4 points.
	*/
	public function Box ( rad : Number,h : Number, lg : Number, mode:String, quality:Number )
	{
		super ();
		_h = (h === undefined) ? 6 : h ;
		_lg = (lg === undefined) ? 6 : lg ;
		_radius = (rad === undefined) ? 100 : rad ;
		_q = (undefined == quality || quality <= 0 || quality > 10) ?  1 : int(quality) ;
		_mode = ( undefined == mode || (mode != 'tri' && mode != 'quad') ) ? 'tri' : mode;
		generate ();
	}
	
	/**
	* generate
	* 
	* <p>Generate all is needed to construct the Object3D : </p>
	* <ul>
	* 	<li>{@link Vertex}</li>
	* 	<li>{@link UVCoords}</li>
	* 	<li>{@link TriFace3D}</li>
	* </ul>
	* <p>It can construct dynamically the object, taking care of your preferences given in arguments. <br/>
	*    Note in Sandy 0.1 all faces have only three points.
	*    This will change in the future version, 
	*    and give to you the possibility to choose n points per faces</p> 
	*/
	public function generate ( Void ) : Void
	{
		// initialisation
		aPoints = []; aNormals = []; aFaces = [];		
		//we build points
		var h2 : Number = - _h / 2;
		var r2 : Number = _radius / 2;
		var l2 : Number = _lg / 2;
		var p0 : Vertex = new Vertex (-r2,-h2,l2);
		aPoints.push (p0);
		var p1 : Vertex = new Vertex (r2,-h2,l2);
		aPoints.push (p1);
		var p2 : Vertex = new Vertex (r2,h2,l2);
		aPoints.push (p2);
		var p3 : Vertex = new Vertex (-r2,h2,l2);
		aPoints.push (p3);
		var p4 : Vertex = new Vertex (-r2,-h2,-l2);
		aPoints.push (p4);
		var p5 : Vertex = new Vertex (r2,-h2,-l2);
		aPoints.push (p5);
		var p6 : Vertex = new Vertex (r2,h2,-l2);
		aPoints.push (p6);
		var p7 : Vertex = new Vertex (-r2,h2,-l2);
		aPoints.push (p7);
		// -- we setup texture coordinates
		var uv0:UVCoord = new UVCoord (0, 0);
		var uv1:UVCoord = new UVCoord (1, 0);
		var uv2:UVCoord = new UVCoord (0, 1);
		var uv3:UVCoord = new UVCoord (1, 1);
		// -- Faces creation

		//Front Face
		__tesselate(p4, p7, p6, p5,
					uv0, uv2, uv3, uv1,
					_q - 1 );

		//Right Face
		__tesselate(p1, p5, p6, p2,
					uv1, uv0, uv2, uv3,
					_q - 1 );
					
		//Back Face
		__tesselate(p0, p1, p2, p3,
					uv1, uv0, uv2, uv3,
					_q - 1 );

		//Left Face
		__tesselate(p0, p3, p7, p4,
					uv0, uv2, uv3, uv1,
					_q - 1 );
					
		//Bottom Face
		__tesselate(p2, p6, p7, p3,
					uv3, uv1, uv0, uv2,
					_q - 1 );
					
		//Top Face
		__tesselate(p0, p4, p5, p1,
					uv0, uv2, uv3, uv1,
					_q - 1 );	
	}	
	
	private function __tesselate( 	p0:Vertex, p1:Vertex, p2:Vertex, p3:Vertex,
									uv0:UVCoord, uv1:UVCoord, uv2:UVCoord, uv3:UVCoord,
									level:Number):Void
	{
		var f:IPolygon;
		if(level == 0 ) // End of recurssion
		{
			// -- We have the same normal for 2 faces, be careful to don't add extra normal
			if( _mode == 'tri' )
			{
				//Front Face
				f = new Polygon( this, p0, p1, p3 );
				f.setUVCoords( uv0, uv1, uv3 );
				addFace( f );
				f = new Polygon( this, p2, p3, p1 );
				f.setUVCoords( uv2, uv3, uv1 );
				addFace( f );
			}
			else if( _mode == 'quad' )
			{
				//Front Face
				f = new Polygon( this, p0, p1, p2, p3 );
				f.setUVCoords( uv0, uv1, uv2 );
				addFace( f );
			}
			
		}
		else
		{
			//milieu de p0, p1;
			var m01:Vertex = new Vertex( (p0.x+p1.x)/2, (p0.y+p1.y)/2, (p0.z+p1.z)/2 );
			// milieu de p1 p2
			var m12:Vertex = new Vertex( (p1.x+p2.x)/2, (p1.y+p2.y)/2, (p1.z+p2.z)/2 );
			// milieu de p2 p3
			var m23:Vertex = new Vertex( (p2.x+p3.x)/2, (p2.y+p3.y)/2, (p2.z+p3.z)/2 );
			// milieu de p3 p0
			var m30:Vertex = new Vertex( (p3.x+p0.x)/2, (p3.y+p0.y)/2, (p3.z+p0.z)/2 );
			// milieu tout court
			var center:Vertex = new Vertex( (p0.x+p1.x+p2.x+p3.x)/4, (p0.y+p1.y+p2.y+p3.y)/4, (p0.z+p1.z+p2.z+p3.z)/4 );
			aPoints.push ( m01, m12, m23, m30, center );
			
			//milieu de p0, p1;
			var uv01:UVCoord = new UVCoord ((uv0.u+uv1.u)/2, (uv0.v+uv1.v)/2);
			// milieu de p1 p2
			var uv12:UVCoord = new UVCoord ( (uv1.u+uv2.u)/2, (uv1.v+uv2.v)/2 );
			// milieu de p2 p3
			var uv23:UVCoord = new UVCoord ( (uv2.u+uv3.u)/2, (uv2.v+uv3.v)/2 );
			// milieu de p3 p0
			var uv30:UVCoord = new UVCoord ( (uv3.u+uv0.u)/2, (uv3.v+uv0.v)/2 );
			// milieu tout court
			var uvcenter:UVCoord = new UVCoord ( (uv0.u+uv1.u+uv2.u+uv3.u)/4, (uv0.v+uv1.v+uv2.v+uv3.v)/4);
			
			
			__tesselate(center, m30, p0, m01,
						uvcenter, uv30, uv0, uv01,
						level - 1 );
			__tesselate(center, m01, p1, m12,
						uvcenter, uv01, uv1, uv12,
						level - 1 );
			
			__tesselate(center, m12, p2, m23,
						uvcenter, uv12, uv2, uv23,
						level - 1 );
			
			__tesselate(center, m23, p3, m30,
						uvcenter, uv23, uv3, uv30,
						level - 1 );
			
		}
	}
	
	/**
	 * Set skins per side. 
	 * @param skins	Array of 6 skins to be applied in this order : front, right, back, left, bottom, top	 */
	public function setSkins(skins:Array)
	{
		var l:Number = aFaces.length;
		var facesPerSide:Number = l / 6;
		
		for(var n=0;n<l;n++)
		{
			var skinIndex:Number = Math.floor(n / facesPerSide);
			var skin:Skin = skins[skinIndex];
			aFaces[n].setSkin(skin);
		}
		_needRedraw = true;
	}

	/**
	* getSize() returns the length, height, and radius as a Vector (useful for storing an object's attributes).
	* Returns vector where x is the length, y is the height, and z is the radius
	*/	
	public function getSize (Void):Vector 
	{
		return new Vector (_lg, _h, _radius);
	}
	 
	public function getNumSurfaces (Void):Number 
	{
		return  _numSurfaces;
	}
	 
	public function getPrimitiveName (Void):String 
	{
		return "Box";
	}
	 
	public function toString (Void):String 
	{
		return "sandy.primitive." + getPrimitiveName();
	}
	 	
	/**
	* height of the Box
	*/ 
	private var _h	: Number;

	/**
	* depth of the Box
	*/ 
	private var _lg : Number;

	/**
	* wide of the Box
	*/ 
	private var _radius : Number ;
	
	private var _numSurfaces:Number = 6;  // Six surfaces per cube. Differs from polygons/faces.
	
	private var _q:Number;
	
	/*
	 * Mode with 3 or 4 points per face
	 */
	 private var _mode : String;
}