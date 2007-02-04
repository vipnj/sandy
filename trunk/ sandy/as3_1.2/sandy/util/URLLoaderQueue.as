package sandy.util {

	import flash.events.*;
	
	import sandy.events.LoaderEvent;
	import sandy.events.SandyEvent;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	
	

	public class URLLoaderQueue extends EventDispatcher
	{
		
		public static const BITMAP:int = 0;
		public static const SWF:int = 1;
		public static const TEXT:int = 2;
		
		
		private var queue:Array;
		private var txtLoader:URLLoader;
		private var displayListLoader:Loader;
		
		public var resources:Dictionary;
		private var currentItem:Object;
		private var isLoading:Boolean;
		private var stopped:Boolean;
		private var currentResource:Object;
		
		
		
		
		/*
		* Simple FIFO queue implementation for loading
		* external resources.
		* 
		*/
		public function URLLoaderQueue(p_urlList:Array = null, p_type = null)
		{
			clear();
			
			if (p_type != null)
			{
				for (var i:int = 0; i<p_urlList.length; i++)
				{
					p_urlList[i] = {url: p_urlList[i], type:p_type};
				}
			}
			
			addResourceList(p_urlList);
			txtLoader = new URLLoader();
			displayListLoader = new Loader();
			
			configureListeners(txtLoader);
			txtLoader.addEventListener(Event.COMPLETE, completeTxtHandler);
			
			configureListeners(displayListLoader.contentLoaderInfo);
		}
		
		public function addResource(p_url:String, p_type:int):void
		{
			queue.push({url:p_url, type:p_type});
		}
		
		public function addResourceList(p_urlList:Array):void
		{
			if (p_urlList)
				queue = queue.concat(p_urlList);
		}
		
		public function load():void
		{
			if (!isLoading)
			{
				loadNextResource();
				
			} else {
				trace("#Warning [URLLoaderQueue] Loading in progress! First stop the current loading.");
			}
		}
		
		private function clear():void
		{
			stop();
			resources = new Dictionary();
			queue = new Array();
			isLoading = false;
			stopped = false;
		}
		
		public function stop():void
		{
			stopped = true;
		}
		
		public function getResources():Array
		{
			var l_result:Array = new Array();
			
			for (var item in resources) {
				l_result.push(resources[item]);
			}
			
			return l_result;
		}
		
		private function loadNextResource():void
		{
			
			if (queue.length && !stopped) 
			{
				try 
				{
					// First In First Out
					currentResource = queue.splice(0,1)[0];
					
					var l_request:URLRequest = new URLRequest(currentResource.url);
				
					switch (currentResource.type) {
						case BITMAP:
							displayListLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeBmpHandler);
							displayListLoader.load(l_request);
							break;
						
						case SWF:
							displayListLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeSwfHandler);
							displayListLoader.load(l_request);
							break;
							
						case TEXT:
							txtLoader.load(l_request);
							break;
							
						default:
							trace("#Error [URLLoaderQueue] Unrecognized data format: " + currentResource.type);
					}
					
					
				} catch (error:Error) {
					trace("#Error [URLLoaderQueue] Unable to load requested document: " + error);
				}
			} else {
				dispatchEvent(new Event(SandyEvent.ALL_FINISHED));
				clear();
			}
		}
		
		private function configureListeners(p_dispatcher:IEventDispatcher):void 
		{
            p_dispatcher.addEventListener(Event.OPEN, openHandler);
            p_dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            p_dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            p_dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            p_dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }
		
		private function completeTxtHandler(event:Event):void 
		{
			trace("[URLLoaderQueue] Saving reference to loaded URLVariables.");
			resources[currentResource.url] = new URLVariables(event.target.data);
				
			dispatchEvent(new LoaderEvent(Event.COMPLETE, currentResource.url, resources[currentResource]));
			
		}
		
		private function completeBmpHandler(event:Event):void 
		{
            trace("[URLLoaderQueue] Saving reference to loaded Bitmap: " + currentResource.url);
			resources[currentResource.url] = Bitmap(displayListLoader.content);
			loadNextResource();
        }
		
		private function completeSwfHandler(event:Event):void 
		{
            trace("[URLLoaderQueue] Saving reference to loaded Swf: " + currentResource.url);
			resources[currentResource.url] = MovieClip(displayListLoader.content);
			loadNextResource();
        }

        private function openHandler(event:Event):void 
		{
            //trace("openHandler: " + event);
			dispatchEvent(event);
        }

        private function progressHandler(event:ProgressEvent):void 
		{
            //trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
			dispatchEvent(event);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void 
		{
            trace("securityErrorHandler: " + event);
			dispatchEvent(event);
			loadNextResource();
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void 
		{
            //trace("httpStatusHandler: " + event);
			dispatchEvent(event);
        }

        private function ioErrorHandler(event:IOErrorEvent):void 
		{
            trace("ioErrorHandler: " + event);
			dispatchEvent(event);
			loadNextResource();
        }
		
	}

}