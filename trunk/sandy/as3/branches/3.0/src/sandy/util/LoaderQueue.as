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

package sandy.util
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import sandy.events.QueueEvent;
	import sandy.events.SandyEvent;

	[Event(name="queueComplete", type="sandy.events.SandyEvent")]
	[Event(name="queueLoaderError", type="sandy.events.SandyEvent")]

	public class LoaderQueue extends EventDispatcher
	{
		private var m_oLoaders : Object;
		private var m_nLoaders : int;
		private var m_bErrorOccurred : Boolean;
		
		public function LoaderQueue()
		{
			m_bErrorOccurred = false;
			m_oLoaders = new Object();
		}
		
		public function add( p_sID : String, p_oURLRequest : URLRequest ) : void
		{
			m_oLoaders[ p_sID ] = 
			{
				ID : p_sID,
				loader : new Loader(),
				request : p_oURLRequest
			};
			
			m_nLoaders++;
		}
		
		public function start() : void
		{
			for each( var l_oLoader : Object in m_oLoaders )
			{
				l_oLoader.loader.load( l_oLoader.request );
				l_oLoader.loader.contentLoaderInfo.addEventListener( Event.COMPLETE, completeHandler );
	            l_oLoader.loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			}
		}
		
		private function completeHandler( p_oEvent : Event ) : void
		{
			m_nLoaders--;
			if( m_nLoaders == 0 && !m_bErrorOccurred ) 
				dispatchEvent( new QueueEvent( QueueEvent.QUEUE_COMPLETE, m_oLoaders ) );
			else if( m_nLoaders == 0 && m_bErrorOccurred ) 
				dispatchEvent( new QueueEvent( QueueEvent.QUEUE_LOADER_ERROR ) );
		}
		
		private function ioErrorHandler( p_oEvent : Event ) : void
		{
			m_nLoaders--;
			m_bErrorOccurred = true;
			// additio to fire the error. Otherwhise we don't send anything
			dispatchEvent( new QueueEvent( QueueEvent.QUEUE_LOADER_ERROR ) );
		}
	}
}