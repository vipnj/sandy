package sandy.parser 
{
	
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.Event;
	
	import sandy.core.Object3D;
	import sandy.events.SandyEvent;

	
	
	public class Parser extends EventDispatcher 
	{
		
		private var loader:URLLoader;
		private var _object:Object3D;
		
		// Events
		protected var failEvent:Event = new Event(SandyEvent.FAIL);
		protected var loadEvent:Event = new Event(SandyEvent.LOAD);
		protected var finishedEvent:Event = new Event(SandyEvent.FINISHED);
		protected var parsingProgressEvent:Event = new Event(SandyEvent.PARSING_PROGRESS);
		
		
		
		
		public function Parser()
		{
			
		}
		
		public function parse(p_o3D:Object3D, p_url:String):void
		{
			if (!p_o3D)
			{
				trace("#Error [Parser] parse() No object passed. Check if Sandy's World3D container is initialized properlly.");
				return;
			}
			
			_object = p_o3D;
			
			loader = new URLLoader();
			
			loader.addEventListener( Event.COMPLETE, parseData );
			loader.addEventListener( ProgressEvent.PROGRESS, onProgress);
			loader.addEventListener( IOErrorEvent.IO_ERROR, onIOError);

			var l_request:URLRequest = new URLRequest(p_url);

			try
			{
				loader.load(l_request);
				dispatchEvent( loadEvent );
			}
			catch(p_error:Error)
			{
				trace( "Error in loading ase file" );
				dispatchEvent( failEvent );
			}
			
		}
		
		public function parseData(p_event:Event):void
		{
			// this method has to be overriden in allsubclasses
		}
		
		public function onProgress(p_event:ProgressEvent):void
		{
			trace( "Loading progress loaded:" + p_event.bytesLoaded + " total: " + p_event.bytesTotal );
			dispatchEvent(p_event);
		}
		
		public function onIOError(p_event:Event):void
		{
			trace( "#Error [Parser] IO error occured during loading process." );
			dispatchEvent( failEvent );
			dispatchEvent( finishedEvent );
			
		}
		
		public function get object3D():Object3D
		{
			return _object;
		}
		
		public function get progress():Number
		{
			return -1;
			// It has to be overriden in all subclasses
		}
	}
}