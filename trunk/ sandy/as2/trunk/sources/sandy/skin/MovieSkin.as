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
* Allow you to texture a 3D Object with a movieClip wich contains animation, picture, or video.
* @author		Thomas Pfeiffer - kiroukou
* @since		1.0
* @version		1.0
* @date 		22.04.2006 
**/
class sandy.skin.MovieSkin extends BasicSkin implements Skin
{
	/**
	* Create a new MovieSkin.
	* @param url URL to load
	*/
	public function MovieSkin( url:String, b:Boolean )
	{
		super();
		
		_url = url;
		// we try to attach it from the library
		_mc = World3D.getInstance().getContainer().attachMovie(url, "Skin_"+_ID_, -10000-_ID_);
		if( _mc == undefined )
		{
			_mc = World3D.getInstance().getContainer().createEmptyMovieClip("Skin_"+_ID_, -10000-_ID_);
			_mcl = new MovieClipLoader();
			_mcl.addListener(this);
			_mcl.loadClip( url, _mc);
			_loaded = true;
			_initialized = false;
		}
		else
		{
			_loaded = false;
			_initialized = true;
			_animated = _mc._totalframes > 1;
			_h = _mc._height;
			_w = _mc._width;
			updateTexture();
			_mc._visible = false;
		}
		//
		_m = new Matrix();
		_bSmooth = false;
		_p = new Point(0, 0);
		_cmf = new ColorMatrixFilter();
		//
		if( b ) World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, updateTexture );
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
	}
 
	public function isAnimated( Void ):Boolean
	{
		return _animated;
	}
	
	public function isInitialized( Void ):Boolean
	{
		return _initialized;
	}
	
	public function get smooth():Boolean
	{
		return _bSmooth;
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
	* Returns the MovieClip used to texture objects with.
	* Usefull for example when you need to apply a function to the movieClip, such as stop(), gotoAndPlay(), etc..
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
			var l:Light3D 	= World3D.getInstance().getLight();
			var lp:Number	= 0.01 * l.getPower();
			var dot:Number 	= lp - ( VectorMath.dot( l.getDirectionVector(), f.createNormale() ) );
			// -- update the color transform matrix
			_cmf.matrix = __getBrightnessTransform( dot );
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
		_texture = BitmapUtil.movieToBitmap( _mc );
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
	
	private function __getBrightnessTransform( scale:Number ) : Array
	{
		var s = scale;
		var o:Number = 0;
		//
		return new Array 
		(
			s	, 0.0	, 0.0	, 0.0	, o,
			0.0	, s		, 0.0	, 0.0	, o,
			0.0	, 0.0	, s		, 0.0	, o,
			0.0	, 0.0	, 0.0	, 1.0	, o
		);
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
			_mc.stop();
			_initialized = true;
			_animated = target._totalframes > 1;
			broadcastEvent(_eOnUpdate);
		}
	}
	
	private function onLoadError  (target:MovieClip, code:String):Void 
	{ 
		trace("MovieSkin::erreur"); 
	} 
		
	// --
	private var _url:String;
	private var _mc:MovieClip;
	private var _animated:Boolean;
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
