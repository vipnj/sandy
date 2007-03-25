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

import sandy.core.face.Face;
import sandy.core.light.Light3D;
import sandy.core.World3D;
import sandy.math.VectorMath;
import sandy.skin.Skin;
import sandy.skin.SkinType;
import sandy.skin.BasicSkin;

/**
* TextureSkin
*  
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		12.01.2006 
**/
class sandy.skin.TextureSkin extends BasicSkin implements Skin
{

	/**
	* Create a new TextureSkin.
	* 
	* @param t : The actionScriptLink of the bitmap;
	*/
	public function TextureSkin( t:BitmapData )
	{
		super();
		texture = t;
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
	/////////////
	// GETTERS //
	/////////////	
	public function get texture():BitmapData
	{
		return _texture;
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
	* Start the rendering of the Skin
	* @param f	The face which is being rendered
	* @param mc The mc where the face will be build.
	*/ 	
	public function begin( f:Face, mc:MovieClip ):Void
	{
		var x0: Number = f['_va'].sx;
		var y0: Number = f['_va'].sy;
		var x1: Number = f['_vb'].sx;
		var y1: Number = f['_vb'].sy;
		var x2: Number = f['_vc'].sx;
		var y2: Number = f['_vc'].sy;
		// --
		if( !( _w > 0 && _h > 0 ) ) return;
		// --
		var sMat = 	{ 	a:( x1 - x0 ) / _w, 
						b:( y1 - y0 ) / _w, 
						c:( x2 - x0 ) / _h, 
						d:( y2 - y0 ) / _h, 
						tx: x0, 
						ty:y0 
					};
		// --
		if( undefined == f['tMat'] )
		{
			var auv:Array  = f['aUv'];	
			var u0: Number = auv[0].u * _w;
			var v0: Number = auv[0].v * _h;
			var u1: Number = auv[1].u * _w;
			var v1: Number = auv[1].v * _h;
			var u2: Number = auv[2].u * _w;
			var v2: Number = auv[2].v * _h;
			// --
			var mat:Matrix = new Matrix( (u1 - u0)/_w, (v1 - v0)/_w, (u2 - u0)/_h, (v2 - v0)/_h, u0, v0 );
			mat.invert();
			f['tMat'] = mat;
		}
		var tMat = f['tMat'];
		var rMat = __concat( tMat, sMat );
		// -- 
		if( _useLight == true )
		{
			//TODO copy only the little part which is needed is the bitmap if possible.
			_tmp = _texture.clone();
			var l:Light3D 	= World3D.getInstance().getLight();
			var lp:Number	= 0.01 * l.getPower();
			var dot:Number 	= lp - ( VectorMath.dot( l.dir, f.createNormale() ) );
			// -- update the color transform matrix
			_cmf.matrix = __getBrightnessTransform( dot );
			// TODO: Optimize here with a different way to produce the light effect
			// and in aplying the filter only to the considered part of the texture!
			_tmp.applyFilter( _tmp , _tmp.rectangle, _p,  _cmf );
			mc.filters = _filters;
			mc.beginBitmapFill( _tmp, rMat, false, false );
		}
		else
		{
			// -- 
			mc.filters = _filters;
			mc.beginBitmapFill( _texture, rMat, false, false );
		}
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

	/**
	* Finish the rendering of the Skin
	* @param f	The face which is being rendered
	* @param mc The mc where the face will be build.
	*/ 	
	public function end( f:Face, mc:MovieClip ):Void
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
}


	