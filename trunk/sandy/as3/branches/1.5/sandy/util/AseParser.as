package sandy.util
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.unescapeMultiByte;
	
	import sandy.core.Object3D;
	import sandy.core.face.Face;
	import sandy.core.face.TriFace3D;
	import sandy.events.ParserEvent;
	
	/**
	 * Full credits to Andre-Michelle (www.andre-michelle.com)  Parsing *.ASE Files
	 * AsciiExport Version  2,00 (3dmax R6)  Handle ONLY ONE mesh definition
	 * Andre Michelle 09/2005 Adapted to Sandy engine by Thomas PFEIFFER 04/06
	 * @version 1.0
	 * @created 26-VII-2006 13:46:03
	 */
	public class AseParser extends EventDispatcher
	{
	    /**
	     * The load has failed
	     */
	    static public const onFailEVENT:String = 'onFailEVENT';
	    /**
	     * The OBject3D object is initialized
	     */
	    static public const onInitEVENT:String = 'onInitEVENT';
	    /**
	     * The load has started
	     */
	    static public const onLoadEVENT:String = 'onLoadEVENT';

		/**
		 *  The load is in progress
		 */
		public static const onProgressEVENT:String = 'onProgressEVENT';
		
		private static const _eProgress:ParserEvent = new ParserEvent( AseParser.onProgressEVENT, 0, "" );
		
		
		/////////////////////
		///  PROPERTIES   ///
		/////////////////////		
		public const loader:URLLoader = new URLLoader();
		private var _object:Object3D;


	    /**
	     * Initialize the object passed in parameter (which should be new) with the datas
	     * stored in the ASE file given in second parameter
	     * 
	     * @param o    Object3D 	The Object3D we want to initialize
	     * @param url    String	The url of the .ASE file used to initialized the Object3D
	     */
	    public function parse( o:Object3D, url:String ):void
		{
			// Construction d'un objet URLRequest qui encapsule le chemin d'accÃ¨s
			var urlRequest:URLRequest = new URLRequest(url);
			// Ecoute de l'evennement COMPLETE
			loader.addEventListener( Event.COMPLETE, _parse );
			loader.addEventListener( IOErrorEvent.IO_ERROR , _io_error );
			// Lancer le chargement
			_object = o;
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.load(urlRequest);
		}	
		
		
		private function _parse( e:Event ):void
		{
			var file:URLLoader = URLLoader(e.target);
			
			var lines:Array = unescapeMultiByte( (file.data as String ) ).split( '\r\n' );
			var lineLength:uint = lines.length;
			//-- local vars
			var line:String;
			var content:String;
			var f:Face;
			var chunk:String;
			var uvCoordinates:Array = new Array();
			var faces:Array = new Array();
			//-- context vars
			var o:Object3D 	= _object;
			//-- 
			while( lines.length )
			{
				_eProgress.setPercent( 100 - ( lines.length * 100 / lineLength ) );
				dispatchEvent( _eProgress );
				//AseParser.d(_eProgress);
				//-- parsing
				line = String(lines.shift());		
				//-- clear white space from begin
				line = line.substr( line.indexOf( '*' ) + 1 );
//				trace(line.length);
				trace(line.substr(line.length - 10, line.length-1));
				//-- clear closing brackets
				if( line.indexOf( '}' ) >= 0 ) line = '';
				//-- get chunk description
				chunk = line.substr( 0, line.indexOf( ' ' ) );
				//-- 
				switch( chunk )
				{
					case 'MESH_NUMFACES':
					{		
						//var num: Number = ( line.substr( line.lastIndexOf( ' ' ) ) as Number );
						var num: Number =  Number(line.split( ' ' )[1]);
						break;
					}	
					case 'MESH_VERTEX_LIST':
					{
			
						while( ( content = (lines.shift() as String )).indexOf( '}' ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );

							var vertexReg:RegExp = /MESH_VERTEX\s*\d+\s*([\d-.]+)\s*([\d-.]+)\s*([\d-.]+)/
							//var mvl:Array = content.split(  '\t' ); // separate here
							var v1:Number = Number(content.replace(vertexReg, "$1"));
							var v2:Number = Number(content.replace(vertexReg, "$3"));
							var v3:Number = Number(content.replace(vertexReg, "$2"));
							
							//-- switch coordinates to fit my coordinate system
//							o.addPoint( Number( mvl[1] as Number) , -( mvl[3] as Number ), ( mvl[2] as Number ) );
							o.addPoint( v1 , -1*v2, v3 );
						}
						break;
					}	
					case 'MESH_FACE_LIST':
					{
						while( ( content = (lines.shift() as String )).indexOf( '}'  ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );		
							//var mflReg:RegExp = /(.*)\*MESH_SMOOTHING\s*\d+\s*\*MESH_MTLID\s*\d+/
							//var mfl:String = (content.replace(mflReg, "$1"));
							
							var mfl:String = content.split(  '*' )[0]; // ignore: [MESH_SMOOTHING,MESH_MTLID]
							//var drc:Array = mfl.split( ':' ); // separate here
							//var con:String;		
							
							//"MESH_FACE    0:    A:    777 B:    221 C:    122 AB:    1 BC:    1 CA:    1"
							var faceReg:RegExp = /MESH_FACE\s*(\d+):\s*A:\s*(\d+)\s*B:\s*(\d+)\s*C:\s*(\d+)\s*AB:\s*(\d+)\s*BC:\s*(\d+)\s*CA:\s*(\d+)\s*/
							var p1:Number = Number(mfl.replace(faceReg, "$2"));
							var p2:Number = Number(mfl.replace(faceReg, "$4"));
							var p3:Number = Number(mfl.replace(faceReg, "$3"));
							
							faces.push( new TriFace3D( o, o.aPoints[ p1 ], o.aPoints[ p2 ], o.aPoints[ p3 ] ));
						}
						break;
					}		
					case 'MESH_TVERTLIST':
					{		
						while( ( content = (lines.shift() as String )).indexOf( '}' ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );
//							var mtvl:Array = content.split( '\t' ); // separate here
							vertexReg = /MESH_TVERT\s*\d+\s*([\d-.]+)\s*([\d-.]+)\s*([\d-.]+)/
							//var mvl:Array = content.split(  '\t' ); // separate here
							v1 = Number(content.replace(vertexReg, "$1"));
							v2 = Number(content.replace(vertexReg, "$2"));
							//var v3 = (content.replace(vertexReg, "$2"));
							
							uvCoordinates.push( o.addUVCoordinate( v1, 1 - v2 ) );
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
							var id:Number = Number(content.replace(faceReg, "$1"));
							var f1:Number = Number(content.replace(faceReg, "$2"));
							var f2:Number = Number(content.replace(faceReg, "$4"));
							var f3:Number = Number(content.replace(faceReg, "$3"));
							
							//var mtfl: Array = content.split(  '\t' ); // separate here
							//var faceId:Number = Number( mtfl[0].substr( mtfl[0].lastIndexOf( ' ' ) ));
							var faceId:Number = id;
								
							f = faces[faceId];
							f.setUVCoordinates( uvCoordinates[ f1 ],
												uvCoordinates[ f2 ],
												uvCoordinates[ f3 ] );
							o.addFace( f );
						}
						break;
					}
				}
			}
			// Parsing is finished
			dispatchEvent( new ParserEvent(AseParser.onInitEVENT ) );
		}
	    
		/**
		* 
		* @param	url String	The url of the .ASE file used to initialized the Object3D
		*/
	/*
		public function export( url:String ):void
		{
			var lv: LoadVars = new LoadVars();
			//-- here come spaghetti, but its only a boring parser --//
			lv.onLoad = function( sucess: Boolean ): Void
			{
				if( !sucess ) 
				{
					AseParser.broadcastEvent( new ParserEvent( AseParser.onFailEVENT ) );
					return;
				}
				var lines: Array = unescape( this ).split( '\r\n' );
				var line: String;
				var chunk: String;
				var content: String;
				var l:Number;
				var f:Face;
				var faces:Array = new Array();
				var uvCoordinates:Array = new Array();
				var o:Object3D = new Object3D();
				var output:String = new String();
				output += 'var f:Face ;\n';
				output += 'var faces:Array = new Array()\n';
				output += 'var uvCoordinates:Array = new Array();\n';
				
				while( lines.length )
				{
					line = String( lines.shift() );
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
							var num: Number = parseInt( line.substr( line.lastIndexOf( ' ' ) ) );
							break;
						
						case 'MESH_VERTEX_LIST':
		
							while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
							{
								content = content.substr( content.indexOf( '*' ) + 1 );
								var mvl: Array = content.split(  '\t' ); // separate here
								//-- switch coordinates to fit my coordinate system
								o.addPoint( parseFloat( mvl[1] ), -parseFloat( mvl[3] ), parseFloat( mvl[2] ) );
								output += 'addPoint( '+parseFloat( mvl[1] )+','+ -parseFloat( mvl[3] )+', '+parseFloat( mvl[2] )+' );\n';
							}
							break;
							
						case 'MESH_FACE_LIST':
					
							while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
							{
								content = content.substr( content.indexOf( '*' ) + 1 );
								
								var mfl: Array = content.split(  '\t' )[0]; // ignore: [MESH_SMOOTHING,MESH_MTLID]
								var drc: Array = mfl.split( ':' ); // separate here
								var con: String;
								
								output += 'faces.push( new TriFace3D( this, aPoints[ '+parseInt( con.substr( 0, ( con = drc[2] ).lastIndexOf( ' ' ) ) ) +'], aPoints[ '+parseInt( con.substr( 0, ( con = drc[4] ).lastIndexOf( ' ' ) ) ) +'], aPoints[ '+parseInt( con.substr( 0, ( con = drc[3] ).lastIndexOf( ' ' ) ) ) +' ] ) );\n';
							}
							break;
							
						case 'MESH_TVERTLIST':
							
							while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
							{
								content = content.substr( content.indexOf( '*' ) + 1 );
								var mtvl: Array = content.split( '\t' ); // separate here
								output += 'uvCoordinates.push( addUVCoordinate( '+parseFloat( mtvl[1] )+','+ (1-parseFloat( mtvl[2] )) +') );\n';
							}
							break;
							
						case 'MESH_TFACELIST':
						
							while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
							{
								content = content.substr( content.indexOf( '*' ) + 1 );
								var mtfl: Array = content.split(  '\t' ); // separate here
								var faceId:Number = parseInt( mtfl[0].substr( mtfl[0].lastIndexOf( ' ' ) ) );
								
								output += 'f = faces['+faceId+'];\n';
								output += 'f.setUVCoordinates( uvCoordinates[ '+parseInt( mtfl[1] ) +' ], uvCoordinates[ '+parseInt( mtfl[3] )+' ], uvCoordinates[ '+parseInt( mtfl[2] )+' ] );\n';
								output += 'addFace( f );\n';
							}
							break;
					}
				}
				delete o;
				AseParser.broadcastEvent( new ParserEvent(AseParser.onInitEVENT , null, 100, output) );
			};
			lv.load( url );
			AseParser.broadcastEvent( new ParserEvent(AseParser.onLoadEVENT ) );
		}	
		*/	    

		/**
		* Function is call in case of IO error
		* @param	e IOErrorEvent 	IO_ERROR
		*/
		private function _io_error( e:IOErrorEvent ):void
		{
			dispatchEvent( new ParserEvent( WrlParser.onFailEVENT ) );
		}
	}//end AseParser
}
