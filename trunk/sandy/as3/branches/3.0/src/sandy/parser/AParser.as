package sandy.parser
{
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	
	import sandy.core.scenegraph.Group;
	import sandy.parser.ParserEvent;
	
	internal class AParser extends EventDispatcher implements IParser
	{
		protected static var m_eProgress:ParserEvent = new ParserEvent( ParserEvent.onProgressEVENT );
		protected const m_oLoader:URLLoader = new URLLoader();
		protected var m_oGroup:Group;
		protected var m_oFile:Object;
		protected var m_oFileLoader:URLLoader
		private var m_sUrl:String;
		protected var m_sDataFormat:String;
		protected var m_nScale:Number;
		
		public function AParser( p_sFile:*, p_nScale:Number )
		{ 
			m_oGroup = new Group('parser');
			m_nScale = p_nScale;
			if( p_sFile is String )
			{
				m_sUrl = p_sFile;
				m_oFileLoader = new URLLoader();
				m_sDataFormat = URLLoaderDataFormat.TEXT;
			} 
			else 
			{
				m_oFile = p_sFile;
			}
		}
		
		/**
		* Function is call in case of IO error
		* @param	e IOErrorEvent 	IO_ERROR
		*/
		private function _io_error( e:IOErrorEvent ):void
		{
			dispatchEvent( new ParserEvent( ParserEvent.onFailEVENT ) );
		}
		
		protected function parseData( e:Event=null ):void
		{
			if( e != null )
			{
				m_oFileLoader = URLLoader( e.target );
				m_oFile = m_oFileLoader.data;
			}
		}
		
	    /**
	     * Initialize the object passed in parameter (which should be new) with the datas
	     * stored in the ASE file given in second parameter
	     * 
	     * @param o    Object3D 	The Object3D we want to initialize
	     * @param url    String	The url of the .ASE file used to initialized the Object3D
	     */
	    public function parse():void
		{
			if( m_sUrl is String )
			{
				// Construction d'un objet URLRequest qui encapsule le chemin d'acc√É¬®s
				var urlRequest:URLRequest = new URLRequest( m_sUrl );
				// Ecoute de l'evennement COMPLETE
				m_oFileLoader.addEventListener( Event.COMPLETE, parseData );
				m_oFileLoader.addEventListener( IOErrorEvent.IO_ERROR , _io_error );
				// Lancer le chargement
				m_oFileLoader.dataFormat = m_sDataFormat;
				m_oFileLoader.load(urlRequest);
			} 
			else 
			{
				parseData();
			}
		}
	}
}
