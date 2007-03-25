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

	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.events.IEventDispatcher;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	
	import sandy.skin.SkinType;
	import sandy.skin.TextureSkin;
	import sandy.skin.Skin;
	import sandy.core.World3D;
	import sandy.core.face.IPolygon;
	import sandy.core.face.Polygon;
	import sandy.core.light.Light3D;
	import sandy.util.BitmapUtil;
	import sandy.util.URLLoaderQueue;
	import sandy.util.DisplayUtil;
	import sandy.math.VectorMath;
	import sandy.events.SandyEvent;
	
	
	/**
	* MovieSkin
	* Allow you to texture a 3D Object with a movieClip wich contains animation, picture, or video.
	* @author		Thomas Pfeiffer - kiroukou
	* @since		1.0
	* @version		1.0
	* @date 		22.04.2006 
	**/
	public class MovieSkin extends Skin
	{
		/**
		* Create a new MovieSkin.
		* @param url URL to load
		*/
		public function MovieSkin( url:String, b:Boolean = true)
		{
			super();
			
			_url = url;
			
			// try to attach it from the library
			try {
				var skinRef:Class = getDefinitionByName(url) as Class;
				_mc = new skinRef();
			} catch (error: ReferenceError)
			{
				trace("#Warning [MovieSkin] Item doesn't exists in the library. Trying to load external resource.");
			}
			
			
			if( !_mc )
			{
				_loaded = true;
				_initialized = false;
				
				var resLoader:URLLoaderQueue = new URLLoaderQueue();

				if (url.substring(url.length-3) == "swf" )
				{
					isSwf = true;
					resLoader.addResource(url, URLLoaderQueue.SWF);
				} else {
					
					// we're assuming it's a bitmap
					resLoader.addResource(url, URLLoaderQueue.BITMAP);
				}
				
				resLoader.addEventListener(SandyEvent.ALL_FINISHED, loadingComplete);
				resLoader.load();
				
			} else 
				if (_mc is MovieClip || _mc is Bitmap) 
				{
					_loaded = false;
					_initialized = true;
					isSwf = true;
					_animated = MovieClip(_mc).totalFrames > 1;
					_h = _mc.height;
					_w = _mc.width;
					
					updateTexture();
					
				} else 
				{
					trace("#Error [MovieSkin] Cannot load specified skin: " + url + ".");
				}
			//
			_m = new Matrix();
			_bSmooth = false;
			_p = new Point(0, 0);
			_cmf = new ColorMatrixFilter();
		}
		
		public function attach( mc:Sprite ):DisplayObject
		{
			if( _initialized ) 
			{
				if ( _animated )
				{
					// Only animated stuff needs to be refreshed every frame
					World3D.getInstance().addEventListener( SandyEvent.RENDER, updateTexture );
					
					return DisplayUtil.replaceObject(mc, _mc);
					
				} else {
					
					mc.addChild( new Bitmap(_texture));
					
					return mc;
				}
			}
			
			return null;
		}
		
		private function loadingComplete(p_event:Event):void 
		{
			trace("[MovieSkin] Asset loaded successfully.");
			trace(p_event.target.getResources()[0]);
			
			if (isSwf)
			{
				_mc = MovieClip(p_event.target.getResources()[0]);
			} else 
			{
				_mc = Bitmap(p_event.target.getResources()[0]);
			
			}
			
			if( !_initialized )
			{
				_h = _mc.height;
				_w = _mc.width;
				
				updateTexture();
				
				if (isSwf)
				{
					MovieClip(_mc).stop();
					_animated = MovieClip(_mc).totalFrames > 1;
				}
				
				_initialized = true;
				
				dispatchEvent( updateEvent );
				
				//World3D.getInstance().addEventListener( SandyEvent.RENDER, updateTexture );
			}
		
        }
		
		public function isAnimated():Boolean
		{
			return _animated;
		}
		
		public function isInitialized():Boolean
		{
			return _initialized;
		}
		
		public function get smooth():Boolean
		{
			return _bSmooth;
		}
			
		/**
		 * getType, returns the type of the skin
		 * @param void
		 * @return	The appropriate SkinType
		 */
		override public function getType ():SkinType
		{
			return SkinType.MOVIE;
		}
		
		/**
		* Returns the MovieClip used to texture objects with.
		* Usefull for example when you need to apply a function to the movieClip, such as stop(), gotoAndPlay(), etc..
		* @param	void
		* @return	MovieClip The movieclip which is used to texture objects
		*/
		public function getMovie():DisplayObject
		{
			return _mc;
		}
		
		/**
		* Start the rendering of the Skin
		* @param f	The face which is being rendered
		* @param mc The mc where the face will be build.
		*/ 	
		override public function begin( f:IPolygon, mc:Sprite ):void
		{
			if(!_initialized) return;
			
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
			var sMat:Matrix = new Matrix();
			sMat.a = ( x1 - x0 ) / _w;
			sMat.b = ( y1 - y0 ) / _w;
			sMat.c = ( x2 - x0 ) / _h;
			sMat.d = ( y2 - y0 ) / _h;
			sMat.tx = x0;
			sMat.ty = y0;
			
			// --
			var rMat:Matrix = __concat( m, sMat );
			
			// -- 
			if( _useLight)
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
				_tmp.applyFilter( _tmp , _tmp.rect, _p,  _cmf );
				mc.filters = _filters;
				mc.graphics.beginBitmapFill( _tmp.clone(), rMat, false, _bSmooth );
				_tmp.dispose();
				_tmp = null;
			}
			else
			{
				// -- 
				mc.filters = _filters;
				mc.graphics.beginBitmapFill( _texture, rMat, false, _bSmooth );
			}
			
		}
		
		/**
		* Finish the rendering of the Skin
		* @param f	The face which is being rendered
		* @param mc The mc where the face will be build.
		*/ 	
		override public function end( f:IPolygon, mc:Sprite ):void
		{
			mc.graphics.endFill();
		}

		public function updateTexture(p_event:Event = null):void
		{
			if( _texture )
			{
				_texture.dispose();
				_texture = null;
			}
			
			if( _tmp )
			{
				_tmp.dispose();
				_tmp = null;
			}
			
			if (_mc is MovieClip)
				_texture = BitmapUtil.movieToBitmap( MovieClip(_mc) );
			else 
				if (_mc is Bitmap)
				{
					_texture = Bitmap(_mc).bitmapData;
				}
		}
		
		private function __concat( m1:Matrix, m2:Matrix ):Matrix
		{	
			var r:Matrix = new Matrix();
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
		 
			
		// --
		private var _url:String;
		private var isSwf:Boolean;
		private var _mc:DisplayObject;
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
		
		private var _m : Matrix;
	}
}