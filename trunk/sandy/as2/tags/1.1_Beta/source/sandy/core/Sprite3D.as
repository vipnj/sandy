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
import sandy.core.face.Sprite3DFace;
import sandy.core.Object3D;
import sandy.events.ObjectEvent;
import sandy.skin.MovieSkin;
import sandy.util.NumberUtil;	
import sandy.math.VectorMath;
import sandy.core.data.Vector;
	
/**
 * @author		Thomas Pfeiffer - kiroukou
 * @since		0.3
 * @version		0.3
 * @date 		28.03.2006
 **/
class sandy.core.Sprite3D extends Object3D 
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
	public function Sprite3D( pOffset:Number, pScale:Number ) 
	{
		super();
		// -- we create a fictive position point
		super.addPoint( 0, 0, 0 );
		// -- the scale vector
		super.addPoint( 1, 1, 1 );
		// -- we create a fictive normal vector
		super.addPoint( 0, 0, -1 );
		_vView = new Vector(0, 0, 1);
		// -- set the offset
		_nOffset = int(pOffset) || 0;
		// -- set the scale
		_nScale = (undefined == pScale) ? 1.0 : pScale;
		
		createFace();
	}
	
	/**
	* Set a Skin to the Sprite3D.
	* <p>This method will set the the new Skin to all his faces.</p>
	* 
	* @param	s	The MovieSkin to apply to the object
	* @return Bolean False is the skin can't be applied, true is everything is fine.
	*/
	public function setSkin( s:MovieSkin ):Boolean
	{
		if( s.getMovie()._totalframes < 360 )
		{
			trace("Sandy::Sprite3D#setSkin Error, The MovieSkin used with Sprite3D must have 360 frames, one frame per angle");
			return true;
		}
		else
		{
			super.setSkin( s, true );
			return false;
		}
	}
	
	/**
	 * This method isn't enable with the Sprite3D object. You might get the reason ;)
	 * Returns always false.
	 */
	public function setBackSkin( s:MovieSkin, bOverWrite:Boolean ):Boolean
	{
		return false;
	}
	
	/**
	* getScaleVector
	* <p>Returns the scale vector that represents the result of all the scales transformations applyied during the pipeline.
	* </p>
	* @param	Void
	* @return Number the scale value.
	*/
	public function getScaleVector( Void ):Vector
	{
		return new Vector( aPoints[1].tx - aPoints[0].tx, aPoints[1].ty - aPoints[0].ty, aPoints[1].tz - aPoints[0].tz );
	}
	
	/**
	* Render the Sprite3D.
	* <p>Check Faces display visibility and store visible Faces into ZBuffer.</p>
	*/ 
	public function render ( Void ):Void
	{
		// local copy because it's faster
		var f:Sprite3DFace = _aFaces[0];
		// private property access hack for speed purpose. Please use the equivalent public method in your code!
		var ndepth:Number = f['_va'].wz;
		//
		var vNormale:Vector = new Vector( aPoints[0].wx - aPoints[2].wx, aPoints[0].wy - aPoints[2].wy, aPoints[0].wz - aPoints[2].wz );
		var angle:Number = VectorMath.getAngle( _vView, vNormale );
		if( vNormale.x < 0 ) angle = 2*Math.PI - angle;
		//
		f.setFrame( __frameFromAngle( angle ) );
		// CLIPPING Now is the object behind the camera?
		if ( ndepth > 100 )
		{
			// if face is visible or drawAllFaces is set to true
			if ( !enableBackFaceCulling || f.isVisible () ) 
				ZBuffer.push( {face : f, depth : ndepth} );				
		}
		setModified( false );
	}
	
	/**
	* Create a new Frace.
	* <p>When a new Face is created, by default it has the Skin of the Sprite3D. 
	* The new Face will be automatically stored into the Object3D.</p>	* 
	* @return	The created Face
	*/
	public function createFace ( Void ):Sprite3DFace
	{
		setModified( true );
		//
		var f:Sprite3DFace = new Sprite3DFace( this, aPoints[0], aPoints[1] );
		// set Default Skin
		f.setSkin( MovieSkin( _s ) );
		_aFaces[0] = f;
		// the object listen the face events
		f.addEventListener( ObjectEvent.onPressEVENT, 		this, __onPressed );
		f.addEventListener( ObjectEvent.onRollOverEVENT, 	this, __onRollOver );
		f.addEventListener( ObjectEvent.onRollOutEVENT, 	this, __onRollOut );
		//and return it
		return f;
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
	
	/**
	* getScale
	* Allows you to get the scale of the Sprite3D and later change it with setSCale.
	* @param	Void
	* @return
	*/
	public function getScale( Void ):Number
	{
		return _nScale;
	}
	
	/**
	* Allows you to change the oject's scale.
	* @param	n Number 	The scale. This value must be a Number. A value of 1 let the scale as the perspective one.
	* 						A value of 2.0 will make the object twice bigger. 0 is a forbidden value
	*/
	public function setScale( n:Number ):Void
	{
		if( n )
		{
			_nScale = n;
		}
	}
	
	/**
	* Erase the behaviour of the Object3D addPoint method because Sprite3D handles itself its points. You can't add vertex by yourself here.
	* @param	x
	* @param	y
	* @param	z
	*/
	public function addPoint( x:Number, y:Number, z:Number ):Void
	{
		;
	}
	
	private function __frameFromAngle(a:Number):Number
	{
		a = NumberUtil.toDegree( a );
		a = (( a + _nOffset )+360) % 360;
		return int(a);
	}
	
	// -- frames offset
	private var _nOffset:Number;
	private var _nScale:Number;
	private var _vView:Vector;
	
}