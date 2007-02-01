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

	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	
	import sandy.util.Rectangle;
	import sandy.util.DisplayUtil;
	import sandy.view.Camera3D;
	import sandy.view.IScreen;
	import sandy.core.World3D;
	import sandy.events.SandyEvent;
	
	
	/**
	* Screen
	*
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		25.08.2006
	**/
	public class ClipScreen implements IScreen
	{

		/**
		* Create a new ClipScreen.
		*
		* @param: mc a MovieClip containig the whole rendered scene
		* @param: w a Number giving the width of the rendered screen
		* @param: h a Number giving the height of the rendered screen
		* @param: bgColor [optionnal] the color of the background, white is the default color
		**/
		public function ClipScreen ( w:Number, h:Number, bgColor:Number = 0xFFFFFF)
		{
			_w = w;
			_h = h;
			_sRect 	= new Rectangle( 0, 0, w, h );
			
			_mc = World3D.getInstance().getSceneContainer();
			_bg = World3D.getInstance().getBGContainer();
			
			setColor( bgColor );
			
			World3D.getInstance().addEventListener( SandyEvent.CONTAINER_CREATED, __onWorldContainer );
		}
		
		private function __onWorldContainer( e:Event ):void
		{
			_mc = World3D.getInstance().getSceneContainer();
			_bg = World3D.getInstance().getBGContainer();
		}
		
		/**
		* Returns the background color
		* @return Number The color value
		*/
		public function getColor():Number
		{
			return _bgColor;
		}
		
		/**
		* Set the color of the background
		* @param	n The color number
		*/
		public function setColor( n:Number ):void
		{
			_bgColor = n;
			__drawBackGround();
		}
		
		/**
		 * Set the {@code Camera3D} for the screen.
		 * @param	c	The {@code Camera3D}.
		 */
		public function setCamera( c:Camera3D ):void
		{
			_c = c;
		}
		
		/**
		 * Get the screen corresponding {@code Camera3D}.
		 * @return	c	The {@code Camera3D}.
		 */
		public function getCamera():Camera3D
		{
			return _c;
		}
		
		/**
		* Resize the screen. It makes the screen bigger or smaller, and the center of the rendered animation is modified too.
		* @param	r The new dimension of the viewport. Remember that you certainly have to change the camera projection too.
		*/
		public function setSize( r:Rectangle ):void
		{
			_sRect 	= r;
			_w = _sRect.width;
			_h = _sRect.height;
			_c.updateScreen();
		}
		
		/**
		 * Returns the rectangle representing the screen dimensions.
		 * @return	A Rectangle.
		 */
		public function getSize():sandy.util.Rectangle
		{
			return _sRect;
		}
		
		/**
		* Returns the ratio between the wide and height of the screen as a number
		* @param	void
		* @return The dimension ratio between width and height (width/height)
		*/
		public function getRatio():Number
		{
			return _w/_h;
		}
		
		/**
		 * Return the container clip.
		 * This is very usefull if you want to apply a filter to the whole scene! The filter will be applied on the parent
		 * MovieClip, rathen than the skins who apply the filters to the faces only.
		 * @return	The clip container.
		 */		
		public function getClip():DisplayObject
		{
			return _mc;
		}
		
		/**
		 * render the array of {@code Face} passed in arguments.
		 * 
		 * @param	a	The array of {@code Face}.
		 */
		public function render ( a:Array ):void
		{
			//var ms = getTimer();
			
			// -- 
			var l:int = a.length;
			var l_2Render:Object;
			
			while( --l > -1 )
			{
				l_2Render = a[int(l)];
				
				DisplayUtil.swapObjectWithIndex(l_2Render.movie, l);	
				l_2Render.callback();
			}
			
			//trace("Czas: " + (getTimer()-ms));
		}
		
		public function render2 ( a:Array ):void
		{
			var l_container:DisplayObject = World3D.getInstance().clearSceneContainer();
			
			// -- 
			var l:int = a.length;
			var l_2Render:Object;
			
			for(var i:int=0; i < l; i++) 
			{
				l_2Render = a[int(i)];
				
				l_container.addChild(l_2Render.movie);
				l_2Render.callback();
			}
			
		}
		
		/**
		 * Dispose the ClipScreen.
		 */
		public function dispose ():void
		{
			_mc.parent.removeChild(_mc);
			_mc = null;
		}	
		
			
		private function __drawBackGround():void
		{
			if (!_bg) return;
			
			_bg.graphics.clear();
			_bg.graphics.beginFill(_bgColor);
			_bg.graphics.moveTo(0,0);
			_bg.graphics.lineTo(_sRect.width, 0);
			_bg.graphics.lineTo(_sRect.width, _sRect.height);
			_bg.graphics.lineTo(0,_sRect.height);
			_bg.graphics.lineTo(0,0);
			_bg.graphics.endFill();
		}
		
		// -- movieclip containing the onscreen bitmapData visualisation
		private var _mc:DisplayObject;
		private var _bg:DisplayObject;
		// -- color of the background
		private var _bgColor:Number;
		// -- Screen rectangle, to memorize screen dimension
		private var _sRect:Rectangle;
		// -- Owner Camera3D reference
		private var _c:Camera3D;
		private var _w:Number;
		private var _h:Number;
	}

}