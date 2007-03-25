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

/**
* Rectangle
* <p> wrapper to MM Flash8 Rectangle class. Useful to store area dimension, and having our class allows to export in
* player 6 and 7 easily </p>
* @author		Thomas Pfeiffer - kiroukou
* @since		0.1
* @version		0.2
* @date 		12.01.2006 
**/
class sandy.util.Rectangle 
{
	/*
	 * x Number Position of the top left corner of the Rectangle horizontally
	 */
	 public var x:Number;
	 /**
	 * y Number Position of the top left corner of the Rectangle vertically
	 */
	 public var y:Number;
	  
	 /**
	 * width Number Width of the Rectangle
	 */
	 public var width:Number;
	   
	 /**
	 * height Number Width of the Rectangle
	 */
	 public var height:Number;
	   
	 /**
	  * Constructor of the Rectangle class
	  * default values are 0 as width, height, and corner position.
	  */
	 public function Rectangle( px:Number, py:Number, pwidth:Number, pheight:Number )
	 {
	 	x = px || 0;
	 	y = py || 0;
	 	width = pwidth || 0;
	 	height = pheight || 0;
	 }
}	