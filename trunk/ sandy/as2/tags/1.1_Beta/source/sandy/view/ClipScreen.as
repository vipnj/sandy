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

import sandy.core.face.Face;
import sandy.util.Rectangle;
import sandy.view.Camera3D;
import sandy.view.IScreen;

/**
* Screen
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @since		0.1
* @version		0.2
* @date 		12.01.2006
**/
class sandy.view.ClipScreen implements IScreen
{

	/**
	* Create a new ClipScreen.
	*
	* @param: mc a MovieClip containig the whole rendered scene
	* @param: w a Number giving the width of the rendered screen
	* @param: h a Number giving the height of the rendered screen
	* @param: bgColor [optionnal] the color of the background, white is the default color :: NOT IMPLEMENTED YET
	**/
	public function ClipScreen (mc:MovieClip, w:Number, h:Number, bgColor:Number)
	{
		_bgColor = (bgColor == undefined) ? 0xFFFFFF : bgColor;
		// --
		_mc 	= mc;
		_sRect 	= new Rectangle( 0, 0, w, h );
		_mc.scrollRect = _sRect;
	}
	
	/**
	 * Set the {@code Camera3D} for the screen.
	 * 
	 * @param	c	The {@code Camera3D}.
	 */
	public function setCamera( c:Camera3D ):Void
	{
		_c = c;
	}
	
	/**
	* Resize the screen. It makes the screen bigger or smaller, and the center of the rendered animation is modified too.
	* This method is not tested, so please gibe us a feedback if you use it.
	* @param	r
	*/
	public function setSize( r:Rectangle ):Void
	{
		_sRect 	= r;
		_mc.scrollRect = r;
	}
	
	/**
	 * Returns the rectangle representing the screen dimensions.
	 * 
	 * @return	A Rectangle.
	 */
	public function getSize( Void ):Rectangle
	{
		return _sRect;
	}
	
	/**
	 * Return the container clip.
	 * This is very usefull if you want to apply a filter to the whole scene! The filter will be applied on the parent
	 * MovieClip, rathen than the skins who apply the filters to the faces only.
	 * @return	The clip container.
	 */		
	public function getClip( Void ):MovieClip
	{
		return _mc;
	}
	
	/**
	 * render the array of {@code Face} passed in arguments.
	 * 
	 * @param	a	The array of {@code Face}.
	 */
	public function render ( a:Array ):Void
	{
		_mc.child.removeMovieClip();
		var c:MovieClip = _mc.createEmptyMovieClip( 'child', 0 );
		// -- 
		var l:Number = a.length;
		while( --l > -1 )
		{
			var face : Face = a[l].face;
			var mc : MovieClip = c.createEmptyMovieClip( 'c_'+l, l );
			face.render(mc);
		};
	}
	
	/**
	 * Dispose the ClipScreen.
	 */
	public function dispose ( Void ):Void
	{
		_mc.removeMovieClip();
	}	
	
	// -- movieclip containing the onscreen bitmapData visualisation
	private var _mc:MovieClip;
	// -- color of the background
	private var _bgColor:Number;
	// -- Screen rectangle, to memorize screen dimension
	private var _sRect:Rectangle;
	// -- Owner Camera3D reference
	private var _c:Camera3D;
	
}

