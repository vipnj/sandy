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

import com.bourre.events.BasicEvent;
import com.bourre.events.EventType;

/**
 * @author 		Thomas Pfeiffer - kiroukou
 * @since		0.2
 * @version		0.2
 * @date 		12.01.2006
 */
class sandy.events.ObjectEvent extends BasicEvent
{
	/**
	 * The onPress Object Event. Broadcasted once a face of an object is clicked
	 */
	public static var onPressEVENT:EventType = new EventType("onPress");
	
	/**
	 *  The onRollOver Object Event. Broadcasted once the mouse is over the object.
	 */
	public static var onRollOverEVENT:EventType = new EventType("onRollOver");
	/**
	 *  The onRollOut Object Event. Broadcasted once the mouse is out the object.
	 */
	 
	public static var onRollOutEVENT:EventType = new EventType("onRollOut");
	
	/**
	 * Constructor
	 */
	public function ObjectEvent(e : EventType, oT ) 
	{
		super( e, oT );
	}
}