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

	import sandy.skin.SkinType;

	/**
	 * @author 		Thomas Pfeiffer - kiroukou
	 * @version		1.0
	 * @date 		05.08.2006
	 */
	public class SkinEvent extends Event 
	{
		public static const onUpdateEVENT:String = 'onUpdateEVENT';
		
		public function SkinEvent( e:String, type:uint ) 
		{
			super( e );
			_type = type;
		}
		
		public function getSkinType():uint
		{
			return _type;
		}
		
		public function setSkinType( type:uint ):void
		{
			_type = type;
		}
		
		private var _type:uint;
	}
}