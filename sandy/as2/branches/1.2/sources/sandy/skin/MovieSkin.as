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
import sandy.core.World3D;
import sandy.skin.SkinType;
import sandy.skin.TextureSkin;
import sandy.util.BitmapUtil;
import sandy.skin.BasicSkin;
import sandy.skin.Skin;
import sandy.core.face.IPolygon;
import flash.geom.Matrix;
import sandy.core.light.Light3D;
import sandy.math.VectorMath;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;

/**
* MovieSkin
* Allow you to texture a 3D Object with a movieClip which contains animation, picture, or video.
* @author		Thomas Pfeiffer - kiroukou
* @author		Bruce Epstein - zeusprod
* @since		1.0
* @version		1.2.3
* @date 		03.08.2007 
**/
class sandy.skin.MovieSkin extends BasicSkin implements Skin
{
	/**
	* Create a new MovieSkin.
	* @param url : URL to load. Can be an external SWF's url, a symbol name, or a movie clip instance.
	* @param bDontAnimate : Boolean; if true (the default in Sandy 1.2) we DISABLE the automatic update of the texture property.
	* @param bSmooth :	Boolean; if true perform smoothing (performance-intensive).
	*/
	public function MovieSkin( url, bDontAnimate:Boolean, bSmooth:Boolean )
	{
		// New bitmap will be set later using BitmapUtil.movieToBitmap()
		super();
		
		
	
		var inputIsClip:Boolean = false;
		
		// Try to attach the "url" name from the library (i.e., assume it is an internal symbol)
		if (url instanceof MovieClip) {
			_mc = World3D.getInstance().getContainer().createEmptyMovieClip("Skin_"+_ID_, -10000-_ID_);
			
			// trace ("A movieclip named " + url._name + " was passed to MovieSkin constructor.");
			// Copy the bitmap from the input clip to the target clip - won't help for animation purposes.
			// In AS3, we could duplicate the clip and reparent it, but that isn't supported in AS2.			
			_mc.attachBitmap(BitmapUtil.movieToBitmap(url), _mc.getNextHighestDepth(), "auto", true);
			_animate = false;

			_url = targetPath(_mc);  // This isn't really valid/used in this case.
			
			inputIsClip = true;

		} else {
			_animate = (bDontAnimate == undefined) ? false : !bDontAnimate;
			//trace ("URL passed in is a symbol or string");
			_url = url;
			// Try to create an instance from a library symbol of the specified name, if it exists.
			_mc = World3D.getInstance().getContainer().attachMovie(url, "Skin_"+_ID_, -10000-_ID_);
		}
		
	
		// If attaching the "url" from the library failed, it isn't a symbol,
		// so assume it is an external URL and try to load it.
		if( _mc == undefined )
		{
			/*
			if (typeof url == "string") {
				trace ("URL passed in is a string or _mc creation otherwise failed " + url);
			} else {
				trace ("Something is wrong. Url passed in is not a string, it is " + (typeof url));
			}
			*/
			// Create a clip to hold it
			_mc = World3D.getInstance().getContainer().createEmptyMovieClip("Skin_"+_ID_, -10000-_ID_);
			
			_mcl = new MovieClipLoader();
			_mcl.addListener(this);
			// Load the external URL in the clip.
			// The MovieClipLoader class will invoke onLoadInit() when the external swf loads.
			_mcl.loadClip(url, _mc);
			_loaded = true;
			_initialized = false;
		} else if (inputIsClip) {
			// trace ("URL passed in was a clip named '" + url._name + "'");
			_initialized = false;
			onLoadInit(_mc);
			_loaded = false;
	
		} else {
			
			// trace ("URL passed in was a symbol");
			// Otherwise, assume the clip is already initialized.
			_loaded = false;
			_initialized = true;
			_animated = _mc._totalframes > 1;
			setAnimateUpdate(_animate && _animated);
			_h = _mc._height;
			_w = _mc._width;
			updateTexture();
			_mc._visible = false;
		}
		//
		_m = new Matrix();
		_bSmooth = (bSmooth == undefined) ? false : bSmooth;
		_p = new Point(0, 0);
		_cmf = new ColorMatrixFilter();
	}
	
	public function setAnimateUpdate( animate:Boolean ):Void {
		_animate = animate;
		if (_animate) {
			_mc.play();
			if (isAnimated()) {
				// If the clip should be animated, update the movie clip periodically 
            	World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, updateTexture );
			} else {
				//trace ("There's no sense updating a movie with only a single frame");
			}
		} else {
			// Otherwise, stop the clip and don't bother updating it.
			_mc.stop();
			World3D.getInstance().removeEventListener( World3D.onRenderEVENT, this );
		}
	}
		
	public function attach( mc:MovieClip ):Void
	{
		if( _loaded == true ) 
		{
			if ( _animated == true )
			{
				_mcl.loadClip( _url, mc );
			}
			else
			{
				mc.attachBitmap( _texture, 0 );
			}
		}
		else
		{
			if( _animated == false )
			{
				mc.attachBitmap( _texture, 0 );
			}
			else
			{
				mc.attachMovie( _url, "toto", 0 );
			}
		}
		setAnimateUpdate(_animate && _animated);
	}
 
	public function isAnimated( Void ):Boolean
	{
		return _animated;
	}
	
	public function getAnimate( Void ):Boolean
	{
		return _animate;
	}
	
	
	public function isInitialized( Void ):Boolean
	{
		return _initialized;
	}
	
	// Getter for smooth property. Setter isn't supported.
	public function get smooth():Boolean
	{
		return _bSmooth;
	}
	
	// Getter for url property. Setter isn't supported.
	public function get url():String
	{
		return _url;
	}
	
	public function get dontAnimate():Boolean
	{
		return !_animate;
	}
	
	public function set dontAnimate( inBool:Boolean ):Void
	{
		_animate = !inBool;
		setAnimateUpdate(_animate);
	}
	
		
	/**
	 * getType, returns the type of the skin
	 * @param Void
	 * @return	The appropriate SkinType
	 */
	public function getType ( Void ):SkinType
	{
		return SkinType.MOVIE;
	}
	
	 
	 /**
	* Returns the name of the skin you are using.
	* For the MovieSkin class, this value is set to "MOVIE"
	* @param	Void
	* @return String representing your skin.
	*/
	public function getName( Void ):String
	{
		return "MOVIE";
	}
	
	/**
	* Returns the MovieClip used to texture objects with.
	* Useful for example when you need to apply a function to the movieClip, such as stop(), gotoAndPlay(), etc..
	* @param	Void
	* @return	MovieClip The movieclip which is used to texture objects
	*/
	public function getMovie( Void ):MovieClip
	{
		return _mc;
	}
	
	/**
	* Start the rendering of the Skin
	* @param f	The face which is being rendered
	* @param mc The mc where the face will be build.
	*/ 	
	public function begin( f:IPolygon, mc:MovieClip ):Void
	{
		var a:Array = f.getVertices();
		var m:Matrix = f.getTextureMatrix();
		// --
		var x0: Number = a[0].sx;
		var y0: Number = a[0].sy;
		var x1: Number = a[1].sx;
		var y1: Number = a[1].sy;
		var x2: Number = a[2].sx;
		var y2: Number = a[2].sy;
		// --
		var sMat = 	{ 	a:( x1 - x0 ) / _w, 
						b:( y1 - y0 ) / _w, 
						c:( x2 - x0 ) / _h, 
						d:( y2 - y0 ) / _h, 
						tx: x0, 
						ty: y0 
					};
		// --
		var rMat = __concat( m, sMat );
		// -- 
		if( _useLight == true )
		{
			//TODO copy only the little part which is needed is the bitmap if possible.
			_tmp = _texture.clone();
			var lightStrength:Number = World3D.getInstance().getLight().calculate(f.createNormale()) + 
									   World3D.getInstance().getAmbientLight();
			// -- update the color transform matrix
			_cmf.matrix = __getBrightnessTransform( lightStrength );
			// TODO: Optimize here with a different way to produce the light effect
			// and in aplying the filter only to the considered part of the texture!
			_tmp.applyFilter( _tmp , _tmp.rectangle, _p,  _cmf );
			mc.filters = _filters;
			mc.beginBitmapFill( _tmp, rMat, false, _bSmooth );
		}
		else
		{
			// -- 
			mc.filters = _filters;
			mc.beginBitmapFill( _texture, rMat, false, _bSmooth );
		}
	}
	
	/**
	* Finish the rendering of the Skin
	* @param f	The face which is being rendered
	* @param mc The mc where the face will be build.
	*/ 	
	public function end( f:IPolygon, mc:MovieClip ):Void
	{
		mc.endFill();
	}
	
	/**
	* Give a string representation of the class
	* @param	Void
	* @return	String the string representing the object.
	*/
	public function toString( Void ):String
	{
		return 'sandy.skin.MovieSkin' ;
	}

	public function updateTexture( Void ):Void
	{
		if( _texture )
		{
			_texture.dispose();
			delete _texture;
		}
		if( _tmp )
		{
			_tmp.dispose();
			delete _tmp;
		}
		_texture = BitmapUtil.movieToBitmap( _mc);
		

	}
	
	private function __concat( m1, m2 ):Object
	{	
		var r = {};
		r.a = m1.a * m2.a;
		r.d = m1.d * m2.d;
		r.b = r.c = 0;
		r.ty = m1.ty * m2.d + m2.ty;
		r.tx = m1.tx * m2.a + m2.tx;
		if( m1.b != 0 || m1.c !=0 || m2.b != 0 || m2.c != 0 )
		{
			r.a += m1.b * m2.c;
			r.d += m1.c * m2.b;
			r.b += m1.a * m2.b + m1.b * m2.d;
			r.c += m1.c * m2.a + m1.d * m2.c;
			r.tx += m1.ty * m2.c;
			r.ty += m1.tx * m2.b;
		}
		return r;
	}
	
	/**
	 * Creates a brightness transformation matrix according to the supplied brightness level.
	 * If the World3D.GO_BRIGHT flag is set then the rgb offsets are used (5th column)
	 * If the flag is not set then the rgb scaling components are used instead.
	 */
	private function __getBrightnessTransform( brightness:Number ) : Array
	{
		if(World3D.GO_BRIGHT)
		{
			var o:Number = (brightness * 512) - 256;
			return new Array 
			(
				1	, 0.0	, 0.0	, 0.0	, o,
				0.0	, 1		, 0.0	, 0.0	, o,
				0.0	, 0.0	, 1		, 0.0	, o,
				0.0	, 0.0	, 0.0	, 1.0	, 1
			);
		}
		else
		{
			var s:Number = brightness;
			return new Array 
			(
				s	, 0.0	, 0.0	, 0.0	, 0,
				0.0	, s		, 0.0	, 0.0	, 0,
				0.0	, 0.0	, s		, 0.0	, 0,
				0.0	, 0.0	, 0.0	, 1.0	, 0
			);
						
		}
	}
	
	private function onLoadStart  (target:MovieClip):Void 
	{ 
		; 
	}

	private function onLoadProgress  (target:MovieClip, loaded:Number, total:Number):Void 
	{ 
		; 
	}
	
	private function onLoadComplete  (target:MovieClip):Void 
	{ 
		; 
	}
	
	private function onLoadInit  (target:MovieClip):Void 
	{ 
		if( _initialized == false )
		{
			_h = target._height;
			_w = target._width;
			updateTexture();
			_mc._visible = false;
			_initialized = true;
			_animated = target._totalframes > 1;
			setAnimateUpdate(_animate && _animated);
			broadcastEvent(_eOnUpdate);
			broadcastEvent(_eOnInit);
			
		}
	}
	
	private function onLoadError (target:MovieClip, code:String):Void 
	{ 
		switch (code) {
			case "URLNotFound":
      			trace("MovieSkin error URLNotFound: Unable to connect to URL: " + target._url);
      			break;
			case "LoadNeverCompleted":
				trace("MovieSkin error LoadNeverCompleted: Unable to complete download: " + target);
				break;
			default:
				trace ("MovieSkin error: " + code);
				break;
   		}
		broadcastEvent(_eOnError, code);
		
	}
		
	// --
	private var _url:String;
	private var _mc:MovieClip;
	private var _animated:Boolean;  // If true, clip has more than one frame
	private var _animate:Boolean;  // If true, update the clip periodically
	private var _h:Number;
	private var _w:Number;
	private var _texture:BitmapData;
	private var _tmp:BitmapData;
	private var _cmf:ColorMatrixFilter;
	private var _bSmooth:Boolean;
	private var _p:Point;
	private var _initialized:Boolean;
	private var _loaded:Boolean;
	private var _mcl:MovieClipLoader;

	private var _m : Matrix;
}
