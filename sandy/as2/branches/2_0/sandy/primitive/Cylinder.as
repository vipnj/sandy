import sandy.primitive.Primitive3D;
import sandy.core.data.UVCoord;
import sandy.core.scenegraph.Shape3D;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.data.Vertex;
import com.bourre.log.Logger;

/**
 * All credits goes to Tim Knip
 * Original source code is avialable at : http://suite75.net/svn/papervision3d/tim/as2/org/papervision3d/objects/Cylinder.as
 */
class sandy.primitive.Cylinder extends Shape3D implements Primitive3D
{
	/**
	* Number of segments horizontally. Defaults to 8.
	*/
	public var segmentsW :Number;

	/**
	* Number of segments vertically. Defaults to 6.
	*/
	public var segmentsH :Number;

	/**
	* Default radius of Cylinder if not defined.
	*/
	static public var DEFAULT_RADIUS :Number = 100;

	/**
	* Default height if not defined.
	*/
	static public var DEFAULT_HEIGHT :Number = 100;

	/**
	* Default scale of Cylinder texture if not defined.
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


	private var topRadius:Number;
	private var radius:Number;
	private var height:Number;
	
	/**
	* Create a new Cylinder object.
	* <p/>
	* @param	p_sName The name of the object
	* <p/>
	* @param	radius		[optional] - Desired radius.
	* <p/>
	* @param	segmentsW	[optional] - Number of segments horizontally. Defaults to 8.
	* <p/>
	* @param	segmentsH	[optional] - Number of segments vertically. Defaults to 6.
	* <p/>
	* @param	topRadius	[optional] - An optional parameter for con- or diverging cylinders
	* <p/>
	* @param	initObject	[optional] - An object that contains user defined properties with which to populate the newly created GeometryObject3D.
	* <p/>
	* It includes x, y, z, rotationX, rotationY, rotationZ, scaleX, scaleY scaleZ and a user defined extra object.
	* <p/>
	* If extra is not an object, it is ignored. All properties of the extra field are copied into the new instance. The properties specified with extra are publicly available.
	*/
	function Cylinder( p_sName:String, p_nRadius:Number, p_nHeight:Number, p_nSegmentsW:Number, p_nSegmentsH:Number, p_nTopRadius:Number )
	{
		super( p_sName );

		this.segmentsW = Math.max( MIN_SEGMENTSW, p_nSegmentsW || DEFAULT_SEGMENTSW); // Defaults to 8
		this.segmentsH = Math.max( MIN_SEGMENTSH, p_nSegmentsH || DEFAULT_SEGMENTSH); // Defaults to 6
		radius = (p_nRadius==undefined) ? DEFAULT_RADIUS : p_nRadius; // Defaults to 100
		height = (p_nHeight==undefined) ? DEFAULT_HEIGHT : p_nHeight; // Defaults to 100
		topRadius = (p_nTopRadius==undefined) ? radius : p_nTopRadius;

		var scale :Number = DEFAULT_SCALE;
		
		geometry = generate();
	}

	public function generate():Geometry3D
	{
		var l_oGeometry3D:Geometry3D = new Geometry3D();
		// --
		var i:Number, j:Number, k:Number;
		var iHor:Number = Math.max(3,this.segmentsW);
		var iVer:Number = Math.max(2,this.segmentsH);
		var aVtc:Array = new Array();
		// --
		for ( j = 0; j < (iVer+1); j++ ) 
		{ // vertical
			var fRad1:Number = Number(j/iVer);
			var fZ:Number = height*(j/(iVer+0))-height/2;
			var fRds:Number = topRadius+(radius-topRadius)*(1-j/(iVer));
			var aRow:Array = new Array();
			var oVtx:Number;
			// --
			for ( i = 0; i < (iHor); i++ ) 
			{ // horizontal
				var fRad2:Number = Number(2*i/iHor);
				var fX:Number = fRds*Math.sin(fRad2*Math.PI);
				var fY:Number = fRds*Math.cos(fRad2*Math.PI);
				// --
				oVtx = l_oGeometry3D.setVertex( l_oGeometry3D.getNextVertexID(), fY, fZ, fX );//fY, -fZ, fX );
				aRow.push(oVtx);
			}
			aVtc.push(aRow);
		}

		var iVerNum:Number = aVtc.length;

		var aP4uv:Number, aP1uv:Number, aP2uv:Number, aP3uv:Number;
		var aP1:Number, aP2:Number, aP3:Number, aP4:Number;
		var l_oP1:Vertex, l_oP2:Vertex, l_oP3:Vertex;
		// --
		var nF:Number;
		for ( j=0; j<iVerNum; j++ ) 
		{
			var iHorNum:Number = aVtc[j].length;
			for ( i=0; i<iHorNum; i++ ) 
			{
				if ( j > 0 && i >= 0 ) 
				{
					// select vertices
					var bEnd:Boolean = i==(iHorNum-0);
					// --					
					aP1 = aVtc[j][bEnd?0:i];
					aP2 = aVtc[j][(i==0?iHorNum:i)-1];
					aP3 = aVtc[j-1][(i==0?iHorNum:i)-1];
					aP4 = aVtc[j-1][bEnd?0:i];
					// -- uv
					var fJ0:Number = j		/ iVerNum;
					var fJ1:Number = (j-1)	/ iVerNum;
					var fI0:Number = (i+1)	/ iHorNum;
					var fI1:Number = i		/ iHorNum;
					//
					aP4uv = l_oGeometry3D.setUVCoords(l_oGeometry3D.getNextUVCoordID(), fI0, 1-fJ1);
					aP1uv = l_oGeometry3D.setUVCoords(l_oGeometry3D.getNextUVCoordID(), fI0, 1-fJ0);
					aP2uv = l_oGeometry3D.setUVCoords(l_oGeometry3D.getNextUVCoordID(), fI1, 1-fJ0);
					aP3uv = l_oGeometry3D.setUVCoords(l_oGeometry3D.getNextUVCoordID(), fI1, 1-fJ1);
					// 2 faces
					nF = l_oGeometry3D.setFaceVertexIds( l_oGeometry3D.getNextFaceID(), aP1, aP2, aP3 );
					l_oGeometry3D.setFaceUVCoordsIds( nF, aP1uv, aP2uv, aP3uv );
					
					nF = l_oGeometry3D.setFaceVertexIds( l_oGeometry3D.getNextFaceID(), aP1, aP3, aP4 );
					l_oGeometry3D.setFaceUVCoordsIds( nF, aP1uv, aP3uv, aP4uv );
				}
			}
			if (j==0||j==(iVerNum-1)) 
			{
				for (i=0;i<(iHorNum-2);i++) 
				{
					// uv
					var iI:Number = Math.floor(i/2);
					aP1 = aVtc[j][iI];
					aP2 = (i%2==0)? (aVtc[j][iHorNum-2-iI]) : (aVtc[j][iI+1]);
					aP3 = (i%2==0)? (aVtc[j][iHorNum-1-iI]) : (aVtc[j][iHorNum-2-iI]);

					// --
					l_oP1 = l_oGeometry3D.aVertex[aP1];
					l_oP2 = l_oGeometry3D.aVertex[aP2];
					l_oP3 = l_oGeometry3D.aVertex[aP3];
					// --
					var bTop:Boolean = j==0;
					aP1uv = l_oGeometry3D.setUVCoords(l_oGeometry3D.getNextUVCoordID(), (bTop?1:0)+(bTop?-1:1)*(l_oP1.x/radius/2+.5), 1-(l_oP1.z/radius/2+.5) );
					aP2uv = l_oGeometry3D.setUVCoords(l_oGeometry3D.getNextUVCoordID(), (bTop?1:0)+(bTop?-1:1)*(l_oP2.x/radius/2+.5), 1-(l_oP2.z/radius/2+.5) );
					aP3uv = l_oGeometry3D.setUVCoords(l_oGeometry3D.getNextUVCoordID(), (bTop?1:0)+(bTop?-1:1)*(l_oP3.x/radius/2+.5), 1-(l_oP3.z/radius/2+.5) );
					
					// face
					if (j==0)
					{ 	
						nF = l_oGeometry3D.setFaceVertexIds( l_oGeometry3D.getNextFaceID(), aP1, aP3, aP2 );
						l_oGeometry3D.setFaceUVCoordsIds( nF, aP1uv, aP3uv, aP2uv );
					}
					else
					{
						nF = l_oGeometry3D.setFaceVertexIds( l_oGeometry3D.getNextFaceID(), aP1, aP2, aP3 );
						l_oGeometry3D.setFaceUVCoordsIds( nF, aP1uv, aP2uv, aP3uv );
					}
					//if (j==0)	aFace.push( new Face3D(new Array(aP1,aP3,aP2), this.material, new Array(aP1uv,aP3uv,aP2uv)) );
					//else		aFace.push( new Face3D(new Array(aP1,aP2,aP3), this.material, new Array(aP1uv,aP2uv,aP3uv)) );
				}
			}
		}
		// --
		return l_oGeometry3D;
	}
}

