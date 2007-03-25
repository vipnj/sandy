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

import sandy.core.face.Polygon;
import sandy.core.Object3D;
import sandy.events.ParserEvent;
import sandy.util.StringUtil;

/**
 * Parsing *.WRL Files
 * can  handle several mesh definitions in the same file. They will be added to the same and unique object!
 * IMPORTANT : .WRL files must NOT have indentation! Please choose the without indentation option before generation.
 * IMPORTANT : The actual version of this parser doesn't handle the texture coordinates.
 * @author Thomas PFEIFFER / kiroukou
 * @see AseParser
 * @version 1.0
 */
class sandy.util.WrlParser
{
	/**
	 *  The OBject3D object is initialized
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
	private static var _oEB:EventBroadcaster = new EventBroadcaster( WrlParser );
	

	private static var _CONTEXT:Object = new Object();
	
	/**
	* Interval of time between two calls to parsing method. A big value makes parsing slower but less CPU intensive.
	*/
	public static var INTERVAL:Number = 5;
	/**
	* Number of lines parsed after a parsing method call. This is a good factor to change if you want to make your parser faster or less CPU intensive
	*/
	public static var ITERATIONS_PER_INTERVAL:Number = 10;
	
	/**
	* Initialize the object passed in parameter (which should be new) with the datas stored in the ASE file given in second parameter
	* @param	o Object3D 	The Object3D we want to initialize
	* @param	url String	The url of the .ASE file used to initialized the Object3D
	* @param	bReversed	Boolean	[optionnal] If the file contains an object that face orientation is different from
	* Sandy's one, you should set this value to true.
	*/
	public static function parse( o:Object3D, url: String, bReversed:Boolean ): Void
	{
		var bR:Boolean = (undefined == bReversed) ? false : true;
		var lv: LoadVars = new LoadVars();
		//--
		lv.onLoad = function( sucess: Boolean ): Void
		{
			if( !sucess ) 
			{
				WrlParser.broadcastEvent( new ParserEvent( WrlParser.onFailEVENT ) );
				return;
			}
			var content:String = unescape( this );
			// --
			var aObjects:Array	= StringUtil.getTextBetween( content, 'DEF', ']\r\n}' );
			// if no objects were found, it should have only one!
			//if( !aObjects.length ) aObjects[0] = StringUtil.getTextBetween( content, 'DEF', ']\r\n}' );
			var aVertices:Array = StringUtil.getTextBetween( content, 'point [', ']' );			
			var aFaces:Array 	= StringUtil.getTextBetween( content, 'coordIndex [', ']' );
			// --
			if( aVertices.length != aFaces.length )
			{
				trace('.WRL File corrupted');
				trace('vertices definition number : '+aVertices.length);
				trace('faces definition number :'+aFaces.length );
				return;
			}
			
			WrlParser._CONTEXT.object = o;
			WrlParser._CONTEXT.aObjects = aObjects;
			WrlParser._CONTEXT.aVertices = aVertices;
			WrlParser._CONTEXT.aFaces = aFaces;
			WrlParser._CONTEXT.bR = bReversed;
			WrlParser._CONTEXT.id = setInterval( WrlParser._parse, WrlParser.INTERVAL );
			
		};
		lv.load( url );
		WrlParser.broadcastEvent( new ParserEvent(WrlParser.onLoadEVENT ) );
	}		

	private static function _parse( Void ):Void
	{
		var nIterations:Number = ITERATIONS_PER_INTERVAL;
		//-- 
		while( --nIterations > -1 )
		{
			if( _CONTEXT.aObjects.length == 0 )
			{
				clearInterval( _CONTEXT.id );
				WrlParser.broadcastEvent( new ParserEvent(WrlParser.onInitEVENT ) );
				return;
			}
			else
			{
				// -- local variables
				var coords:Array;
				var f:Polygon;
				var i: Number, l:Number, idV:Number;
				var obj:String 		= _CONTEXT.aObjects.shift();
				var vertice:String 	= _CONTEXT.aVertices.shift();
				var face:String 	= _CONTEXT.aFaces.shift();
				var o:Object3D 		= _CONTEXT.object;
			
				var aOffsets:Array 	= StringUtil.getTextBetween( obj, 'translation ', '\r\n' );
				var aOffset:Array = [0, 0, 0];
				for ( i = 0; i < aOffsets.length; i++ )
				{
					coords = aOffsets[ i ].split(' ');
					aOffset[ 0 ] += parseFloat( coords[0] );
					aOffset[ 1 ] += parseFloat( coords[1] );
					aOffset[ 2 ] += parseFloat( coords[2] );					
				}
				// to remember to use the good ids for points and faces
				idV = o.aPoints.length;
				var svertices:String = vertice.split('\r\n').join('');
				var sfaces:String = face.split('\r\n').join('');
				// -- we have to clean a bit more the strings
				svertices 	= StringUtil.replace( svertices, '  ', '' );
				sfaces 		= StringUtil.replace( sfaces, ' ', '' );
				// --
				var avertices:Array = svertices.split( ',' );
				var afaces:Array	= sfaces.split( ',-1' );
				// --
				l = avertices.length;
				for( i = 0 ; i < l; i++ )
				{
					coords = avertices[ i ].split('\r\n').join('').split(' ');
					if(i > 0) coords.shift();
					// we get the objet translation => offset coordinates
					o.addPoint(   parseFloat( coords[0] ) + parseFloat( aOffset[0] ), 
								  parseFloat( coords[1] ) - parseFloat( aOffset[1] ), 
								  parseFloat( coords[2] ) + parseFloat( aOffset[2] ));
				}
				l = afaces.length;
				for( i = 0 ; i < l-1; i++ )
				{
					var ids:Array = afaces[ i ].split(',');
					if(i > 0) ids.shift();
					// seems that WRL format use a different face orientation than Sandy
					if( WrlParser._CONTEXT.bR ) ids.reverse();
					o.addFace(  new Polygon( o, 	o.aPoints[parseInt( ids[0] )+idV], 
													o.aPoints[parseInt( ids[1] )+idV], 
													o.aPoints[parseInt( ids[2] )+idV] ) );
				}
			}
		}
	}
	
	/**
	* 
	* @param	url String	The url of the .ASE file used to initialized the Object3D
	*/
	public static function export( url: String, bReversed:Boolean ):Void
	{
		var bR:Boolean = (undefined == bReversed) ? false : true;
		var lv: LoadVars = new LoadVars();
		//--
		lv.onLoad = function( sucess: Boolean ):Void
		{
			if( !sucess ) 
			{
				WrlParser.broadcastEvent( new ParserEvent( WrlParser.onFailEVENT ) );
				return;
			}
			var output:String = new String();
			var content:String = unescape( this );
			var i: Number, j:Number, l:Number, n:Number, idV:Number, idTot:Number = 0;
			var coords:Array;
			// --
			var aObjects:Array	= StringUtil.getTextBetween( content, 'DEF', ']\r\n}' );
			// if no objects were found, it should have only one!
			//if( !aObjects.length ) aObjects[0] = StringUtil.getTextBetween( content, 'DEF', ']\r\n}' );
			var aVertices:Array = StringUtil.getTextBetween( content, 'point [', ']' );			
			var aFaces:Array 	= StringUtil.getTextBetween( content, 'coordIndex [', ']' );
			// --
			if( aVertices.length != aFaces.length )
			{
				output += '.WRL File corrupted\n';
				output += 'vertices definition number : '+aVertices.length+'\n';
				output += 'faces definition number :'+aFaces.length;
			}
			for( n = 0; n < aObjects.length; n++ )
			{
				var aOffsets:Array 	= StringUtil.getTextBetween( aObjects[n], 'translation ', '\r\n' );
				var aOffset:Array = [0, 0, 0];
				for ( i = 0; i < aOffsets.length; i++ )
				{
					coords = aOffsets[ i ].split(' ');
					aOffset[ 0 ] += parseFloat( coords[0] );
					aOffset[ 1 ] += parseFloat( coords[1] );
					aOffset[ 2 ] += parseFloat( coords[2] );					
				}
				// to remember to use the good ids for points and faces
				idV = idTot;
				var svertices:String = aVertices[n].split('\r\n').join('');
				var sfaces:String = aFaces[n].split('\r\n').join('');
				// -- we have to clean a bit more the strings
				svertices 	= StringUtil.replace( svertices, '  ', '' );
				sfaces 		= StringUtil.replace( sfaces, ' ', '' );
				// --
				var avertices:Array = svertices.split( ',' );
				var afaces:Array	= sfaces.split( ',-1' );
				// --
				l = avertices.length;
				for( i = 0 ; i < l; i++ )
				{
					coords = avertices[ i ].split('\r\n').join('').split(' ');
					if(i > 0) coords.shift();
					// we get the objet translation => offset coordinates
					output += 'addPoint( '+(parseFloat( coords[0] ) + parseFloat( aOffset[0] ))+','+ 
											(- parseFloat( coords[1] ) - parseFloat( aOffset[1]))+','+ 
											parseFloat( coords[2] ) + parseFloat( aOffset[2] )+');\n';
					idTot++;
				}
				l = afaces.length;
				for( i = 0 ; i < l-1; i++ )
				{
					var ids:Array = afaces[ i ].split(',');
					if(i > 0) ids.shift();
					//var uv:Array = new Array( ids.length );
					//for( j = 0; j < ids.length; j++ )
					//	ids[j] = parseInt( ids[j] )+idV;
					// seems that WRL format use a different face orientation than Sandy
					if( bR ) ids.reverse();
					output += 'addFace( new TriFace3D( this, aPoints['+(parseInt( ids[0] )+idV)+'], aPoints['+(parseInt( ids[1] )+idV)+'], aPoints['+(parseInt( ids[2] )+idV)+'] ) );\n';
				}
			}
			// --
			WrlParser.broadcastEvent( new ParserEvent( WrlParser.onInitEVENT, null, 100,output ) );
		};
		lv.load( url );
		WrlParser.broadcastEvent( new ParserEvent( WrlParser.onLoadEVENT ) );
	}	
	
}