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
import sandy.view.IScreen;
import com.bourre.events.BasicEvent;
import sandy.core.World3D;

/**
* Screen
*
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		25.08.2006
**/
class sandy.view.ClipScreen implements IScreen
{

	/**
	* Create a new ClipScreen.
	*
	* @param: mc a MovieClip containig the whole rendered scene
	* @param: w a Number giving the width of the rendered screen
	* @param: h a Number giving the height of the rendered screen
	* @param: bgColor [optionnal] the color of the background, white is the default color
	**/
	public function ClipScreen ( w:Number, h:Number, bgColor:Number)
	{
		_w = w;
		_h = h;
		_sRect 	= new Rectangle( 0, 0, w, h );
		setColor( (bgColor == undefined) ? 0xFFFFFF : bgColor );
		_mc = World3D.getInstance().getContainer();
		World3D.getInstance().addEventListener( World3D.onContainerCreatedEVENT, this, __onWorldContainer );
	}
	
	private function __onWorldContainer( e:BasicEvent ):Void
	{
		_mc = World3D.getInstance().getContainer();
		_bg = _mc.createEmptyMovieClip( 'background', -1 );
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
	 * Set the {@code Camera3D} for the screen.
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
	* Resize the screen. It makes the screen bigger or smaller, and the center of the rendered animation is modified too.
	* @param	r The new dimension of the viewport. Remember that you certainly have to change the camera projection too.
	*/
	public function setSize( r:Rectangle ):Void
	{
		_sRect 	= r;
		_w = _sRect.width;
		_h = _sRect.height;
		_c.resize(_w, _h);
	}
	
	/**
	 * Returns the rectangle representing the screen dimensions.
	 * @return	A Rectangle.
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
		// -- 
		var l:Number;
		l = a.length;
		while( --l > -1 )
		{
			a[l].movie.swapDepths( l );
			a[l].callback();
		}
	}
	
	/**
	 * Dispose the ClipScreen.
	 */
	public function dispose ( Void ):Void
	{
		_mc.removeMovieClip();
	}	
	
		
	private function __drawBackGround( Void ):Void
	{
		_bg.clear();
		_bg.beginFill(_bgColor);
		_bg.moveTo(0,0);
		_bg.lineTo(_sRect.width,0);
		_bg.lineTo(_sRect.width,_sRect.height);
		_bg.lineTo(0,_sRect.height);
		_bg.lineTo(0,0);
		_bg.endFill();
	}
	
	// -- movieclip containing the onscreen bitmapData visualisation
	private var _mc:MovieClip;
	private var _bg:MovieClip;
	// -- color of the background
	private var _bgColor:Number;
	// -- Screen rectangle, to memorize screen dimension
	private var _sRect:Rectangle;
	// -- Owner Camera3D reference
	private var _c:Camera3D;
	private var _w:Number;
	private var _h:Number;
}

