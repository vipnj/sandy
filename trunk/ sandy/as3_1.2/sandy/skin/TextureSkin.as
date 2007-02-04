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

package sandy.skin 
{
		
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;

	import sandy.core.face.IPolygon;
	import sandy.core.light.Light3D;
	import sandy.core.World3D;
	import sandy.math.VectorMath;
	import sandy.skin.Skin;
	import sandy.skin.SkinType;
	import sandy.events.SandyEvent;
	
	import sandy.util.NumberUtil;

	
	/**
	* TextureSkin
	*  
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		12.01.2006 
	**/
	public class TextureSkin extends Skin
	{
		
		private var _w:Number;
		private var _h:Number;
		private var _tmp:BitmapData;
		private var _p:Point;
		private var _cmf:ColorMatrixFilter;
		private var _texture:BitmapData;
		private var _bSmooth:Boolean;
		private var _m:Matrix;

		

		/**
		* Create a new TextureSkin.
		* 
		* @param t : The actionScriptLink of the bitmap;
		*/
		public function TextureSkin( t:BitmapData )
		{
			super();
			_m = new Matrix();
			texture = t;
			_bSmooth = false;
			_p = new Point(0, 0);
			_cmf = new ColorMatrixFilter();

		}
		
		/**
		 * Enable the smooth mode when drawing the texture.
		 * The quality shall be higher while the performance shall decrease when enabled.
		 */
		public function set smooth( b:Boolean )
		{
			_bSmooth = b;
			dispatchEvent( updateEvent );
		}
		
		public function get smooth():Boolean
		{
			return _bSmooth;
		}
		
		/**
		 * Change the transparency of the texture.
		 * A value is expected to set the transparency. This value represents the percentage of transparency.
		 * @param pValue An offset to change the transparency. A value between 0 and 100. 
		 * If the given value isn't i this interval, it will be clamped.
		 */
		public function setTransparency( pValue:Number ):void
		{
			pValue = 0.01 * NumberUtil.constrain( pValue, 0, 100 );
			
			_cmf = null;
			
			var matrix:Array = [
								1, 0, 0, 0, 0,
								0, 1, 0, 0, 0, 
								0, 0, 1, 0, 0, 
								0, 0, 0, pValue, 0];
	 
			_cmf = new ColorMatrixFilter( matrix );
			
			texture.applyFilter( texture, texture.rect, _p, _cmf );
			
			dispatchEvent( updateEvent );
		}
		
		
		
		/////////////
		// SETTERS //
		/////////////	
		public function set texture( b:BitmapData )
		{
			if (!b) return;
			
			_texture = b;
			_w = b.width;
			_h = b.height;
			dispatchEvent( updateEvent );
		}	
		/////////////
		// GETTERS //
		/////////////	
		public function get texture():BitmapData
		{
			return _texture;
		}
		
		
		
		/**
		 * 
		 * @param
		 * @return
		 */
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

		private function __concat( m1:Matrix, m2:Matrix ):Matrix
		{	
			var r = new Matrix();
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
		 * getType, returns the type of the skin
		 * @param void
		 * @return	The appropriate SkinType
		 */
		override public function getType ():SkinType
		{
			return SkinType.TEXTURE;
		}
		
		/**
		* Start the rendering of the Skin
		* @param f	The face which is being rendered
		* @param mc The mc where the face will be build.
		*/ 	
		override public function begin( f:IPolygon, mc:Sprite ):void
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
			var sMat:Matrix = new Matrix(	( x1 - x0 ) / _w, 
											( y1 - y0 ) / _w, 
											( x2 - x0 ) / _h, 
											( y2 - y0 ) / _h, 
											x0, 
											y0 );
			// --
			var rMat:Matrix = __concat( m, sMat );
			
			// -- 
			if( _useLight )
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
				mc.graphics.beginBitmapFill( _tmp, rMat, false, _bSmooth );
				_tmp.dispose();
				_tmp = null;
			} else {
				// -- 
				mc.filters = _filters;
				mc.graphics.beginBitmapFill( texture, rMat, false, _bSmooth );
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

	}
}