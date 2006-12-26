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

import sandy.util.Rectangle;
import sandy.view.Camera3D;

/**
* IScreen
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @since		0.1
* @version		0.2
* @date 		12.01.2006
**/

interface sandy.view.IScreen
{
	/**
	 * Set the {@code Camera3D} for the screen.
	 * 
	 * @param	c	The {@code Camera3D}.
	 */
	public function setCamera( c:Camera3D ):Void;
	
	/**
	 * Return the clip container.
	 * 
	 * @return	The clip container.
	 */	
	public function getClip( Void ):MovieClip;
	
	/**
	 * Render the array of {@code Face} passed in arguments.
	 * 
	 * @param	A The Array of {@code Face}.
	 */
	public function render ( a:Array ):Void;
	
	/**
	 * Returns the rectangle representing the screen dimensions.
	 * 
	 * @return	A Rectangle.
	 */
	public function getSize( Void ):Rectangle;
	
	/**
	 * Destroy the screen.
	 */
	public function dispose ( Void ):Void;
}
