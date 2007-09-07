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
package sandy.view 
{
	/**
	 * The view port represents the rendered screen.
	 *
	 * <p>This is the area where the view of the camera is projected.<br/>
	 * It may be the whole or only a part of the stage</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */	
	public final class ViewPort
	{
	    /**
		* Creates a new ViewPort.
		*
		* @param p_nW 	The width of the rendered screen
		* @param p_nH 	The height of the rendered screen
		**/
		public function ViewPort ( p_nW:Number, p_nH:Number )
		{
			w = p_nW;
			h = p_nH;
			update();
		}
		
		/**
		 * Updates the view port
		 */
		public function update():void
		{
			w2 = w/2;
			h2 = h/2;
			ratio = w/h;
		}
		
		public var w:Number;
		public var h:Number;
		public var w2:Number;
		public var h2:Number;
		public var ratio:Number;
	}
}