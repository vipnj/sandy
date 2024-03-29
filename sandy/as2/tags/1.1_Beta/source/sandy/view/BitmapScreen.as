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
		_bgColor = (bgColor == undefined) ? 0xFFFFFF : bgColor;
		// --
		_mc 	= mc;
		_tmp 	= mc._parent.createEmptyMovieClip("__sandy_screen_temp", mc._parent.getNextHighestDepth() );
		_sRect 	= new Rectangle( 0, 0, w, h );
		_off 	= new BitmapData( w, h, false, _bgColor );
		_on  	= _off.clone();
		// -- 
		//_tmp._visible = false;
		_mc.attachBitmap( _on, 0/*, "always", true*/ );
	}
	/**
	 * Set the {@code Camera3D} for the screen
	 * 
	 * @param	c	The {@code Camera3D}.
	 */
	public function setCamera( c:Camera3D ):Void
	{
		_c = c;
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
	 * Returns the rectangle representing the screen dimensions
	 * 
	 * @return	A Rectangle
	 */
	public function getSize( Void ):sandy.util.Rectangle
	{
		return _sRect;
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

	/////////////////
	/// private
	/////////////////
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
	// -- point Zero is always the oint a top left of the screen, so store it is a static variable
	private static var ZP:Point = new Point( 0, 0 );	
}

