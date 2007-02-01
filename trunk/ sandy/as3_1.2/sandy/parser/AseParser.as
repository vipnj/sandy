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
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.utils.Timer;
	
	import sandy.core.data.UVCoord;
	import sandy.core.data.Vertex;
	import sandy.core.face.IPolygon;
	import sandy.core.face.Polygon;
	import sandy.core.Object3D;
	import sandy.events.ParserEvent;
	import sandy.events.TimerEvent;

	/**
	 * Full credits to Andre-Michelle (www.andre-michelle.com)
	 * 
	 * Parsing *.ASE Files
	 * AsciiExport Version  2,00 (3dmax R6)
	 * 
	 * Handle ONLY ONE mesh definition
	 * 
	 * Andre Michelle 09/2005
	 * Adapted to Sandy engine by Thomas PFEIFFER 04/06
	 */
	public class AseParser extends Parser
	{
		/**
		* 	Interval of time between two calls to parsing method. 
		* 	A big value makes parsing slower but less CPU intensive.
		*/
		public static var INTERVAL:int = 5;
		
		/**
		* 	Number of lines parsed after a parsing method call. 
		* 	This is a good factor to change if you want to make 
		* 	your parser faster or less CPU intensive.
		*/
		public static var ITERATIONS_PER_INTERVAL:int = 10;
		
		
		
		private var lines:Array;
		private var linesLength:int;
		private var uvCoordinates:Array;
		private var faces:Array;
		private var timer:Timer;
		
		
		
		/**
		* Initialize the object passed in parameter (which should be new) with the datas stored in the ASE file given in second parameter
		* @param	o Object3D 	The Object3D we want to initialize
		* @param	url String	The url of the .ASE file used to initialized the Object3D
		*/
		override public function parseData(p_event:Event):void
		{
			var loader:URLLoader = URLLoader(p_event.target);
			lines = unescape(loader.data).split( '\r\n' );
			linesLength = lines.length;
			
			if (linesLength<=1) 
			{
				lines = unescape(loader.data).split( '\n' );
				linesLength = lines.length;
			}
			
			if (linesLength<=1) 
			{
				lines = unescape(loader.data).split( '\r' );
				linesLength = lines.length;
			}
			
			trace('linesLength: ' + linesLength);
			uvCoordinates = new Array();
			faces = new Array();	
			
			timer = new Timer(INTERVAL);
			timer.addEventListener(TimerEvent.TIMER, _parseData);
			timer.start();
			
		}	
		
		override public function get progress():Number
		{
			return (100 - ( lines.length * 100 / linesLength ) );
		}
		
		private function _parseData(p_event:Event):void
		{
			//-- local vars
			var line:String;
			var content:String;
			var f:IPolygon;
			var nIterations:int = ITERATIONS_PER_INTERVAL;
			var chunk:String;
			
			//-- context vars
			var o:Object3D 	= object3D;
			
			//-- 
			while( --nIterations > -1 )
			{
				if( lines.length == 0 )
				{
					timer.stop();
					timer = null;
					//o.addFaceList(faces);
					dispatchEvent( finishedEvent );
					return;
					
				} else
				{
					dispatchEvent( parsingProgressEvent );
					
					//-- parsing
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
							
							var num: int = parseInt( line.substr( line.lastIndexOf( ' ' ) ) );
							break;
								
						case 'MESH_VERTEX_LIST':
							
							while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
							{
								content = content.substr( content.indexOf( '*' ) + 1 );

								var mvl: Array = content.split(  '\t' ); // separate here
								
								//-- switch coordinates to fit my coordinate system
								var l_nV = new Vertex(parseFloat( mvl[1] ), parseFloat( mvl[3] ), parseFloat( mvl[2] ) );
								//trace(l_nV);
								o.addVertexPoint(l_nV);
								
							}
							break;
							
						case 'MESH_FACE_LIST':
							
							while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
							{
								
								content = content.substr( content.indexOf('*') + 1 );						
								
								var mfl: String = content.split('\t')[0];
								var drc: Array = mfl.split(':'); // separate here
								
								var con: String = drc[2];
								
								var l_pol:Polygon = new Polygon( o, 	o.aPoints[ parseInt( con.substr( 0, ( con = drc[2] ).lastIndexOf( ' ' ) ) ) ],
																o.aPoints[ parseInt( con.substr( 0, ( con = drc[3] ).lastIndexOf( ' ' ) ) ) ],
																o.aPoints[ parseInt( con.substr( 0, ( con = drc[4] ).lastIndexOf( ' ' ) ) ) ] );
								
								faces.push( l_pol );
								
							}
								
							break;
									
						case 'MESH_TVERTLIST':
							
							while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
							{
								content = content.substr( content.indexOf( '*' ) + 1 );
								var mtvl: Array = content.split( '\t' ); // separate here
								uvCoordinates.push( new UVCoord( parseFloat( mtvl[1] ), 1-parseFloat( mtvl[2] ) ) );
							}
							break;
									
						case 'MESH_TFACELIST':
							
							while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
							{
								content = content.substr( content.indexOf( '*' ) + 1 );
								
								var mtfl: Array = content.split(  '\t' ); // separate here
								var faceId:int = parseInt( mtfl[0].substr( mtfl[0].lastIndexOf( ' ' ) ) );
								f = faces[int(faceId)];
								f.setUVCoords(	uvCoordinates[ int(parseInt( mtfl[1] )) ],
												uvCoordinates[ int(parseInt( mtfl[2] )) ],
												uvCoordinates[ int(parseInt( mtfl[3] )) ] );
								o.addFace( f );
							}
							break;
					}
				}
			}
		}
	}
}