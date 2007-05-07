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
import sandy.core.face.Polygon;
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
	private var radius:Number;
	
	/**
	* Number of segments horizontally. Defaults to 8.
	*/
	public var segmentsW :Number;

	/**
	* Number of segments vertically. Defaults to 6.
	*/
	public var segmentsH :Number;

	/**
	* Default radius of Sphere if not defined.
	*/
	static public var DEFAULT_RADIUS :Number = 100;

	/**
	* Default scale of Sphere texture if not defined.
	*/
	static public var DEFAULT_SCALE :Number = 1;

	/**
	* Default value of gridX if not defined.
	*/
	static public var DEFAULT_SEGMENTSW :Number = 8;

	/**
	* Default value of gridY if not defined.
	*/
	static public var DEFAULT_SEGMENTSH :Number = 6;

	/**
	* Minimum value of gridX.
	*/
	static public var MIN_SEGMENTSW :Number = 3;

	/**
	* Minimum value of gridY.
	*/
	static public var MIN_SEGMENTSH :Number = 2;

	/**
	* Create a new Sphere object.
	* @param	radius		[optional] - Desired radius.
	* <p/>
	* @param	segmentsW	[optional] - Number of segments horizontally. Defaults to 8.
	* <p/>
	* @param	segmentsH	[optional] - Number of segments vertically. Defaults to 6.
	*/
	function Sphere( p_sName:String , p_nRadius:Number, p_nSegmentsW:Number, p_nSegmentsH:Number )
	{
		super( p_sName );
		// --
		this.segmentsW = Math.max( MIN_SEGMENTSW, p_nSegmentsW || DEFAULT_SEGMENTSW); // Defaults to 8
		this.segmentsH = Math.max( MIN_SEGMENTSH, p_nSegmentsH || DEFAULT_SEGMENTSH); // Defaults to 6
		radius = (p_nRadius != undefined) ? p_nRadius : DEFAULT_RADIUS; // Defaults to 100
		// --
		var scale :Number = DEFAULT_SCALE;
		// --
		geometry = generate();
	}

	public function generate():Geometry3D
	{
		var l_oGeometry:Geometry3D = new Geometry3D();
		// --
		var i:Number, j:Number, k:Number;
		var iHor:Number = Math.max(3,this.segmentsW);
		var iVer:Number = Math.max(2,this.segmentsH);
		// --
		var aVtc:Array = new Array();
		for ( j=0; j<(iVer+1) ;j++ ) 
		{ // vertical
			var fRad1:Number = Number(j/iVer);
			var fZ:Number = -radius*Math.cos(fRad1*Math.PI);
			var fRds:Number = radius*Math.sin(fRad1*Math.PI);
			var aRow:Array = new Array();
			var oVtx:Number;
			for ( i=0; i<iHor ; i++ ) 
			{ // horizontal
				var fRad2:Number = Number(2*i/iHor);
				var fX:Number = fRds*Math.sin(fRad2*Math.PI);
				var fY:Number = fRds*Math.cos(fRad2*Math.PI);
				if (!((j==0||j==iVer)&&i>0)) 
				{ // top||bottom = 1 vertex
					oVtx = l_oGeometry.setVertex( l_oGeometry.getNextVertexID(), fY, fZ, fX );//fY, -fZ, fX );
				}
				aRow.push(oVtx);
			}
			aVtc.push(aRow);
		}
		// --
		var iVerNum:Number = aVtc.length;
		for ( j=0; j<iVerNum; j++ ) 
		{
			var iHorNum:Number = aVtc[j].length;
			if (j>0) 
			{ // &&i>=0
				for ( i=0; i<iHorNum; i++ ) 
				{
					// select vertices
					var bEnd:Boolean = i==(iHorNum-0);
					// --
					var l_nP1:Number = aVtc[j][bEnd?0:i];
					var l_nP2:Number = aVtc[j][(i==0?iHorNum:i)-1];
					var l_nP3:Number = aVtc[j-1][(i==0?iHorNum:i)-1];
					var l_nP4:Number = aVtc[j-1][bEnd?0:i];
					// uv
					var fJ0:Number = j		/ iVerNum;
					var fJ1:Number = (j-1)	/ iVerNum;
					var fI0:Number = (i+1)	/ iHorNum;
					var fI1:Number = i		/ iHorNum;
					
					var l_nUV4:Number = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), fI0, 1-fJ1 );
					var l_nUV1:Number = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), fI0, 1-fJ0 );
					var l_nUV2:Number = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), fI1, 1-fJ0 );
					var l_nUV3:Number = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), fI1, 1-fJ1 );
					
					// 2 faces
					if (j<(aVtc.length-1))
					{	
						var l_nF:Number = l_oGeometry.setFaceVertexIds( l_oGeometry.getNextFaceID(), l_nP1, l_nP2, l_nP3 );
						l_oGeometry.setFaceUVCoordsIds( l_nF, l_nUV1, l_nUV2, l_nUV3 );
						//aFace.push( new Face3D(new Array(aP1,aP2,aP3),new Array(aP1uv,aP2uv,aP3uv)) );
					}
					if (j>1)
					{
						var l_nF:Number = l_oGeometry.setFaceVertexIds( l_oGeometry.getNextFaceID(), l_nP1, l_nP3, l_nP4 );
						l_oGeometry.setFaceUVCoordsIds( l_nF, l_nUV1, l_nUV3, l_nUV4 );
						//aFace.push( new Face3D(new Array(aP1,aP3,aP4), new Array(aP1uv,aP3uv,aP4uv)) );
					}

				}
			}
		}
		// --
		return l_oGeometry;
	}
}