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

import sandy.core.transform.TransformType;


/**
 * @author 		Thomas Pfeiffer - kiroukou
 * @since		0.2
 * @version		1.2.1
 * @date 		23.08.2007
 */
class sandy.events.TransformEvent extends BasicEvent
{
	/**
	 * The Interpolation start Event. Broadcasted when the Interpolation is started
	 */
	public static var onStartEVENT:EventType = new EventType("onStart");
	/**
	 *  The Interpolation end Event. Broadcasted when the Interpolation is finished
	 */
	public static var onEndEVENT:EventType = new EventType("onEnd");
	
	/**
	 * Constructor
	 */
	public function TransformEvent(e : EventType, oT, type:TransformType ) 
	{
		super(e, oT);
		_nType = type;
	}
	
	/**
	 * Return the type of transformation
	 * @return TransformType The transformation ID
	 */
	public function getTransformType( Void ):TransformType
	{
		return _nType;
	}
		
	private var _nType:TransformType;

}
