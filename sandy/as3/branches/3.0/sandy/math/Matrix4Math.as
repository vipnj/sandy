package sandy.math 
{
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
	import sandy.util.NumberUtil;
	import sandy.math.FastMath;
	import sandy.errors.SingletonError;
	import flash.geom.Matrix;
	
	/**
	* Math functions for {@link Matrix4}.
	* @author		Thomas Pfeiffer - kiroukou
	* @since		0.1
	* @version		0.2
	* @date 		12.01.2006
	* 
	**/
	public class Matrix4Math 
	{
		public static var USE_FAST_MATH:Boolean = false;
		
		/**
		 * Compute the multiplication of 2 {@code Matrix4} but as they were 3x3 matrix.
		 *
		 * @param {@code m1} a {@code Matrix}.
		 * @param {@code m2} a {@code Matrix}.
		 * @return The result of computation : a {@code Matrix4}.
		 */
		public static function multiply3x3(m1:Matrix4, m2:Matrix4) : Matrix4 
		{
			const m111:Number = m1.n11, m211:Number = m2.n11,
			m121:Number = m1.n21, m221:Number = m2.n21,
			m131:Number = m1.n31, m231:Number = m2.n31,
			m112:Number = m1.n12, m212:Number = m2.n12,
			m122:Number = m1.n22, m222:Number = m2.n22,
			m132:Number = m1.n32, m232:Number = m2.n32,
			m113:Number = m1.n13, m213:Number = m2.n13,
			m123:Number = m1.n23, m223:Number = m2.n23,
			m133:Number = m1.n33, m233:Number = m2.n33;
			
			return new Matrix4
			(
				m111 * m211 + m112 * m221 + m113 * m231,
				m111 * m212 + m112 * m222 + m113 * m232,
				m111 * m213 + m112 * m223 + m113 * m233,
				0,
				m121 * m211 + m122 * m221 + m123 * m231,
				m121 * m212 + m122 * m222 + m123 * m232,
				m121 * m213 + m122 * m223 + m123 * m233,
				0,
				m131 * m211 + m132 * m221 + m133 * m231,
				m131 * m212 + m132 * m222 + m133 * m232,
				m131 * m213 + m132 * m223 + m133 * m233,
				0,
				0,0,0,1			
			);
		}

	
		public static function multiply4x3( m1:Matrix4, m2:Matrix4 ):Matrix4
		{
			const m111:Number = m1.n11, m211:Number = m2.n11,
				m121:Number = m1.n21, m221:Number = m2.n21,
				m131:Number = m1.n31, m231:Number = m2.n31,
				m112:Number = m1.n12, m212:Number = m2.n12,
				m122:Number = m1.n22, m222:Number = m2.n22,
				m132:Number = m1.n32, m232:Number = m2.n32,
				m113:Number = m1.n13, m213:Number = m2.n13,
				m123:Number = m1.n23, m223:Number = m2.n23,
				m133:Number = m1.n33, m233:Number = m2.n33,
				m214:Number = m2.n14, m224:Number = m2.n24,	m234:Number = m2.n34;
			
			return new Matrix4
			(
				m111 * m211 + m112 * m221 + m113 * m231,
				m111 * m212 + m112 * m222 + m113 * m232,
				m111 * m213 + m112 * m223 + m113 * m233,
				m214 * m111 + m224 * m112 + m234 * m113 + m1.n14,
				
				m121 * m211 + m122 * m221 + m123 * m231,
				m121 * m212 + m122 * m222 + m123 * m232,
				m121 * m213 + m122 * m223 + m123 * m233,
				m214 * m121 + m224 * m122 + m234 * m123 + m1.n24,
				
				m131 * m211 + m132 * m221 + m133 * m231,
				m131 * m212 + m132 * m222 + m133 * m232,
				m131 * m213 + m132 * m223 + m133 * m233,
				m214 * m131 + m224 * m132 + m234 * m133 + m1.n34,
				
				0, 0, 0, 1
			);
		}
			
		/**
		 * Compute the multiplication of 2 {@code Matrix4}.
		 *
		 * @param {@code m1} a {@code Matrix}.
		 * @param {@code m2} a {@code Matrix}.
		 * @return The result of computation : a {@code Matrix4}.
		 */
		public static function multiply(m1:Matrix4, m2:Matrix4) : Matrix4 
		{
			const m111:Number = m1.n11, m121:Number = m1.n21, m131:Number = m1.n31, m141:Number = m1.n41,
				m112:Number = m1.n12, m122:Number = m1.n22, m132:Number = m1.n32, m142:Number = m1.n42, 
				m113:Number = m1.n13, m123:Number = m1.n23, m133:Number = m1.n33, m143:Number = m1.n43,
				m114:Number = m1.n14, m124:Number = m1.n24, m134:Number = m1.n34, m144:Number = m1.n44,
				m211:Number = m2.n11, m221:Number = m2.n21, m231:Number = m2.n31, m241:Number = m2.n41,
				m212:Number = m2.n12, m222:Number = m2.n22, m232:Number = m2.n32, m242:Number = m2.n42, 
				m213:Number = m2.n13, m223:Number = m2.n23, m233:Number = m2.n33, m243:Number = m2.n43,
				m214:Number = m2.n14, m224:Number = m2.n24, m234:Number = m2.n34, m244:Number = m2.n44;
			
			return new Matrix4
			(
				m111 * m211 + m112 * m221 + m113 * m231 + m114 * m241,
				m111 * m212 + m112 * m222 + m113 * m232 + m114 * m242,
				m111 * m213 + m112 * m223 + m113 * m233 + m114 * m243,
				m111 * m214 + m112 * m224 + m113 * m234 + m114 * m244,
		
				m121 * m211 + m122 * m221 + m123 * m231 + m124 * m241,
				m121 * m212 + m122 * m222 + m123 * m232 + m124 * m242,
				m121 * m213 + m122 * m223 + m123 * m233 + m124 * m243,
				m121 * m214 + m122 * m224 + m123 * m234 + m124 * m244,
		
				m131 * m211 + m132 * m221 + m133 * m231 + m134 * m241,
				m131 * m212 + m132 * m222 + m133 * m232 + m134 * m242,
				m131 * m213 + m132 * m223 + m133 * m233 + m134 * m243,
				m131 * m214 + m132 * m224 + m133 * m234 + m134 * m244,
		
				m141 * m211 + m142 * m221 + m143 * m231 + m144 * m241,
				m141 * m212 + m142 * m222 + m143 * m232 + m144 * m242,
				m141 * m213 + m142 * m223 + m143 * m233 + m144 * m243,
				m141 * m214 + m142 * m224 + m143 * m234 + m144 * m244
			);
		}
		
		/**
		 * Compute an addition {@code Matrix4}.
		 *
		 * @param {@code m1} Matrix to add.
		 * @param {@code m2} Matrix to add.
		 * @return The result of computation : a {@code Matrix4}.
		 */
		public static function addMatrix(m1:Matrix4, m2:Matrix4): Matrix4
		{
			return new Matrix4
			(
				m1.n11 + m2.n11, m1.n12 + m2.n12, m1.n13 + m2.n13, m1.n14 + m2.n14,
				m1.n21 + m2.n21, m1.n22 + m2.n22, m1.n23 + m2.n23, m1.n24 + m2.n24,
				m1.n31 + m2.n31, m1.n32 + m2.n32, m1.n33 + m2.n33, m1.n34 + m2.n34,
				m1.n41 + m2.n41, m1.n42 + m2.n42, m1.n43 + m2.n43, m1.n44 + m2.n44
			);
		}
		
		/**
		 * Compute a clonage {@code Matrix4}.
		 *
		 * @param {@code m1} Matrix to clone.
		 * @return The result of clonage : a {@code Matrix4}.
		 */
		public static function clone(m:Matrix4):Matrix4
		{
			return new Matrix4(	m.n11,m.n12,m.n13,m.n14,
	                            m.n21,m.n22,m.n23,m.n24,
								m.n31,m.n32,m.n33,m.n34,
								m.n41,m.n42,m.n43,m.n44
	                           );
		}
		
		/**
		 * Compute a multiplication of a vertex and the matrix{@code Matrix4}.
		 *
		 * @param {@code m} Matrix4.
		 * @param {@code v} Vertex
		 * @return void
		 */    
		public static function vectorMult( m:Matrix4, pv:Vector ): Vector
		{
			const x:Number=pv.x, y:Number=pv.y, z:Number=pv.z;
			return  new Vector( (x * m.n11 + y * m.n12 + z * m.n13 + m.n14),
								(x * m.n21 + y * m.n22 + z * m.n23 + m.n24),
								(x * m.n31 + y * m.n32 + z * m.n33 + m.n34));
		}
	
		/**
		 * Compute a multiplication of a vector and the matrix{@code Matrix4} 
		 *    as there were of 3 dimensions.
		 *
		 * @param {@code m} Matrix4.
		 * @param {@code v} Vector
		 * @return void
		 */
		public static function vectorMult3x3( m:Matrix4, pv:Vector ):Vector
		{
			const x:Number=pv.x, y:Number=pv.y, z:Number=pv.z;
			return  new Vector( (x * m.n11 + y * m.n12 + z * m.n13),
								(x * m.n21 + y * m.n22 + z * m.n23),
								(x * m.n31 + y * m.n32 + z * m.n33));
		}
	        
		/**
		 * Compute a Rotation {@code Matrix4} from the Euler angle in degrees unit.
		 *
		 * @param {@code ax} angle of rotation around X axis in degree.
		 * @param {@code ay} angle of rotation around Y axis in degree.
		 * @param {@code az} angle of rotation around Z axis in degree.
		 * @return The result of computation : a {@code Matrix4}.
		 */
		public static function eulerRotation ( ax:Number, ay:Number, az:Number ) : Matrix4
		{
			var m:Matrix4 = Matrix4.createIdentity();
			ax = NumberUtil.toRadian(ax);
			ay = NumberUtil.toRadian(ay);
			az = NumberUtil.toRadian(az);
			// --
			const a:Number = ( USE_FAST_MATH == false ) ? Math.cos( ax ) : FastMath.cos(ax);
			const b:Number = ( USE_FAST_MATH == false ) ? Math.sin( ax ) : FastMath.sin(ax);
			const c:Number = ( USE_FAST_MATH == false ) ? Math.cos( ay ) : FastMath.cos(ay);
			const d:Number = ( USE_FAST_MATH == false ) ? Math.sin( ay ) : FastMath.sin(ay);
			const e:Number = ( USE_FAST_MATH == false ) ? Math.cos( az ) : FastMath.cos(az);
			const f:Number = ( USE_FAST_MATH == false ) ? Math.sin( az ) : FastMath.sin(az);
			const ad:Number = a * d	;
			const bd:Number = b * d	;
	
			m.n11 =   c  * e         ;
			m.n12 = - c  * f         ;
			m.n13 =   d              ;
			m.n21 =   bd * e + a * f ;
			m.n22 = - bd * f + a * e ;
			m.n23 = - b  * c 	 ;
			m.n31 = - ad * e + b * f ;
			m.n32 =   ad * f + b * e ;
			m.n33 =   a  * c         ;
		
			return m;
		}
		
		/**
		 * 
		 * @param angle Number angle of rotation in degrees
		 * @return the computed matrix
		 */
		public static function rotationX ( angle:Number ):Matrix4
		{
			var m:Matrix4 = Matrix4.createIdentity();
			angle = NumberUtil.toRadian(angle);
			const c:Number = ( USE_FAST_MATH == false ) ? Math.cos( angle ) : FastMath.cos( angle );
			const s:Number = ( USE_FAST_MATH == false ) ? Math.sin( angle ) : FastMath.sin( angle );
	
			m.n22 =  c;
			m.n23 =  s;
			m.n32 = -s;
			m.n33 =  c;
			return m;
		}
		
		/**
		 * 
		 * @param angle Number angle of rotation in degrees
		 * @return the computed matrix
		 */
		public static function rotationY ( angle:Number ):Matrix4
		{
			var m:Matrix4 = Matrix4.createIdentity();
			angle = NumberUtil.toRadian(angle);
			const c:Number = ( USE_FAST_MATH == false ) ? Math.cos( angle ) : FastMath.cos( angle );
			const s:Number = ( USE_FAST_MATH == false ) ? Math.sin( angle ) : FastMath.sin( angle );
			// --
			m.n11 =  c;
			m.n13 = -s;
			m.n31 =  s;
			m.n33 =  c;
			return m;
		}
		
		/**
		 * 
		 * @param angle Number angle of rotation in degrees
		 * @return the computed matrix
		 */
		public static function rotationZ ( angle:Number ):Matrix4
		{
			var m:Matrix4 = Matrix4.createIdentity();
			angle = NumberUtil.toRadian(angle);
			const c:Number = ( USE_FAST_MATH == false ) ? Math.cos( angle ) : FastMath.cos( angle );
			const s:Number = ( USE_FAST_MATH == false ) ? Math.sin( angle ) : FastMath.sin( angle );
			// --
			m.n11 =  c;
			m.n12 =  s;
			m.n21 = -s;
			m.n22 =  c;
			return m;
		}
		
		/**
		 * Compute a Rotation around a Vector which represents the axis of rotation{@code Matrix4}.
		 *
		 * @param {@code v} The axis of rotation
		 * @param The angle of rotation in degree
		 * @return The result of computation : a {@code Matrix4}.
		 */
		public static function axisRotationVector ( v:Vector, angle:Number ) : Matrix4
		{
			return Matrix4Math.axisRotation( v.x, v.y, v.z, angle );
		}
		
		/**
		 * Compute a Rotation around an axis{@code Matrix4}.
		 *
		 * @param {@code nRotX} rotation X.
		 * @param {@code nRotY} rotation Y.
		 * @param {@code nRotZ} rotation Z.
		 * @param The angle of rotation in degree
		 * @return The result of computation : a {@code Matrix4}.
		 */
		public static function axisRotation ( u:Number, v:Number, w:Number, angle:Number ) : Matrix4
		{
			var m:Matrix4 	= Matrix4.createIdentity();
			angle = NumberUtil.toRadian( angle );
			// -- modification pour verifier qu'il n'y ai pas un probleme de precision avec la camera
			const c:Number = ( USE_FAST_MATH == false ) ? Math.cos( angle ) : FastMath.cos( angle );
			const s:Number = ( USE_FAST_MATH == false ) ? Math.sin( angle ) : FastMath.sin( angle );
			const scos:Number	= 1 - c ;
			// --
			var suv	:Number = u * v * scos ;
			var svw	:Number = v * w * scos ;
			var suw	:Number = u * w * scos ;
			var sw	:Number = s * w ;
			var sv	:Number = s * v ;
			var su	:Number = s * u ;
			
			m.n11  =   c + u * u * scos	;
			m.n12  = - sw 	+ suv 			;
			m.n13  =   sv 	+ suw			;
	
			m.n21  =   sw 	+ suv 			;
			m.n22  =   c + v * v * scos 	;
			m.n23  = - su 	+ svw			;
	
			m.n31  = - sv	+ suw 			;
			m.n32  =   su	+ svw 			;
			m.n33  =   c	+ w * w * scos	;
	
			return m;
		}
		
		/**
		 * Compute a translation {@code Matrix4}.
		 * 
		 * <pre>
		 * |1  0  0  0|
		 * |0  1  0  0|
		 * |0  0  1  0|
		 * |Tx Ty Tz 1|
		 * </pre>
		 * 
		 * @param {@code nTx} translation X.
		 * @param {@code nTy} translation Y.
		 * @param {@code nTz} translation Z.
		 * @return The result of computation : a {@code Matrix4}.
		 */
		public static function translation(nTx:Number, nTy:Number, nTz:Number) : Matrix4 
		{
			var m : Matrix4 = Matrix4.createIdentity();
			m.n14 = nTx;
			m.n24 = nTy;
			m.n34 = nTz;
			return m;
		}
	
		/**
		 * Compute a translation from a vector {@code Matrix4}.
		 * 
		 * <pre>
		 * |1  0  0  0|
		 * |0  1  0  0|
		 * |0  0  1  0|
		 * |Tx Ty Tz 1|
		 * </pre>
		 * 
		 * @param {@code v} translation Vector.
	( * @return The result of computation : a {@code Matrix4}.
		 */
		public static function translationVector( v:Vector ) : Matrix4 
		{
			var m : Matrix4 = Matrix4.createIdentity();
			m.n14 = v.x;
			m.n24 = v.y;
			m.n34 = v.z;
			return m;
		}
		
		/**
		 * Compute a scale {@code Matrix4}.
		 * 
		 * <pre>
		 * |Sx 0  0  0|
		 * |0  Sy 0  0|
		 * |0  0  Sz 0|
		 * |0  0  0  1|
		 * </pre>
		 *
		 * @param {@code nRotX} translation X.
		 * @param {@code nRotY} translation Y.
		 * @param {@code nRotZ} translation Z.
		 * @return The result of computation : a {@code Matrix}.
		 */
		public static function scale(nXScale:Number, nYScale:Number, nZScale:Number) : Matrix4 
		{
			var matScale : Matrix4 = Matrix4.createIdentity();
			matScale.n11 = nXScale;
			matScale.n22 = nYScale;
			matScale.n33 = nZScale;
			return matScale;
		}
		
		/**
		 * Compute a scale {@code Matrix4}.
		 * 
		 * <pre>
		 * |Sx 0  0  0|
		 * |0  Sy 0  0|
		 * |0  0  Sz 0|
		 * |0  0  0  1|
		 * </pre>
		 *
		 * @param {@code Vector} The vector containing the scale values
		 * @return The result of computation : a {@code Matrix}.
		 */
		public static function scaleVector( v:Vector) : Matrix4 
		{
			var matScale : Matrix4 = Matrix4.createIdentity();
			matScale.n11 = v.x;
			matScale.n22 = v.y;
			matScale.n33 = v.z;
			return matScale;
		}
			
		/**
		* Compute the determinant of the 4x4 square matrix
		* @param m a Matrix4
		* @return Number the determinant
		*/
		public static function det( m:Matrix4 ):Number
		{
			return		(m.n11 * m.n22 - m.n21 * m.n12) * (m.n33 * m.n44 - m.n43 * m.n34)- (m.n11 * m.n32 - m.n31 * m.n12) * (m.n23 * m.n44 - m.n43 * m.n24)
					 + 	(m.n11 * m.n42 - m.n41 * m.n12) * (m.n23 * m.n34 - m.n33 * m.n24)+ (m.n21 * m.n32 - m.n31 * m.n22) * (m.n13 * m.n44 - m.n43 * m.n14)
					 - 	(m.n21 * m.n42 - m.n41 * m.n22) * (m.n13 * m.n34 - m.n33 * m.n14)+ (m.n31 * m.n42 - m.n41 * m.n32) * (m.n13 * m.n24 - m.n23 * m.n14);
	
		}
		
		public static function det3x3( m:Matrix4 ):Number
		{	
			return m.n11 * ( m.n22 * m.n33 - m.n23 * m.n32 ) + m.n21 * ( m.n32 * m.n13 - m.n12 * m.n33 ) + m.n31 * ( m.n12 * m.n23 - m.n22 * m.n13 );
		}
	
		/**
		 * Computes the trace of the matrix.
		 * @param m Matrix4 The matrix we want to compute the trace
		 * @return The trace value which is the sum of the element on the diagonal
		 */
		public static function getTrace( m:Matrix4 ):Number
		{
			return m.n11 + m.n22 + m.n33 + m.n44;
		}
		
		/**
		* Return the inverse of the matrix passed in parameter.
		* @param m The matrix4 to inverse
		* @return Matrix4 The inverse Matrix4
		*/
		public static function getInverse( m:Matrix4 ):Matrix4
		{
			//take the determinant
			var d:Number = Matrix4Math.det( m );
			if( Math.abs(d) < 0.001 )
			{
				//We cannot invert a matrix with a null determinant
				return null;
			}
			//We use Cramer formula, so we need to devide by the determinant. We prefer multiply by the inverse
			d = 1/d;
			var m11:Number = m.n11;var m21:Number = m.n21;var m31:Number = m.n31;var m41:Number = m.n41;
			var m12:Number = m.n12;var m22:Number = m.n22;var m32:Number = m.n32;var m42:Number = m.n42;
			var m13:Number = m.n13;var m23:Number = m.n23;var m33:Number = m.n33;var m43:Number = m.n43;
			var m14:Number = m.n14;var m24:Number = m.n24;var m34:Number = m.n34;var m44:Number = m.n44;
			return new Matrix4 (
			d * ( m22*(m33*m44 - m43*m34) - m32*(m23*m44 - m43*m24) + m42*(m23*m34 - m33*m24) ),
			-d* ( m12*(m33*m44 - m43*m34) - m32*(m13*m44 - m43*m14) + m42*(m13*m34 - m33*m14) ),
			d * ( m12*(m23*m44 - m43*m24) - m22*(m13*m44 - m43*m14) + m42*(m13*m24 - m23*m14) ),
			-d* ( m12*(m23*m34 - m33*m24) - m22*(m13*m34 - m33*m14) + m32*(m13*m24 - m23*m14) ),
			-d* ( m21*(m33*m44 - m43*m34) - m31*(m23*m44 - m43*m24) + m41*(m23*m34 - m33*m24) ),
			d * ( m11*(m33*m44 - m43*m34) - m31*(m13*m44 - m43*m14) + m41*(m13*m34 - m33*m14) ),
			-d* ( m11*(m23*m44 - m43*m24) - m21*(m13*m44 - m43*m14) + m41*(m13*m24 - m23*m14) ),
			d * ( m11*(m23*m34 - m33*m24) - m21*(m13*m34 - m33*m14) + m31*(m13*m24 - m23*m14) ),
			d * ( m21*(m32*m44 - m42*m34) - m31*(m22*m44 - m42*m24) + m41*(m22*m34 - m32*m24) ),
			-d* ( m11*(m32*m44 - m42*m34) - m31*(m12*m44 - m42*m14) + m41*(m12*m34 - m32*m14) ),
			d * ( m11*(m22*m44 - m42*m24) - m21*(m12*m44 - m42*m14) + m41*(m12*m24 - m22*m14) ),
			-d* ( m11*(m22*m34 - m32*m24) - m21*(m12*m34 - m32*m14) + m31*(m12*m24 - m22*m14) ),
			-d* ( m21*(m32*m43 - m42*m33) - m31*(m22*m43 - m42*m23) + m41*(m22*m33 - m32*m23) ),
			d * ( m11*(m32*m43 - m42*m33) - m31*(m12*m43 - m42*m13) + m41*(m12*m33 - m32*m13) ),
			-d* ( m11*(m22*m43 - m42*m23) - m21*(m12*m43 - m42*m13) + m41*(m12*m23 - m22*m13) ),
			d * ( m11*(m22*m33 - m32*m23) - m21*(m12*m33 - m32*m13) + m31*(m12*m23 - m22*m13) )
			);
		}
		
		/**
		 * Realize a rotation around a specific axis (the axis must be normalized!) and from an pangle degrees and around a specific position.
		 * @param pAxis A 3D Vector representing the axis of rtation. Must be normalized
		 * @param ref Vector The center of rotation as a 3D point.
		 * @param pAngle Number The angle of rotation in degrees.
		 */
		public static function axisRotationWithReference( axis:Vector, ref:Vector, pAngle:Number ):Matrix4
		{
			var angle:Number = ( pAngle + 360 ) % 360;
			var m:Matrix4 = Matrix4Math.translation ( ref.x, ref.y, ref.z );
			m = Matrix4Math.multiply ( m, Matrix4Math.axisRotation( axis.x, axis.y, axis.z, angle ));
			m = Matrix4Math.multiply ( m, Matrix4Math.translation ( -ref.x, -ref.y, -ref.z ));
			return m;
		}
	}
}