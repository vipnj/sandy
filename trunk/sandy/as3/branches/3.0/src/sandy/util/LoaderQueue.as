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
	import flash.display.LoaderInfo;

	[Event(name="queueComplete", type="sandy.events.SandyEvent")]
	[Event(name="queueLoaderError", type="sandy.events.SandyEvent")]

       	/**
	 * Utility class for loading resources.
	 *
	 * <p>A LoaderQueue allows you to queue up requests for loading external resources</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class LoaderQueue extends EventDispatcher
	{
		private var m_oLoaders : Object;
		private var m_nLoaders : int;
		private var m_oQueueEvent : QueueEvent;
		
		/**
		 * Creates a new loader queue.
		 *
		 */
		public function LoaderQueue()
		{
			m_oLoaders = new Object();
			m_oQueueEvent = new QueueEvent( QueueEvent.QUEUE_COMPLETE );
		}
		
		/**
		 * Adds a new request to this loader queue.
		 *
		 * <p>The request is given its own loader and is added to a loader queue<br/>
		 * The loding is postponed until the start method of the queue is called.</p>
		 * 
		 * @param p_sID		A string identifier for this request
		 * @param p_oURLRequest	The request
		 */
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
		
		/**
		 * Starts the loading of all resources in the queue.
		 *
		 * <p>All loaders in the queue are started and IOErrorEvent and the COMPLETE event are subscribed to.</p>
		 */
		public function start() : void
		{
			for each( var l_oLoader : Object in m_oLoaders )
			{
				l_oLoader.loader.load( l_oLoader.request );
				l_oLoader.loader.contentLoaderInfo.addEventListener( Event.COMPLETE, completeHandler );
	            		l_oLoader.loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			}
		}
		
		/**
		 * Fires a QueueEvent, once all requested resources are loaded.
		 * Type QUEUE_COMPLETE
		 */
		private function completeHandler( p_oEvent : Event ) : void
		{
			m_nLoaders--;
			
			if( m_nLoaders == 0 ) 
			{
				m_oQueueEvent.loaders = m_oLoaders;
				dispatchEvent( m_oQueueEvent );
			}
		}
		
		/**
		 * Fires an error event if any of the loaders didn't succeed
		 *
		 */
		private function ioErrorHandler( p_oEvent : IOErrorEvent ) : void
		{	
			trace( p_oEvent.text );

			m_nLoaders--;
			
			if( m_nLoaders == 0 ) 
			{
				m_oQueueEvent.loaders = m_oLoaders;
				dispatchEvent( m_oQueueEvent );
			}
		}
	}
}