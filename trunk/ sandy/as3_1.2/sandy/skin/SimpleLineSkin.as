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

package sandy.skin {

	import sandy.core.face.IPolygon;
	import sandy.skin.Skin;
	import sandy.skin.BasicSkin;
	import sandy.skin.SkinType;
	import sandy.events.SandyEvent;
	
	import flash.display.DisplayObject;
	
	
	/**
	* SimpleLineSkin
	*  
	* @author		Thomas Pfeiffer - kiroukou
	* @author		Tabin Cédric - thecaptain
	* @author		Nicolas Coevoet - [ NikO ]
	* @version		0.2
	* @date 		12.01.2006 
	**/
	public class SimpleLineSkin extends BasicSkin
	{
		/**
		* Create a new SimpleLineSkin
		* 
		* @param t The size of line
		* @param c The color ot the line
		* @param a The alpha of the line
		* 
		*/ 
		public function SimpleLineSkin( t:Number = 2, c:Number = 0x000000,  a:Number = 100)
		{
			super();
			_thickness = t;
			_color = c;
			_alpha = a;
		}

		/////////////
		// SETTERS //
		/////////////

		public function set alpha( n:Number )
		{
			_alpha = n;
			dispatchEvent( updateEvent );
		}
		public function set color( n:Number )
		{
			_color = n;
			dispatchEvent( updateEvent );
		}
		public function set thickness( n:Number )
		{
			_thickness = n;
			dispatchEvent( updateEvent );
		}	
		/////////////
		// GETTERS //
		/////////////	
		public function get alpha():Number
		{
			return _alpha;
		}
		public function get color():Number
		{
			return _color;
		}	
		public function get thickness():Number
		{
			return _thickness;
		}		
		/**
		 * getType, returns the type of the skin
		 * @param void
		 * @return	The appropriate SkinType
		 */
		 override public function getType ():SkinType
		 {
			return SkinType.SIMPLE_LINE;
		 }
		
		/**
		* Start the rendering of the Skin
		* @param f	The face which is being rendered
		* @param mc The mc where the face will be build.
		*/ 	
		override public function begin( f:IPolygon, mc:DisplayObject ):void
		{
			mc.filters = _filters;
			mc.graphics.lineStyle( thickness, color,alpha);
		}
		
		/**
		* Finish the rendering of the Skin
		* @param f	The face which is being rendered
		* @param mc The mc where the face will be build.
		*/ 	
		override public function end( f:IPolygon, mc:DisplayObject ):void
		{
			; // nothing here
		}
		
		
		/**
		 * Color of the lines
		 */
		private var _color:Number;
		/**
		 * Thickness of the lines
		 */
		private var _thickness:Number;
		/**
		 * Alpha transparency of the lines
		 */
		private var _alpha:Number;
		
	}
}