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

import sandy.core.face.Polygon;
import sandy.core.light.Light3D;
import sandy.core.World3D;
import sandy.materials.BasicMaterial;
import sandy.materials.MaterialType;
import sandy.math.VectorMath;
import sandy.util.BitmapUtil;
import sandy.util.NumberUtil;

/**
 * BitmapMaterial
 *  
 * @author		Thomas Pfeiffer - kiroukou
 * @version		2.0
 * @date 		06.04.2007 
 **/

class sandy.materials.BitmapMaterial extends BasicMaterial
{

	/**
	* Create a new TextureSkin.
	* 
	* @param t : The actionScriptLink of the bitmap;
	*/
	public function BitmapMaterial( t:BitmapData )
	{
		super();
		texture = t;
		_p = new Point(0, 0);
		_cmf = new ColorMatrixFilter();
	}
	


	/**
	 * Change the transparency of the texture.
	 * A value is expected to set the transparency. This value represents the percentage of transparency.
	 * @param pValue An offset to change the transparency. A value between 0 and 100. 
	 * If the given value isn't i this interval, it will be clamped.
	 */
	public function setTransparency( pValue:Number ):Void
	{
		pValue = 0.01 * NumberUtil.constrain( pValue, 0, 100 );
		if( _cmf ) delete _cmf;
		var matrix:Array = [
						 	1, 0, 0, 0, 0,
				 			0, 1, 0, 0, 0, 
				 			0, 0, 1, 0, 0, 
				 			0, 0, 0, pValue, 0];
 
		_cmf = new ColorMatrixFilter( matrix );
		texture.applyFilter( texture, texture.rectangle, _p, _cmf );
	}
	
	/**
	 * getType, returns the type of the skin
	 * @param Void
	 * @return	The appropriate SkinType
	 */
	 public function get type ():MaterialType
	 { return MaterialType.TEXTURE; }
	
	/**
	 * Start the rendering of the Skin
	 * @param f	The face which is being rendered
	 * @param mc The mc where the face will be build.
	 */
	public function begin( f:Polygon, mc:MovieClip ):Void
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
		var rMat = BitmapUtil.concatBitmapMatrix( m, sMat );
		// -- 
		if( _useLight == true )
		{
			//TODO copy only the little part which is needed is the bitmap if possible.
			_tmp = _texture.clone();
			var l:Light3D 	= World3D.getInstance().light;
			var lp:Number	= 0.01 * l.getPower();
			var dot:Number 	= lp - ( VectorMath.dot( l.getDirectionVector(), f.createNormale() ) );
			// -- update the color transform matrix
			_cmf.matrix = __getBrightnessTransform( dot );
			// TODO: Optimize here with a different way to produce the light effect
			// and in aplying the filter only to the considered part of the texture!
			_tmp.applyFilter( _tmp , _tmp.rectangle, _p,  _cmf );
			mc.filters = _filters;
			mc.beginBitmapFill( _tmp, rMat, false, _bSmooth );
			_tmp.dispose();
			delete _tmp;
		}
		else
		{
			// -- 
			mc.filters = _filters;
			mc.beginBitmapFill( texture, rMat, false, _bSmooth );
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


	public function toString( Void ):String
	{
		return 'sandy.materials.BitmapMaterial' ;
	}

	
	private var _w:Number;
	private var _h:Number;

	private var _p:Point;
	private var _cmf:ColorMatrixFilter;
	private var _texture:BitmapData;

}


	