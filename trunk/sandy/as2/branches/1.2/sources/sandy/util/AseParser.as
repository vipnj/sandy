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

import com.bourre.events.EventBroadcaster;
import com.bourre.events.EventType;
import com.bourre.events.IEvent;
import com.bourre.commands.Delegate;

import sandy.core.data.UVCoord;
import sandy.core.face.IPolygon;
import sandy.core.face.Polygon;
import sandy.core.Object3D;
import sandy.events.ParserEvent;

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
class sandy.util.AseParser
{
	/**
	 *  The Object3D object is initialized
	 */
	public static var onInitEVENT:EventType = new EventType( 'onInitEVENT' );
	/**
	 * The load has started
	 */
	public static var onLoadEVENT:EventType = new EventType( 'onLoadEVENT' );
	/**
	 *  The load has failed
	 */
	public static var onFailEVENT:EventType = new EventType( 'onFailEVENT' );
	/**
	 *  The load is in progress
	 */
	public static var onProgressEVENT:EventType = new EventType( 'onProgressEVENT' );
	
	/**
	 * Add a listener for a specific event.
	 * @param t EventType The type of event we want to register
	 * @param o The object listener
	 */
	public static function addEventListener( t:EventType, o ):Void
	{
		_oEB.addEventListener.apply( _oEB, arguments );
	}
	
	/**
	 * Remove a listener for a specific event.
	 * @param e String The type of event we want to register
	 * @param oL The object listener
	 */
	public static function removeEventListener( e:EventType, oL ):Void
	{
		_oEB.removeEventListener( e, oL );
	}
	
	/**
	 * Wrapper for EventDispatcher compatibility.
	 * @example<code>e.dispatchEvent( {type:'onSomething', target:this, param:12} );</code>
	 * @param o Event object.
	 */
	private static function dispatchEvent( o:Object ):Void
	{
		_oEB.dispatchEvent.apply( _oEB, arguments );
	}
	
	/**
	 * Broadcast event to suscribed listeners.
	 * @example<code>e.broadcastEvent( new BasicEvent(MyClass.onSomethingEVENT) );</code>
	 * @param e IEvent. Event object must implement IEvent interface.
	 */
	private static function broadcastEvent( e:IEvent ):Void
	{
		_oEB.broadcastEvent.apply( _oEB, arguments );
	}
	
	/**
	 * _oEB : The EventBroadcaster instance which manage the event system of world3D.
	 */
	private static var _oEB:EventBroadcaster = new EventBroadcaster( AseParser );
	
	private static var _eProgress:ParserEvent = new ParserEvent( AseParser.onProgressEVENT, null, 0, "" );
	//private static var _CONTEXT:Object = new Object();
	private var _CONTEXT:Object;
	private var lv: LoadVars;

	/**
	* Interval of time between two calls to parsing method. A big value makes parsing slower but less CPU intensive.
	*/
	public static var INTERVAL:Number = 5;
	
	/**
	* Number of lines parsed after a parsing method call. This is a good factor to change if you want to make your parser faster or less CPU intensive
	*/
	public static var ITERATIONS_PER_INTERVAL:Number = 50;
	
	public function AseParser ( o:Object3D, url: String ) {
		
		//trace ("New AseParser object " + url);
		_CONTEXT = new Object();
		_CONTEXT.object = o;
		
		lv = new LoadVars();
		 // Delegate the onLoad handler to this instance's scope
		lv.onLoad = Delegate.create( this, aseFileLoaded );
		lv.load( url );//+'&t='+getTimer()
		
		AseParser.broadcastEvent( new ParserEvent(AseParser.onLoadEVENT ) );
	}
	
	
			
	private function aseFileLoaded( success: Boolean ): Void
	{
		if( !success ) 
		{
			trace ("loading ASE file failed");
			AseParser.broadcastEvent( new ParserEvent( AseParser.onFailEVENT ) );
		}
		else
		{
			//-- here come spaghetti, but its only a boring parser --//
			// AseParser._CONTEXT.object = o;
			//_CONTEXT.lines 	= unescape( this ).split( '\r\n' );
			// We've changed the scope, so "this" is not the lv object. Get the result from lv
			_CONTEXT.lines 	= unescape( lv.toString() ).split( '\r\n' );
			
			_CONTEXT.linesLength = _CONTEXT.lines.length;
			
			_CONTEXT.uvCoordinates = new Array();
			_CONTEXT.faces 	= new Array();	
			if (_CONTEXT.linesLength > 0) { 
				//_CONTEXT.id = setInterval(AseParser._parse, AseParser.INTERVAL );
				// Use "this" as the scope for the _parse routine invoked by the interval
				_CONTEXT.id = setInterval(this, "_parse", AseParser.INTERVAL );
			} else {
				trace ("Something is wrong with _CONTEXT.linesLength in ASE parser");
			}
		}

	};
		

	/**
	* Initialize the object passed in parameter (which should be new) with the datas stored in the ASE file given in second parameter
	* @param	o Object3D 	The Object3D we want to initialize
	* @param	url String	The url of the .ASE file used to initialized the Object3D
	*/
	public static function parse( o:Object3D, url: String ): Void
	{
		//trace ("Reached parse in AseParser.as");
		new AseParser (o, url);
	}	
	
	
	private function _parse( Void ):Void
	{
		//-- local vars
		var line:String;
		var content:String;
		var f:IPolygon;
		var nIterations:Number = ITERATIONS_PER_INTERVAL;
		var chunk:String;
		//-- context vars
		var lines:Array = _CONTEXT.lines;
		var o:Object3D 	= _CONTEXT.object;
		//-- 
		while( --nIterations > -1 )
		{
			if( lines.length == 0 )
			{
				clearInterval( _CONTEXT.id );
				AseParser.broadcastEvent( new ParserEvent(AseParser.onInitEVENT ) );
				return;
			}
			else
			{
				_eProgress.setPercent( 100 - ( lines.length * 100 / _CONTEXT.linesLength ) );
				AseParser.broadcastEvent(_eProgress);
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
						var num: Number = parseInt( line.substr( line.lastIndexOf( ' ' ) ) );
						break;
							
					case 'MESH_VERTEX_LIST':
			
						while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );
							var mvl: Array = content.split(  '\t' ); // separate here
							//-- switch coordinates to fit my coordinate system
							o.addPoint( parseFloat( mvl[1] ), parseFloat( mvl[3] ), parseFloat( mvl[2] ) );
						}
						break;
						
					case 'MESH_FACE_LIST':
				
						while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );						
							var mfl: Array = content.split(  '\t' )[0]; // ignore: [MESH_SMOOTHING,MESH_MTLID]
							var drc: Array = mfl.split( ':' ); // separate here
							var con: String;		
							_CONTEXT.faces.push( new Polygon( o, o.aPoints[ parseInt( con.substr( 0, ( con = drc[2] ).lastIndexOf( ' ' ) ) ) ],
														o.aPoints[ parseInt( con.substr( 0, ( con = drc[3] ).lastIndexOf( ' ' ) ) ) ],
														o.aPoints[ parseInt( con.substr( 0, ( con = drc[4] ).lastIndexOf( ' ' ) ) ) ] ) );
							}
						break;
								
					case 'MESH_TVERTLIST':
								
						while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );
							var mtvl: Array = content.split( '\t' ); // separate here
							_CONTEXT.uvCoordinates.push( new UVCoord( parseFloat( mtvl[1] ), 1-parseFloat( mtvl[2] ) ) );
						}
						break;
								
					case 'MESH_TFACELIST':
					
						while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );
							var mtfl: Array = content.split(  '\t' ); // separate here
							var faceId:Number = parseInt( mtfl[0].substr( mtfl[0].lastIndexOf( ' ' ) ) );
							
							f = _CONTEXT.faces[faceId];
							
							f.setUVCoords( 	_CONTEXT.uvCoordinates[ parseInt( mtfl[1] ) ],
											_CONTEXT.uvCoordinates[ parseInt( mtfl[2] ) ],
											_CONTEXT.uvCoordinates[ parseInt( mtfl[3] ) ] );
							
							o.addFace( f );
						}
						break;
				}
			}
		}
	}
		
	/**
	* 
	* @param	url String	The url of the .ASE file used to initialized the Object3D
	*/
	public static function export( url: String ): Void
	{
		var lv: LoadVars = new LoadVars();
		//-- here come spaghetti, but its only a boring parser --//
		lv.onLoad = function( success: Boolean ): Void
		{
			if( !success ) 
			{
				AseParser.broadcastEvent( new ParserEvent( AseParser.onFailEVENT ) );
				return;
			}
			var lines: Array = unescape( this ).split( '\r\n' );
			var line: String;
			var chunk: String;
			var content: String;
			var l:Number;
			var f:Polygon;
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
}