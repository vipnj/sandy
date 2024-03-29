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
import sandy.core.data.Quaternion;
import sandy.core.data.Vector;
import sandy.math.Matrix4Math;
import sandy.math.VectorMath;
import sandy.util.NumberUtil;

/**
 * QuaternionMath
 * Tools useful to manipulate the quaternion object.
 * @author Thomas PFEIFFER - Kiroukou
 * @version UNTESTED - DO NOT USE THIS CLASS UNLESS YOU KNOW EXACTLY WHAT YOU ARE DOING
 */
class sandy.math.QuaternionMath 
{

	public static function getVector( q:Quaternion):Vector
	{
		return new Vector( q.x,q.y,q.z );
	}

	public static function setVector( q:Quaternion, v:Vector ):Void
	{
		q.x = v.x;
		q.y = v.y;
		q.z = v.z;
	}

	public static function setScalar( q:Quaternion, n:Number ):Void
	{
		q.w = n;
	}

	public static function equal( q:Quaternion, q2:Quaternion ):Boolean
	{
		return ( q.x == q2.x && q.y == q2.y && q.z == q2.z && q.w == q2.w );
	}


	public static function clone( q:Quaternion ):Quaternion
	{
		return new Quaternion( q.x, q.y, q.z, q.w );
	}

	public static function getConjugate( q:Quaternion ):Quaternion
	{
		return new Quaternion( -q.x, -q.y, -q.z, q.w );
	}

	public static function conjugate( q:Quaternion ):Void
	{
		q.x = -q.x;
		q.y = -q.y;
		q.z = -q.z;
	}

	public static function getMagnitude( q:Quaternion ):Number
	{
		//return Math.sqrt( this.multiply( this.getConjugate() ) );
		return Math.sqrt ( q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z );
	}

	public static function normalize( q:Quaternion ):Void
	{
		var m:Number = QuaternionMath.getMagnitude( q );
		q.x /= m;
		q.y /= m;
		q.z /= m;
		q.w /= m;
	}

	public static function multiply( q:Quaternion, q2:Quaternion ):Quaternion
	{
		var x1,x2:Number;
		var y1,y2:Number;
		var z1,z2:Number;
		var w1,w2:Number;
		x1 = q.x; y1 = q.y; z1 = q.z; w1 = q.w;
		x2 = q2.x; y2 = q2.y; z2 = q2.z; w2 = q2.w;

		return new Quaternion(	w1*x2 + x1*w2 + y1*z2 - z1*y2,
								w1*y2 + y1*w2 + z1*x2 - x1*z2,
								w1*z2 + z1*w2 + x1*y2 - y1*x2,
								w1*w2 - x1*x2 - y1*y2 - z1*z2);
		
	}

	public static function multiplyVector( q:Quaternion, v:Vector ):Quaternion
	{
		var x1,x2:Number;
		var y1,y2:Number;
		var z1,z2:Number;
		var w1,w2:Number;
		x1 = q.x; y1 = q.y; z1 = q.z; w1 = q.w;
		x2 = v.x; y2 = v.y; z2 = v.z; w2 = 0;
		
		return new Quaternion( 	w1*x2 + y1*z2 - z1*y2,
								w1*y2 + z1*x2 - x1*z2,
								w1*z2 + x1*y2 - y1*x2,
								x1*x2 - y1*y2 - z1*z2);
	}


	public static function toEuler( q:Quaternion ):Vector
	{
		var sqw:Number = q.w*q.w;
		var sqx:Number = q.x*q.x;
		var sqy:Number = q.y*q.y;
		var sqz:Number = q.z*q.z;
		var atan2:Function = Math.atan2;
		var rds:Number = 180/Math.PI;
		var euler:Vector = new Vector();
		// heading = rotaton about z-axis
		euler.z = atan2(2 * (q.x*q.y + q.z*q.w), (sqx - sqy - sqz + sqw) ) * rds ;
		// bank = rotation about x-axis
		euler.x = atan2(2 * (q.y*q.z + q.x*q.w),(-sqx - sqy + sqz + sqw) ) * rds ;
		// attitude = rotation about y-axis
		euler.y = Math.asin(-2 * (q.x*q.z - q.y*q.w)) * rds ;
		return euler ;
	}
	
	//Attention les angles doivent etre en degrés avec -180<x<180 , -90<y<90, -180<z<180 !!!
	public static function setEuler( x:Number, y:Number, z:Number ):Quaternion
	{
		var q:Quaternion = new Quaternion();
		var fsin:Function = Math.sin ;
		var fcos:Function = Math.cos ;
		//Conversion des angles en radians
		NumberUtil.toRadian( x );
		NumberUtil.toRadian( y );
		NumberUtil.toRadian( z );
		
		var angle:Number;
		angle = 0.5 * x ;
		var sr:Number = fsin(angle) ;
		var cr:Number = fcos(angle) ;
		angle = y * 0.5 ;
		var sp:Number = fsin(angle) ;
		var cp:Number = fcos(angle) ;
		angle = z * 0.5 ;
		var sy:Number = fsin(angle) ;
		var cy:Number = fcos(angle) ;

		var cpcy = cp * cy ;
		var spcy = sp * cy ;
		var cpsy = cp * sy ;
		var spsy = sp * sy ;

		q.x = sr * cpcy - cr * spsy ;
		q.y = cr * spcy + sr * cpsy ;
		q.z = cr * cpsy - sr * spcy ;
		q.w = cr * cpcy + sr * spsy ;
		QuaternionMath.normalize( q );
		return q;
	}

	public static function getRotationMatrix( q:Quaternion ):Matrix4
	{
		var xx,yy,zz,xy,xz,xw,yz,yw,zw:Number;

		xx = q.x*q.x;
		xy = q.x*q.y;
		xz = q.x*q.z;
		xw = q.x*q.w;
		yy = q.y*q.y;
		yz = q.y*q.z;
		yw = q.y*q.w;
		zz = q.z*q.z;
		zw = q.z*q.w;

		var m:Matrix4 = Matrix4.createIdentity();

		m.n11  = 1 - 2 * ( yy + zz )	 	;
		m.n12  = 	2 * ( xy + zw ) 		;
		m.n13  = 	2 * ( xz - yw ) 		;

		m.n21  = 	2 * ( xy - zw ) 		;
		m.n22  = 1 - 2 * ( xx + zz ) 		;
		m.n23  =   	2 * ( yz + xw ) 		;

		m.n31  = 	2 * ( xz + yw ) 		;
		m.n32  =   	2 * ( yz - xw ) 		;
		m.n33 = 1 - 2 * ( xx + yy )			;

		return m;
	}


	public static function setByMatrix( m:Matrix4 ):Quaternion
	{
		var q:Quaternion = new Quaternion();
		var t:Number = Matrix4Math.getTrace( m );
		var m0:Number = m.n11; var m5:Number = m.n22; var m10:Number = m.n33;
		if( t > 0.0000001 )
		{
			var s:Number = Math.sqrt( t ) * 2 ;
			q.x = ( m.n23 - m.n32 ) / s ;
			q.y = ( m.n31 - m.n13 ) / s ;
			q.z = ( m.n12 - m.n21 ) / s ;
			q.w = 0.25 * s ;
		}
		else if( m0 > m5 && m0 > m10 )
		{
			var s:Number = Math.sqrt( 1 + m0 - m5 - m10 ) * 2 ;
			q.x = 0.25 * s ;
			q.y = ( m.n12 + m.n21 ) / s ;
			q.z = ( m.n31 + m.n13 ) / s ;
			q.w = ( m.n23 - m.n32 ) / s ;
		}
		else if( m5 > m10 )
		{
			var s:Number = Math.sqrt( 1 + m5 - m0 - m10 ) * 2 ;
			q.y = 0.25 * s ;
			q.x = ( m.n12 + m.n21 ) / s ;
			q.w = ( m.n31 - m.n13 ) / s ;
			q.z = ( m.n23 + m.n32 ) / s ;
		}
		else
		{
			var s:Number = Math.sqrt( 1 + m10 - m5 - m0 ) * 2 ;
			q.z = 0.25 * s ;
			q.w = ( m.n12 - m.n21 ) / s ;
			q.x = ( m.n31 + m.n13 ) / s ;
			q.y = ( m.n23 + m.n32 ) / s ;
		}
		QuaternionMath.normalize( q );
		return q;
	}


	public static function setAxisAngle( axe:Vector, angle:Number):Quaternion
	{
		VectorMath.normalize( axe );
		var a2:Number = angle * 0.5;
		var sa:Number = Math.sin( a2 ) ;
		var q:Quaternion = new Quaternion();
		q.w = Math.cos( a2 ) ;
		q.x = axe.x * sa ;
		q.y = axe.y * sa ;
		q.z = axe.z * sa ;
		QuaternionMath.normalize( q );
		return q;
	}


	public static function getAxisAngle( q:Quaternion ):Quaternion
	{
		QuaternionMath.normalize( q );
		var ca:Number = q.w;
		var a:Number = Math.acos( ca ) * 2 ;
		var sa:Number = Math.sqrt( 1 - ca * ca ) ;
		if( Math.abs( sa ) < 0.00005 ) sa = 1;
		var axis:Vector = new Vector(q.x/sa, q.y/sa, q.z/sa, 0);
		
		var rq:Quaternion = new Quaternion();
		QuaternionMath.setVector( rq, axis );
		QuaternionMath.setScalar( rq, NumberUtil.toDegree( a ) );
		return rq;
	}

	public static function getDotProduct( q:Quaternion, q2:Quaternion):Number
	{
		return ( q.x * q2.x) + (q.y * q2.y) + (q.z * q2.z) + (q.w * q2.w);
	}


	public static function multiplyByVector( q:Quaternion, v:Vector ):Vector
	{
		return new Vector( q.x * v.x * -q.x, q.y * v.y * -q.y, q.z * v.z * -q.z );
		/*
		var q:Quaternion = this.clone();
		var qc:Quaternion;
		qc = q.getConjugate();
		q.multiplyVector(v);
		q.multiply(qc);
		return new Vector4(q.getX(), q.getY(), q.getZ(), 0);
		*/
		/*
		// nVidia SDK implementation adapted by kiroukou
		var uv, uuv, qvec, v1, v2:Vector4;
		qvec 	=  new Vector4(q.x, q.y, q.z, 0);

		uv   	= qvec.crossV(v);

		uuv 	= qvec.crossV(uv);

		uv.scale(2 * q.w);
		uuv.scale(2);
		v1 = uv.getAddV(uuv);

		v2 = v.getAddV(v1);

		return (v2);
		*/
	}

}