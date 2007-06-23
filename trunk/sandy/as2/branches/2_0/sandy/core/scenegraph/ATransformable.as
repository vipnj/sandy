
import com.bourre.log.Logger;

import sandy.core.data.Matrix4;
import sandy.core.data.Vector;
import sandy.core.scenegraph.Node;
import sandy.core.transform.Transform3D;
import sandy.core.transform.TransformType;
import sandy.math.Matrix4Math;
import sandy.math.VectorMath;

/**
 * @author thomaspfeiffer
 */
class sandy.core.scenegraph.ATransformable extends Node
{
	public var transform:Transform3D;

	public function ATransformable ( p_sName:String )
	{
		super( p_sName );
		_p 		= new Vector();
		_oScale = new Vector( 1, 1, 1 );
		_vRotation = new Vector(0,0,0);
		// --
		initFrame();
		// --
		_vLookatDown = new Vector(0.00000000001, -1, 0);// value to avoid some colinearity problems.;
		// --
		_nRoll 	= 0;
		_nTilt 	= 0;
		_nYaw  	= 0;
		// --
		m_tmpMt = Matrix4.createIdentity();
		transform = new Transform3D();
	}
    
    public function initFrame( Void ):Void
    {
    	_vSide 	= new Vector( 1, 0, 0 );
		_vUp 	= new Vector( 0, 1 ,0 );
		_vOut 	= new Vector( 0, 0, 1 );
    }
    
    public function toString():String
    {
    	return "sandy.core.scenegraph.ATransformable";
    }
    
	/**
	 * X position of the node
	 */
	public function set x( px:Number )
	{
		_p.x = px;
		changed = true;
		transform.type = TransformType.TRANSLATION;
	}
	
	public function get x():Number
	{
		return _p.x;
	}
	
	/**
	 * Y position of the node
	 */
	public function set y( py:Number )
	{
		_p.y = py;
		changed = true;
		transform.type = TransformType.TRANSLATION;	
	}
	
	public function get y():Number
	{
		return _p.y;
	}
	
	/**
	 * Z position of the node
	 */
	public function set z( pz:Number )
	{
		_p.z = pz;
		changed = true;
		transform.type = TransformType.TRANSLATION;
	}
	
	public function get z():Number
	{
		return _p.z;
	}				

	public function get out():Vector
	{
		return _vOut;
	}
	public function get side():Vector
	{
		return _vSide;
	}
	
	public function get up():Vector
	{
		return _vUp;
	}
	
	/**
	 * sx correspond in the scale value in the local obejct frame axis
	 * @param p_scaleX Number the number you ant to scale your object. A value of 1 scale to the original value, 2 makes
	 * the object seems twice bigger on the X axis.
	 * NOTE : This value does not affect the camera object.
	 */
	public function set scaleX( p_scaleX:Number )
	{
		_oScale.x = p_scaleX;
		changed = true;
		transform.type = TransformType.SCALE;	
	}
				
	public function get scaleX():Number
	{
		return _oScale.x;
	}

	/**
	 * sy correspond in the scale value in the local obejct frame axis
	 * @param p_scaleY Number the number you ant to scale your object. A value of 1 scale to the original value, 2 makes
	 * the object seems twice bigger on the Y axis.
	 * NOTE : This value does not affect the camera object.
	 */
	public function set scaleY( p_scaleY:Number )
	{
		_oScale.y = p_scaleY;
		changed = true;
		transform.type = TransformType.SCALE;	
	}
				
	public function get scaleY():Number
	{
		return _oScale.y;
	}
	
	/**
	 * sz correspond in the scale value in the local obejct frame axis
	 * @param p_scaleZ Number the number you ant to scale your object. A value of 1 scale to the original value, 2 makes
	 * the object seems twice bigger on the Z axis.
	 * NOTE : This value does not affect the camera object.
	 */
	public function set scaleZ( p_scaleZ:Number )
	{
		_oScale.z = p_scaleZ;
		changed = true;
		transform.type = TransformType.SCALE;	
	}
				
	public function get scaleZ():Number
	{
		return _oScale.z;
	}	
    
	/**
	 * Allow the camera to translate along its side vector. 
	 * If you imagine yourself in a game, it would be a step on your right or on your left
	 * @param	d	Number	Move the camera along its side vector
	 */
	public function moveSideways( d : Number ) : Void
	{
		changed = true;
		_p.x += _vSide.x * d;
		_p.y += _vSide.y * d;
		_p.z += _vSide.z * d;
		transform.type = TransformType.TRANSLATION;	
	}
	
	/**
	 * Allow the camera to translate along its up vector. 
	 * If you imagine yourself in a game, it would be a jump on the direction of your body (so not always the vertical!)
	 * @param	d	Number	Move the camera along its up vector
	 */
	public function moveUpwards( d : Number ) : Void
	{
		changed = true;
		_p.x += _vUp.x * d;
		_p.y += _vUp.y * d;
		_p.z += _vUp.z * d;
		transform.type = TransformType.TRANSLATION;	
	}
	
	/**
	 * Allow the camera to translate along its view vector. 
	 * If you imagine yourself in a game, it would be a step in the direction you look at. If you look the sky
	 * you will translate upwards ! So be careful with its use.
	 * @param	d	Number	Move the camera along its viw vector
	 */
	public function moveForward( d : Number ) : Void
	{
		changed = true;
		_p.x += _vOut.x * d;
		_p.y += _vOut.y * d;
		_p.z += _vOut.z * d;
		transform.type = TransformType.TRANSLATION;	
	}
 
	/**
	 * Allow the camera to translate horizontally
	 * If you imagine yourself in a game, it would be a step in the direction you look at but without changing 
	 * your altitude.
	 * @param	d	Number	Move the camera horizontally
	 */	
	public function moveHorizontally( d:Number ) : Void
	{
		changed = true;
		_p.x += _vOut.x * d;
		_p.z += _vOut.z * d;	
		transform.type = TransformType.TRANSLATION;	
	}
	
	/**
	 * Allow the camera to translate vertically
	 * If you imagine yourself in a game, it would be a jump strictly vertical.
	 * @param	d	Number	Move the camera vertically
	 */	
	public function moveVertically( d:Number ) : Void
	{
		changed = true;
		_p.y += d;	
		transform.type = TransformType.TRANSLATION;		
	}
	
	 /**
	 * Allow the camera to translate lateraly
	 * If you imagine yourself in a game, it would be a step on the right with a positiv parameter and to the left
	 * with a negative parameter
	 * @param	d	Number	Move the camera lateraly
	 */	
	public function moveLateraly( d:Number ) : Void
	{
		changed = true;
		_p.x += d;
		transform.type = TransformType.TRANSLATION;		
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
		changed = true;
		_p.x += px;
		_p.y += py;
		_p.z += pz;	
		transform.type = TransformType.TRANSLATION;
	}
	
	
	/**
	 * Rotate the camera around a specific axis by an angle passed in parameter
	 * NOTE : The axis will be normalized automatically.
	 * @param	ax	Number	The x coordinate of the axis
	 * @param	ay	Number	The y coordinate of the axis
	 * @param	az	Number	The z coordinate of the axis
	 * @param	nAngle	Number	The amount of rotation. This angle is in degrees.
	 */
	public function rotateAxis( ax : Number, ay : Number, az : Number, nAngle : Number ):Void
	{
		changed = true;
		nAngle = (nAngle + 360)%360;
		var n:Number = Math.sqrt( ax*ax + ay*ay + az*az );
		var m : Matrix4 = Matrix4Math.axisRotation( ax/n, ay/n, az/n, nAngle );
		_vUp   = Matrix4Math.vectorMult3x3( m, _vUp  );
		_vSide = Matrix4Math.vectorMult3x3( m, _vSide);
		_vOut  = Matrix4Math.vectorMult3x3( m, _vOut );
		transform.type = TransformType.ROTATION;
	}
 

	public function set target( p_oTarget:Vector )
	{
		lookAt( p_oTarget.x, p_oTarget.y, p_oTarget.z) ;
	}
	
	/**
	 * Make the camera look at a specific position. Useful to follow a moving object or a static object while the camera is moving.
	 * @param	px	Number	The x position to look at
	 * @param	py	Number	The y position to look at
	 * @param	pz	Number	The z position to look at
	 */
	public function lookAt( px:Number, py:Number, pz:Number ):Void
	{
		changed = true;
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
	public function set rotateX ( nAngle:Number )
	{
		nAngle = (nAngle + 360)%360;
		var l_nAngle:Number = nAngle - _vRotation.x;
		// --
		var m:Matrix4 = Matrix4Math.rotationX( l_nAngle );
		_vUp   = Matrix4Math.vectorMult3x3( m, _vUp  );
		_vSide = Matrix4Math.vectorMult3x3( m, _vSide);
		_vOut  = Matrix4Math.vectorMult3x3( m, _vOut );
		// --
		changed = true;
		_vRotation.x = nAngle;
		transform.type = TransformType.ROTATION;
	}
	
	public function get rotateX():Number
	{
		return _vRotation.x;
	}
	
	/**
	 * rotateY - Rotation around the global Y axis of the camera frame
	 * @param nAngle Number The angle of rotation in degree.
	 * @return Void
	 */
	public function set rotateY ( nAngle:Number )
	{
		nAngle = (nAngle + 360)%360;
		var l_nAngle:Number = nAngle - _vRotation.y;
		// --
		var m:Matrix4 = Matrix4Math.rotationY ( l_nAngle );
		_vUp   = Matrix4Math.vectorMult3x3( m, _vUp  );
		_vSide = Matrix4Math.vectorMult3x3( m, _vSide);
		_vOut  = Matrix4Math.vectorMult3x3( m, _vOut );
		// --
		_vRotation.y = nAngle;
		changed = true;
		transform.type = TransformType.ROTATION;
	}
	
	public function get rotateY():Number
	{
		return _vRotation.y;
	}
	
	/**
	 * rotateZ - Rotation around the global Z axis of the camera frame
	 * @param nAngle Number The angle of rotation in degree between : [ -180; 180 ].
	 * @return
	 */
	public function set rotateZ ( nAngle:Number )
	{
		changed = true;
		nAngle = (nAngle + 360)%360;
		var l_nAngle:Number = nAngle - _vRotation.z;
		// --
		var m:Matrix4 = Matrix4Math.rotationZ ( l_nAngle );
		_vUp   = Matrix4Math.vectorMult3x3( m, _vUp  );
		_vSide = Matrix4Math.vectorMult3x3( m, _vSide);
		_vOut  = Matrix4Math.vectorMult3x3( m, _vOut );
		// --
		_vRotation.z = nAngle;
		transform.type = TransformType.ROTATION;
	}	
	
	public function get rotateZ():Number
	{
		return _vRotation.z;
	}
	
	/**
	 * Tilt - Rotation around the local X axis of the camera frame
	 * Range from -90 to +90 where 0 = Horizon, +90 = straight up and –90 = straight down.
	 * @param nAngle Number The angle of rotation in degree.
	 * @return Void
	 */
	public function set tilt ( nAngle:Number )
	{
		changed = true;
		var l_nAngle:Number = (nAngle + 360)%360 - _nTilt;
		// --
		var m:Matrix4 = Matrix4Math.axisRotation ( _vSide.x, _vSide.y, _vSide.z, l_nAngle );
		_vUp   = Matrix4Math.vectorMult3x3( m, _vUp  );
		_vOut  = Matrix4Math.vectorMult3x3( m, _vOut );
		// --
		_nTilt = l_nAngle;
		transform.type = TransformType.ROTATION;
	}
	
	/**
	 * Pan - Rotation around the local Y axis of the camera frame
	 * Range from 0 to 360 where 0=North, 90=East, 180=South and 270=West.
	 * @param nAngle Number The angle of rotation in degree.
	 * @return Void
	 */
	public function set pan ( nAngle:Number )
	{
		changed = true;
		var l_nAngle:Number = (nAngle + 360)%360 - _nYaw;
		// --
		var m:Matrix4 = Matrix4Math.axisRotation ( _vUp.x, _vUp.y, _vUp.z, l_nAngle );
		_vSide = Matrix4Math.vectorMult3x3( m, _vSide);
		_vOut  = Matrix4Math.vectorMult3x3( m, _vOut );
		// --
		_nYaw = l_nAngle;
		transform.type = TransformType.ROTATION;
	}

	/**
	 * Realize a rotation around a specific axis (the axis must be normalized!) and from an pangle degrees and around a specific position.
	 * @param pAxis A 3D Vector representing the axis of rtation. Must be normalized !!
	 * @param ref Vector The center of rotation as a 3D point.
	 * @param pAngle Number The angle of rotation in degrees.
	 */
	public function rotAxisWithReference( axis:Vector, ref:Vector, pAngle:Number ):Void
	{
		var angle:Number = ( pAngle + 360 ) % 360;
		// --
		var m:Matrix4 = Matrix4Math.translation ( ref.x, ref.y, ref.z );
		m = Matrix4Math.multiply4x3 ( m, Matrix4Math.axisRotation( axis.x, axis.y, axis.z, angle ));
		m = Matrix4Math.multiply4x3 ( m, Matrix4Math.translation ( -ref.x, -ref.y, -ref.z ));
		// --
		_vUp   = Matrix4Math.vectorMult3x3( m, _vUp  );
		_vSide = Matrix4Math.vectorMult3x3( m, _vSide);
		_vOut  = Matrix4Math.vectorMult3x3( m, _vOut );
		// --
		transform.type = TransformType.ROTATION;
		changed = true;
	}
		
	/**
	 * roll - Rotation around the local Z axis of the camera frame
	 * Range from -180 to +180 where 0 means the plane is aligned with the horizon, 
	 * +180 = Full roll right and –180 = Full roll left. In both cases, when the roll is 180 and –180, 
	 * the plane is flipped on its back.
	 * @param nAngle Number The angle of rotation in degree.
	 * @return
	 */
	public function set roll ( nAngle:Number )
	{
		changed = true;
		var l_nAngle:Number = (nAngle + 360)%360 - _nRoll;
		// --
		var m:Matrix4 = Matrix4Math.axisRotation ( _vOut.x, _vOut.y, _vOut.z, l_nAngle );
		_vUp   = Matrix4Math.vectorMult3x3( m, _vUp  );
		_vSide = Matrix4Math.vectorMult3x3( m, _vSide);
		// --
		_nRoll = l_nAngle;
		transform.type = TransformType.ROTATION;
	}	

	public function get roll():Number{return _nRoll;}
	
	public function get tilt():Number{return _nTilt;}
	
	public function get pan():Number{return _nYaw;}
	
	/**
	* Set the position of the camera. Basically apply a translation.
	* @param x x position of the camera
	* @param y y position of the camera
	* @param z z position of the camera
	*/
	public function setPosition( x:Number, y:Number, z:Number ):Void
	{
		changed = true;
		// we must consider the screen y-axis inversion
		_p.x = x;
		_p.y = y;
		_p.z = z;	
		transform.type = TransformType.TRANSLATION;
	}
	

	/**
	 * This method goal is to update the node. For node's with transformation, this method shall
	 * update the transformation taking into account the matrix cache system.
	 * FIXME: Transformable nodes shall upate their transform if necessary before calling this method.
	 */
	public function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):Void
	{
		updateTransform();
		// --
		if( p_bChanged || changed )
		{
			 if( p_oModelMatrix )
			 	_oModelCacheMatrix = (transform.matrix) ? Matrix4Math.multiply4x3( p_oModelMatrix, transform.matrix ) : p_oModelMatrix;
			 else
			 	_oModelCacheMatrix = transform.matrix;
		}
		//
		super.update( _oModelCacheMatrix, p_bChanged );
	}

	
 	/**
	 * This method shall be called to update the transform matrix of the current object/node
	 * before being rendered.
	 */
	public function updateTransform( Void ):Void
	{
		if( changed )
		{
			var mt:Matrix4 = m_tmpMt;
			mt.n11 = _vSide.x * _oScale.x; 
			mt.n12 = _vUp.x; 
			mt.n13 = _vOut.x; 
			mt.n14 = _p.x;
			
			mt.n21 = _vSide.y; 
			mt.n22 = _vUp.y * _oScale.y; 
			mt.n23 = _vOut.y; 
			mt.n24 = _p.y;
			
			mt.n31 = _vSide.z; 
			mt.n32 = _vUp.z; 
			mt.n33 = _vOut.z * _oScale.z;  
			mt.n34 = _p.z;
			
			transform.matrix = mt;
		}
	}
	
	/**
	* Get the position of the element.
	* If the parameter equals "local" the function returns a vector container the position relative to the parent frame.
	* If the parameter equals "absolute" the function returns the absolute position in the world frame.
	* If the parameter equals "camera" the function returns the absolute position in the camera frame.
	* Default value is "local"
	* @return the position of the element as a Vector
	*/
	public function getPosition( p_sMode:String ):Vector
	{
		var l_oPos:Vector;
		switch( p_sMode )
		{
			case "local" 	: l_oPos = new Vector( _p.x, _p.y, _p.z ); break;
			case "absolute" : l_oPos = new Vector( _oViewCacheMatrix.n14, _oViewCacheMatrix.n24, _oViewCacheMatrix.n34 ); break;
			case "camera" 	: l_oPos = new Vector( _oModelCacheMatrix.n14, _oModelCacheMatrix.n24, _oModelCacheMatrix.n34 ); break;
			default 		: l_oPos = new Vector( _p.x, _p.y, _p.z ); break;
		}
		return l_oPos;
	}

	// Side Orientation Vector
	private var _vSide:Vector;
	// view Orientation Vector
	private var _vOut:Vector;
	// up Orientation Vector
	private var _vUp:Vector;
	// current tilt value
	private var _nTilt:Number;
	// current yaw value
	private var _nYaw:Number;
	// current roll value
	private var _nRoll:Number;
	private var _vRotation:Vector;	
	private var _vLookatDown:Vector; // Private absolute down vector
	private var _p:Vector;	
	private var _oScale:Vector;
	private var m_tmpMt:Matrix4; // temporary transform matrix used at updateTransform
}