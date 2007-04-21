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
import flash.geom.ColorTransform;

import sandy.core.face.IPolygon;
import sandy.core.light.Light3D;
import sandy.core.World3D;
import sandy.math.VectorMath;
import sandy.skin.Skin;
import sandy.skin.SkinType;
import sandy.skin.BasicSkin;
import sandy.skin.TextureSkin;
import sandy.util.NumberUtil;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.extensions.test.Profiler;

/**
* PrelitTextureSkin
* 
* Like a normal textures skin except that it pre-calculates a set of lit bitmaps
* to speed up rendering. There must be a light specified in the world for the rendering
* to work correctly.
* 
* @author		Martin Wood-Mitrovski
* @version		1.0
* @date 		08.04.2007 
**/
class sandy.skin.PrelitTextureSkin extends TextureSkin implements Skin
{
	public function PrelitTextureSkin( t:BitmapData, numTextures:Number )
	{
		super(t);

		_prelit = [];

		_textureCount = numTextures == undefined ? DEFAULT_TEXTURE_COUNT : numTextures;
		
		updateTextures(t);
	}
	
	/**
	 * Recalculate the set of textures for a new bitmap
	 * The lighting model matches that of the normal MovieSkin and TextureSkin
	 * where the range is from black to the plain bitmap, rather than from black to bitmap to white.
	 */
	public function updateTextures( t:BitmapData ):Void
	{
		texture = t;
		var offsetMax = World3D.GO_BRIGHT ? 512 : 256;
		
		for(var n=0;n<_textureCount;n++)
		{
			_tmp = t.clone();
			var off:Number = (n * (offsetMax / (_textureCount-1))) - 256;
			_tmp.colorTransform(_tmp.rectangle, new ColorTransform(1, 1, 1, 1, off, off, off, 0));
			
			_prelit[n] = _tmp;
		}
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
		var lightStrength:Number = World3D.getInstance().getLight().calculate(f.createNormale()) + 
								   World3D.getInstance().getAmbientLight();
		// Calculate texture ID
		var tID:Number = Math.floor(_textureCount * lightStrength);
		if(tID >= _textureCount) tID = _textureCount - 1;

		mc.beginBitmapFill( _prelit[tID], rMat, false, _bSmooth );
	}
	
	public function dispose( Void ):Void
	{
		for(var n=0;n<_prelit.length;n++)
		{
			_prelit[n].dispose();
		}
	}
	
	public static var DEFAULT_TEXTURE_COUNT = 32;
	private var _prelit:Array;
	private var _textureCount:Number;
}


	