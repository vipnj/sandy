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

package sandy.view {

	import sandy.util.Rectangle;
	import sandy.view.Camera3D;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;

	/**
	* IScreen
	* @author		Thomas Pfeiffer - kiroukou
	* @author		Tabin C�dric - thecaptain
	* @author		Nicolas Coevoet - [ NikO ]
	* @version		1.0
	**/

	public interface IScreen
	{

		/**
		 * Set the {@code Camera3D} for the screen.
		 * @param	c	The {@code Camera3D}.
		 */
		function setCamera( c:Camera3D ):void;

		/**
		* Returns the background color
		* @return Number The color value
		*/
		function getColor():Number;
		
		/**
		* Set the color of the background and refresh the background of the screen.
		* @param	n The color number
		*/
		function setColor( n:Number ):void;
		
		/**
		 * Return the clip container.
		 * @return	The clip container.
		 */	
		function getClip():DisplayObject;
		
		/**
		 * Render the array of {@code Face} passed in arguments. 
		 * @param	A The Array of {@code Face}.
		 */
		function render ( a:Array ):void;

		/**
		* Resize the screen. It makes the screen bigger or smaller, and the center of the rendered animation is modified too.
		* @param	r The new dimension of the viewport. Remember that you certainly have to change the camera projection too.
		*/
		function setSize( r:Rectangle ):void;
		
		/**
		 * Returns the rectangle representing the screen dimensions.
		 * @return	A Rectangle.
		 */
		function getSize():Rectangle;
		
		/**
		* Returns the ratio between the wide and height of the screen as a number
		* @param	void
		* @return The dimension ratio between width and height (width/height)
		*/
		function getRatio():Number;
		
		/**
		 * Free all the screen ressources.
		 */
		function dispose ():void;
	}
}