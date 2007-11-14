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

import flash.geom.Matrix;
import flash.geom.Point;

import sandy.core.Object3D;
import sandy.core.data.BBox;
import sandy.core.data.Matrix4;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.face.IPolygon;
import sandy.core.World3D;
import sandy.math.ColorMath;
import sandy.math.Matrix4Math;
import sandy.skin.Skin;
import sandy.skin.SkinType;
import sandy.skin.BasicSkin;

/**
* ZLightenSkin
* From an original code from Andre Michelle (www.andre-michelle.com). All credits belongs to Andre Michelle.
* Adaptation to Sandy's engine and optimizations by Thomas PFEIFFER
* @author		Andre Michelle and Sandy's port by Thomas Pfeiffer - kiroukou
* @since		1.0
* @version		1.0
* @date 		12.04.2006 
**/
class sandy.skin.ZLightenSkin extends BasicSkin implements Skin
{
	/**
	* Create a new Zlighting skin thnaks to a gradient effect.
	* IMPORTANT : Be carefull with the value of color! Depending on the value passed, the skin might gives some strange results. 
	* I'm working on it!
	* @param col	Number	the color of the object in hexa
	*/
	public function ZLightenSkin( col:Number )
	{
		super();
		_p = new Point(0, 0);
		// -- 
		_useLight = false;
		// --
		_blendMoveActive = false;
		//
		_matrix = new Matrix();
		// -- 
		_oCol = {r:1.0, g:1.0, b:1.0 };
		if( col )
		{
			_oCol = ColorMath.hex2rgbn( col );
		}
	}

	public function set color( n:Number )
	{
		_oCol = ColorMath.hex2rgbn( n );
		broadcastEvent( _eOnUpdate );
	}
	
	/////////////
	// GETTERS //
	/////////////	

	public function get color():Number
	{
		return ColorMath.rgb2hex( _oCol.r, _oCol.g, _oCol.b );
	}	
	
	/**
	 * getType, returns the type of the skin
	 * @param Void
	 * @return	The appropriate SkinType
	 */
	 public function getType ( Void ):SkinType
	 {
	 	return SkinType.ZLIGHTEN;
	 }
	 
	 /**
	* Returns the name of the skin you are using.
	* For the ZLightenSkin class, this value is set to "ZLIGHTEN"
	* @param	Void
	* @return String representing your skin.
	*/
	public function getName( Void ):String
	{
		return "ZLIGHTEN";
	}
	 	
	/**
	* Enable (true value) or disable (false value) the blend mode. The blend mode allows
	* a kind of transparency
	* @param	b Boolean true to enable the blend mode , false otherwise
	*/
	public function enableBlendMode( b:Boolean ):Void
	{
		_blendMoveActive = b;
	}
	
	/**
	* Start the rendering of the Skin
	* @param f	The face which is being rendered
	* @param mc The mc where the face will be build.
	*/ 	
	public function begin( f:IPolygon, mc:MovieClip ):Void
	{
		var vert:Array = new Array(3);
		var v0:Vertex; vert[0] = f['_va'];
		var v1:Vertex; vert[1] = f['_vb'];
		var v2:Vertex; vert[2] = f['_vc'];
		//-- we sort the vertices depending of their depth. This is usefull since the computations above needs an ordered array.
		var zIndices: Array = vert.sortOn( 'wz', Array.NUMERIC | Array.RETURNINDEXEDARRAY );
		v0 = vert[zIndices[0]];
		v1 = vert[zIndices[1]];
		v2 = vert[zIndices[2]];
		// --
		var x0: Number = v0.sx;
		var y0: Number = v0.sy;
		var x1: Number = v1.sx;
		var y1: Number = v1.sy;
		var x2: Number = v2.sx;
		var y2: Number = v2.sy;
		// -- we use the normal, so we need to create it and project it.
		var vn:Vector 	= f.createNormale();
		var mp:Matrix4 	= World3D.getInstance().getCurrentProjectionMatrix();
		Matrix4Math.projectVector( mp, vn );
		var nx: Number = vn.x;
		var ny: Number = vn.y;
		// we normalize the normal, important step!
		var nl: Number = Math.sqrt( nx * nx + ny * ny );
		nx /= nl;
		ny /= nl;
		//-- compute gray values
		var aB:BBox = Object3D(f['_o']).getBBox();
		var diff:Number = aB.max.z - aB.min.z;
		// --
		var g0: Number = 0xff - ( v0.wz - aB.min.z ) / diff * 0xff;
		var g1: Number = 0xff - ( v2.wz - aB.min.z ) / diff * 0xff;
		//-- compute gradient matrix
		var dx20: Number = x2 - x0;
		var dy20: Number = y2 - y0;
		var zLen: Number = nx * dx20 + ny * dy20;
		var zLen2: Number = zLen * 2;
		// --
		_matrix.createGradientBox( zLen2, zLen2, Math.atan2( ny, nx ), x0 - zLen, y0 - zLen );
		if( _blendMoveActive ) mc.blendMode = 'lighten';
		//-- draw gradient
		mc.filters = _filters;
		mc.beginGradientFill( 'linear', [ ( g0 << 16 )*_oCol.r | ( g0 << 8 )*_oCol.g | g0*_oCol.b, ( g1 << 16 )*_oCol.r | ( g1 << 8 )*_oCol.g | g1*_oCol.b ], [ 100, 100 ], [ 128, 0xff ], _matrix );
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
		return 'sandy.skin.ZLightenSkin' ;
	}

	private var _p:Point;
	private var _useLight : Boolean;
	private var _matrix:Matrix;
	private var _blendMoveActive:Boolean;
	private var _oCol:Object;
}
