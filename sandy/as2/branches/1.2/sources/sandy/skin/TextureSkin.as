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
import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flash.geom.Point;

import sandy.core.face.IPolygon;
import sandy.core.light.Light3D;
import sandy.core.World3D;
import sandy.math.VectorMath;
import sandy.skin.Skin;
import sandy.skin.SkinType;
import sandy.skin.BasicSkin;
import sandy.util.NumberUtil;

/**
* TextureSkin
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Bruce Epstein	- zeusprod
* @since		1.0
* @version		1.2.1
* @date 		12.04.2007 
**/
class sandy.skin.TextureSkin extends BasicSkin implements Skin
{

	/**
	* Create a new TextureSkin.
	* 
	* @param t : BitmapData object, such as the actionScript Link of the bitmap;
	* @param bSmooth : Boolean; if true perform smoothing (performance-intensive).
	* @param a: Number; Transparency from 0 (invisible) to 100 (opaque)
	*/
	public function TextureSkin( t:BitmapData, bSmooth:Boolean, a:Number )
	{
		super();
		_m = new Matrix();
		texture = t;
		_bSmooth = (bSmooth == undefined) ? false : bSmooth;
		alpha = (a == undefined) ? 100 : a;
		_p = new Point(0, 0);
		_cmf = new ColorMatrixFilter();
	}
	
	/////////////
	// SETTERS //
	/////////////	
	public function set texture( b:BitmapData )
	{
		_texture = b;
		_w = b.width;
		_h = b.height;
		broadcastEvent( _eOnUpdate );
	}
		
	/**
	 * Enable the smooth mode when drawing the texture.
	 * The quality shall be higher while the performance shall decrease when enabled.
	 */
	public function set smooth( b:Boolean )
	{
		_bSmooth = b;
		broadcastEvent( _eOnUpdate );
	}
	
	public function set alpha( newVal:Number )
	{
		setTransparency (newVal);
		broadcastEvent( _eOnUpdate );
	}
	
	/////////////
	// GETTERS //
	/////////////	
	public function get texture():BitmapData
	{
		return _texture;
	}
	
	public function get smooth():Boolean
	{
		return _bSmooth;
	}
	
	public function get alpha():Number
	{
		return _alpha;
	}
	
	/**
	 * Change the transparency of the texture.
	 * A value is expected to set the transparency. This value represents the percentage of transparency.
	 * @param pValue An offset to change the transparency. A value between 0 and 100. 
	 * If the given value isn't in this interval, it will be clamped.
	 */
	public function setTransparency( pValue:Number ):Void
	{
		_alpha = NumberUtil.constrain( pValue, 0, 100 );
		if( _cmf ) delete _cmf;
		var matrix:Array = [1, 0, 0, 0, 0,
				 			0, 1, 0, 0, 0, 
				 			0, 0, 1, 0, 0, 
				 			0, 0, 0, (0.01 * _alpha), 0];
 
		_cmf = new ColorMatrixFilter( matrix );
		texture.applyFilter( texture, texture.rectangle, _p, _cmf );
		broadcastEvent( _eOnUpdate );
	}
	
	/**
	 * getType, returns the type of the skin
	 * @param Void
	 * @return	The appropriate SkinType
	 */
	 public function getType ( Void ):SkinType
	 {
	 	return SkinType.TEXTURE;
	 }
	 
	 /**
	* Returns the name of the skin you are using.
	* For the TextureSkin class, this value is set to "TEXTURE"
	* @param	Void
	* @return String representing your skin.
	*/
	public function getName( Void ):String
	{
		return "TEXTURE";
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
			mc.beginBitmapFill( texture, rMat, false, _bSmooth );
		}
	}
	
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
				0.0	, 0.0	, 0.0	, 1.0	, 0
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

	/**
	* Finish the rendering of the Skin
	* @param f	The face which is being rendered
	* @param mc The mc where the face will be build.
	*/ 	
	public function end( f:IPolygon, mc:MovieClip ):Void
	{
		mc.endFill();
	}

	public function toString( Void ):String
	{
		return 'sandy.skin.TextureSkin' ;
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
	
	private var _w:Number;
	private var _h:Number;
	private var _tmp:BitmapData;
	private var _p:Point;
	private var _cmf:ColorMatrixFilter;
	private var _texture:BitmapData;
	private var _bSmooth:Boolean;
	private var _alpha:Number;
	private var _m:Matrix;
}


	