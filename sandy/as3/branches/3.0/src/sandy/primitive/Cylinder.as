package sandy.primitive
 {
	import sandy.core.data.Vertex;
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.Shape3D;
	
       	/**
	 *
	 * The Cylinder class is used for creating a cylinder primitive or a truncated cone.
	 * All credits go to Tim Knipt from suite75.net who did the AS2 implementation.
	 * Original sources available at : http://www.suite75.net/svn/papervision3d/tim/as2/org/papervision3d/objects/Cone.as
	 * 
	 * @author		Thomas Pfeiffer
	 * @author		Tim Knipt
	 * @version		3.0
	 * @date 		26.07.2007
	 *
	 * @example To create a cylinder with a base radius of 150 and a height of 300,
	 * with default number of faces, here is the statement:
	 *
	 * <listing version="3.0">
	 *     var cyl:Cylinder = new Cylinder( "theCylinder", 150, 300 );
	 *  </listing>
	 * To create a truncated cone, you pass a top radius value to the constructor
	 * <listing version="3.0">
	 *     var tCone:Cylinder = new Cylinder( "trunkCone", 150, 300, 0, 0, 40 );
	 *  </listing>
	 * You can exclude the top or bottom surfaces, by passing true values in the last two parameters.
	 */
	public class Cylinder extends Shape3D implements Primitive3D
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
		* Default radius
		*/
		static public var DEFAULT_RADIUS :Number = 100;
	
		/**
		* Default height
		*/
		static public var DEFAULT_HEIGHT :Number = 100;
	
		/**
		* Default scale of Cylinder texture
		*/
		static public var DEFAULT_SCALE :Number = 1;
	
		/**
		* Default value for number of segments hoizontally
		*/
		static public var DEFAULT_SEGMENTSW :Number = 8;
	
		/**
		* Default for number of segments vertically
		*/
		static public var DEFAULT_SEGMENTSH :Number = 6;
	
		/**
		* Minimum value for number of segments hoizontally
		*/
		static public var MIN_SEGMENTSW :Number = 3;
	
		/**
		* Minimum value for number of segments hoizontally
		*/
		static public var MIN_SEGMENTSH :Number = 2;
	
	
		private var topRadius:Number;
		private var radius:Number;
		private var height:Number;
		
		private var m_bIsTopExcluded:Boolean;
		private var m_bIsBottomExcluded:Boolean;

		/**
		* Creates a Cylinder primitive or truncated cone.
		*
		* <p>The cylinder is created at the origin of the world coordinate system, with its axis
		* along the y axis, and with the bottom and top surfaces paralell to the zx plane</p>
		*
		* <p>Most arguments to the constructor have default values. If you pass in a top radius, 
		* that is different from the bottom radius, a truncated cone is created.</br>
		* By passing true values to one or both of p_bExcludeBottom and p_bExludeTop, 
		* you exclude the bottom and/or top surfaces from being created.</p>
		* 
		* @param	p_sName 	A String identifier of this object
		* @param	radius		[optional] - Desired radius. Defaults to 100
		* @param	p_nHeight	[optional] - Desired height. Defaults to 100		
		* @param	segmentsW	[optional] - Number of segments horizontally. Defaults to 8.
		* @param	segmentsH	[optional] - Number of segments vertically. Defaults to 6.
		* @param	topRadius	[optional] - An optional parameter for cone- or diverging cylinders
		* @param	p_bExcludeBottom[optional] - Exclude the creation of the bottom surface. Default false
		* @param	p_bExludeTop	[optional] - Exclude the creation of the top surface. Default false
		*/
		function Cylinder( p_sName:String = null, p_nRadius:Number=100, p_nHeight:Number=100, p_nSegmentsW:Number=8, p_nSegmentsH:Number=6, p_nTopRadius:Number=0, p_bExcludeBottom:Boolean=false, p_bExludeTop:Boolean=false )
		{
			super( p_sName );
	
			this.segmentsW = Math.max( MIN_SEGMENTSW, p_nSegmentsW || DEFAULT_SEGMENTSW); // Defaults to 8
			this.segmentsH = Math.max( MIN_SEGMENTSH, p_nSegmentsH || DEFAULT_SEGMENTSH); // Defaults to 6
			radius = (p_nRadius==0) ? DEFAULT_RADIUS : p_nRadius; // Defaults to 100
			height = (p_nHeight==0) ? DEFAULT_HEIGHT : p_nHeight; // Defaults to 100
			topRadius = (p_nTopRadius==0) ? radius : p_nTopRadius;
	
			var scale :Number = DEFAULT_SCALE;
			m_bIsBottomExcluded = p_bExcludeBottom;
			m_bIsTopExcluded = p_bExludeTop;
			
			geometry = generate();
		}
		
		/**
		 * Generates the geometry for this Shape3D
		 *
		 * @see sandy.core.data.Vertex
		 * @see sandy.core.data.UVCoord
		 * @see sandy.core.data.Polygon
		 */
		public function generate(... arguments):Geometry3D
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
				if ((j==0 && !m_bIsTopExcluded) || ( j==(iVerNum-1) && !m_bIsBottomExcluded ) ) 
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
		public override function toString():String
		{
			return "sandy.primitive.Cylinder";
		}		
	}
}