package sandy.util
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.unescapeMultiByte;
	
	import sandy.core.data.AnimationData;
	import sandy.events.ParserEvent;
	
	/**
	 * Allows you to load and parse Sandy Animation File (.SA).
	 * @created 27-VII-2006 12:46:52
	 * @author Thomas PFEIFFER 04/06
	 * @version 1.0
	 * @date 	24.06.06
	 */
	public class SaParser extends EventDispatcher
	{
	    static private var _CONTEXT: Object = new Object();
	    /**
	     * _oEB : The EventBroadcaster instance which manage the event system of world3D.
	     */
	    //static private var _oEB: EventBroadcaster = new EventBroadcaster( SaParser );
	    /**
	     * Interval of time between two calls to parsing method. A big value makes parsing
	     * slower but less CPU intensive.
	     */
	    static public var INTERVAL: Number = 5;
	    /**
	     * Number of lines parsed after a parsing method call. This is a good factor to
	     * change if you want to make your parser faster or less CPU intensive
	     */
	    static public var ITERATIONS_PER_INTERVAL: Number = 10;
	    /**
	     * The load has failed
	     */
	    static public const onFailEVENT: String = 'onFailEVENT';
	    /**
	     * The OBject3D object is initialized
	     */
	    static public const onInitEVENT: String = 'onInitEVENT';
	    /**
	     * The load has started
	     */
	    static public const onLoadEVENT: String = 'onLoadEVENT';
	    /**
	     * The load is in progress
	     */
	    static public var onProgressEVENT:String = 'onProgressEVENT';

		private static const _eProgress:ParserEvent = new ParserEvent( SaParser.onProgressEVENT, 0, "" );
	   
	   	/////////////////////
		///  PROPERTIES   ///
		/////////////////////		
		public const loader:URLLoader = new URLLoader();
		//private var _object:Object3D;
	   
	    /**
	     * Initialize the object passed in parameter (which should be new) with the datas
	     * stored in the ASE file given in second parameter
	     * 
	     * @param o    AnimationData 	The AnimationData we want to fill
	     * @param url    String	The url of the .ASE file used to initialized the Object3D
	     */
	    public function parse(o:AnimationData, url:String): void
	    {
	    	_CONTEXT.object = o;
	    	
	    	// Construction d'un objet URLRequest qui encapsule le chemin d'accÃ¨s
			var urlRequest:URLRequest = new URLRequest(url);
			
			// Ecoute de l'evennement COMPLETE
			loader.addEventListener( Event.COMPLETE, _parse );
			loader.addEventListener( IOErrorEvent.IO_ERROR , _io_error );
			
			// Lancer le chargement
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.load(urlRequest);
	    }
		
		/**
	     * 
	     * @param void    void
	     */
	    private function _parse( e:Event ): void
	    {
	    	var a:Array;
			//var nIterations:Number = ITERATIONS_PER_INTERVAL;
			//-- context vars
			//var lines:Array = _CONTEXT.lines;
			
			var file:URLLoader = URLLoader(e.target);
			
			var lines:Array = unescapeMultiByte( (file.data as String ) ).split( '\r\n' );
			var lineLength:uint = lines.length;
			
			_CONTEXT.lines = lines;
			_CONTEXT.linesLength = lineLength;
			//_CONTEXT.id = setInterval( SaParser._parse, SaParser.INTERVAL );
					
			//var o:AnimationData = _CONTEXT.object;
			//-- 
			//while( --nIterations > -1 )
			while( lines.length )
			{
			//	if( lines.length == 0 )
				//{
					//clearInterval( _CONTEXT.id );
					//SaParser.broadcastEvent( new ParserEvent(SaParser.onInitEVENT ) );
					//return;
				//}
				//else
				//{
					_eProgress.setPercent( 100 - ( lines.length * 100 / lineLength ) );
					dispatchEvent( _eProgress );
					//
					var line:String;
					var i:Number, l:Number;
					var frameId:Number, vertexId:Number, vertexX:Number, vertexY:Number, vertexZ:Number;
					
					line = String(lines.shift());
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
							_CONTEXT.object.addElement( _CONTEXT.frameId, parseInt( a[1] ), parseFloat( a[2] ), -parseFloat( a[4] ), parseFloat( a[3] ) );
						}
					}
				//}
			}
			// Parsing is finished
			dispatchEvent( new ParserEvent(SaParser.onInitEVENT ) );
	    }
	    
	    /**
		* Function is call in case of IO error
		* @param	e IOErrorEvent 	IO_ERROR
		*/
		private function _io_error( e:IOErrorEvent ):void
		{
			dispatchEvent( new ParserEvent( WrlParser.onFailEVENT ) );
		}
		
	}//end SaParser

}