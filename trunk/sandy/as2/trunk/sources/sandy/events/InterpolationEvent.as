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


import com.bourre.events.EventType;

import sandy.core.transform.TransformType;
import sandy.events.TransformEvent;

/**
 * @author 		Thomas Pfeiffer - kiroukou
 * @since		0.2
 * @version		0.2
 * @date 		12.01.2006
 */
class sandy.events.InterpolationEvent extends TransformEvent 
{
	/**
	 * The Interpolation interpolation Event. It's the event broadcasted every time the interpolation is updated
	 */
	public static var onProgressEVENT:EventType = new EventType( "onProgress" );
	/**
	 * The Interpolation start Event. Broadcasted when the Interpolation is started
	 */
	public static var onPauseEVENT:EventType = new EventType( "onPause" );
	/**
	 *  The Interpolation resume Event. Broadcasted when the Interpolation is resumed
	 */
	public static var onResumeEVENT:EventType = new EventType( "onResume" );
	/**
	 * Constructor
	 */
	public function InterpolationEvent( e:EventType, oT, type:TransformType, percent:Number ) 
	{
		super( e, oT, type );
		_nPercent = percent;
	}
	
	/**
	 * Returns the percentage of the Interpolation.
	 * @return Number The percentage of the Interpolation, a number between [0;1].
	 */
	public function getPercent( Void ):Number
	{
		return _nPercent;
	}
	
	private var _nPercent:Number;

	public function setPercent(pPercent : Number) : Void 
	{
		_nPercent = pPercent;
	}

}