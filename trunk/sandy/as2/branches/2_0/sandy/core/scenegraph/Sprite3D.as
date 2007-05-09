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
import sandy.core.data.Vertex;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Sprite2D;
import sandy.math.VectorMath;
import sandy.util.NumberUtil;
	
/**
 * @author		Thomas Pfeiffer - kiroukou
 * @date 		28.02.2007
 **/
class sandy.core.scenegraph.Sprite3D extends Sprite2D 
{
	/**
	* A Sprite3D is in fact a special Sprite2D. A Sprite3D is batween a real Object3D and a Sprite2D.
	* It has a skin which is a movie clip containing 360 frames (at least!). 
	* Depending on the camera position, the _currentframe of the Clip3D will change, to give a 3D effect.
	* @param	pOffset Number 	A number between [0-360] to give an offset in the 3D representation.
	* @param 	pScale Number 	A number used to change the scale of the displayed object. In case that the object projected dimension
	* 							isn't adapted to your needs. Default value is 1.0 which means unchanged. A value of 2.0 will make the object
	* 							twice bigger and so on.
	*/
	public function Sprite3D ( p_Name:String, pScale:Number, pOffset:Number ) 
	{
		super(p_Name, pScale);
		// -- we create a fictive normal vector
		geometry.setVertex(1, 0, 0, -1);
		geometry.setVertex(2, 0, 0, 1);
		// --
		_dir = geometry.aVertex[1];
		_vView = geometry.aVertex[2];
		// -- set the offset
		_nOffset = pOffset||0;
	}
	
    public function render( p_oCamera:Camera3D ):Void
	{
        super.render( p_oCamera );
		// --
        var vNormale:Vector = new Vector( _v.wx - _dir.wx, _v.wy - _dir.wy, _v.wz - _dir.wz );
		var angle:Number = VectorMath.getAngle( _vView, vNormale );
		if( vNormale.x < 0 ) angle = 2*Math.PI - angle;
		// FIXME problem around 180 frame. A big jump occurs. Problem of precision ?
		aPolygons[0].container.gotoAndStop( __frameFromAngle( angle ) );
	}
	
	
	private function __frameFromAngle(a:Number):Number
	{
		a = NumberUtil.toDegree( a );
		a = (( a + _nOffset )+360) % 360;
		return a;
	}
			

	/**
	* getOffset
	* Ollows you to get the offset of the Clip3D and later change it with setOffset if you need.
	* @param	void
	* @return
	*/
	public function getOffset():Number
	{
		return _nOffset;
	}
	
	/**
	* Allows you to change the oject offset.
	* @param	n Number The offset. This value must be between 0 and 360.
	*/
	public function setOffset( n:Number ):Void
	{
		_nOffset = n;
	}
	
	// -- frames offset
	private var _nOffset:Number;
	private var _nScale:Number;
	private var _vView:Vector;
	private var _dir:Vertex;
	
}