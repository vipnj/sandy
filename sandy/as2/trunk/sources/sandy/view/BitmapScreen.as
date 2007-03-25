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

import flash.display.BitmapData;
import flash.geom.Point;

import sandy.util.Rectangle;
import sandy.view.Camera3D;
import sandy.view.IScreen;

/**
* BitmapScreen
* This class is an alternative to ClipScreen BUT it's more bugguy and finally slower. I don't recommend to use it.
* @author		Thomas Pfeiffer - kiroukou
* @since		0.1
* @version		0.2
* @date 		12.01.2006 
**/

class sandy.view.BitmapScreen implements IScreen
{
	/**
	* Create a new BitmapScreen
	*
	* @param: mc a MovieClip containig the whole rendered scene
	* @param: tmp a MovieClip used for temporary drawing
	* @param: w a Number giving the width of the rendered screen
	* @param: h a Number giving the height of the rendered screen
	* @param: bgColor [optionnal] the color of the background, white is the default color
	**/
	public function BitmapScreen (mc:MovieClip, w:Number, h:Number, bgColor:Number)
	{
		setColor( (bgColor == undefined) ? 0xFFFFFF : bgColor );
		// --
		_mc 	= mc;
		_bg 	= _mc.createEmptyMovieClip( 'background', 0 );
		_tmp 	= mc._parent.createEmptyMovieClip("__sandy_screen_temp", mc._parent.getNextHighestDepth() );
		_w = w;
		_h = h;
		_sRect 	= new Rectangle( 0, 0, w, h );
		_off 	= new BitmapData( w, h, false, _bgColor );
		_on  	= _off.clone();
		// -- 
		//_tmp._visible = false;
		_mc.attachBitmap( _on, 0/*, "always", true*/ );
	}

	/**
	* Returns the background color
	* @return Number The color value
	*/
	public function getColor( Void ):Number
	{
		return _bgColor;
	}
	
	/**
	* Set the color of the background
	* @param	n The color number
	*/
	public function setColor( n:Number ):Void
	{
		_bgColor = n;
		__drawBackGround();
	}
	
	/**
	 * Set the {@code Camera3D} for the screen
	 * @param	c	The {@code Camera3D}.
	 */
	public function setCamera( c:Camera3D ):Void
	{
		_c = c;
	}

	/**
	 * Get the screen corresponding {@code Camera3D}.
	 * @return	c	The {@code Camera3D}.
	 */
	public function getCamera( Void ):Camera3D
	{
		return _c;
	}
	
	/**
	 * Return the container clip.
	 * 
	 * @return	The clip container.
	 */	
	public function getClip( Void ):MovieClip
	{
		return _tmp;
	}
	
	/**
	* Resize the screen. It makes the screen bigger or smaller, and the center of the rendered animation is modified too.
	* @param	r The new dimension of the viewport. Remember that you certainly have to change the camera projection too.
	*/
	public function setSize( r:Rectangle ):Void
	{
		_sRect 	= r;
		_w = _sRect.width;
		_h = _sRect.height;
	}
	
	/**
	 * Returns the rectangle representing the screen dimensions
	 * 
	 * @return	A Rectangle
	 */
	public function getSize( Void ):sandy.util.Rectangle
	{
		return _sRect;
	}
	
	/**
	* Returns the ratio between the wide and height of the screen as a number
	* @param	Void
	* @return The dimension ratio between width and height (width/height)
	*/
	public function getRatio( Void ):Number
	{
		return _w/_h;
	}
	
	/**
	 * Render the array of {@code Face} passed in arguments.
	 * 
	 * @param	a	The array of {@code Face}.
	 */
	public function render ( a:Array ):Void
	{
		var l:Number = a.length;
		// -- for loop is necessary beause here the way to display is the inverse of ClipScreen
		while( --l> -1 )
		{
			// -- initialize the clip by clearing it content
			_tmp.clear(); // TODO le clear() ca serait mieux d'utiliser un remove et recreer ...
			// -- we render in the temporary clip
			a[l].face.render( _tmp );
			// -- we copy thr result in the offscreen BitmapData
			_off.draw( _tmp/*, null, null, null, null, true */);
		}
		// -- we update the visible bitmapData with new rendered data
		_on.copyPixels ( _off, _off.rectangle, ZP );
		// -- initialization of the offscreen bitmapData, we make a copy of Rectangle into the official MM Rectangle class
		// otherwise i can't compile. Strange
		//TODO check if there is not another solution
		var r = new flash.geom.Rectangle( _sRect.x, _sRect.y, _sRect.width, _sRect.height );
		_off.fillRect ( r, _bgColor );
	}
	
	/**
	 * Dispose the BitmapScreen.
	 */
	public function dispose ( Void ):Void
	{
		_off.dispose();
		_on.dispose();
		_mc.removeMovieClip();
	}
	
	private function __drawBackGround( Void ):Void
	{
		_bg.beginFill(_bgColor);
		_bg.moveTo(0,0);
		_bg.lineTo(_sRect.width,0);
		_bg.lineTo(_sRect.width,_sRect.height);
		_bg.lineTo(0,_sRect.height);
		_bg.lineTo(0,0);
		_bg.endFill();
	}
	/////////////////
	/// private
	/////////////////
	private var _bg:MovieClip;
	// -- BitmapData used for drawing the scene, face per face. Will be hidden
	private var _off:BitmapData;
	// -- Copy of offscreen bitmapData when all the scene is rendered correctly.
	private var _on:BitmapData;
	// -- temporary movieClip used for drawing faces befor copying them into the offscreen BitmapData
	private var _tmp:MovieClip;
	// -- movieclip containing the onscreen bitmapData visualisation
	private var _mc:MovieClip;
	// -- color of the background
	private var _bgColor:Number;
	// -- Screen rectangle, to memorize screen dimension
	private var _sRect:Rectangle;
	// -- Owner Camera3D reference
	private var _c:Camera3D;
	private var _w:Number;
	private var _h:Number;
	// -- point Zero is always the oint a top left of the screen, so store it is a static variable
	private static var ZP:Point = new Point( 0, 0 );	
}

