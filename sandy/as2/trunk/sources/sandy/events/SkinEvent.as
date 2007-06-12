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
import sandy.skin.SkinType;
/**
 * @author 		Thomas Pfeiffer - kiroukou
 * @author		Martin Wood-Mitrovski
 * @author		Bruce Epstein - zeusprod
 * @since		1.1
 * @version		1.2.2
 * @date 		12.06.2007
 */
class sandy.events.SkinEvent extends BasicEvent 
{
	public static var onUpdateEVENT:EventType = new EventType('onUpdateEVENT');
	public static var onInitEVENT:EventType = new EventType('onInitEVENT');
	public static var onErrorEVENT:EventType = new EventType('onErrorEVENT');
	
	// Flag to indicate that the texture matrices need updating
	public var needsTextureUpdate:Boolean;
	
	public function SkinEvent(e : EventType, oT, type:SkinType ) 
	{
		super( e, oT );
		_type = type;
	}
	
	public function getSkinType( Void ):SkinType
	{
		return _type;
	}
	
	private var _type:SkinType;
}