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

import sandy.core.buffer.ZBuffer;
import sandy.core.data.Vector;
import sandy.core.Sprite2D;
import sandy.math.VectorMath;
import sandy.skin.MovieSkin;
import sandy.util.NumberUtil;
import sandy.core.data.Vertex;
	
/**
 * @author		Thomas Pfeiffer - kiroukou
 * @since		0.3
 * @version		0.3
 * @date 		28.03.2006
 **/
class sandy.core.Sprite3D extends Sprite2D 
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
	public function Sprite3D( pScale:Number, pOffset:Number ) 
	{
		super(pScale);
		// -- we create a fictive normal vector
		aPoints[1] = new Vertex( 0, 0, -1 );
		_vView = new Vector(0, 0, 1);
		// -- set the offset
		_nOffset = int(pOffset) || 0;
	}
	
	/**
	* Set a Skin to the Object3D.
	* <p>This method will set the the new Skin to all his faces.</p>
	* 
	* @param	s	The TexstureSkin to apply to the object
	* @return	Boolean True is the skin is applied, false otherwise.
	*/
	public function setSkin( s:MovieSkin ):Boolean
	{
		_s = s;
		if( _s.isInitialized() )
			__updateContent();
		else
			_s.addEventListener( MovieSkin.onUpdateEVENT, this, __updateContent);
		return true;
	}
	
	private function __updateContent( Void ):Void
	{
		if( _s.getMovie()._totalframes != 360 )
		{
			trace("Sprite3D:: Error, the skin movie must have 360 frames");
		}
		else
		{
			_s.attach( container );
		}
	}

	
	/**
	* Render the Sprite3D.
	* <p>Check Faces display visibility and store visible Faces into ZBuffer.</p>
	*/ 
	public function render ( Void ):Void
	{
		//
		var vNormale:Vector = new Vector( _v.wx - aPoints[1].wx, _v.wy - aPoints[1].wy, _v.wz - aPoints[1].wz );
		var angle:Number = VectorMath.getAngle( _vView, vNormale );
		if( vNormale.x < 0 ) angle = 2*Math.PI - angle;
		// FIXME problem around 180 frame. A big jump occurs. Problem of precision ?
		container.gotoAndStop( __frameFromAngle( angle ) );
		//
		super.render();
	}
	
	private function __frameFromAngle(a:Number):Number
	{
		a = NumberUtil.toDegree( a );
		a = (( a + _nOffset )+360) % 360;
		return int(a);
	}
		

	/**
	* getOffset
	* Ollows you to get the offset of the Clip3D and later change it with setOffset if you need.
	* @param	Void
	* @return
	*/
	public function getOffset( Void ):Number
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
	
}