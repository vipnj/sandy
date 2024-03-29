﻿/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author or authors.
Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 ( the "License" );
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
import com.bourre.data.iterator.ObjectIterator;
	
import flash.display.BitmapData;
import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flash.geom.Point;
	
import sandy.core.Scene3D;
import sandy.core.data.Polygon;
import sandy.core.data.Vertex;
import sandy.materials.IAlphaMaterial;
import sandy.materials.Material;
import sandy.materials.MaterialType;
import sandy.materials.attributes.MaterialAttributes;
import sandy.util.NumberUtil;

/**
 * Displays a bitmap on the faces of a 3D shape.
 *
 * @author		Thomas Pfeiffer - kiroukou
 * @author		Xavier Martin - zeflasher - transparency managment
 * @author		Makc for first renderRect implementation
 * @author		James Dahl - optimization in renderRec method
 * @author		(porting) Floris - xdevltd
 * @version		2.0.2
 * @date 		26.07.2007
 */
	 
class sandy.materials.BitmapMaterial extends Material implements IAlphaMaterial
{

	/**
	 * This property enables smooth bitmap rendering when set to true.
	 * The default value is set to false to have the best performance first.
	 * Enable this property have a performance impact, use it warefully
	 */
	public var smooth:Boolean;

	/**
	 * Precision of the bitmap mapping.
	 * This material uses an affine linear mapping. It results in a lack of accuracy at rendering time when the surface to draw is too big.
	 * One usual solution is to augment the number of polygon, but the performance cost can be quite big.
	 * Another solution is to change the precision property value. The lower the value, the more accurate the perspective correction is.
	 * To disable the perspective correction, set this property to zero, which is also the default value
	 * If you use the precision to solve the distortion issue, you can reduce the primitives quality ( except if you are experiencing some sorting issues )
	 */
	public var precision:Number;

	/**
	 * Maximum recurssion depth when using precision > 1 ( which enables the perspective correction ).
	 * The bigger the number is, the more accurate the result will be.
	 * Try to change this value to fits your needs to obtain the best performance.
	 */
	public var maxRecurssionDepth:Number;
	
	/**
	 * Creates a new BitmapMaterial.
	 * <p>Please note that we use internally a copy of the constructor bitmapdata. That means in case you need to access this bitmapdata, you can't just use the same reference
	 * but you shall use the BitmapMaterial#texture getter property to make it work.</p>
	 *
	 * @param p_oTexture	The bitmapdata for this material.
	 * @param p_oAttr		The attributes for this material.
	 * @param p_nPrecision	The precision of this material. Using a precision with 0 makes the material behave as before. Then 1 as precision is very high and requires a lot of computation but proceed a the best perpective mapping correction. Bigger values are less CPU intensive but also less accurate. Usually a value of 5 is enough.
	 *
	 * @see sandy.materials.attributes.MaterialAttributes
	 */
	public function BitmapMaterial( p_oTexture:BitmapData, p_oAttr:MaterialAttributes, p_nPrecision:Number )
	{
		super( p_oAttr );
		smooth = false;
		maxRecurssionDepth = 5;
		map = new Matrix();
		matrix = new Matrix();
		m_oPoint = new Point();
		m_oOffset = new Point( 0, 0 );
		m_oTiling = new Point( 1, 1 );
		// --
		m_oType = MaterialType.BITMAP;
		// --
		var temp:BitmapData = new BitmapData( p_oTexture.width, p_oTexture.height, true, 0 );
		temp.draw( p_oTexture );
		texture = temp;
		// --
		m_oCmf = new ColorMatrixFilter();
		m_oPolygonMatrixMap = new Map();
		precision = p_nPrecision||0;
	}

	/**
	 * @private
	 */
	public function renderPolygon( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:MovieClip ) : Void
	{
       	if( m_oTexture == null ) return;
       	// --
		var l_points:Array, l_uv:Array;
		var v0:Vertex, v1:Vertex,v2:Vertex;
		var i:Number, l:Number;
		// --
		polygon = p_oPolygon;
       	graphics = p_mcContainer;
		// --
		m_nRecLevel = 0;
		// -- Need some tesselation or mapping texture computation (clipped case)
		if( polygon.isClipped || polygon.vertices.length > 3 )
		{
			l_points = polygon.isClipped ? p_oPolygon.cvertices : p_oPolygon.vertices;
			l_uv = polygon.isClipped ? p_oPolygon.caUVCoord : p_oPolygon.aUVCoord;
			// --
			l = l_points.length - 1;
			for( i = 1; i < l; i++ )
			{
				map = _createTextureMatrix( l_uv[ 0 ].u, l_uv[ 0 ].v, l_uv[ int( i ) ].u, l_uv[ int( i ) ].v, l_uv[ int( i + 1 ) ].u, l_uv[ int( i + 1 ) ].v );
				// --
		        v0 = l_points[ 0 ];
		        v1 = l_points[ int( i ) ];
		        v2 = l_points[ int( i + 1 ) ];
	
		        if( precision == 0 )
		        {
		        	renderTriangle( map.a, map.b, map.c, map.d, map.tx, map.ty, v0.sx, v0.sy, v1.sx, v1.sy, v2.sx, v2.sy );
		        }
		        else
		        {
			        renderRec( map.a, map.b, map.c, 
							   map.d, map.tx, map.ty,
							   v0.sx, v0.sy, v0.wz,
							   v1.sx, v1.sy, v1.wz,
							   v2.sx, v2.sy, v2.wz  );
		        }
			}	    
		}
		else
		{
			l_points = p_oPolygon.vertices;
			l_uv = p_oPolygon.aUVCoord;
			// --
			map = Matrix( m_oPolygonMatrixMap.get( polygon.id ) );
			v0 = l_points[ 0 ];
        	v1 = l_points[ 1 ];
        	v2 = l_points[ 2 ];
			if( precision == 0 )
	        {
	        	renderTriangle( map.a, map.b, map.c, map.d, map.tx, map.ty, v0.sx, v0.sy, v1.sx, v1.sy, v2.sx, v2.sy );
	        }
	        else
	        {
		        renderRec( 	map.a, map.b, map.c, map.d, map.tx, map.ty,
							v0.sx, v0.sy, v0.wz,
							v1.sx, v1.sy, v1.wz,
							v2.sx, v2.sy, v2.wz );
	        }
		}
		// --
		if( attributes ) attributes.draw( graphics, polygon, this, p_oScene ) ;
		// --
		l_points = null;
		l_uv = null;
	}

	/**
	 * @private
	 */
	private function renderRec( ta:Number, tb:Number, tc:Number, td:Number, tx:Number, ty:Number,
		ax:Number, ay:Number, az:Number, bx:Number, by:Number, bz:Number, cx:Number, cy:Number, cz:Number ) : Void
	{
		m_nRecLevel++;
		var ta2:Number = ta + ta;
		var tb2:Number = tb + tb;
		var tc2:Number = tc + tc;
		var td2:Number = td + td;
		var tx2:Number = tx + tx;
		var ty2:Number = ty + ty;
		var mabz:Number = 2 / ( az + bz );
		var mbcz:Number = 2 / ( bz + cz );
		var mcaz:Number = 2 / ( cz + az );
		var mabx:Number = ( ax * az + bx * bz ) * mabz;
		var maby:Number = ( ay * az + by * bz ) * mabz;
		var mbcx:Number = ( bx * bz + cx * cz ) * mbcz;
		var mbcy:Number = ( by * bz + cy * cz ) * mbcz;
		var mcax:Number = ( cx * cz + ax * az ) * mcaz;
		var mcay:Number = ( cy * cz + ay * az ) * mcaz;
		var dabx:Number = ax + bx - mabx;
		var daby:Number = ay + by - maby;
		var dbcx:Number = bx + cx - mbcx;
		var dbcy:Number = by + cy - mbcy;
		var dcax:Number = cx + ax - mcax;
		var dcay:Number = cy + ay - mcay;
		var dsab:Number = ( dabx * dabx + daby * daby );
		var dsbc:Number = ( dbcx * dbcx + dbcy * dbcy );
		var dsca:Number = ( dcax * dcax + dcay * dcay );
		var mabxHalf:Number = mabx * 0.5;
		var mabyHalf:Number = maby * 0.5;
		var azbzHalf:Number = ( az + bz ) * 0.5;
		var mcaxHalf:Number = mcax * 0.5;
		var mcayHalf:Number = mcay * 0.5;
		var czazHalf:Number = ( cz + az ) * 0.5;
		var mbcxHalf:Number = mbcx * 0.5;
		var mbcyHalf:Number = mbcy * 0.5;
		var bzczHalf:Number = ( bz + cz ) * 0.5;
 
		if( ( m_nRecLevel > maxRecurssionDepth ) || ( ( dsab <= precision ) && ( dsca <= precision ) && ( dsbc <= precision ) ) )
		{
			renderTriangle( ta, tb, tc, td, tx, ty, ax, ay, bx, by, cx, cy );
			m_nRecLevel--; return;
		}
 
		if( ( dsab > precision ) && ( dsca > precision ) && ( dsbc > precision ) )
		{
			renderRec( ta2, tb2, tc2, td2, tx2, ty2,
					   ax, ay, az, mabxHalf, mabyHalf, azbzHalf, mcaxHalf, mcayHalf, czazHalf );
 
			renderRec( ta2, tb2, tc2, td2, tx2-1, ty2,
					   mabxHalf, mabyHalf, azbzHalf, bx, by, bz, mbcxHalf, mbcyHalf, bzczHalf );
 
			renderRec( ta2, tb2, tc2, td2, tx2, ty2-1,
					   mcaxHalf, mcayHalf, czazHalf, mbcxHalf, mbcyHalf, bzczHalf, cx, cy, cz );
 
			renderRec( -ta2, -tb2, -tc2, -td2, -tx2+1, -ty2+1,
						mbcxHalf, mbcyHalf, bzczHalf, mcaxHalf, mcayHalf, czazHalf, mabxHalf, mabyHalf, azbzHalf );
 
			m_nRecLevel--; return;
		}
 
		var dmax:Number = Math.max( dsab, Math.max( dsca, dsbc ) );
 
		if( dsab == dmax )
		{
			renderRec( ta2, tb, tc2, td, tx2, ty,
					   ax, ay, az, mabxHalf, mabyHalf, azbzHalf, cx, cy, cz );
 
			renderRec( ta2 + tb, tb, tc2 + td, td, tx2 + ty - 1, ty,
					   mabxHalf, mabyHalf, azbzHalf, bx, by, bz, cx, cy, cz );
 
		m_nRecLevel--; return;
		}
 
		if( dsca == dmax )
		{
			renderRec( ta, tb2, tc, td2, tx, ty2,
					   ax, ay, az, bx, by, bz, mcaxHalf, mcayHalf, czazHalf );
 
			renderRec( ta, tb2 + ta, tc, td2 + tc, tx, ty2 + tx - 1,
					   mcaxHalf, mcayHalf, czazHalf, bx, by, bz, cx, cy, cz );
 
			m_nRecLevel--; return;
		}
 
		renderRec( ta - tb, tb2, tc - td, td2, tx - ty, ty2,
				   ax, ay, az, bx, by, bz, mbcxHalf, mbcyHalf, bzczHalf );
 
		renderRec( ta2, tb - ta, tc2, td - tc, tx2, ty - tx,
				   ax, ay, az, mbcxHalf, mbcyHalf, bzczHalf, cx, cy, cz );
 
		m_nRecLevel--;
	}
        

	/**
	 * @private
	 */
	private function renderTriangle( a:Number, b:Number, c:Number, d:Number, tx:Number, ty:Number,
		v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number ) : Void
	{
		var a2:Number = v1x - v0x;
		var b2:Number = v1y - v0y;
		var c2:Number = v2x - v0x;
		var d2:Number = v2y - v0y;
		
		matrix.a = a * a2 + b * c2;
		matrix.b = a * b2 + b * d2;
		matrix.c = c * a2 + d * c2;
		matrix.d = c * b2 + d * d2;
		matrix.tx = tx * a2 + ty * c2 + v0x;
		matrix.ty = tx * b2 + ty * d2 + v0y;

		graphics.lineStyle();
		graphics.beginBitmapFill( m_oTexture, matrix, repeat, smooth );
		graphics.moveTo( v0x, v0y );
		graphics.lineTo( v1x, v1y );
		graphics.lineTo( v2x, v2y );
		graphics.endFill();
	}

	/**
	 * @private
	 */
	private function _createTextureMatrix( p_nU0:Number, p_nV0:Number, p_nU1:Number, p_nV1:Number, p_nU2:Number, p_nV2:Number ) : Matrix
	{
		var u0:Number = ( p_nU0 * m_oTiling.x + m_oOffset.x ) * m_nWidth,
			v0:Number = ( p_nV0 * m_oTiling.y + m_oOffset.y ) * m_nHeight,
			u1:Number = ( p_nU1 * m_oTiling.x + m_oOffset.x ) * m_nWidth,
			v1:Number = ( p_nV1 * m_oTiling.y + m_oOffset.y ) * m_nHeight,
			u2:Number = ( p_nU2 * m_oTiling.x + m_oOffset.x ) * m_nWidth,
			v2:Number = ( p_nV2 * m_oTiling.y + m_oOffset.y ) * m_nHeight;
		// -- Fix perpendicular projections. Not sure it is really useful here since there's no texture prjection. This will certainly solve the freeze problem tho
		if( ( u0 == u1 && v0 == v1 ) || ( u0 == u2 && v0 == v2 ) )
		{
			u0 -= ( u0 > 0.05 )? 0.05:-0.05;
			v0 -= ( v0 > 0.07 )? 0.07:-0.07;
		}
		if( u2 == u1 && v2 == v1 )
		{
			u2 -= ( u2 > 0.05 ) ? 0.04:-0.04;
			v2 -= ( v2 > 0.06 ) ? 0.06:-0.06;
		}
		// --
		var m:Matrix = new Matrix( ( u1 - u0 ), ( v1 - v0 ), ( u2 - u0 ), ( v2 - v0 ), u0, v0 );
		m.invert();
		return m;
	}

	/**
	 * The texture ( bitmap ) of this material.
	 */
	public function get texture() : BitmapData
	{
		return m_oTexture;
	}

	/**
	 * @private
	 */
	public function set texture( p_oTexture:BitmapData ) : Void
	{
		if( p_oTexture == m_oTexture )
		{
			return;
		}
		else
		{
			if( m_oTexture ) m_oTexture.dispose();
			if( m_orgTexture ) m_orgTexture.dispose();
		}
		// --
		var l_bReWrap:Boolean = false;
		if( m_nHeight != p_oTexture.height ) l_bReWrap = true;
		else if( m_nWidth != p_oTexture.width ) l_bReWrap = true;
		// --
		m_oTexture = p_oTexture;
		m_orgTexture = p_oTexture.clone();
		
		m_nHeight = m_oTexture.height;
		m_nWidth = m_oTexture.width;
		m_nInvHeight = 1 / m_nHeight;
		m_nInvWidth = 1 / m_nWidth;
		// -- We reinitialize the precomputed matrix
		var keys:ObjectIterator = m_oPolygonMatrixMap.getKeysIterator();
		if( l_bReWrap )
		{
			while( keys.hasNext() )
			{
				var l_oPoly:Polygon = Polygon.POLYGON_MAP.get( keys.next() );
				init( l_oPoly );
			}
		}
	}

	/**
	 * Sets texture tiling and optional offset. Tiling is applied first.
	 */
	public function setTiling( p_nW:Number, p_nH:Number, p_nU:Number, p_nV:Number ) : Void
	{
		m_oTiling.x = p_nW;
		m_oTiling.y = p_nH;
		// --
		m_oOffset.x = p_nU - Math.floor( p_nU )||0;
		m_oOffset.y = p_nV - Math.floor( p_nV )||0;
		// --
		var keys:ObjectIterator = m_oPolygonMatrixMap.getKeysIterator();
		while( keys.hasNext() )
		{
			var l_oPoly:Polygon = Polygon.POLYGON_MAP.get( keys.next() );
			init( l_oPoly );
		}
	}
		

	/**
	 * Changes the transparency of the texture.
	 *
	 * <p>The passed value is the percentage of opacity.</p>
	 *
	 * @param p_nValue 	A value between 0 and 1. ( automatically constrained )
	 */
	public function setTransparency( p_nValue:Number ) : Void
	{
		p_nValue = NumberUtil.constrain( p_nValue, 0, 1 );
		if( m_oCmf ) m_oCmf = null;
		var matrix:Array = [ 1, 0, 0, 0, 0,
						     0, 1, 0, 0, 0,
						     0, 0, 1, 0, 0,
						     0, 0, 0, p_nValue, 0 ];

		m_oCmf = new ColorMatrixFilter( matrix );
		texture.applyFilter( m_orgTexture, texture.rectangle, m_oPoint, m_oCmf );
	}

	/**
	 * Indicates the alpha transparency value of the material. Valid values are 0 ( fully transparent ) to 1 ( fully opaque ).
	 *
	 * @default 1.0
	 */
	public function get alpha() : Number 
	{
		return m_nAlpha;
	}

	/**
	 * @private
	 */
	public function set alpha( p_nValue:Number ) : Void	
	{
		setTransparency( p_nValue );
		m_nAlpha = p_nValue;
		m_bModified = true;
	}

	/**
	 * @private
	 */
	public function unlink( p_oPolygon:Polygon ) : Void
	{
		if( m_oPolygonMatrixMap.containsKey( p_oPolygon.id ) )
			m_oPolygonMatrixMap.remove( p_oPolygon.id );
		// --
		super.unlink( p_oPolygon );
	}
	
	/**
	 * @param p_oPolygon	The face dressed by this material
	 */
	public function init( p_oPolygon:Polygon ) : Void
	{
		if( p_oPolygon.vertices.length >= 3 )
		{
			var m:Matrix = null;
			// --
			if( m_nWidth > 0 && m_nHeight > 0 )
			{
				var l_aUV:Array = p_oPolygon.aUVCoord;
				if( l_aUV )
				{
					m = _createTextureMatrix( l_aUV[ 0 ].u, l_aUV[ 0 ].v, l_aUV[ int( 1 ) ].u, l_aUV[ int( 1 ) ].v, l_aUV[ int( 2 ) ].u, l_aUV[ int( 2 ) ].v );
				}
			}
			// --
			m_oPolygonMatrixMap.put( p_oPolygon.id, m );
		}
		// --
		super.init( p_oPolygon );
	}

	/**
	 * Returns a string representation of this object.
	 *
	 * @return	The fully qualified name of this object.
	 */
	public function toString() : String
	{
		return 'sandy.materials.BitmapMaterial' ;
	}

	/**
	 * @private
	 */
	public var polygon:Polygon;
	
	/**
	 * @private
	 */
	public var graphics:MovieClip;
	
	/**
	 * @private
	 */
	public var map:Matrix;

	/**
	 * @private
	 */
	private var m_oTexture:BitmapData;
	
	/**
	 * @private
	 */
	private var m_orgTexture:BitmapData;
		
	private var m_nHeight:Number;
	private var m_nWidth:Number;
	private var m_nInvHeight:Number;
	private var m_nInvWidth:Number;
	private var m_nAlpha:Number = 1.0;

	private var m_nRecLevel:Number = 0;
		
	/**
	 * @private
	 */
	private var m_oPolygonMatrixMap:Map;
	
	/**
	 * @private
	 */
	private var m_oPoint:Point;
	
	/**
	 * @private
	 */
	private var m_oCmf:ColorMatrixFilter;
	
	/**
	 * @private
	 */
	private var matrix:Matrix;
		
	/**
   	 * @private
	 */
	private var m_oTiling:Point;
		
	/**
	 * @private
	 */
	private var m_oOffset:Point;

	/**
	 * @private
	 */
	public var forceUpdate:Boolean;
	
}