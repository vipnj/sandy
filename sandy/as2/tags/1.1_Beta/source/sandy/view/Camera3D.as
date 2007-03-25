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
import sandy.math.Matrix4Math;
import sandy.math.VectorMath;
import sandy.util.NumberUtil;
import sandy.util.Rectangle;
import sandy.view.Frustum;
import sandy.view.IScreen;
import sandy.core.transform.Interpolator3D; 
import sandy.core.transform.TransformType;
import sandy.events.InterpolationEvent;

/**
* Camera3D
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		12.07.2006
**/
class sandy.view.Camera3D 
{
	/**
	 * final Matrix4 which is the result of the transformation and projection matrix's multiplication.
	 */
	public var m:Matrix4;
	
	/**
	 * associated screen
	 */
	public var is:IScreen;
 	
 	/**
 	 * The frustum of the camera. See {@see Frustum} class.
 	 */
 	public var frustrum:Frustum;
 	
	/**
	 * Create a new Camera3D.
	 * 
	 * @param nFoc The focal of the Camera3D
	 * @param s the screen associated to the camera
	 */
	public function Camera3D( nFoc:Number, s:IScreen )
	{
		_p 		= new Vector();
		is      = s;
		_nFocal = nFoc;
		// --
		_vOut 	= new Vector( 0, 0, 1 );
		_vSide 	= new Vector( 1, 0, 0 );
		_vUp 	= new Vector( 0, 1 ,0 );
		// --
		_nRoll 	= 0;
		_nTilt 	= 0;
		_nYaw  	= 0;
		// --
		is.setCamera ( this );
		_rDim 	= is.getSize();
		_mt = _mp = m = _mv = Matrix4.createIdentity();
		_compiled = false;
		__loadSimpleProjection();
		_oInt = null;
		//__loadPerspective( 1, 1, 50, 5000000 );
		//math_matrix4d_perspective(90, 1, 50, 5000000 );
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
		_p.y -= d;		
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
		_p.y -= py;
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
	public function rotateAxis( ax : Number, ay : Number, az : Number, nAngle : Number )
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
	public function lookAt( px : Number, py : Number, pz : Number ) : Void
	{
		_compiled = false;
		_vOut = VectorMath.sub( new Vector(px, -py, pz), _p );
		VectorMath.normalize( _vOut );
		_vSide = VectorMath.cross( _vOut, new Vector(0, -1, 0) );
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
		//_nYaw = NumberUtil.constrain( (_nYaw + nAngle)%360, 0, 360 );
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
		//_nRoll = NumberUtil.constrain( _nRoll + nAngle, -180, 180 );
		//if( _nRoll == -180 || _nRoll == 180 ) return;
		_compiled = false;
		nAngle = (nAngle + 360)%360;
		var m:Matrix4 = Matrix4Math.axisRotation ( _vOut.x, _vOut.y, _vOut.z, nAngle );
		Matrix4Math.vectorMult3x3( m, _vSide);
		Matrix4Math.vectorMult3x3( m, _vUp);
	}	

	
	/**
	* Set the position of the camera. Basically apply a translation.
	* @param x x position of the camera
	* @param y y position of the camera
	* @param z z position of the camera
	*/
	public function setPosition( x : Number, y : Number, z : Number ) : Void
	{
		_compiled = false;
		// we must consider the screen y-axis inversion
		_p.x = x;
		_p.y = -y;
		_p.z = z;	
	}
	
	/**
	* Get the offset of the screen of the camera along  axis.
	* @return a Number corresponding to the offset
	*/
	public function getXOffset( Void ) : Number
	{
		return _rDim.width / 2;
	}
	
	/**
	* Get the offset of the screen of the camera along Y axis.
	* @return a Number corresponding to the offset
	*/
	public function getYOffset( Void ) : Number
	{
		return _rDim.height / 2;
	}
	
	/**
	* Get the position of the camera.
	* @return the position of the camera as a Vector
	*/
	public function getPosition( Void ) : Vector
	{
		return new Vector(_p.x, - _p.y, _p.z );
	}
	
	/**
	* Set the screen of the camera. 
	* @param {code s} the Screen instance
	*/
	public function setScreen( s : IScreen ) : Void
	{
		is = s;
		_rDim = is.getSize();
		is.setCamera ( this );
	}
	
	/**
	* Set the nodal distance of the camera.
	* @param n the nodal distance
	*/
	public function setFocal( n : Number ) : Void
	{
		_compiled = false;
		_nFocal = n;
		__loadSimpleProjection();
	}
	
	/**
	* Return the nodal distance of the camera.
	* @return a Number as the nodal distance
	*/
	public function getFocal( Void ) : Number
	{
		return _nFocal;
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
		return (_compiled == false);
	}
	
	/**
	* Compile the camera transformations by multiplicating the matrix together.
	* Be carefull to call isModified method before to save computations. 
	*/
	public function compile( Void ):Void
	{
		if(! _compiled )
		{
			// we set up the rotation matrix from euler's angle
			_mt = __updateRotationMatrix();
			// we add the translation effect
			_mt = Matrix4Math.multiply ( _mt, Matrix4Math.translation(  -_p.x, - _p.y, -_p.z ) );
			m 	= Matrix4Math.multiply ( _mp, _mt );
			//m = Matrix4Math.getInverse( m );
			_compiled = true;
		}
	}
	
	/**
	* Return the projection matrix. 
	* 
	* @return Matrix4
	*/
	public function getProjectionMatrix(Void):Object
	{
		return _mp;
	}
	
	/**
	* Return the transformation matrix. 
	* 
	* @return Matrix4
	*/
	public function getTransformMatrix(Void):Object
	{
		return _mt;
	}
	
	//
	// PRIVATE
	//
	private function __loadPerspective( fovy:Number, aspect:Number, zNear:Number, zFar:Number ) : Void
	{
		var fovy2:Number = NumberUtil.toRadian( fovy / 2 );
		var f:Number = 1 / Math.tan( fovy2 );
		//
		_mp.n11 = f / aspect;
		_mp.n12 = 0;
		_mp.n13 = 0;
		_mp.n14 = 0;
		//					
		_mp.n21 = 0;
		_mp.n22 = f;
		_mp.n23 = 0;
		_mp.n24 = 0;
		//					
		_mp.n31 = 0;
		_mp.n32 = 0;
		_mp.n33 = ( zFar + zNear ) / ( zNear - zFar );
		_mp.n34 = ( 2 * zFar * zNear ) / ( zNear - zFar );
		//							
		_mp.n41 = 0;
		_mp.n42 = 0;
		_mp.n43 = - 1;
		_mp.n44 = 0;
		// we create the frustum
		//frustrum = new Frustum();
		//frustrum.extractPlanes( _mp , true );
	}	
		
	private function __loadPerspective2( left:Number, right:Number, top:Number, bottom:Number, zNear:Number, zFar:Number ) : Void
	{
		//
		_mp.n11 = 2 * zNear / ( right - left );
		_mp.n12 = 0;
		_mp.n13 = ( right + left ) / ( right - left );
		_mp.n14 = 0;
		//					
		_mp.n21 = 0;
		_mp.n22 =  2 * zNear / ( top - bottom );
		_mp.n23 = ( top + bottom ) / ( top - bottom );
		_mp.n24 = 0;
		//					
		_mp.n31 = 0;
		_mp.n32 = 0;
		_mp.n33 = ( zFar + zNear ) / ( zNear - zFar );
		_mp.n34 = ( 2 * zFar * zNear ) / ( zNear - zFar );
		//							
		_mp.n41 = 0;
		_mp.n42 = 0;
		_mp.n43 = - 1;
		_mp.n44 = 0;
		// we create the frustum
		//frustrum = new Frustum();
		//frustrum.extractPlanes( _mp , true );
	}	
	
/******************************************************************************
 * void    math_matrix4d_frustum
 */
/*! Description : Compute frustum and store it in matrix passed through arguments
 *
 * \param par_pr_matrix : Matrix to fill with frustum description
 * \param par_d_left    : Left coordinate of the near plane
 * \param par_d_right   : Right coordinate of the near plane
 * \param par_d_bottom  : Bootom coordinate of the near plane
 * \param par_d_top     : Top coordinate of the near plane
 * \param par_d_z_near  : Z coordinate of the near plane
 * \param par_d_z_far   : Z coordinate of the far plane
 *
 * \return void 
 *
 * <B>Global input:</B>
 *
 * <B>Global output:</B>
 */
/*****************************************************************************/
	private function math_matrix4d_frustum( par_d_left:Number,
											par_d_right:Number,
											par_d_bottom:Number,
											par_d_top:Number,
											par_d_z_near:Number,
											par_d_z_far:Number )
	{
		var loc_d_width:Number,  loc_d_height:Number, loc_d_depth:Number;
		//
		delete _mp;
		_mp = Matrix4.createZero();
		//
		loc_d_width  = par_d_right  -   par_d_left;
		loc_d_height = par_d_top    -   par_d_bottom;
		loc_d_depth  = par_d_z_near -   par_d_z_far;

		//[0]
		_mp.n11 = (2 * par_d_z_near)/loc_d_width;
		//[5]
		_mp.n22 = (2 * par_d_z_near)/loc_d_height;
		//[8]
		_mp.n31 = (par_d_right + par_d_left)   / loc_d_width;
		//_mp.n13 = (par_d_right + par_d_left)   / loc_d_width;
		//[9]
		_mp.n32 = (par_d_top   + par_d_bottom) / loc_d_width;
		//_mp.n23 = (par_d_top   + par_d_bottom) / loc_d_width;
		//[10]
		_mp.n33 = (par_d_z_far + par_d_z_near     ) / loc_d_depth;
		//[14]
		_mp.n43 = (par_d_z_far * par_d_z_near * 2.) / loc_d_depth;
		//_mp.n34 = (par_d_z_far * par_d_z_near * 2.) / loc_d_depth;
		//[11]
		_mp.n34 = -1.0;
		//_mp.n43 = -1.0;
		//[15]
		_mp.n44 = 0.0;

	}

 

/******************************************************************************
 * void    math_matrix4d_perspective
 */
/*! Description : Sets up a perspective projection matrix
 *
 * \param par_pr_matrix         : Matrix to fill
 * \param par_d_field_of_view   : Field of view vertical glu_perspective
 * \param par_d_aspect_ratio    : View aspect ratio ( = x / y)
 * \param par_d_z_near          : Distance from the viewer to the near clipping plane
 * \param par_d_z_far           : Distance from the viewer to the far clipping plane
 *
 * \return void 
 *
 * <B>Global input:</B>
 *
 * <B>Global output:</B>
 */
/*****************************************************************************/
	public function math_matrix4d_perspective(	par_d_field_of_view:Number,
												par_d_aspect_ratio:Number,
												par_d_z_near:Number,
												par_d_z_far:Number     )
	{
		var loc_d_x:Number, loc_d_y:Number;
		par_d_field_of_view = NumberUtil.toRadian( par_d_field_of_view );
		par_d_field_of_view = par_d_field_of_view * 0.5;
		loc_d_y = par_d_z_near * Math.sin(par_d_field_of_view) / Math.cos(par_d_field_of_view);
		loc_d_x = par_d_aspect_ratio * loc_d_y;

		math_matrix4d_frustum ( -loc_d_x, loc_d_x,
								-loc_d_y, loc_d_y,
								par_d_z_near, par_d_z_far);
								
		//_mp = Matrix4Math.getInverse( _mp );

	}

	/**
	* __loadProjection (private)
	* 
	* <p>Compute the projection matrix</p> 
	* 
	*/
	private function __loadSimpleProjection( Void ) : Void
	{
		_mp.n12 = _mp.n13 = _mp.n14 = _mp.n21 = _mp.n23 = _mp.n24 = _mp.n31 = _mp.n32 = _mp.n34 = _mp.n41 = _mp.n42 = _mp.n44 = 0;
		_mp.n11 = _mp.n22 = _mp.n33 = _nFocal;
		_mp.n43 = 1;
	}
	
	private function __updateRotationMatrix ( Void ):Matrix4
	{
		return new Matrix4( _vSide.x, 	_vSide.y, 	_vSide.z, 	0,
							_vUp.x, 	_vUp.y,		_vUp.z, 	0,		
							_vOut.x, 	_vOut.y, 	_vOut.z, 	0,
							0, 			0, 			0, 			1 );
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
	
	/**
	 * Matrix4 of tranformations (will be inversed at the end to have the correct view transformation. 
	 * That's why is separated from the projection matrix which must not be inversed)
	 */ 
	private var _mt : Matrix4;
	
	/**
	 * projection Matrix4
	 */
	private var _mp : Matrix4;
	
	/*
	 * ViewPort matrix
	 */
	private var _mv : Matrix4;
	
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
	private var _nFocal : Number;
	
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
	
	/**
	 * screen size useful to create an offset
	 */
	private var _rDim : Rectangle;	
	
	/**
	* The interpolator
	*/
	private var _oInt:Interpolator3D;
}