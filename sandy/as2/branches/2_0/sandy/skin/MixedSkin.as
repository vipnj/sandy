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

import sandy.core.data.Vector;
import sandy.core.face.IPolygon;
import sandy.core.light.Light3D;
import sandy.core.World3D;
import sandy.math.VectorMath;
import sandy.skin.BasicSkin;
import sandy.skin.Skin;
import sandy.skin.SkinType;
import sandy.util.NumberUtil;

/**
* MixedSkin
*  
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		23.06.2006 
**/
class sandy.skin.MixedSkin extends BasicSkin implements Skin
{
	private var _colorLine:Number;
	private var _alphaLine:Number;
	private var _thickness:Number;
	private var _colorBkg:Number;
	private var _alphaBkg:Number;	

	/**
	* Create a new MixedSkin.
	* 
	* @param cb Number The color used to fill the Object faces
	* @param an Number The alpha value used to fill the Object faces
	* @param cl Number The color of the lines used to draw the Object edges
	* @param al Number The alpha of the lines used to draw the Object edges
	* @param tl Number The thickness of the lines used to draw the Object edges
	* 
	*/ 
	public function MixedSkin(cb:Number,ab:Number,cl:Number, al:Number,tl:Number )
	{
		super();
		_colorLine 	= (isNaN(cl)) ? 0x000000 : cl;
		_alphaLine 	= (isNaN(al)) ? 100 : al;
		_thickness 	= (isNaN(tl)) ? 2 : tl;
		_colorBkg 	= (isNaN(cb)) ? 0xEEEEEE : cb;
		_alphaBkg 	= (isNaN(ab)) ? 100 : ab;
		//--
		_useLight = false;
		this.filters = [];
	}

	/////////////
	// SETTERS //
	/////////////
	public function set alphaBkg( n:Number )
	{
		_alphaBkg = n;
		broadcastEvent( _eOnUpdate );
	}
	public function set colorBkg( n:Number )
	{
		_colorBkg = n;
		broadcastEvent( _eOnUpdate );
	}
	public function set thickness( n:Number )
	{
		_thickness = n;
		broadcastEvent( _eOnUpdate );
	}
	public function set alphaLine( n:Number )
	{
		_alphaLine = n;
		broadcastEvent( _eOnUpdate );
	}
	public function set colorLine( n:Number )
	{
		_colorLine = n;
		broadcastEvent( _eOnUpdate );
	}
	
	/////////////
	// GETTERS //
	/////////////	
	public function get alphaBkg():Number
	{
		return _alphaBkg;
	}
	public function get colorBkg():Number
	{
		return _colorBkg;
	}	
	public function get thickness():Number
	{
		return _thickness;
	}	
	public function get alphaLine():Number
	{
		return _alphaLine;
	}	
	public function get colorLine():Number
	{
		return _colorLine;
	}

	/**
	 * getType, returns the type of the skin
	 * @param Void
	 * @return	The appropriate SkinType
	 */
	 public function getType ( Void ):SkinType
	 {
	 	return SkinType.MIXED;
	 }
	
	/**
	* Start the rendering of the Skin
	* @param f	The face which is being rendered
	* @param mc The mc where the face will be build.
	*/ 	
	public function begin( face:IPolygon, mc:MovieClip ):Void
	{
		mc.filters = _filters;
		// -- 
		var col:Number = _colorBkg;
		if( _useLight )
		{
			var l:Light3D 	= World3D.getInstance().light;
			var vn:Vector 	= face.createNormale();
			var vl:Vector 	= l.getDirectionVector();
			var lp:Number	= l.getPower()/100;
			// --
			var r:Number = ( col >> 16 )& 0xFF;
			var g:Number = ( col >> 8 ) & 0xFF;
			var b:Number = ( col ) 		& 0xFF;
			// --
			var dot:Number =  - ( VectorMath.dot( vl, vn ) );
			r = NumberUtil.constrain( r*(dot+lp), 0, 255 );
			g = NumberUtil.constrain( g*(dot+lp), 0, 255 );
			b = NumberUtil.constrain( b*(dot+lp), 0, 255 );
			// --
			col =  r << 16 | g << 8 |  b;
		}
		mc.lineStyle( _thickness, _colorLine, _alphaLine );
		mc.beginFill( col , _alphaBkg );
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
		return 'sandy.skin.MixedSkin' ;
	}
	
}
