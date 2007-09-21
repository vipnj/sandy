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

package sandy.parser
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.net.URLRequest;

	import sandy.core.data.*;
	import sandy.core.scenegraph.*;
	import sandy.events.QueueEvent;
	import sandy.materials.*;
	import sandy.math.Matrix4Math;
	import sandy.util.LoaderQueue;
	import sandy.util.NumberUtil;

	/**
	 * Transforms a COLLADA XML Document into Sandy geometries.
	 * <p>Creates a Group as rootnode which appends all geometries it finds.
	 * Recommended settings for the COLLADA exporter:</p>
	 * <ul>
	 * <li>Relative paths</li>
	 * <li>Triangulate</li>
	 * <li>Normals</li>
	 * </ul>
	 *
	 * @author		Dennis Ippel - ippeldv
	 * @since		1.0
	 * @version		3.0
	 * @date 		26.07.2007
	 *
	 * @example To parse a COLLADA object at runtime:
	 *
	 * <listing version="3.0">
	 *     var parser:IParser = Parser.create( "/path/to/my/colladafile.dae", Parser.COLLADA );
	 * </listing>
	 *
	 * @example To parse an embedded COLLADA object:
	 *
	 * <listing version="3.0">
	 *     [Embed( source="/path/to/my/colladafile.dae", mimeType="application/octet-stream" )]
	 *     private var MyCollada:Class;
	 *
	 *     ...
	 *
	 *     var parser:IParser = Parser.create( new MyCollada(), Parser.COLLADA );
	 * </listing>
	 */

	public class ColladaParser extends AParser implements IParser
	{
		private var m_oCollada : XML;
		private var m_bYUp : Boolean;

		private var m_oMaterials : Object;

		public var RELATIVE_TEXTURE_PATH : String;

		/**
		 * Creates a new COLLADA parser instance.
		 *
		 * @param p_sUrl		Can be either a string pointing to the location of the
		 * 						COLLADA file or an instance of an embedded COLLADA file
		 * @param p_nScale		The scale factor
		 */
		public function ColladaParser( p_sUrl:*, p_nScale:Number )
		{
			super( p_sUrl, p_nScale );
		}

		/**
		 * Starts the parsing process
		 *
		 * @param e				The Event object
		 */
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

		/**
		 * Parses the 3D scene
		 * @param p_oScene		COLLADA XML's scene node
		 */
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

		/**
		 * Reads the geometry and materials. Also performs scaling, translation
		 * and rotation operations.
		 * @param p_oNode		XML node containing a node from the 3D scene
		 * @return 				A parsed Shape3D
		 */
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
				var l_oVector : Vector;
				//var l_oScale : Transform3D;

				l_oGeometry = new Geometry3D();
				l_oAppearance = getAppearance( p_oNode );

				l_aGeomArray = p_oNode.instance_geometry.@url.split( "#" );
				l_sGeometryID = l_aGeomArray[ 1 ];
				// -- get the vertices
				l_oGeometry = getGeometry( l_sGeometryID, m_oMaterials );

				// -- create the new shape
				l_oShape = new Shape3D( p_oNode.@name, l_oGeometry, l_oAppearance );

				// -- scale
				if( p_oNode.scale.length() > 0 ) {
					l_oVector = stringToVector( p_oNode.scale );
					l_oMatrix.multiply(
						Matrix4Math.scale(
							l_oVector.x,
							l_oVector.z,
							l_oVector.y )
						)
					);
				}
				// -- translation
				if( p_oNode.translate.length() > 0 ) {
					l_oVector = stringToVector( p_oNode.translate );
					l_oMatrix.multiply(
						Matrix4Math.translation(
							l_oVector.x,
							l_oVector.z,
							l_oVector.y )
					);
				}
				// -- rotate
 				if( p_oNode.rotate.length() == 1 ) {
					var l_oRotations : Array = stringToArray( p_oNode.rotate );
					l_oMatrix.multiply(
						Matrix4Math.axisRotation(
							l_oRotations[ 0 ],
							l_oRotations[ 2 ],
							l_oRotations[ 1 ],
							l_oRotations[ 3 ] )
					);
				} else if( p_oNode.rotate.length() == 3 ) {
					for( var j:int=0; j < 3; j++ )
					{
						var l_oRot : Array = stringToArray( p_oNode.rotate[i] );

						switch( p_oNode.rotate[j].@sid.toLowerCase() )
						{
							case "rotatex":
								l_oShape.rotateX = Number( l_oRot[ 3 ] );
								break;
							case "rotatey":
								l_oShape.rotateY = Number( l_oRot[ 3 ] );
								break;
							case "rotatez":
								l_oShape.rotateZ = Number( l_oRot[ 3 ] );
								break;
						}
					}
				}

				// -- baked matrix
				if( p_oNode.matrix.length() > 0 ) 
				{
					l_oMatrix.multiply(
						stringToMatrix( p_oNode.matrix )
					);
					//l_oShape.setPosition( l_oMatrix.n14, l_oMatrix.n34, l_oMatrix.n24 );
					l_oShape.scaleX = l_oMatrix.n11;
					l_oShape.scaleY = l_oMatrix.n33;
					l_oShape.scaleZ = l_oMatrix.n22;
				}

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

				l_oShape.matrix = l_oMatrix;

				return l_oShape;
			}
			else
			{
				return null;
			}
		}

		/**
		 * Parses the geometry XML of a certain node.
		 *
		 * @param p_sGeometryID		The COLLADA node ID
		 * @param p_oMaterials		An object array containing all the loaded materials
		 * @return 					The parsed Geometry3D
		 */
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

			// -- get normals float array
			if(  l_oTriangles.input.( @semantic == "NORMAL" ).length() > 0 )
			{
				var l_sNormalsID : String = l_oTriangles.input.( @semantic == "NORMAL" ).@source.split("#")[1];
				var l_aNormalFloats : Array = getFloatArray( l_sNormalsID, l_oGeometry );
				var l_nNormalFloats : int = l_aNormalFloats.length;

				// -- set normals
				for( i = 0; i < l_nNormalFloats; i++ )
				{
					var l_oNormal:Object = l_aNormalFloats[ i ];

					l_oOutpGeom.aVertexNormals[ i ] = new Vertex(
						l_oNormal.x,
						l_oNormal.z,
						l_oNormal.y
					);
				}
			}

			l_aTriangles = convertTriangleArray( l_oTriangles.input, l_aTriangles, l_nCount );
			var l_nTriangeLength : int = l_aTriangles.length;

			for( i = 0; i < l_nTriangeLength; i++ )
			{
				var l_aVertex : Array = l_aTriangles[ i ].VERTEX;
				var l_aNormals : Array = l_aTriangles[ i ].NORMAL;
				var l_aUVs : Array = l_aTriangles[ i ].TEXCOORD;

				l_oOutpGeom.setFaceVertexIds( i, l_aVertex[ 0 ], l_aVertex[ 1 ], l_aVertex[ 2 ] );
				if( l_aUVs != null ) l_oOutpGeom.setFaceUVCoordsIds( i, l_aUVs[ 0 ], l_aUVs[ 1 ], l_aUVs[ 2 ] );

			}

			return l_oOutpGeom;
		}

		/**
		 * Takes a space separated string from an XML node and turns it into a vector array
		 * @param p_sSourceID		The COLLADA node ID
		 * @param p_oGeometry		And XMLList containing space separated values
		 * @return 					An array containing parsed vectors
		 */
		private function getFloatArray( p_sSourceID : String, p_oGeometry : XMLList ) : Array
		{
			var l_aFloatArray : Array = p_oGeometry..source.( @id == p_sSourceID ).float_array.split(" ");
			var l_nCount:uint = p_oGeometry..source.( @id == p_sSourceID ).technique_common.accessor.@count;
			var l_nOffset:uint = p_oGeometry..source.( @id == p_sSourceID ).technique_common.accessor.@stride;

			var l_nFloatArray : int = l_aFloatArray.length;
			var l_aOutput : Array = new Array();

			for( var i:int = 0; i < l_nFloatArray; i += l_nOffset )
			{
				var l_oCoords : Object;
				// FIX FROM THOMAS to solve the case there's only UV coords exported instead of UVW. To clean
				if( l_nOffset == 3 )
				{
					l_oCoords = {	x : Number( l_aFloatArray[ i ] ),
									y : Number( l_aFloatArray[ i + 1 ] ),
									z : Number( l_aFloatArray[ i + 2 ] )
								};
				}
				else if( l_nOffset == 2 )
				{
					l_oCoords =	{	x : Number( l_aFloatArray[ i ] ),
									y : Number( l_aFloatArray[ i + 1 ] )
								};
				}
				l_aOutput.push( l_oCoords );
			}

			return l_aOutput;
		}

		/**
		 * The <triangles> element provides the information needed to bind vertex
		 * attributes together and then organize those vertices into individual
		 * triangles. This method binds the individual values to the given
		 * input semantics (can be VERTEX, TEXCOORD, NORMAL, ... )
		 *
		 * @param p_oInput				An XMLList containing the input semantic elements
		 * @param p_aTriangles			An array containing the vertex attributes for a
		 * 								given number of triangles
		 * @param p_nTriangleCount		The number of triangles
		 * @return 						An array containing objects that hold vertex attributes
		 * 								for each input semantic
		 */
		private function convertTriangleArray( p_oInput : XMLList, p_aTriangles : Array, p_nTriangleCount : int ) : Array
		{
			var l_nInput : int = p_oInput.length();
			var l_nTriangles : int = p_aTriangles.length;
			var l_aOutput : Array = new Array();
			var l_nValuesPerTriangle : int = l_nTriangles / p_nTriangleCount;
			var l_nMaxOffset : int;

			for( var m:int = 0; m < l_nInput; m++ )
			{
				l_nMaxOffset = Math.max( l_nMaxOffset, Number( p_oInput[ m ].@offset ) );
			}
			l_nMaxOffset += 1;
			// -- iterate through all triangles
			for( var i : int = 0; i < p_nTriangleCount; i++ )
			{
				var semantic : Object = new Object();

				for( var j : int = 0; j < l_nValuesPerTriangle; j++ )
				{
					for( var k : int = 0; k < l_nInput; k++ )
					{
						if( int( p_oInput[ k ].@offset ) == j % l_nMaxOffset )
						{
							if( !semantic[ p_oInput[ k ].@semantic ] )
								semantic[ p_oInput[ k ].@semantic ] = new Array();

							var index:int = ( i * l_nValuesPerTriangle ) + j;
							semantic[ p_oInput[ k ].@semantic ].push( p_aTriangles[ index ] );
						}
					}
				}

				l_aOutput.push( semantic );
			}

			return l_aOutput;
		}

		/**
		 * Converts a space separated string to an array
		 *
		 * @param p_sValues		A string containing space separated values
		 * @return 				The resulting array
		 */
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

		/**
		 * Converts a string to a vector
		 *
		 * @param p_sValues		A string containing space separated values
		 * @return 				The resulting vector
		 */
		private function stringToVector( p_sValues : String ) : Vector
		{
			var l_aValues : Array = p_sValues.split(" ");
			var l_nValues : int = l_aValues.length;

			if( l_nValues != 3 )
				throw new Error( "ColladaParser.stringToVector(): A vector must have 3 values" );

			return new Vector( l_aValues[ 0 ], l_aValues[ 1 ], l_aValues[ 2 ] );
		}

		/**
		 * Converts a space separated string to a matrix
		 *
		 * @param p_sValues		A string containing space separated values
		 * @return 				The resulting matrix
		 */
		private function stringToMatrix( p_sValues : String ) : Matrix4
		{
			var l_aValues : Array = p_sValues.split(" ");
			var l_nValues : int = l_aValues.length;

			if( l_nValues != 16 )
				throw new Error( "ColladaParser.stringToMatrix(): A vector must have 16 values" );

			var l_oMatrix4 : Matrix4 = new Matrix4(
				l_aValues[ 0 ], l_aValues[ 1 ], l_aValues[ 2 ], l_aValues[ 3 ],
				l_aValues[ 4 ], l_aValues[ 5 ], l_aValues[ 6 ], l_aValues[ 7 ],
				l_aValues[ 8 ], l_aValues[ 9 ], l_aValues[ 10 ], l_aValues[ 11 ],
				l_aValues[ 12 ], l_aValues[ 13 ], l_aValues[ 14 ], l_aValues[ 15 ]
			);

			return l_oMatrix4;
		}

		/**
		 * Reads material information. If texture maps are used on the
		 * original object and the parser cannot find these files, then
		 * WireframeMaterial will be used by default.
		 *
		 * @param p_oNode		The XML node containing material information
		 * @return 				The parsed appearance
		 */
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

					if( m_oMaterials[ l_sImageID ].bitmapData ) l_oAppearance = new Appearance( new BitmapMaterial( m_oMaterials[ l_sImageID ].bitmapData ) );
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

		/**
		 * Extracts the location of the images and used it to load the textures.
		 * If the images aren't found at the specified path, RELATIVE_TEXTURE_PATH
		 * will be used.
		 *
		 * @param p_oLibImages		An XMLList containing information about the images
		 * @return 					An object array containg the object ID, filename
		 * 							and loader data
		 */

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
			}
			l_oQueue.addEventListener( QueueEvent.QUEUE_COMPLETE, imageQueueCompleteHandler );
			l_oQueue.start();

			return l_oImages;
		}

		/**
		 * The event handler that is fired when the image loading queue has finished
		 * loading. Bitmapdata is transfered to a material array and the parseScene
		 * method is called.
		 *
		 * @param p_oEvent		Event object containing LoaderQueue information
		 */
		private function imageQueueCompleteHandler( p_oEvent : QueueEvent ) : void
		{
			var l_oLoaders : Object = p_oEvent.loaders;

			for each( var l_oLoader : Object in l_oLoaders )
			{
				if( l_oLoader.loader.content )
					m_oMaterials[ l_oLoader.ID ].bitmapData = Bitmap( l_oLoader.loader.content ).bitmapData;
			}

			parseScene( m_oCollada.library_visual_scenes.visual_scene[0] );
		}
	}
}
