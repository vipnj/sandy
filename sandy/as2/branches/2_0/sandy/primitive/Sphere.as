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
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.primitive.Primitive3D;

	

	/**
	* Generate a Sphere 3D coordinates. The Sphere generated is a 3D object that can be rendered by Sandy's engine.
	* You can play with the constructor's parameters to ajust it to your needs.  
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		12.07.2006 
	**/
	class sandy.primitive.Sphere extends Shape3D implements Primitive3D
	{
		//////////////////
		///PRIVATE VARS///
		//////////////////	
		private var _quality:Number ;
		private var _radius:Number ;

		
		/*
		 * Mode with 3 or 4 points per face
		 */
		 private var _mode : String;
		 
		
		/**
		* This is the constructor to call when you nedd to create a Sphere primitive.
		* <p>This method will create a complete object with vertex, normales, texture coords and the faces.
		*    So it allows to have a custom 3D object easily </p>
		* <p>{@code radius} represents the radius of the Sphere,  {@code quality} represent its quality (between 1 and 5), more quality is up, more faces there is</p>
		* @param 	radius 	Number
		* @param 	quality	Number
		* @param mode String represent the two available modes to generates the faces.
		* "tri" is necessary to have faces with 3 points, and "quad" for 4 points.
		*/
		public function Sphere( radius:Number, quality:Number, mode:String)
		{
			super();
			_radius = ( radius ) ? radius : 50;
			quality = (quality) ? quality : 1;
			quality = (quality <= 0 || quality > 10) ? 10 : quality;
			_mode = ( mode != 'tri' && mode != 'quad' ) ? 'tri' : mode;
			_quality = 4 + 2*quality ;
			geometry = generate();
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
			
			_radius = _radius;
			var i:Number;
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

			//-- Point du haut de la sphere
			points.push({x:0, y:_radius, z:0});
			//-- Point du bas de la sphere
			points.push({x:0, y:-_radius, z:0});
			
			texture.push( new UVCoord( 0.5 , 1 ) );
			texture.push( new UVCoord( 0.5 , 0 ) );
			
			//-- Technique du quadrillage pour la creation des points de la sphere. Permet de simplifier la texturation
			//Boucle pour theta
			for( theta = 0 ; theta < 2*pi; tx-=pas2/2 , theta += pas )
			{
				nbptsv ++;
				ty = 1-pas2;
				nbptsh = 0;
				//Boucle pour phi
				for(phi = phi_deb ; phi>= phi_fin; ty-= pas2, phi -= pas )
				{
					nbptsh++;
					var o:Object = {};
					//Passage en sphque.
					o.x = _radius*cos(phi)*sin(theta);
					o.y = _radius*sin(phi);
					o.z = _radius*cos(phi)*cos(theta);
					//On nettoie les coords pour simplifier les calculs
					o.x = ( abs(o.x) < Number(1e-4) ) ? 0 : o.x;
					o.y = ( abs(o.y) < Number(1e-4) ) ? 0 : o.y ;
					o.z = ( abs(o.z) < Number(1e-4) ) ? 0 : o.z;
					//-- on ajoute les coords de texture
					texture.push( new UVCoord( tx , ty ) );
					points.push(o);
				}	
			}
			
			//un petit coup pour les textures
			for(phi = phi_deb,ty = 1-pas2 ; phi>= phi_fin; ty-= pas2, phi -= pas )
			{
				texture.push( new UVCoord( tx , ty ) );
			}
			
			var l:Number = points.length;
			for(i = 0 ; i < l; i++)
			{
				l_geometry.addPoint(new Vertex(points[int(i)].x, points[int(i)].y, points[int(i)].z));
			}
			var id:Number;
			var n:Vector;
			//--Pour le sommet
			for( i = 2; i<l; i+=nbptsh)
			{
				
				id =((i+nbptsh) >= l) ?  ((i+nbptsh)%l+2) : ((i+nbptsh));
				//TODO checker les UV
				l_geometry.createFaceByIds(0, id, i );
				l_geometry.addUVCoords( texture[0], texture[int(id)], texture[int(i)] );
			}

			//--Pour le bas
			
			for( i = 1+nbptsh; i<l; i+=nbptsh)
			{				
				id = ((i+nbptsh)>=l)? ((i+nbptsh)%l+2) : ((i+nbptsh));
				//TODO checker les UV
				l_geometry.createFaceByIds(1, i, id);
				l_geometry.addUVCoords( texture[1], texture[int(i)], texture[int(id)] );
			}
			
			//--Si on est sur un hedra il n'y a que les sommets
			if( l <= 6 ) return l_geometry;
			//--Pour le centre
			for(  i = 2; i < l-1; i += 1 )
			{
				//Si on est sur la bas de la sphere on passe
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
					l_geometry.createFaceByIds(pt1, pt3, pt2 );
					l_geometry.addUVCoords( texture[int(i)], texture[int(i+nbptsh)], texture[int(i+1)] );
					
					l_geometry.createFaceByIds(pt2, pt3, pt4 );
					l_geometry.addUVCoords( texture[int(i+1)], texture[int(i+nbptsh)], texture[int(i+1+nbptsh)] );

				}
				else if( _mode == 'quad' )
				{
					l_geometry.createFaceByIds(pt1, pt3, pt4, pt2 );
					l_geometry.addUVCoords( texture[int(pt1)], texture[int(i+nbptsh)], texture[int(i+1+nbptsh)]/*, texture[int(i+1)]*/ );
				}
			}
			
			return l_geometry;
		}

	}