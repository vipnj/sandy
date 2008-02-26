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
	import flash.utils.Dictionary;

	import sandy.commands.Delegate;

	/**
	 * Perhaps a dev can enlighten us ;)
	 *
	 * @version 3.0
	 */
	public class EventBroadcaster
	{
	    private var m_oAll:Dictionary = new Dictionary(true);
	    private var m_oType:Dictionary = new Dictionary(true);
	    private var m_oEventListener:Dictionary = new Dictionary(true);
	    private var m_oDelegateDico:Dictionary = new Dictionary(true);
	    private var listeners:Array;

	    public function EventBroadcaster()
	    {
	    }

	    public function isRegistered(listener:Object, type:String = null):Boolean
		{
			if (type == null)
			{
				return m_oAll[listener];
			}
			else
			{
				if (m_oType[type])
				{
					for each(var lElt:* in m_oType[type])
					{
						if (lElt == listener)
						{
							return true;
						}
					}

					return false;
				}
				else
				{
					return false;
				}
			}
		}

	    public function removeListenerCollection(type:String):void
		{
			delete m_oType[type];
		}

	    public function getListenerCollection(type:String = null):Dictionary
		{
			return (type != null) ? m_oType[type] : m_oAll;
		}

		public function addEventListener(type:String, listener:Object, ...rest):Boolean
		{
			if (listener is Function)
			{
				var d:Delegate = new Delegate(listener as Function);

				if (rest)
				{
					d.setArgumentsArray(rest);
				}

				m_oDelegateDico[listener] = d;
				listener = d;

			}
			else if (listener.hasOwnProperty(type) && (listener[type] is Function))
			{
				//

			}
			else if (listener.hasOwnProperty("handleEvent") && listener.handleEvent is Function)
			{
				//

			}
			else
			{
				return false;	//ERROR CASE
			}

			if (!isRegistered(listener))
			{
				if (!(m_oType[type]))
				{
					m_oType[type] = new Dictionary(true);
				}
				// --
				var lDico:Dictionary = getListenerCollection(type);

				if (!lDico[listener])
				{
					lDico[listener] = listener;
					_storeRef(type, listener);
					return true;
				}
			}

			return false;
		}

		public function hasListenerCollection(type:String):Boolean
		{
			return (m_oType[type] != null);
		}

		public function removeEventListener(type:String, listener:Object):Boolean
		{
			if (hasListenerCollection(type))
			{
				var c:Dictionary = getListenerCollection(type);
				if (listener is Function)
				{
					listener = m_oDelegateDico[listener];
				}
				// --
				if (c[listener])
				{
					_removeRef(type, listener);
					if (isDicoEmpty(c))
					{
						removeListenerCollection(type);
					}

					delete c[listener];

					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				return false;
			}
		}

		public function broadcastEvent(e:Event):void
		{
			if (hasListenerCollection(e.type))
			{
				_broadcastEvent( getListenerCollection(e.type), e );
			}
			//
			if (!isDicoEmpty(m_oAll))
			{
				_broadcastEvent(m_oAll, e);
			}
		}

		public function _broadcastEvent(c:Dictionary, e:Event):void
		{
			var type:String = e.type;

			for each(var listener:Object in c)
			{
				if (listener.hasOwnProperty(type) && listener[type] is Function)
				{
					listener[type](e);

				}
				else if (listener.hasOwnProperty("handleEvent") && listener.handleEvent is Function)
				{
					listener.handleEvent(e);

				}
				else
				{
					//ERROR
				}
			}
		}

		private function _removeRef(type:String, listener:Object):void
		{
			var m:Dictionary = m_oEventListener[listener];
			delete m[ type ];

			if (isDicoEmpty(m))
			{
				delete m_oEventListener[ listener ];
			}
		}

		private function _storeRef(type:String, listener:Object):void
		{
			if (!m_oEventListener[listener])
			{
				m_oEventListener[listener]= new Dictionary(true);
			}
			m_oEventListener[listener][type] = listener;
		}

		private function isDicoEmpty(pDico:Dictionary):Boolean
		{
			var i:uint = 0;
			for each(var lElt:* in pDico)
			{
				i++;
			}
			return (i == 0);
		}
	}
}