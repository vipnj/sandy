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
import sandy.core.face.Polygon;
import sandy.core.Object3D;
import sandy.primitive.Primitive3D;
import sandy.core.data.UVCoord;
import sandy.util.NumberUtil;

/**
* CylSurface
* A cylindrically curved surface 
* @author		Bertil Gralvik 	- Petit
* @author		Bruce Epstein	- zeusprod
* Devleoped from the ideas in Plane3D by
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric 	- thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @since		1.2.1
* @version		0.6
* @date 		12.04.2007 
**/

class sandy.primitive.CylSurface extends Object3D implements Primitive3D
{
	//////////////////
	///PRIVATE VARS///
	//////////////////	
	private var _quality:Number ;
    private var _mode : String;
	private var _radius:Number ;
	private var _height:Number ;
	private var _angle:Number ;
	private var _angleRad:Number;
	private var _aUv:Array = new Array();
	
	var testCanvas:MovieClip;
	/**
	* This is the constructor to call when you need to create a CylSurface primitive.
	* <p>This method will create a complete object with vertex, normales, texture coords and the faces.
	*    So it allows to have a custom 3D object easily </p>
	* <p>{@code radius} represents the radius of the cylinder, {@code height} represent its height and {@code quality} its quality, so the number of faces </p>
	* @param radius Number
	* @param height	Number
	* @param angle Number, the generating angle in degrees starting from 0
	* @param quality Number
	* @param mode String represent the two available modes to generates the faces.
	* "tri" is necessary to have faces with 3 points, and "quad" for 4 points.
	*/
	public function CylSurface( radius:Number, height:Number, angle:Number, quality:Number, mode:String, gridAngle:Number )
	{
		super( ) ;
		_radius  = (undefined == radius) ? 100 :  radius   ;
		_quality = (undefined == quality) ? 6 : quality ;
		_height  = (undefined == height) ? 6 : height ;
		_angle   = (undefined == angle) ? 90 : angle ;
		_mode    = (undefined == mode || (mode != 'tri' && mode != 'quad') ) ? 'tri' : mode;
		testCanvas = _root.createEmptyMovieClip("test", _root.getNextHighestDepth());
		testCanvas._y = 50;
		testCanvas._x = 50;
		generate();
	}
	/* CylSurf generate
	*  The function generates an Objec3D with a cylinddrical surface
	*/
	public function generate(Void):Void
	{
		// Translated names for convinience 
		var r:Number = _radius;
		var q:Number = _quality;
		_angleRad = NumberUtil.toRadian(_angle); // radians		
		var h:Number = _height;
		//-- Variables locales
		var cos:Function = Math.cos;
		var sin:Function = Math.sin;
		var abs:Function = Math.abs;
		var n:Vector;
		var f:Polygon;
		var created:Boolean = false;
		// Grid
		//var gridAng:Number = _angleRad/q;
		var gridAng:Number = _angleRad/q;
		var gridRad:Number =  NumberUtil.toRadian (gridAng);
		var gridY:Number = h/q;
		// Start
		// theta0 = 0; ( automatically )
		var y0:Number = -h/2;
		// Walk upwards from y = - h/2
		for( var i = 0; i < q; i++ ){ // each y value
			var y = y0 + i*gridY;
			// Walk the circumference from theta = 0 to theta = endAngle
			for( var j = 0; j < q; j++){  // each theta value
				var theta = j*gridAng;

				// calculate the vertices for four points of the cell
				var p1 = new Vertex( r * cos(theta), y, r*sin(theta)); 
				var p2 = new Vertex( r * cos(theta + gridAng), y, r*sin(theta + gridAng)); 
				var p3 = new Vertex( r * cos(theta + gridAng), y + gridY, r*sin(theta + gridAng)); 
				var p4 = new Vertex( r * cos(theta), y + gridY, r*sin(theta));				

				// Push the points to the aPoints Array and save the indices
				var id1 = aPoints.push(p1)-1;
				var id2 = aPoints.push(p2)-1;
				var id3 = aPoints.push(p3)-1;
				var id4 = aPoints.push(p4)-1;
				
				// Add UV coordinates to this Objec3D
				_aUv.push(new UVCoord (j/q, i/q));
				_aUv.push(new UVCoord ((j+1)/q, i/q));
				_aUv.push(new UVCoord ((j+1)/q,(i+1)/q));
				_aUv.push(new UVCoord (j/q,(i+1)/q));

				// ===== Make faces if mode is 'tri' - the only mode available in this version
				// Add the correct UV cordinates to the faces for texturing
				if ( _mode == 'tri' ){
					f = new Polygon(this, aPoints[id1], aPoints[id4], aPoints[id2] );
					f.setUVCoords( _aUv[id1], _aUv[id4], _aUv[id2] ); 
					addFace( f );
					if(!created){
						n = f.createNormale ();
						aNormals.push ( n );
						created = true;
					}
					else
					{
					f.setNormale (n);
					}
					f = new Polygon(this, aPoints[id4], aPoints[id3], aPoints[id2] );
					f.setUVCoords( _aUv[id4], _aUv[id3], _aUv[id2] ); 
					addFace( f );
					f.setNormale( n );
				}
				else {
					trace ("Quad mode not supported");
					f = new Polygon(this, aPoints[id1], aPoints[id4], aPoints[id3], aPoints[id2] );
					f.setUVCoords( _aUv[id1], _aUv[id4], _aUv[id3], _aUv[id2] );
					addFace( f );			
					
					if (!created)
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
			}
		}
	}
	
	/**
	* getSize() returns the radius, height, and angle as a Vector (useful for storing an object's attributes).
	* Returns vector where x is the radius, y is the height, and z is the angle
	*/	
	public function getSize (Void):Vector {
		return new Vector (_radius, _height, _angle);
	}
	
	 public function getPrimitiveName (Void):String {
		 return "CylSurface";
	 }
	 
	 public function toString (Void):String {
		 return "sandy.primitive." + getPrimitiveName();
	 }
	 
	// Test method to draw all cells on a separate MovieClip
	function drawCell(p1:Vertex,p2:Vertex,p3:Vertex,p4:Vertex){
		var mc:MovieClip = testCanvas;
		mc.lineStyle(1);
		mc.moveTo(p1.x,p1.z);
		mc.lineTo(p2.x,p2.z);
		mc.lineTo(p3.x,p3.z);
		mc.lineTo(p4.x,p4.z);
		mc.lineTo(0,0);		
	}	
}