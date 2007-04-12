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
import sandy.core.Object3D;
import sandy.primitive.Primitive3D;
import sandy.core.data.UVCoord;
import sandy.core.face.IPolygon;
import sandy.core.face.Polygon;
import sandy.util.NumberUtil;

/**
* Generate an Ellipsoid using 3D coordinates. 
* The Ellipsoid generated is a 3D object that can be rendered by Sandy's engine. 
* @author		RichL - generalized from Sphere.as
* @version		1.2.1
* @date 		12.04.2007 
**/
class sandy.primitive.Ellipsoid extends Object3D implements Primitive3D
{
	//////////////////
	///PRIVATE VARS///
	//////////////////	
	private var _quality:Number;
	private var _xradius:Number;
	private var _yradius:Number;
	private var _zradius:Number;

	/**
	* This is the constructor to call when you need to create an Ellipsoid primitive.
	* <p>This method will create a complete object with vertex, normales, texture coords and the faces.</p>
	* <p>
	* {@code xradius} represents the x radius of the Ellipsoid,  
	* {@code yradius} represents the y radius of the Ellipsoid,  
	* {@code zradius} represents the z radius of the Ellipsoid,  
	* {@code quality} represent quality (between 1 and 5), the higher the quality the more faces there are
	* </p>
	* @param 	xradius 	Number
	* @param 	yradius 	Number
	* @param 	zradius 	Number
	* @param 	quality		Number
	* @param 	mode 		String represents the two available modes to generate the faces.
	* "tri" is necessary to have faces with 3 points, and "quad" for 4 points.
	*/
	public function Ellipsoid(xradius:Number, yradius:Number, zradius:Number, quality:Number, mode:String)
	{	super();
		_xradius =(undefined == xradius) ? 5 : xradius;		
		_yradius =(undefined == yradius) ? 5 : yradius;		
		_zradius =(undefined == zradius) ? 5 : zradius;		
		if (undefined == quality) quality = 1 ;
		_quality = 4 + 2 * NumberUtil.constrain(quality, 1, 10);
		_mode = ( undefined == mode || (mode != 'tri' && mode != 'quad') ) ? 'tri' : mode;
		generate();
	}
	
	/**
	* Generate all that is needed to construct the object. Vertex, UVCoords, Faces
	* 
	* <p>Generates the points, normals and faces of the primitive depending on the parameters given</p>
	* <p>It dynamically constructs the object taking into account your preferences given in the parameters.</p>
	*/
	public function generate(Void):Void
	{
		_xradius = _xradius;
		_yradius = _yradius;
		_zradius = _zradius;
		var points:Array = new Array();
		var texture:Array = new Array();
		var faces:Array = new Array();
		var f:IPolygon;
		//-- Variables locales
		var cos:Function = Math.cos;
		var sin:Function = Math.sin;
		var abs:Function = Math.abs;
		var pi:Number = Math.PI;
		var pi2:Number = pi/2;
		var tx:Number = 1;
		var ty:Number = 0;
		var nbptsh:Number = 0;
		var nbptsv:Number = 0;
		//-- Initialisations des variables
		var theta:Number ;
		var phi:Number ;
		var pas:Number = (2*pi/_quality);
		var pas2:Number = (2/_quality);
		//-- point de depart de la boucle phi
		var phi_deb:Number = pi2 - pas ;
		//-- point d'arrivde phi
		var phi_fin:Number = -pi2 + pas ;

		//-- Point du haut de la Ellipsoid
		points.push({x:0, y:_yradius, z:0});
		//-- Point du bas de la Ellipsoid
		points.push({x:0, y:-_yradius, z:0});
		
		texture.push( new UVCoord( 0.5 , 1 ) );
		//trace("UV "+texture.length+" "+tx+" "+ty);
		texture.push( new UVCoord( 0.5 , 0 ) );
		//trace("UV "+texture.length+" "+tx+" "+ty);

		//-- Technique du quadrillage pour la creation des points de la Ellipsoid. Permet de simplifier la texturation
		//Boucle pour theta
		for( theta = 0 ; theta < 2*pi; tx-=pas2/2 , theta += pas )
		{
			nbptsv ++;
			ty = 1-pas2;
			nbptsh=0;
			//Boucle pour phi
			for(phi = phi_deb ; phi>= phi_fin; ty-= pas2, phi -= pas )
			{
				nbptsh++;
				var o:Object = {};
				//Passage en sphque.
				//trace("phi "+phi+" theta "+theta);				
				o.x = _xradius*cos(phi)*sin(theta);
				o.y = _yradius*sin(phi);
				o.z = _zradius*cos(phi)*cos(theta);
				//On nettoie les coords pour simplifier les calculs
				o.x = ( abs(o.x) < Number(1e-4) ) ? 0 : o.x;
				o.y = ( abs(o.y) < Number(1e-4) ) ? 0 : o.y ;
				o.z = ( abs(o.z) < Number(1e-4) ) ? 0 : o.z;
				//trace("x "+o.x+" y "+o.y+" z "+o.z);				
				//-- on ajoute les coords de texture
				texture.push( new UVCoord( tx , ty ) );
			    //trace("UV "+texture.length+" "+tx+" "+ty);
				points.push(o);
			}	
		}
		
		//un petit coup pour les textures
		for(phi = phi_deb,ty = 1-pas2 ; phi>= phi_fin; ty-= pas2, phi -= pas )
		{
			texture.push( new UVCoord( tx , ty ) );
			//trace("UV "+texture.length+" "+tx+" "+ty);
		}
		
		var l:Number = points.length;
		for(var i:Number = 0 ; i < l; i++)
		{
			var v:Vertex = new Vertex(points[i].x,points[i].y,points[i].z);
			aPoints.push(v);
		}
		
		var n:Vector;
		//--Pour le sommet
		for(var i:Number=2;i<l;i+=nbptsh)
		{
			var id:Number;
			id =((i+nbptsh) >= l) ? ((i+nbptsh)%l+2) : ((i+nbptsh));
			f = new Polygon(this, aPoints[0], aPoints[id], aPoints[i] );
			if(id==2){//Fixes wierd triangle at top. Use l(= points length) instead of id==2
			  f.setUVCoords( texture[0], texture[l], texture[i] );
			  //trace("TOP 0 2 "+i);
			} else {
			  f.setUVCoords( texture[0], texture[id], texture[i] );				
			  //trace("TOP 0 "+id+" "+i);
			}
			aNormals.push ( f.createNormale () );
			addFace( f );
		}
		
		//--Pour le bas
		for(var i:Number = 1+nbptsh; i<l; i+=nbptsh)
		{
			var id:Number;
			id = ((i+nbptsh)>=l)? ((i+nbptsh)%l+2) : ((i+nbptsh));
			//TODO checker les UV
			f = new Polygon(this, aPoints[1], aPoints[i], aPoints[id] );
			if(id==(1+nbptsh)){//Fixes wierd triangle at bottom. Use l-1+nbptsh instead of id==(1+nbptsh)
			  f.setUVCoords(texture[1],texture[i],texture[l-1+nbptsh]);
			  //trace("BOT 1 "+i+" "+(l-1+nbptsh));
			} else {
			  f.setUVCoords(texture[1],texture[i],texture[id]);
			  //trace("BOT 1 "+i+" "+id);
			}
			aNormals.push ( f.createNormale () );
			addFace( f );
		}
		//--Si on est sur un hedra il n'y a que les sommets
		if( l <= 6 ) return;
		//--Pour le centre
		for( var i:Number = 2; i < l-1; i += 1 )
		{
			//Si on est sur la bas de la Ellipsoid on passe
			if( (i-1)%nbptsh == 0 ) continue;
			var pt1:Number;
			var pt2:Number;
			var pt3:Number;
			var pt4:Number;
			//	1 ---- 3
			//  |      |
			//  2 ---- 4
			pt1 = i;
			pt2 = ((i+1)>=l) ? ((i+1)%l+2) : ((i+1));
			pt3 = ((i+nbptsh)>=l) ? ((i+nbptsh)%l+2) : ((i+nbptsh));
			pt4 = ((i+1+nbptsh)>=l) ? ((i+1+nbptsh)%l+2) : ((i+1+nbptsh));
			if( _mode == 'tri' )
			{
				f = new Polygon(this, aPoints[pt1], aPoints[pt3], aPoints[pt2] );
				f.setUVCoords( texture[i], texture[(i+nbptsh)], texture[(i+1)] );
				n = f.createNormale ();
				aNormals.push ( n  );
				addFace( f );
				
				f = new Polygon(this, aPoints[pt2], aPoints[pt3], aPoints[pt4] );
				f.setUVCoords( texture[i+1], texture[(i+nbptsh)], texture[(i+1+nbptsh)] );
				f.setNormale( n );
				addFace( f );
			}
			else if( _mode == 'quad' )
			{
				f = new Polygon(this, aPoints[pt1], aPoints[pt3], aPoints[pt4], aPoints[pt2] );
				f.setUVCoords( texture[pt1], texture[(i+nbptsh)], texture[(i+1+nbptsh)], texture[(i+1)] );
				n = f.createNormale ();
				aNormals.push ( n  );
				addFace( f );
			}
		}
	}
	
	/**
	* getSize() returns the radius as a Vector (useful for storing an object's attributes).
	* Returns vector where x, y, and z are the x, y, and z radii
	*/	
	public function getSize (Void):Vector {
		return new Vector (_xradius, _yradius, _zradius);
	}
	
	/**
	* getPrimitiveName() returns the string "Sphere"
	*/	
	 public function getPrimitiveName (Void):String {
		 return "Ellipsoid";
	 }
	 
	 public function toString (Void):String {
		 return "sandy.primitive." + getPrimitiveName();
	 }
	
	/*
	 * Mode with 3 or 4 points per face
	 */
	 private var _mode : String;
	 
}

