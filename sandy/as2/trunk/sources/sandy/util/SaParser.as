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

import sandy.core.data.AnimationData;
import sandy.events.ParserEvent;
/**
 * Allows you to load and parse Sandy Animation File (.SA). 
 * @author 	Thomas PFEIFFER 04/06
 * @version 1.0
 * @date 	24.06.06
 */
class sandy.util.SaParser
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
	 * @example <code>e.broadcastEvent( new BasicEvent(MyClass.onSomethingEVENT) );</code>
	 * @param e IEvent. Event object must implement IEvent interface.
	 */
	private static function broadcastEvent( e:IEvent ):Void
	{
		_oEB.broadcastEvent.apply( _oEB, arguments );
	}
	
	/**
	 * _oEB : The EventBroadcaster instance which manage the event system of world3D.
	 */
	private static var _oEB:EventBroadcaster = new EventBroadcaster( SaParser );
	private static var _eProgress:ParserEvent = new ParserEvent( SaParser.onProgressEVENT, null, 0, "" );
	
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
	* @param	o AnimationData 	The AnimationData we want to fill
	* @param	url String	The url of the .ASE file used to initialized the Object3D
	*/
	public static function parse( o:AnimationData, url: String ): Void
	{
		var lv: LoadVars = new LoadVars();
		//-- here come spaghetti, but its only a boring parser --//
		lv.onLoad = function( sucess: Boolean ): Void
		{
			if( !sucess ) 
			{
				SaParser.broadcastEvent( new ParserEvent( SaParser.onFailEVENT ) );
			}
			else
			{
				SaParser._CONTEXT.object = o;
				SaParser._CONTEXT.lines = unescape( this ).split( '\r\n' );
				SaParser._CONTEXT.linesLength = SaParser._CONTEXT.lines.length;
				SaParser._CONTEXT.id = setInterval( SaParser._parse, SaParser.INTERVAL );
			}
		};
		lv.load( url );//+'&t='+getTimer()
		SaParser.broadcastEvent( new ParserEvent(SaParser.onLoadEVENT ) );
	}	
	
	private static function _parse( Void ):Void
	{
		var a:Array;
		var nIterations:Number = ITERATIONS_PER_INTERVAL;
		//-- context vars
		var lines:Array = _CONTEXT.lines;
		var o:AnimationData = _CONTEXT.object;
		//-- 
		while( --nIterations > -1 )
		{
			if( lines.length == 0 )
			{
				clearInterval( _CONTEXT.id );
				SaParser.broadcastEvent( new ParserEvent(SaParser.onInitEVENT ) );
				return;
			}
			else
			{
				_eProgress.setPercent( 100 - ( lines.length * 100 / _CONTEXT.linesLength ) );
				SaParser.broadcastEvent(_eProgress);
				//
				var line:String;
				var i:Number, l:Number;
				var frameId:Number, vertexId:Number, vertexX:Number, vertexY:Number, vertexZ:Number;
				line = String( lines.shift() );
				if( line != "" )
				{
					a = line.split(' ');
					if( a[0] == "frame" )
					{
						_CONTEXT.frameId = parseInt( a[1] );
					}
					else if( a[0] == "vertex" )
					{
						// vertex ID, X, -Z, Y
						_CONTEXT.object.addElement( _CONTEXT.frameId, parseInt( a[1] ), parseFloat( a[2] ), parseFloat( a[4] ), parseFloat( a[3] ) );
					}
				}
			}
		}
	}
	
}