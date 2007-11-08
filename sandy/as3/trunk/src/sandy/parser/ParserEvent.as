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

package sandy.parser
{
	import flash.events.Event;
	
	import sandy.core.scenegraph.Group;

	/**
	 * Events that are used by the Parser classes.
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		16.03.2007
	 **/
	 
	public final class ParserEvent extends Event
	{
		/**
	     * The load has failed
	     */
	    static public const FAIL:String = 'onFailEVENT';
	    /**
	     * The OBject3D object is initialized
	     */
	    static public const INIT:String = 'onInitEVENT';
	    /**
	     * The load has started
	     */
	    static public const LOAD:String = 'onLoadEVENT';
		/**
		 *  The load is in progress
		 */
		public static const PROGRESS:String = 'onProgressEVENT';
		
		public var percent:Number;
		public var group:Group;

		/**
		 * The ParserEvent constructor
		 * 
		 * @param p_sType		The event type string
		 */
		public function ParserEvent( p_sType:String )
		{
			super( p_sType );
		}
	}
}