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
 
import sandy.core.data.Matrix4;
import sandy.core.data.Vector;
import sandy.core.transform.Interpolator3D;
import sandy.core.transform.TransformType;
import sandy.events.InterpolationEvent;
import sandy.math.Matrix4Math;
import sandy.math.VectorMath;
import sandy.util.NumberUtil;
import sandy.util.Rectangle;
import sandy.view.Frustum;
import sandy.view.Viewport;

/**
* Camera3D
* @author		Thomas Pfeiffer - kiroukou
* @author		Bruce Epstein - zeusprod
* @since		1.0
* @version		1.2.3
* @date 		07.08.2007
**/
class sandy.view.Camera3D 
{
 	/**
 	 * The frustum of the camera. See {@see Frustum} class.
 	 */
 	public var frustrum:Frustum;
 	
 	public var viewport:Viewport;
 	
	/**
	 * Create a new Camera3D.
	 * The default camera projection is the perspective one with default parameters values.
	 * @param w Number The width of the screen
	 * @param h Number The height of the screen
	 */
	public function Camera3D( p_nWidth:Number, p_nHeight:Number )
	{
		_p 		= new Vector();
		// --
		_vOut 	= new Vector( 0, 0, 1 );
		_vSide 	= new Vector( 1, 0, 0 );
		_vUp 	= new Vector( 0, 1 ,0 );
		_vLookatDown = new Vector(0.00000000001, -1, 0);// value to avoid some colinearity problems.
		// --
		_nRoll 	= 0;
		_nTilt 	= 0;
		_nYaw  	= 0;
		// --
		viewport = new Viewport( p_nWidth, p_nHeight );
		frustrum = new Frustum();
		
		// -- Default to fov 45, near plane 50 and far plane 3000
		_nFovY = 45;
		_nNear = 50;
		_nFar = 3000;
		
		setPerspectiveProjection();
		//setPerspective();
		// --
		_mt = _mf = _mv = Matrix4.createIdentity();
		_compiled = false;
		_oInt = null;
	}

	
	/**
	* Update the screen viewport dimensions
	* @param	Void
	*/
	public function resize( p_nWidth:Number, p_nHeight:Number ):Void
	{
		delete viewport;	
		viewport = new Viewport( p_nWidth, p_nWidth );
		_compiled = false;
	}
	
	/**
	 * Allow the camera to translate along its side vector. 
	 * If you imagine yourself in a game, it would be a step on your right or on your left
	 * @param	d	Number	Move the camera along its side vector
	 */
	public function moveSideways( d : Number ) : Void
	{
		_compiled = false;
		_p.x += _vSide.x * d;
		_p.y += _vSide.y * d;
		_p.z += _vSide.z * d;
	}
	
	/**
	 * Allow the camera to translate along its up vector. 
	 * If you imagine yourself in a game, it would be a jump on the direction of your body (so not always the vertical!)
	 * @param	d	Number	Move the camera along its up vector
	 */
	public function moveUpwards( d : Number ) : Void
	{
		_compiled = false;
		_p.x += _vUp.x * d;
		_p.y += _vUp.y * d;
		_p.z += _vUp.z * d;
	}
	
	/**
	 * Allow the camera to translate along its view vector. 
	 * If you imagine yourself in a game, it would be a step in the direction you look at. If you look the sky
	 * you will translate upwards ! So be careful with its use.
	 * @param	d	Number	Move the camera along its viw vector
	 */
	public function moveForward( d : Number ) : Void
	{
		_compiled = false;
		_p.x += _vOut.x * d;
		_p.y += _vOut.y * d;
		_p.z += _vOut.z * d;
	}
 
	/**
	 * Allow the camera to translate horizontally
	 * If you imagine yourself in a game, it would be a step in the direction you look at but without changing 
	 * your altitude.
	 * @param	d	Number	Move the camera horizontally
	 */	
	public function moveHorizontally( d:Number ) : Void
	{
		_compiled = false;
		_p.x += _vOut.x * d;
		_p.z += _vOut.z * d;		
	}
	
 	/**
	 * Allow the camera to translate vertically
	 * If you imagine yourself in a game, it would be a jump strictly vertical.
	 * @param	d	Number	Move the camera vertically
	 */	
	public function moveVertically( d:Number ) : Void
	{
		_compiled = false;
		_p.y += d;		
	}
	
	/**
	* Translate the camera from it's actual position with the offset values pased in parameters
	* 
	* @param px x offset that will be added to the x coordinate of the camera
	* @param py y offset that will be added to the y coordinate position of the camera
	* @param pz z offset that will be added to the z coordinate position of the camera
	*/
	public function translate( px:Number, py:Number, pz:Number ) : Void
	{
		_compiled = false;
		// we must consider the screen y-axis inversion
		_p.x += px;
		_p.y += py;
		_p.z += pz;	
	}
	
	
	 /**
	 * Allow the camera to translate lateraly
	 * If you imagine yourself in a game, it would be a step on the right with a positiv parameter and to the left
	 * with a negative parameter
	 * @param	d	Number	Move the camera lateraly
	 */	
	public function moveLateraly( d:Number ) : Void
	{
		_compiled = false;
		_p.x += d;		
	}
	
	/**
	 * Rotate the camera around a specific axis by an angle passed in parameter
	 * @param	ax	Number	The x coordinate of the axis
	 * @param	ay	Number	The y coordinate of the axis
	 * @param	az	Number	The z coordinate of the axis
	 * @param	nAngle	Number	The amount of rotation. This angle is in degrees.
	 */
	public function rotateAxis( ax : Number, ay : Number, az : Number, nAngle : Number ):Void
	{
		_compiled = false;
		nAngle = (nAngle + 360)%360;
		var n:Number = Math.sqrt( ax*ax + ay*ay + az*az );
		var m : Matrix4 = Matrix4Math.axisRotation( ax/n, ay/n, az/n, nAngle );
		Matrix4Math.vectorMult3x3( m, _vSide);
		Matrix4Math.vectorMult3x3( m, _vUp);
		Matrix4Math.vectorMult3x3( m, _vOut);
	}
 
	/**
	 * Make the camera look at a specific position. Useful to follow a moving object or a static object while the camera is moving.
	 * @param	px	Number	The x position to look at
	 * @param	py	Number	The y position to look at
	 * @param	pz	Number	The z position to look at
	 */
	public function lookAt( px:Number, py:Number, pz:Number ):Void
	{
		_compiled = false;
		_vOut = VectorMath.sub( new Vector(px, py, pz), _p );
		VectorMath.normalize( _vOut );
		// -- the vOut vector should not be colinear with the reference down vector!
		_vSide = VectorMath.cross( _vOut, _vLookatDown );
		VectorMath.normalize( _vSide );
		_vUp = VectorMath.cross( _vOut, _vSide );
		VectorMath.normalize( _vUp );
	}
 
	/**
	 * RotateX - Rotation around the global X axis of the camera frame
	 * @param nAngle Number The angle of rotation in degree.
	 * @return Void
	 */
	public function rotateX ( nAngle:Number ):Void
	{
		_compiled = false;
		nAngle = (nAngle + 360)%360;
		var m:Matrix4 = Matrix4Math.axisRotation ( 1, 0, 0, nAngle );
		Matrix4Math.vectorMult3x3( m, _vUp);
		Matrix4Math.vectorMult3x3( m, _vSide);
		Matrix4Math.vectorMult3x3( m, _vOut);
	}
	
	/**
	 * rotateY - Rotation around the global Y axis of the camera frame
	 * @param nAngle Number The angle of rotation in degree.
	 * @return Void
	 */
	public function rotateY ( nAngle:Number ):Void
	{
		_compiled = false;
		nAngle = (nAngle + 360)%360;
		var m:Matrix4 = Matrix4Math.axisRotation ( 0, 1, 0, nAngle );
		Matrix4Math.vectorMult3x3( m, _vUp);
		Matrix4Math.vectorMult3x3( m, _vSide);
		Matrix4Math.vectorMult3x3( m, _vOut);
	}
	
	/**
	 * rotateZ - Rotation around the global Z axis of the camera frame
	 * @param nAngle Number The angle of rotation in degree between : [ -180; 180 ].
	 * @return
	 */
	public function rotateZ ( nAngle:Number ):Void
	{
		_compiled = false;
		nAngle = (nAngle + 360)%360;
		var m:Matrix4 = Matrix4Math.axisRotation ( 0, 0, 1, nAngle );
		Matrix4Math.vectorMult3x3( m, _vUp);
		Matrix4Math.vectorMult3x3( m, _vSide);
		Matrix4Math.vectorMult3x3( m, _vOut);
	}	
	
	/**
	 * Tilt - Rotation around the local X axis of the camera frame
	 * Range from -90 to +90 where 0 = Horizon, +90 = straight up and –90 = straight down.
	 * @param nAngle Number The angle of rotation in degree.
	 * @return Void
	 */
	public function tilt ( nAngle:Number ):Void
	{
		//_nTilt = NumberUtil.constrain( _nTilt + nAngle, -90, 90 );
		//if( _nTilt == -90 || _nTilt == 90 ) return;
		_compiled = false;
		nAngle = (nAngle + 360)%360;
		_nTilt = nAngle;
		var m:Matrix4 = Matrix4Math.axisRotation ( _vSide.x, _vSide.y, _vSide.z, nAngle );
		Matrix4Math.vectorMult3x3( m, _vUp);
		Matrix4Math.vectorMult3x3( m, _vOut);
	}
	
	/**
	 * Pan - Rotation around the local Y axis of the camera frame
	 * Range from 0 to 360 where 0=North, 90=East, 180=South and 270=West.
	 * @param nAngle Number The angle of rotation in degree.
	 * @return Void
	 */
	public function pan ( nAngle:Number ):Void
	{
		_compiled = false;
		nAngle = (nAngle + 360)%360;
		_nYaw = nAngle;
		var m:Matrix4 = Matrix4Math.axisRotation ( _vUp.x, _vUp.y, _vUp.z, nAngle );
		Matrix4Math.vectorMult3x3( m, _vSide);
		Matrix4Math.vectorMult3x3( m, _vOut);
	}
	
	/**
	 * roll - Rotation around the local Z axis of the camera frame
	 * Range from -180 to +180 where 0 means the plane is aligned with the horizon, 
	 * +180 = Full roll right and –180 = Full roll left. In both cases, when the roll is 180 and –180, 
	 * the plane is flipped on its back.
	 * @param nAngle Number The angle of rotation in degree.
	 * @return
	 */
	public function roll ( nAngle:Number ):Void
	{
		_compiled = false;
		nAngle = (nAngle + 360)%360;
		_nRoll = nAngle;
		var m:Matrix4 = Matrix4Math.axisRotation ( _vOut.x, _vOut.y, _vOut.z, nAngle );
		Matrix4Math.vectorMult3x3( m, _vSide);
		Matrix4Math.vectorMult3x3( m, _vUp);
	}	

	public function getLookUp( Void ):Vector
	{
		return _vUp;
	}
	public function getLookOut( Void ):Vector
	{
		return _vOut;
	}
	public function getLookSide( Void ):Vector
	{
		return _vSide;
	}
	
	
	public function getRoll( Void ):Number
	{
		return _nRoll;
	}
	
	public function getPitch( Void ):Number
	{
		return _nTilt;
	}
	
	public function getYaw( Void ):Number
	{
		return _nYaw;
	}
	
	
	public function getFov( Void ):Number
	{
		return _nFovY;
	}
	
	public function getNearPlane( Void ):Number
	{
		return _nNear;
	}
	
	public function getFarPlane( Void ):Number
	{
		return _nFar;
	}
	
    // We need to set _compiled to true after the camera matrix has been computed.
    // Otherwise, the system perpetually redraws the scene thinking the matrix changed. 
	public function setCompiled( b:Boolean ):Void
	{
		_compiled = b;
	}
	
	
	/**
	* Set the position of the camera. Basically apply a translation.
	* @param x x position of the camera
	* @param y y position of the camera
	* @param z z position of the camera
	*/
	public function setPosition( x:Number, y:Number, z:Number ):Void
	{
		_compiled = false;
		// we must consider the screen y-axis inversion
		_p.x = x;
 		_p.y = y;
		_p.z = z;	
	}
	
	
	/**
	* Get the position of the camera.
	* @return the position of the camera as a Vector
	*/
	public function getPosition( Void ) : Vector
	{
		return new Vector(_p.x, _p.y, _p.z );
	}
	
	/**
	* Set an interpolator to the camera. Currently the camera handles only a Path interpolator or a Position interpolation.
	* @param	i Interpolator3D	The interpolator you want to apply to the camera. It must be a Path interpolator or a Position interpolation
	* @return Boolean True is the operation goes well, false otherwise
	*/
	public function setInterpolator( i:Interpolator3D ):Boolean
	{
		if( i.getType() == TransformType.PATH_INTERPOLATION || i.getType() == TransformType.TRANSLATION_INTERPOLATION )
		{
			removeInterpolator();
			_oInt = i;
			_oInt.addEventListener( InterpolationEvent.onProgressEVENT, this, __onInterpolation );
			return true;
		}
		else
		{
			return false;
		}
	}
	
	/**
	* REmove the interpolator is exist. remove also the listeners.
	* @param	Void
	* @return Boolean True is the operation goes well, false otherwise.
	*/
	public function removeInterpolator( Void ):Boolean
	{
		if(  null == _oInt ) return false;
		else
		{
			_oInt.removeEventListener( InterpolationEvent.onProgressEVENT, this );
			delete _oInt;
			_oInt = null;
			return true;
		}
	}
	
	/**
	* This method helps you to know if something has changed in the camera, and if you need to compile it again to take care about the modifications.
	* @param	Void
	* @return	Boolean True value is returned if something has changed, false otherwise.
	*/
	public function isModified( Void ):Boolean
	{
		/* If the camera matrix is not compiled, then the camera has been modified */
		return (_compiled == false);
	}
	
	/**
	* Compile the camera transformations by multiplying the matrix together.
	* Do this only if isModified() is true, to save computations. 
	*/
	public function compile( Void ):Void
	{
		if (isModified()) {
			// we set up the rotation matrix from euler's angle
			__updateTransformMatrix();
			// we add the translation effect
			_mf = Matrix4Math.multiply ( _mp, _mt );
			setCompiled(true);
		}
	}
	
	public function getMatrix( Void ):Matrix4
	{
		return _mf;
	}
	
	/**
	* Return the projection matrix. 
	* 
	* @return Matrix4
	*/
	public function getProjectionMatrix(Void):Matrix4
	{
		return _mp;
	}
	
	/**
	 * Returns the inverse of the projection matrix
	 */
	public function getProjectionMatrixInverse( Void ):Matrix4
	{
		return _mpInv;
	}
	
	/**
	* Return the transformation matrix. 
	* 
	* @return Matrix4
	*/
	public function getTransformMatrix(Void):Matrix4
	{
		if (isModified()) {
			__updateTransformMatrix();
			//setCompiled();  // FIXME - This causes the first redraw to be incorrect.
			//compile(); // FIXME - This causes the first redraw to be incorrect.
		}
		return _mt;
	}

	public function getTransformationMatrixInverse( Void ):Matrix4
	{
		return  Matrix4Math.getInverse( _mt );
	}
	
	public function toString(Void):String
	{
		return "sandy.view.Camera3D";
	}
		
	/**
	* Set an orthographic projection. This projection in opposite of the perspective one, don't distort distances and pictures
	* @param	screenWidth The screen width. Default value: the screen width
	* @param	screenHeight The screen height. Default value: the screen height.
	* @param	zNear The distance betweeen the camera position and the near plane. Default value: 10.
	* @param	zFar The distance betweeen the camera position and the far plane. Default value: 10,000.
	*/
	/*
 	public function setOrthoProjection(screenWidth:Number, screenHeight:Number, zNear:Number, zFar:Number):Void
	{
		var h:Number, w:Number, Q:Number;
		// --
		if( undefined == screenWidth ) screenWidth = _is.getSize().width;
		if( undefined == screenHeight ) screenHeight = _is.getSize().height;
		if( undefined == zNear ) zNear = 10;
		if( undefined == zFar ) zFar = 10000;
		// --
		w = 2*zNear/screenWidth;
	    h = 2*zNear/screenHeight;
	    Q = zFar/(zFar - zNear);

		delete _mp;
		_mp = Matrix4.createZero();
		_mp.n11 = w;
		_mp.n22 = h;
		_mp.n33 = Q;
		_mp.n34 = -Q*zNear;
		_mp.n43 = 1;
	}
	*/
	
	/**
	* Set a projection matrix with perspective. This projection allows a more human visual representation of objects.
	* @param	fovY The angle of view in degress. Default value is 45 when Camera is created. If undefined, it defaults to last setting.
	* @param	aspectRatio The ratio between vertical and horizontal pixels. Default value: the screeen ratio (width/height)
	* @param	zNear The distance between the camera position and the near plane. Default value is 50 when Camera is created. If undefined, it defaults to last setting.
	* @param	zFar The distance between the camera position and the far plane. Default value: 3,000 when Camera is created. If undefined, it defaults to last setting.
	*/
	public function setPerspectiveProjection(fovY:Number, aspectRatio:Number, zNear:Number, zFar:Number):Void
	{
		//trace ("reached setPerspectiveProjection");
		var cotan:Number, Q:Number;
		// --
		if( undefined == fovY ) fovY = _nFovY;
		if( undefined == aspectRatio ) aspectRatio = viewport.ratio;
		if( undefined == zNear ) zNear = _nNear;
		if( undefined == zFar ) zFar = _nFar;
		// --
		frustrum.computePlanes(aspectRatio, zNear, zFar, fovY );
		
		_nFovY = fovY;
		_nNear = zNear;
		_nFar  = zFar;
		
		fovY = NumberUtil.toRadian( fovY );
		cotan = 1 / Math.tan(fovY / 2);
		Q = zFar/(zFar - zNear);
		
		delete _mp;
		_mp = Matrix4.createZero();
		_mp.n11 = cotan / aspectRatio;
		_mp.n22 = cotan;
		_mp.n33 = Q;
		_mp.n34 = -Q*zNear;
		_mp.n43 = 1;
		
		_compiled = false;
		
	}
	

	
	private function __updateTransformMatrix ( Void ):Void
	{
		_mt.n11 = _vSide.x; 
		_mt.n12 = _vSide.y; 
		_mt.n13 = _vSide.z; 
		_mt.n14 = - VectorMath.dot( _vSide, _p );
		
		_mt.n21 = _vUp.x; 
		_mt.n22 = _vUp.y; 
		_mt.n23 = _vUp.z; 
		_mt.n24 = - VectorMath.dot( _vUp, _p );
		
		_mt.n31 = _vOut.x; 
		_mt.n32 = _vOut.y; 
		_mt.n33 = _vOut.z; 
		_mt.n34 = - VectorMath.dot( _vOut, _p );
		
		_mt.n41 = 0; _mt.n42 = 0; _mt.n43 = 0; _mt.n44 = 1;
	}
	
	/**
	* On an interpolation event, we compute the correct position, and update the camera.
	* @param	e
	*/
	private function __onInterpolation( e:InterpolationEvent ):Void
	{
		var m:Matrix4 = Interpolator3D(e.getTarget()).getMatrix();
		_p.x = m.n14;
		_p.y = m.n24;
		_p.z = m.n34;
		_compiled = false;
	}
		
	/**
	 * Position of camera ( a Vector )
	 */
	private var _p : Vector;

	private var _mt : Matrix4; // transformation matrix
	private var _mp : Matrix4; // projection Matrix4
	private var _mpInv : Matrix4; // Inverse of the projection matrix 
	
	/*
	 * ViewPort matrix
	 */
	private var _mv : Matrix4;


	private var _mf:Matrix4; // final Matrix4 which is the result of the transformation and projection matrix's multiplication.
	/**
	 * boolean allowing kind of cache matrix computation
	 */
	private var _compiled : Boolean;
	
	/**
	 * Camera Side Orientation Vector
	 */
    private var _vSide : Vector;
    
    /**
	 * Camera view Orientation Vector
	 */
    private var _vOut : Vector;
    
    /**
	 * Camera up Orientation Vector
	 */
	 private var _vUp : Vector;
	
	/**
	 * Nodal Distance of camera ( and not Focal ;) )
	 */
	private var _nFocal : Number; // Not used?
	
	/**
	 * current tilt value
	 */
	private var _nTilt : Number;
	
	/**
	 * current yaw value
	 */
	private var _nYaw : Number;
	
	/**
	 * current roll value
	 */
	private var _nRoll : Number;  
	
	// Private absolute down vector
	private var _vLookatDown:Vector;
	/**
	 * screen size useful to create an offset
	 */
	private var _rDim : Rectangle;	
	/**
	* The interpolator
	*/
	private var _oInt:Interpolator3D;
	
	// The field-of-view
	private var _nFovY;
	// Near and far planes
	private var _nFar:Number;
	private var _nNear:Number;
}
