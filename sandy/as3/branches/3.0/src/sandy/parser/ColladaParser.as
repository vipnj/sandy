package sandy.parser
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vector;
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.Node;
	import sandy.core.scenegraph.Shape3D;
	import sandy.events.QueueEvent;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.ColorMaterial;
	import sandy.math.Matrix4Math;
	import sandy.util.LoaderQueue;
	import sandy.util.NumberUtil;
	
	public class ColladaParser extends AParser implements IParser
	{
		private var m_oCollada : XML;
		private var m_bYUp : Boolean; 
		
		private var m_oMaterials : Object;
		
		public var RELATIVE_TEXTURE_PATH : String;
		
		public function ColladaParser( p_sUrl:*, p_nScale:Number )
		{
			super( p_sUrl, p_nScale );
		}
		
		protected override function parseData( e:Event=null ) : void
		{
			super.parseData( e );
			
			// -- read the XML
			m_oCollada = XML( m_oFile );

			default xml namespace = m_oCollada.namespace();
			
			if( m_oCollada.library_images.length() > 0 )
				m_oMaterials = loadImages( m_oCollada.library_images.image );
			else
				parseScene( m_oCollada.library_visual_scenes.visual_scene[0] );
		}
		
		private function parseScene( p_oScene : XML ) : void
		{
			// -- local variables
			var l_oNodes : XMLList = p_oScene.node;
			var l_nNodeLen : int = l_oNodes.length();

			for( var i:int = 0; i < l_nNodeLen; i++ )
			{
				var l_oNode : Node = parseNode( l_oNodes[i] );
				// -- add the shape to the group node
				if( l_oNode != null )
					m_oGroup.addChild( l_oNode );
			}

			// -- Parsing is finished
			var l_eOnInit : ParserEvent = new ParserEvent( ParserEvent.onInitEVENT );
			l_eOnInit.group = m_oGroup;
			dispatchEvent( l_eOnInit );
		}
		
		private function parseNode( p_oNode : XML ) : Node
		{
			// -- local variables
			var l_oGeometry : Geometry3D;

			if( p_oNode.child( "instance_geometry" ).length() != 0 )
			{
				var l_oMatrix : Matrix4 = new Matrix4();
				var l_aGeomArray:Array;
				var l_sGeometryID : String;
				var l_oShape:Shape3D;
				var l_oNodes : XMLList;
				var l_nNodeLen : int;
				var l_oAppearance : Appearance = m_oStandardAppearance;
				//var l_oScale : Transform3D;
				
				// -- scale
				if( p_oNode.scale.length() > 0 ) {
					l_oMatrix.multiply( 
						Matrix4Math.scaleVector( stringToVector( p_oNode.scale ) )
					);
				}
				// -- translation
				if( p_oNode.translate.length() > 0 ) {
					l_oMatrix.multiply( 
						Matrix4Math.translationVector( stringToVector( p_oNode.translate ) )
					);
				}
				
				l_oGeometry = new Geometry3D();
				//l_oAppearance = m_oStandardAppearance;//getAppearance( p_oNode );
				l_oAppearance = getAppearance( p_oNode );
				//l_oMaterials = getMaterials( p_oNode );
				//l_oAppearance = new Appearance( new BitmapMaterial( m_oMaterials[ "D__Dev_FlexProjects_Papervision3DTutorial_assets_borobudur-java-indonesia_png" ].bitmapData ) );
				
				l_aGeomArray = p_oNode.instance_geometry.@url.split( "#" );
				l_sGeometryID = l_aGeomArray[ 1 ];
				// -- get the vertices
				l_oGeometry = getGeometry( l_sGeometryID, m_oMaterials ); 
				
				// -- create the new shape
				l_oShape = new Shape3D( p_oNode.@name, l_oGeometry, l_oAppearance );

				// -- loop through subnodes
				l_oNodes = p_oNode.node;
				l_nNodeLen = l_oNodes.length();
	
				for( var i:int = 0; i < l_nNodeLen; i++ )
				{
					var l_oNode : Node = parseNode( l_oNodes[i] );
				// -- add the shape to the group node
					if( l_oNode != null )
						l_oShape.addChild( l_oNode );
				}

//				l_oShape.appearance = l_oAppearance;//;new Appearance( new ColorMaterial( 0xFF, 100, new LineAttributes() ) );

				// -- doesn't work yet
				l_oShape.matrix = l_oMatrix;
				return l_oShape;
			} 
			else 
			{
				return null;
			}
		}
		
		private function getGeometry( p_sGeometryID : String, p_oMaterials : Object ) :  Geometry3D
		{
			var i : int;
			var l_oOutpGeom : Geometry3D = new Geometry3D();
			var l_oGeometry : XMLList = m_oCollada.library_geometries.geometry.( @id == p_sGeometryID );

			// -- triangles
			var l_oTriangles : XML = l_oGeometry.mesh.triangles[0];
			var l_aTriangles : Array = stringToArray( l_oTriangles.p );
			var l_sMaterial : String = l_oTriangles.@material;
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
					l_oVertex.x * m_nScale, 
					l_oVertex.z * m_nScale,
					l_oVertex.y * m_nScale
				);
			} 
			
			if( l_oTriangles.input.( @semantic == "TEXCOORD" ).length() > 0 )
			{
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
				var l_aUVs : Array = l_aTriangles[ i ].TEXCOORD;

				l_oOutpGeom.setFaceVertexIds( i, l_aVertex[ 0 ], l_aVertex[ 1 ], l_aVertex[ 2 ] );
				l_oOutpGeom.setFaceUVCoordsIds( i, l_aUVs[ 0 ], l_aUVs[ 1 ], l_aUVs[ 2 ] );

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
		
		private function stringToVector( p_sValues : String ) : Vector
		{
			var l_aValues : Array = p_sValues.split(" ");
			var l_nValues : int = l_aValues.length;
			
			if( l_nValues != 3 )
				throw new Error( "A vector must have 3 values" );
			
			return new Vector( l_aValues[ 0 ], l_aValues[ 1 ], l_aValues[ 2 ] );
	}
		
		private function getAppearance( p_oNode : XML ) : Appearance
		{
			// -- local variables
			var l_oAppearance : Appearance = null;
			
			// -- Get this node's instance materials
			for each( var l_oInstMat : XML in p_oNode..instance_material )
			{
				// -- get the corresponding material from the library
				var l_oMaterial : XML = m_oCollada.library_materials.material.( @id == l_oInstMat.@target.split( "#" )[ 1 ] )[ 0 ];
				// -- get the corresponding effect
				var l_sEffectID : String = l_oMaterial.instance_effect.@url.split( "#" )[ 1 ];
				
				var l_oEffect : XML = ( l_sEffectID == "" )
					? m_oCollada.library_effects.effect[ 0 ][ 0 ]
					: m_oCollada.library_effects.effect.( @id == l_sEffectID )[ 0 ];
				
				// -- no textures here or colors defined 
				if( l_oEffect..texture.length() == 0 && l_oEffect..phong.length() == 0 ) return m_oStandardAppearance;
				
				if( l_oEffect..texture.length() > 0 )
				{
					// -- get the texture ID and use it to get the surface source
					var l_sTextureID : String = l_oEffect..texture[ 0 ].@texture;
					var l_sSurfaceID : String = l_oEffect..newparam.( @sid == l_sTextureID ).sampler2D.source;
					
					// -- now get the image ID
					var l_sImageID : String = l_oEffect..newparam.( @sid == l_sSurfaceID ).surface.init_from;
					// -- get image's location on the hard drive
					
					if( m_oMaterials[ l_sImageID ] ) l_oAppearance = new Appearance( new BitmapMaterial( m_oMaterials[ l_sImageID ].bitmapData ) );
					if( l_oAppearance == null ) l_oAppearance = m_oStandardAppearance;
				}
				else if( l_oEffect..phong.length() > 0 )
				{
					// -- get the ambient color
					var l_aColors : Array = stringToArray( l_oEffect..phong..ambient.color );
					var l_nColor : Number;
					
					var r : int = NumberUtil.constrain( l_aColors[0] * 255, 0, 255 );
					var g : int = NumberUtil.constrain( l_aColors[1] * 255, 0, 255 );
					var b : int = NumberUtil.constrain( l_aColors[2] * 255, 0, 255 );

					l_nColor =  r << 16 | g << 8 |  b;
					
					l_oAppearance = new Appearance( new ColorMaterial( l_nColor, l_aColors[ 3 ] * 100 ) );
				}				
			}
			
			if( l_oAppearance == null ) return m_oStandardAppearance;
			else return l_oAppearance;
		}
		
		private function loadImages( p_oLibImages : XMLList ) : Object
		{
			var l_oImages : Object = new Object();
			var l_oQueue : LoaderQueue = new LoaderQueue();
			
			for each( var l_oImage : XML in p_oLibImages )
			{
				var l_oInitFrom : String = l_oImage.init_from;
				l_oImages[ l_oImage.@id ] = {
					id : l_oImage.@id,
					fileName : l_oInitFrom.substring( l_oInitFrom.lastIndexOf( "/" ) + 1, l_oInitFrom.length )
				}
				
				l_oQueue.add( 
					l_oImage.@id,
					new URLRequest( RELATIVE_TEXTURE_PATH + "/" + l_oImages[ l_oImage.@id ].fileName )
				);
					
				trace(l_oImages[ l_oImage.@id ].fileName);
			}
			l_oQueue.addEventListener( QueueEvent.QUEUE_COMPLETE, imageQueueCompleteHandler );
			l_oQueue.addEventListener( QueueEvent.QUEUE_LOADER_ERROR, imageQueueLoaderErrorHandler );
			l_oQueue.start();
			
			return l_oImages;
		}
		
		private function imageQueueCompleteHandler( p_oEvent : QueueEvent ) : void
		{
			var l_oLoaders : Object = p_oEvent.getLoaders();
			
			for each( var l_oLoader : Object in l_oLoaders )
			{
				m_oMaterials[ l_oLoader.ID ].bitmapData = Bitmap( l_oLoader.loader.content ).bitmapData;
			}
			
			parseScene( m_oCollada.library_visual_scenes.visual_scene[0] );
		}
		
		private function imageQueueLoaderErrorHandler( p_oEvent : QueueEvent ) : void
		{
			trace("loading failed");
			
			parseScene( m_oCollada.library_visual_scenes.visual_scene[0] );
		}
	}
}
