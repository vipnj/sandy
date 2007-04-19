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

import com.bourre.data.collections.Map;

import flash.display.BitmapData;
import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flash.geom.Point;

import sandy.core.face.Polygon;
import sandy.materials.Material;
import sandy.materials.MaterialType;
import sandy.util.NumberUtil;

/**
 * BitmapMaterial
 *  
 * @author		Thomas Pfeiffer - kiroukou
 * @version		2.0
 * @date 		06.04.2007 
 **/

class sandy.materials.BitmapMaterial extends Material
{
	// --
	public var matrix:Matrix;
	// --
	public var smooth:Boolean;

	/**
	 * Create a new BitmapMaterial.
	 * @param t : The bitmapdata
	 */
	public function BitmapMaterial( t:BitmapData )
	{
		super();
		// --
		texture = t;
		smooth = false;
		// --
		m_oPoint = new Point(0, 0);
		m_oCmf = new ColorMatrixFilter();
		m_oPolygonMatrixMap = new Map();
	}

	function renderPolygon( p_oPolygon:Polygon ):Void 
	{
		// -- we prepare the texture
		prepare( p_oPolygon );
		// --
		var mc:MovieClip = p_oPolygon.container;
		var l_points:Array = p_oPolygon.cvertices;
		// --
		mc.beginBitmapFill( m_oTexture, matrix, false, smooth );
		// --
		if( lineAttributes )
			mc.lineStyle( lineAttributes.thickness, lineAttributes.color, lineAttributes.alpha );
		// --
		mc.moveTo( l_points[0].sx, l_points[0].sy );
		// --
		switch( l_points.length )
		{
			case 2 :
				mc.lineTo( l_points[1].sx, l_points[1].sy );
				break;
			case 3 :
				mc.lineTo( l_points[1].sx, l_points[1].sy );
				mc.lineTo( l_points[2].sx, l_points[2].sy );
				break;
			case 4 :
				mc.lineTo( l_points[1].sx, l_points[1].sy );
				mc.lineTo( l_points[2].sx, l_points[2].sy );
				mc.lineTo( l_points[3].sx, l_points[3].sy );
				break;
			default :
				var l:Number = l_points.length;
				while( --l > 0 )
				{
					mc.lineTo( l_points[(l)].sx, l_points[(l)].sy);
				}
				break;
		}
		
		// -- we draw the last edge
		if( lineAttributes )
		{
			mc.lineTo( l_points[0].sx, l_points[0].sy );
		}
		
		// --
		mc.endFill();
	}
		
	public function get texture():BitmapData
	{
		return m_oTexture;
	}
	
	public function set texture( p_oTexture:BitmapData )
	{
		m_oTexture = p_oTexture;
		m_nHeight = m_oTexture.height;
		m_nWidth = m_oTexture.width;
		// FIXME do the init for all the registered polygons
	}

	/**
	 * Change the transparency of the texture.
	 * A value is expected to set the transparency. This value represents the percentage of transparency.
	 * @param pValue An offset to change the transparency. A value between 0 and 100. 
	 * If the given value isn't i this interval, it will be clamped.
	 */
	public function setTransparency( pValue:Number ):Void
	{
		pValue = NumberUtil.constrain( pValue/100, 0, 1 );
		if( m_oCmf ) delete m_oCmf;
		var matrix:Array = [1, 0, 0, 0, 0,
				 			0, 1, 0, 0, 0, 
				 			0, 0, 1, 0, 0, 
				 			0, 0, 0, pValue, 0];
 
		m_oCmf = new ColorMatrixFilter( matrix );
		texture.applyFilter( texture, texture.rectangle, m_oPoint, m_oCmf );
	}
	
	/**
	 * getType, returns the type of the skin
	 * @param Void
	 * @return	The appropriate SkinType
	 */
	 public function get type ():MaterialType
	 { return MaterialType.TEXTURE; }
	
	
	public function init( f:Polygon ):Void
	{
		var m:Matrix = null;
		// --
		//Logger.LOG("BitmapMaterial::init "+m_nHeight+" "+m_nWidth);
		if( m_nWidth > 0 && m_nHeight > 0 )
		{		
			var l_aUV:Array = f.aUVCoord;
			var u0: Number = l_aUV[0].u;
			var v0: Number = l_aUV[0].v;
			var u1: Number = l_aUV[1].u;
			var v1: Number = l_aUV[1].v;
			var u2: Number = l_aUV[2].u;
			var v2: Number = l_aUV[2].v;
			// -- Fix perpendicular projections. Not sure it is really useful here since there's no texture prjection. This will certainly solve the freeze problem tho
			if( (u0 == u1 && v0 == v1) || (u0 == u2 && v0 == v2) )
			{
				u0 -= (u0 > 0.05)? 0.05 : -0.05;
				v0 -= (v0 > 0.07)? 0.07 : -0.07;
			}	
			if( u2 == u1 && v2 == v1 )
			{
				u2 -= (u2 > 0.05)? 0.04 : -0.04;
				v2 -= (v2 > 0.06)? 0.06 : -0.06;
			}
			// --
			m = new Matrix( (u1 - u0), m_nHeight*(v1 - v0)/m_nWidth, m_nWidth*(u2 - u0)/m_nHeight, (v2 - v0), u0*m_nWidth, v0*m_nHeight );
			m.invert();
			//Logger.LOG("Polygon matrix : "+f+" "+m);
		}
		// --
		m_oPolygonMatrixMap.put( f, m );
	}
	
	/**
	 * Start the rendering of the Skin
	 * @param f	The face which is being rendered
	 */
	private function prepare( f:Polygon ):Void
	{
		var a:Array = f.vertices;
		var m:Matrix = m_oPolygonMatrixMap.get( f );
		// --
		var x0: Number = a[0].sx;
		var y0: Number = a[0].sy;
		var x1: Number = a[1].sx;
		var y1: Number = a[1].sy;
		var x2: Number = a[2].sx;
		var y2: Number = a[2].sy;
		// --
		var sMat = 	{ 	a:( x1 - x0 ) / m_nWidth, 
						b:( y1 - y0 ) / m_nWidth, 
						c:( x2 - x0 ) / m_nHeight, 
						d:( y2 - y0 ) / m_nHeight, 
						tx: x0, 
						ty: y0 
					};
		// --
		matrix = m.clone();
		matrix.concat( sMat );
	}
	
	/**
	 * 
	 * @param
	 * @return
	 */
	private function __getBrightnessTransform( scale:Number ) : Array
	{
		var s:Number = scale;
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
	
	
	private var m_oTexture:BitmapData;
	private var m_nHeight:Number;
	private var m_nWidth:Number;
	private var m_oPolygonMatrixMap:Map;
	private var m_oPoint:Point;
	private var m_oCmf:ColorMatrixFilter;
	private var _texture:BitmapData;


}


	