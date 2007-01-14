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
import sandy.core.face.NFace3D;
import sandy.core.face.QuadFace3D;
import sandy.core.face.TriFace3D;
import sandy.core.Object3D;
import sandy.primitive.Primitive3D;
import sandy.core.data.UVCoord;

/**
* Cylinder
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @since		0.1
* @version		0.2
* @date 		12.01.2006 
**/
class sandy.primitive.Cylinder extends Object3D implements Primitive3D
{
	//////////////////
	///PRIVATE VARS///
	//////////////////	
	private var _quality:Number ;
	private var _radius:Number ;
	private var _height:Number ;
	
	/**
	* This is the constructor to call when you nedd to create a Cylinder primitive.
	* <p>This method will create a complete object with vertex, normales, texture coords and the faces.
	*    So it allows to have a custom 3D object easily </p>
	* <p>{@code radius} represents the radius of the cylinder, {@code height} represent its height and {@code quality} its quality, so the number of faces </p>
	* @param radius Number
	* @param height	Number
	* @param quality Number
	* @param mode String represent the two available modes to generates the faces.
	* "tri" is necessary to have faces with 3 points, and "quad" for 4 points.
	*/
	public function Cylinder( radius:Number, height:Number, quality:Number, mode:String )
	{
		super( ) ;
		_radius = (undefined == radius) ? 100 :  radius   ;
		_quality = (undefined == quality) ? 6 : quality ;
		_height = (undefined == height) ? 6 : height ;
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

		//-- Initialisations des variables
		var theta:Number ; //Car plus simple pour les coords de texture (en haut a gauche  == image en 0.0)
		var phi1:Number ;
		var phi2:Number ;
		
		var h:Number = 2*Math.PI * _radius;
		var w:Number = 2*_radius + _height;
		// texture pas
		var tx:Number = w; 
		var ty:Number = h;
		//-- on ajoute les coords de texture
		auv[0] = new UVCoord( 1 , 0.5 );		
		auv[1] = new UVCoord( 0 , 0.5 );

		var pas:Number = (2*pi/_quality);
		var pas2:Number = (_radius/_quality);
		phi1 = Math.atan((_height/2)/_radius);
		phi2 = - phi1;
		//-- Technique du quadrillage pour la creation des points. Permet de simplfier la texturation
		//Boucle pour theta
		points.push( {x:0, y:_height/2, z:0});
		points.push( {x:0, y:-_height/2, z:0});

		ty -= _radius;
		for( theta = 0; theta < 2*pi; tx -= h/_quality, theta += pas )
		{
			points.push({x:_radius*cos(theta) , y: _height/2, z:_radius*sin(theta) });
			points.push({x:_radius*cos(theta) , y: -_height/2, z:_radius*sin(theta) });
			auv.push( new UVCoord( tx/w , ty/h ) );
			auv.push( new UVCoord( tx/w , (ty- _height)/h ) );
		}
		tx -= h/_quality;
		auv.push( new UVCoord( tx/w , ty/h ) );
		auv.push( new UVCoord( tx/w , (ty- _height)/h ) );
		ty -= _radius;
		
		var l:Number = points.length;
		for(var i:Number = 0 ; i < l; i++)
		{
			var v:Vertex = new Vertex(points[i].x,points[i].y,points[i].z);
			aPoints.push(v);
		}
		
		var f:Face;
		//Pour la partie du haut du cylindre
		if ( _mode == 'tri' )
		{
			for(var i:Number=2; i<=l-2; i+=2)
			{
				var j:Number = ( (i+2) >= l )?  2 : i+2 ;
				f = new TriFace3D( this, aPoints[0], aPoints[i], aPoints[j] );
				f.setUVCoordinates( auv[0], auv[i], auv[j] );
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
			f = new NFace3D( this, aId );
			NFace3D(f).setUVCoordinates( aIduv );
			addFace( f );
			//f = this.createFace( aId, [0,0,0,0]);
		}
		aNormals.push( f.createNormale() );
		//Pour le centre 
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
				f = new TriFace3D( this, aPoints[pt1], aPoints[pt2], aPoints[pt3] );
				f.setUVCoordinates( auv[pt1], auv[pt1+1], auv[pt1+2] );
				addFace( f );
				n = f.createNormale();

				f = new TriFace3D( this, aPoints[pt2], aPoints[pt4], aPoints[pt3] );
				f.setUVCoordinates( auv[pt1], auv[pt1+3], auv[pt1+2] );
				addFace( f );
				f.setNormale( n );
		
				aNormals.push( n );
			}
			else if( _mode == 'quad' )
			{
				f = new QuadFace3D( this, aPoints[pt1], aPoints[pt2], aPoints[pt4], aPoints[pt3] );
				f.setUVCoordinates( auv[pt1], auv[pt1+1], auv[pt1+3], auv[pt1+2] );
				addFace( f );
				aNormals.push ( f.createNormale() );
			}
		}
			
		if ( _mode == 'tri' )
		{
			for(var i:Number=l-1; i> 1; i-=2)
			{
				var j:Number = ( (i-2) <= 1 )? l-1  : i-2 ;
				f = new TriFace3D( this, aPoints[1], aPoints[i], aPoints[j] );
				f.setUVCoordinates( auv[1], auv[i], auv[j] );
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
			f = new NFace3D( this, aId );
			NFace3D(f).setUVCoordinates( aIduv );
			addFace( f );
		}
		
		aNormals.push( f.createNormale() );
	}
	
	/*
	 * Mode with 3 or 4 points per face
	 */
	 private var _mode : String;
}