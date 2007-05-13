package sandy.parser
{
	import flash.events.Event;
	import flash.xml.XMLNode;
	
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.Appearance;
	import sandy.materials.WireFrameMaterial;
	import sandy.core.data.Vertex;
	
	public class ColladaParser extends AParser implements IParser
	{
		private var m_oCollada : XML;
		private var m_bYUp : Boolean; 
		
		public function ColladaParser( p_sUrl:String )
		{
			super( p_sUrl );
		}
		
		protected override function parseData( e:Event ) : void
		{
			super.parseData( e );
			
			// -- read the XML
			m_oCollada = new XML( m_oFileLoader.data );
			default xml namespace = m_oCollada.namespace();
			
			parseScene( m_oCollada.library_visual_scenes.visual_scene[0] );
		}
		
		private function parseScene( p_oScene : XML ) : void
		{
			// -- local variables
			var l_oNodes : XMLList = p_oScene.node;
			var l_nNodeLen : int = l_oNodes.length();
			var l_oGeometry : Geometry3D;
			var l_oAppearance : Appearance;

			for( var i:int = 0; i < l_nNodeLen; i++ )
			{
				var l_oNode : XML = l_oNodes[i];
				l_oGeometry = new Geometry3D();
				l_oAppearance = new Appearance( new WireFrameMaterial() );

				var l_aGeomArray:Array = l_oNode.instance_geometry.@url.split("#");
				var l_sGeometryID : String = l_aGeomArray[1];
				// -- get the vertices
				l_oGeometry = getGeometry( l_sGeometryID ); 
				
				// -- create the new shape
				var l_oShape:Shape3D = new Shape3D( l_oNode.@name, l_oGeometry, l_oAppearance );

				// -- add the shape to the group node
				m_oGroup.addChild( l_oShape );
			}

			// -- Parsing is finished
			var l_eOnInit : ParserEvent = new ParserEvent( ParserEvent.onInitEVENT );
			l_eOnInit.group = m_oGroup;
			dispatchEvent( l_eOnInit );
		}
		
		private function getGeometry( p_sGeometryID : String ) :  Geometry3D
		{
			var i : int;
			var l_oOutpGeom : Geometry3D = new Geometry3D();
			var l_oGeometry : XMLList = m_oCollada.library_geometries.geometry.( @id == p_sGeometryID );

			// -- triangles
			var l_oTriangles : XML = l_oGeometry.mesh.triangles[0];
			var l_aTriangles : Array = stringToArray( l_oTriangles.p );
			var l_nCount : Number = Number( l_oTriangles.@count );
			var l_nStep : Number = l_oTriangles.input.length(); 
			
			// -- get vertices float array
			var l_sVerticesID : String = l_oTriangles.input.( @semantic == "VERTEX" ).@source.split("#")[1];
			var l_sPosSourceID : String = l_oGeometry..vertices.( @id == l_sVerticesID ).input.( @semantic == "POSITION" ).@source.split("#")[1];
			var l_aVertexFloats : Array = getFloatArray( l_sPosSourceID, l_oGeometry );
			var l_nVertexFloat : int = l_aVertexFloats.length;
			var l_aVertices : Array = new Array();
			
			// -- set vertices
			for( i = 0; i < l_nVertexFloat; i++ )
			{
				var l_oVertex:Object = l_aVertexFloats[ i ];
				
				l_oOutpGeom.setVertex( 
					i, 
					l_oVertex.x, 
					-l_oVertex.z,
					l_oVertex.y
				);
			} 
			
			// -- get uvcoords float array 		
			var l_sUVCoordsID : String = l_oTriangles.input.( @semantic == "TEXCOORD" ).@source.split("#")[1];
			var l_aUVCoordsFloats : Array = getFloatArray( l_sUVCoordsID, l_oGeometry );
			var l_nUVCoordsFloats : int = l_aUVCoordsFloats.length;
			
			// -- set uvcoords
			for( i = 0; i < l_nUVCoordsFloats; i++ )
			{
				var l_oUVCoord:Object = l_aUVCoordsFloats[ i ];
				
				l_oOutpGeom.setUVCoords( 
					i, 
					l_oUVCoord.x, 
					1 - l_oUVCoord.y
				);		
			}
			/*
			// -- get normals float array 		
			var l_sNormalsID : String = l_oTriangles.input.( @semantic == "NORMAL" ).@source.split("#")[1];
			var l_aNormalFloats : Array = getFloatArray( l_sNormalsID, l_oGeometry );
			var l_nNormalFloats : int = l_aNormalFloats.length;
			
			// -- set normals
			for( i = 0; i < l_nNormalFloats; i++ )
			{
				var l_oNormal:Object = l_aNormalFloats[ i ];
				
				l_oOutpGeom.setVertexNormal( 
					i, 
					l_oNormal.x, 
					l_oNormal.y,
					l_oNormal.z
				);
			} 
			
			
			*/
			l_aTriangles = convertTriangleArray( l_oTriangles.input, l_aTriangles, l_nCount );
			var l_nTriangeLength : int = l_aTriangles.length;
			
			// -- get specific array indices
			var l_nVertexIndex : Number = Number( l_oTriangles.input.( @semantic == "VERTEX" ).@offset );
			var l_nNormalIndex : Number = Number( l_oTriangles.input.( @semantic == "NORMAL" ).@offset );
			var l_nUVCoordsIndex : Number = Number( l_oTriangles.input.( @semantic == "TEXCOORD" ).@offset );
			
			for( i = 0; i < l_nTriangeLength; i++ )
			{
				var l_aVertex : Array = l_aTriangles[ i ].VERTEX;
				var l_aNormals : Array = l_aTriangles[ i ].NORMAL;
				
				l_oOutpGeom.setFaceVertexIds( i, l_aVertex[ 0 ], l_aVertex[ 2 ], l_aVertex[ 1 ] );
				l_oOutpGeom.setFaceUVCoordsIds( i, l_aVertex[ 0 ], l_aVertex[ 2 ], l_aVertex[ 1 ] );
			}
						
			return l_oOutpGeom;
		}
		
		private function getFloatArray( p_sSourceID : String, p_oGeometry : XMLList ) : Array
		{
			var l_aFloatArray : Array = p_oGeometry..source.( @id == p_sSourceID ).float_array.split(" ");
			var l_nFloatArray : int = l_aFloatArray.length;
			var l_aOutput : Array = new Array();
			
			for( var i:int = 0; i < l_nFloatArray; i += 3 )
			{
				var l_oCoords : Object = {
					x : Number( l_aFloatArray[ i ] ),
					y : Number( l_aFloatArray[ i + 1 ] ),
					z : Number( l_aFloatArray[ i + 2 ] )
				}
				l_aOutput.push( l_oCoords );
			}
			
			return l_aOutput;
		}
		
		private function convertTriangleArray( p_oInput : XMLList, p_aTriangles : Array, p_nTriangleCount : int ) : Array
		{
			var l_nInput : int = p_oInput.length();
			var l_nTriangles : int = p_aTriangles.length;
			var l_aOutput : Array = new Array();
			
			// -- iterate through all triangles
			for( var i : int = 0; i < p_nTriangleCount; i++ )
			{
				var semantic : Object = new Object();
				
				// -- iterate through each input field
				for( var j : int = 0; j < 3; j++ )
				{
					for( var k : int = 0; k < l_nInput; k++ )
					{
						if( !semantic[ p_oInput[ k ].@semantic ] )
							semantic[ p_oInput[ k ].@semantic ] = new Array();
						
						semantic[ p_oInput[ k ].@semantic ].push( p_aTriangles.shift() );
					}
				}
				
				l_aOutput.push( semantic );
			}
			
			return l_aOutput;
		}
		
		private function stringToArray( p_sValues : String ) : Array
		{
			var l_aValues : Array = p_sValues.split(" ");
			var l_nValues : int = l_aValues.length;
			
			for( var i:int = 0; i < l_nValues; i++ )
			{
				l_aValues[i] = Number( l_aValues[i] );
			}
			
			return l_aValues;
		}
	}
}