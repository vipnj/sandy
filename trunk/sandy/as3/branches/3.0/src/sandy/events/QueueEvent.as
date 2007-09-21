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

package sandy.events
{
	import flash.events.Event;

	/**
	 *
	 *
	 */
	public class QueueEvent extends Event
	{
		private var _loaders : Object;

		/**
		 *
		 *
		 */
		public static const QUEUE_COMPLETE : String = "queueComplete";
		/**
		 *
		 *
		 */
		public static const QUEUE_LOADER_ERROR : String = "queueLoaderError";

		/**
		 *
		 *
		 */
		public function QueueEvent( type : String, bubbles : Boolean = false,
								   cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
			_loaders = loaders;
		}

		/**
		 *
		 *
		 */
		public function set loaders( loaderObject : Object ) : void
		{
			_loaders = loaderObject;
		}

		/**
		 *
		 *
		 */
		public function get loaders() : Object
		{
			return _loaders;
		}

		/**
		 *
		 *
		 */
		override public function clone():Event
	    	{
	    		var e : QueueEvent = new QueueEvent( type, bubbles, cancelable );
	    		e.loaders = _loaders;
	        	return e;
	    	}
	}
}