/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author Thomas PFEIFFER
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
	/**
	* Sandy custom events
	*
	* @author		Dennis Ippel
	* @version		1.0
	**/
	import flash.events.Event;

	public class SandyEvent extends Event
	{
		public static const LIGHT_ADDED:String = "lightAdded";
		public static const LIGHT_UPDATED:String = "lightUpdated";
		public static const LIGHT_COLOR_CHANGED:String = "lightColorChanged";
		public static const SCENE_RENDER:String = "scene_render";
		public static const SCENE_CULL:String = "scene_cull";
		public static const SCENE_UPDATE:String = "scene_update";
		public static const SCENE_RENDER_DISPLAYLIST:String = "scene_render_display_list";
		public static const CONTAINER_CREATED:String = "containerCreated";
		public static const QUEUE_COMPLETE:String = "queueComplete";
		public static const QUEUE_LOADER_ERROR:String = "queueLoaderError";
		
		public function SandyEvent(type:String, bubbles:Boolean = false,
								   cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
	    {
	        return new SandyEvent(type, bubbles, cancelable);
	    }
	}
}