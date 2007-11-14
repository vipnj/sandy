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
* Conic - Creates a conic section (a slice of a cone)
* @author		Thomas Pfeiffer - kiroukou - 
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @author		Bruce Epstein - zeusprod - adapted from Cylinder.as; added ability to hide faces.
* @since		1.2
* @version		1.2.1
* @date 		12.04.2007 
**/
class sandy.primitive.Conic extends Object3D implements Primitive3D
{
	//////////////////
	///PRIVATE VARS///
	//////////////////	
	private var _quality:Number ;
	private var _radiusTop:Number ;
	private var _radiusBottom:Number ;
	private var _height:Number ;
	private var _noBottom:Boolean ;
	private var _noTop:Boolean ;
	private var _noSides:Boolean ;
	private var _separateFaces:Boolean ;
	
	/**
	* This is the constructor to call when you need to create a Conic primitive.
	* <p>This method will create a complete object with vertex, normales, texture coords and the faces.
	*    So it allows to have a custom 3D object easily </p>
	* <p>{@code radiusTop} represents the radius of the bottom of the conic section,{@code radiusBottom} represents the radius of the top of the conic section, {@code height} represent its height and {@code quality} its quality (the number of faces) </p>
	* @param radiusTop Number The radius of the bottom face of the conic section. 
	*   Set radiusTop or radiusBottom to 1 to create a pointy cone.
	* @param radiusBottom Number The radius of the top face of the conic section. 
	*   Set radiusBottom to a negative number (the opposite sign of radiusTop) to create an hourglass.
	* @param height	Number The height of the conic section
	* @param quality Number The number of faces around the side of the conic section (max 200, which is a lot).
	* @param mode String represent the two available modes to generates the faces.
	* "tri" is necessary to have faces with 3 points, and "quad" for 4 points.
	* @param noBottom Boolean If true, the bottom of the conic section is not rendered (defaults to false
	*   unless radiusTop is 1, in which case the bottom face need not be rendered separately).
	* @param noTop Boolean If true, the top of the conic section is not rendered (defaults to false).
	*   unless radiusBottom is 1, in which case the bottom face need not be rendered separately).
	* @param noSides Boolean If true, the sides of the conic section are not rendered (defaults to false).
	* @param separateFaces Boolean If true, texture faces separately (defaults to false).
	*/
	public function Conic( radiusTop:Number, radiusBottom:Number, height:Number, quality:Number, mode:String,
						 noTop:Boolean, noBottom:Boolean, noSides:Boolean, separateFaces:Boolean)
	{
		super( ) ;
		_radiusTop = (undefined == radiusTop) ? 100 :  radiusTop   ;
		_radiusBottom = (undefined == radiusBottom) ? _radiusTop :  radiusBottom   ;
		_noBottom = (undefined == noBottom) ? false :  noBottom   ;
		_noTop = (undefined == noTop) ? false :  noTop   ;
		// Don't draw the face if the radius is too small to see/notice.
		// But allow negative radii.
		if (_radiusTop <= 1 && _radiusTop >= -1) {
			_noBottom = true;
		}
		if (_radiusBottom <= 1 && _radiusBottom >= -1) {
			_noTop = true;
		}
		_noSides = (undefined == noSides) ? false :  noSides ;
		_separateFaces = (undefined == separateFaces) ? false :  separateFaces ;
		_quality = (undefined == quality) ? 6 : NumberUtil.constrain(quality, 1, 200);
		_height = (undefined == height) ? 6 : height;
		_mode = ( undefined == mode || (mode != 'tri' && mode != 'quad') ) ? 'tri' : mode;
		generate();
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
		// initialisation
		aPoints = []; aNormals = []; aFaces = [];
		//
		var auv:Array = new Array();
		var points:Array = new Array();
		var faces:Array = new Array();
		//-- Variables locales
		var cos:Function = Math.cos;
		var sin:Function = Math.sin;
		var abs:Function = Math.abs;
		var pi:Number = Math.PI;
		var pi2:Number = pi/2;

		// Used for separateFaces - imitated from Box.as
		var uvc:Array = new Array();
		uvc.push (new UVCoord (0, 0));  // uv0
		uvc.push (new UVCoord (1, 0));  // uv1
		uvc.push (new UVCoord (0, 1));  // uv2
		uvc.push (new UVCoord (1, 1));  // uv3
		//-- Initialisations des variables
		var theta:Number ; //Car plus simple pour les coords de texture (en haut a gauche  == image en 0.0)
// Because simpler for the coords of texture (in upper left == image in 0.0)
		var phi1:Number ;
		var phi2:Number ;
		
		var h:Number = 2*Math.PI * _radiusTop;
		var w:Number = 2*_radiusTop + _height;
		// texture pas //do not texture
		var tx:Number = w; 
		var ty:Number = h;
		//the coords of texture are added
		//-- on ajoute les coords de texture
		auv[0] = new UVCoord( 1 , 0.5 );		
		auv[1] = new UVCoord( 0 , 0.5 );

		var pas:Number = (2*pi/_quality);
		var pas2:Number = (_radiusTop/_quality);
		phi1 = Math.atan((_height/2)/_radiusTop);
		phi2 = - phi1;
		//Technique of the squaring for the creation of the points.
		// Allows for simpler (simplified?) Boucle texture for theta
		//-- Technique du quadrillage pour la creation des points. 
		//Permet de simplfier la texturation Boucle pour theta
		points.push( {x:0, y:_height/2, z:0});
		points.push( {x:0, y:-_height/2, z:0});

		ty -= _radiusTop;
		for( theta = 0; theta < 2*pi; tx -= h/_quality, theta += pas )
		{
			points.push({x:_radiusTop*cos(theta) ,
					 y: _height/2, 
					 z:_radiusTop*sin(theta) });
			points.push({x:_radiusBottom*cos(theta) ,
					 y: -_height/2, 
					 z:_radiusBottom*sin(theta) });
			auv.push( new UVCoord( tx/w , ty/h ) );
			auv.push( new UVCoord( tx/w , (ty- _height)/h ) );
		}
		tx -= h/_quality;
		auv.push( new UVCoord( tx/w , ty/h ) );
		auv.push( new UVCoord( tx/w , (ty- _height)/h ) );
		ty -= _radiusTop;
		
		var l:Number = points.length;
		for(var i:Number = 0 ; i < l; i++)
		{
			var v:Vertex = new Vertex(points[i].x,points[i].y,points[i].z);
			aPoints.push(v);
		}
		
		var f:Polygon;
		if (!_noTop) {
			// For the top face of the conic section...
			//Pour la partie du haut du cône
			if ( _mode == 'tri' )
			{
				for(var i:Number=2; i<=l-2; i+=2)
				{
					var j:Number = ( (i+2) >= l )?  2 : i+2 ;
					f = new Polygon( this, aPoints[0], aPoints[i], aPoints[j] );
					// Typo fixed BAEpstein Mar 19, 2007
					f.setUVCoords( auv[0], auv[i], auv[j] );
					addFace( f );
					//f = this.createFace( [0, i, j ], [0, i, j] ) ;
				}
			}
			else if( _mode == 'quad' )
			{
				var aId:Array = new Array();
				var aIduv:Array = new Array();
				for(var i:Number=2; i<=l-2; i+=2)
				{
					aId.push( aPoints[i] );
					aIduv.push( auv[i] );
				}
				// Was NFace3D in Sandy 1.1
				f = new Polygon( this, aId );
				//Polygon(f).setUVCoords( aIduv );
				// Type mismatch BAEpstein
				Polygon(f).setUVCoords( aIduv[0],  aIduv[1], aIduv[2]);
				addFace( f );
				//f = this.createFace( aId, [0,0,0,0]);
			}
			aNormals.push( f.createNormale() );
		}
		// For the center/sides (of the conic section)
		//Pour le centre 
		if (!_noSides) {
			var n:Vector;
			for(var i:Number=0; i < l-3; i+=2)
			{
				var pt1:Number;
				var pt2:Number;
				var pt3:Number;
				var pt4:Number;
				
				pt1 = i+2;
				pt2 = (i+1)%(l-2)+2;
				pt3 = (i+2)%(l-2)+2;
				pt4 = (i+3)%(l-2)+2;
				//faces.push( new QFace3d(this, pt1, pt2, pt4, pt3 ) );
				if( _mode == 'tri' )
				{
				f = new Polygon( this, aPoints[pt1], aPoints[pt2], aPoints[pt3] );
			
					// Sideways variation:  {0, 1, 2} and {1, 3, 2}
					// Inverted (mirrored?) {1, 3, 0} and {3, 2, 0}
					// Right-side up (mirrored?)  {2, 0, 3} and {0, 1, 3}
					if (_separateFaces) {
						// Display the first half of the picture on the face
						f.setUVCoords( uvc[2], uvc[0], uvc[3] );
					} else {
						f.setUVCoords( auv[pt1], auv[pt1+1], auv[pt1+2] );
					}
					addFace( f );
					n = f.createNormale();

					f = new Polygon( this, aPoints[pt2], aPoints[pt4], aPoints[pt3] );
				
					if (_separateFaces) {
						// Display the second half of the picture on the face
						f.setUVCoords(uvc[0],  uvc[1], uvc[3]);
					} else {
						f.setUVCoords( auv[pt1], auv[pt1+3], auv[pt1+2] );
					}
					addFace( f );
					f.setNormale( n );
		
					aNormals.push( n );
				}
				else if( _mode == 'quad' )
				{
					f = new Polygon( this, aPoints[pt1], aPoints[pt2], aPoints[pt4], aPoints[pt3] );
				
					if (_separateFaces) {
						// Display an entire picture on one face
						f.setUVCoords(uvc[2], uvc[0], uvc[1], uvc[3]);
					} else {
						f.setUVCoords( auv[pt1], auv[pt1+1], auv[pt1+3], auv[pt1+2] );
					}
					addFace( f );
					aNormals.push ( f.createNormale() );
				}
			}
		}
		
		// For the bottom face of the conic section
		if (!_noBottom) {
			
			if ( _mode == 'tri' )
			{
				for(var i:Number=l-1; i> 1; i-=2)
				{
					var j:Number = ( (i-2) <= 1 )? l-1  : i-2 ;
					f = new Polygon( this, aPoints[1], aPoints[i], aPoints[j] );
					f.setUVCoords( auv[1], auv[i], auv[j] );
					addFace( f );
				}
			}
			else if( _mode == 'quad' )
			{
				var aId:Array = new Array();
				var aIduv:Array = new Array();
				for(var i:Number=l-1; i> 1; i-=2)
				{
					aId.push( aPoints[i] );
					aIduv.push( auv[i] );
				}
				// Was NFace3D in Sandy 1.1
				f = new Polygon( this, aId );
				//Polygon(f).setUVCoords( aIduv );
				// Type mismatch BAEpstein
				Polygon(f).setUVCoords( aIduv[0],  aIduv[1], aIduv[2]);
				addFace( f );
			}
			
			aNormals.push( f.createNormale() );
		}
	}
	
	 public function getPrimitiveName (Void):String {
		 return "Conic";
	 }

	/**
	* getSize() returns the height and radii as a Vector (useful for storing an object's attributes).
	* Returns vector where x is the top radius, y is the bottom radius, and z is the height, and 
	*/	
	public function getSize (Void):Vector {
		return new Vector (_radiusTop, _radiusBottom, _height);
	}
	 
	
	/*
	 * Mode with 3 or 4 points per face
	 */
	 private var _mode : String;
}