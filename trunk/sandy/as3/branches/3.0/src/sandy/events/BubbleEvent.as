/*
 * Copyright the original author or authors.
 * 
 * Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.mozilla.org/MPL/MPL-1.1.html
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
/**
 * {@code BubbleEvent} defines specific event structure to work with
 * {@link BubbleEventBroadcaster}
 * 
 * @author Thomas PFEIFFER
 * @version 1.0
 */
 
package sandy.events
{
	import flash.events.Event;
	
	public class BubbleEvent extends Event
	{
		private var m_oEvt:Event;
		private var m_oTarget:Object;
		//private var m_sType:String;
		//-------------------------------------------------------------------------
		// Public API
		//-------------------------------------------------------------------------
		
		/**
		 * Constructs a new {@code BubbleEvent} instance.
		 * 
		 * <p>{@link #bubbles} and {@link #propagation} properties are set
		 * to {@code true}.
		 * 
		 * <p>Example
		 * <code>
		 *   var e : BubbleEvent = new BubbleEvent(MyClass.onSomething, this);
		 * </code>
		 * 
		 * @param e an {@link EventType} instance (event name).
		 * @param oT event target.
		 */
		public function BubbleEvent( e : String, oT:Object, p_Evt:Event = null ) 
		{
			super( e, true, true );
			m_oTarget = oT;
			m_oEvt = p_Evt;
		}
		
		
		public override function get target():Object
		{
			return m_oTarget;
		}
		
		public function get event():Event
		{
			return m_oEvt;
		}
		
		/**
		 * Returns the string representation of this instance.
		 * 
		 * @return {@code String} representation of this instance
		 */
		public override function toString() : String
		{
			return 	'BubbleEvent';
		}
	}
}