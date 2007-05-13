package sandy.parser
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.unescapeMultiByte;

	import sandy.parser.Parser;
	import sandy.parser.AParser;
	import sandy.parser.IParser;
	import sandy.parser.ParserEvent;
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.Shape3D;
	import sandy.core.scenegraph.Group;
	import sandy.materials.ColorMaterial;
	import sandy.materials.Appearance;
	import sandy.materials.WireFrameMaterial;

	internal final class ASEParser extends AParser implements IParser
	{
		public function ASEParser( p_sUrl:String )
		{
			super( p_sUrl );
		}
			
		protected override function parseData( e:Event ):void
		{
			super.parseData( e );
			// --
			var lines:Array = unescapeMultiByte( (m_oFileLoader.data as String ) ).split( '\r\n' );
			var lineLength:uint = lines.length;
			var id:uint;
			// -- local vars
			var line:String;
			var content:String;
			var chunk:String;
			var l_oAppearance:Appearance = null;
			var l_oGeometry:Geometry3D = null;
			var l_oShape:Shape3D = null;
			// -- 
			while( lines.length )
			{
				m_eProgress.percent = ( 100 - ( lines.length * 100 / lineLength ) );
				dispatchEvent( m_eProgress );
				//-- parsing
				line = String(lines.shift());		
				//-- clear white space from begin
				line = line.substr( line.indexOf( '*' ) + 1 );
				//-- clear closing brackets
				if( line.indexOf( '}' ) >= 0 ) line = '';
				//-- get chunk description
				chunk = line.substr( 0, line.indexOf( ' ' ) );
				//-- 
				switch( chunk )
				{
					case 'MESH_NUMFACES':
					{		
						//var num: Number =  Number(line.split( ' ' )[1]);
						if( l_oGeometry )
						{
							l_oShape = new Shape3D( null, l_oGeometry, new Appearance( new WireFrameMaterial() ) );
							m_oGroup.addChild( l_oShape );
						}
						// -
						l_oGeometry = new Geometry3D();
						break;
					}	
					case 'MESH_VERTEX_LIST':
					{
						while( ( content = (lines.shift() as String )).indexOf( '}' ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );
							var vertexReg:RegExp = /MESH_VERTEX\s*(\d+)\s*([\d-.]+)\s*([\d-.]+)\s*([\d-.]+)/
							id = uint(content.replace(vertexReg, "$1"));
							var v1:Number = Number(content.replace(vertexReg, "$2"));
							var v2:Number = Number(content.replace(vertexReg, "$4"));
							var v3:Number = Number(content.replace(vertexReg, "$3"));

							l_oGeometry.setVertex(id, v1, -v2, v3 );
						}
						break;
					}	
					case 'MESH_FACE_LIST':
					{
						while( ( content = (lines.shift() as String )).indexOf( '}'  ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );		
							var mfl:String = content.split(  '*' )[0]; // ignore: [MESH_SMOOTHING,MESH_MTLID]
							//"MESH_FACE    0:    A:    777 B:    221 C:    122 AB:    1 BC:    1 CA:    1"
							var faceReg:RegExp = /MESH_FACE\s*(\d+):\s*A:\s*(\d+)\s*B:\s*(\d+)\s*C:\s*(\d+)\s*AB:\s*(\d+)\s*BC:\s*(\d+)\s*CA:\s*(\d+)\s*/
							id = uint(mfl.replace(faceReg, "$1"));
							var p1:uint = uint(mfl.replace(faceReg, "$2"));
							var p2:uint = uint(mfl.replace(faceReg, "$4"));
							var p3:uint = uint(mfl.replace(faceReg, "$3"));
							
							l_oGeometry.setFaceVertexIds(id, p1, p2, p3 );
						}
						break;
					}		
					case 'MESH_TVERTLIST':
					{		
						while( ( content = (lines.shift() as String )).indexOf( '}' ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );
							vertexReg = /MESH_TVERT\s*(\d+)\s*([\d-.]+)\s*([\d-.]+)\s*([\d-.]+)/
							id = uint(content.replace(vertexReg, "$1"));
							v1 = Number(content.replace(vertexReg, "$2"));
							v2 = Number(content.replace(vertexReg, "$3"));
							//var v3 = (content.replace(vertexReg, "$2"));
							l_oGeometry.setUVCoords(id, v1, 1-v2 );
						}
						break;
					}	
					//TODO: there are ASE file without MESH_TFACELIST, what then							
					case 'MESH_TFACELIST':
					{
						while( ( content = (lines.shift() as String)).indexOf( '}' ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );
							faceReg = /MESH_TFACE\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)/
							id = uint(content.replace(faceReg, "$1"));
							var f1:uint = uint(content.replace(faceReg, "$2"));
							var f2:uint = uint(content.replace(faceReg, "$4"));
							var f3:uint = uint(content.replace(faceReg, "$3"));
							l_oGeometry.setFaceUVCoordsIds( id, f1, f2, f3 );
						}
						break;
					}
				}
			}
			// -- 
			l_oShape = new Shape3D( null, l_oGeometry, new Appearance( new WireFrameMaterial() ) );
			m_oGroup.addChild( l_oShape );
			// -- Parsing is finished
			var l_eOnInit:ParserEvent = new ParserEvent( ParserEvent.onInitEVENT );
			l_eOnInit.group = m_oGroup;
			dispatchEvent( l_eOnInit );
		} 
	}// -- end AseParser
}