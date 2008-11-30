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

package sandy.math;

import sandy.core.data.Vector;
 
/**
 * Math functions for vector manipulations.
 *  
 * @author		Thomas Pfeiffer - kiroukou
 * @author Niel Drummond - haXe port 
 * 
 */
class VectorMath
{
	
	/**
	 * Computes the norm of a 3D vector.
	 *
	 * @param p_oV 	The vector.
	 * @return 	The norm of the vector.
	 */
	public static inline function getNorm( p_oV:Vector ):Float
	{
		return Math.sqrt( p_oV.x*p_oV.x + p_oV.y*p_oV.y + p_oV.z*p_oV.z );
	}

#if flash10
	public static inline function getNormInvSqrt( p_oV:Vector ):Float
		{
		return invSqrt( p_oV.x*p_oV.x + p_oV.y*p_oV.y + p_oV.z*p_oV.z );
		}
	public static inline function prepare() {
			var b = new flash.utils.ByteArray();
			b.length = 1024;
			flash.Memory.select(b);
	}

	public static inline function invSqrt( x : Float ) : Float {
			var half = 0.5 * x;
			flash.Memory.setFloat(0,x);
			var i = flash.Memory.getI32(0);
			i = 0x5f3759df - (i>>1);
			flash.Memory.setI32(0,i);
			x = flash.Memory.getFloat(0);
			x = x * (1.5 - half*x*x);
			return x;
	}
#end
	
	/**
	 * Computes the oposite vector of a specified 3D vector.
	 *
	 * @param p_oV 	The vector.
	 * @return 	The opposed vector.
	 */
	public static function negate( p_oV:Vector ): Vector
	{
		return new Vector( - p_oV.x, - p_oV.y, - p_oV.z );
	}
	
	/**
	 * Adds two 3D vectors.
	 *
	 * @param p_oV 	The first vector
	 * @param p_oW 	The second vector
	 * @return 	The resulting vector
	 */
	public static function addVector( p_oV:Vector, p_oW:Vector ): Vector
	{
		return new Vector( 	p_oV.x + p_oW.x ,
                           	p_oV.y + p_oW.y ,
                           	p_oV.z + p_oW.z );
	}
	
	/**
	 * Substracts one 3D vector from another
	 *
	 * @param p_oV 	The vector to subtract from
	 * @param p_oW	The vector to subtract
	 * @return 	The resulting vector
	 */
	public static function sub( p_oV:Vector, p_oW:Vector ): Vector
	{
		return new Vector(	p_oV.x - p_oW.x ,
                            p_oV.y - p_oW.y ,
                            p_oV.z - p_oW.z );
	}
	
	/**
	 * Computes the power of a 3D vector.
	 *
	 * <p>Here the meaning of the power of a vector is a new vector<br />
	 * where each element is the the n:th power of the corresponding element.</p>
	 * <p>Ex: A^n = ( A.x^n, A.y^n, A.z^n ) </p>
	 * 
	 * @param p_oV		The vector.
	 * @param p_nExp	The exponent
	 * @return 		The resulting vector.
	 */
	public static function pow( p_oV:Vector, p_nExp:Float ): Vector
	{
		return new Vector(	Math.pow( p_oV.x, p_nExp ) ,
                            Math.pow( p_oV.y, p_nExp ) ,
                            Math.pow( p_oV.z, p_nExp ) );
	}
	/**
	 * Multiplies a 3D vector by specified scalar.
	 *
	 * @param p_oV 	The vector to multiply
	 * @param n 	The scaler to multiply
	 * @return 	The resulting vector
	 */
	public static function scale( p_oV:Vector, n:Float ): Vector
	{
		return new Vector(	p_oV.x * n ,
                            		p_oV.y * n ,
                            		p_oV.z * n 
                            	);
	}
	
	/**
	 * Computes the dot product the two 3D vectors.
	 *
	 * @param p_oV 	The first vector
	 * @param p_oW 	The second vector
	 * @return 	The dot procuct
	 */
	public static function dot( p_oV: Vector, p_oW: Vector):Float
	{
		return ( p_oV.x * p_oW.x + p_oV.y * p_oW.y + p_oW.z * p_oV.z );
	}
	
	/**
	 * Computes the cross product of two 3D vectors.
	 *
	 * @param p_oW	The first vector
	 * @param p_oV	The second vector
	 * @return 	The resulting cross product
	 */
	public static function cross(p_oW:Vector, p_oV:Vector):Vector
	{
		// cross product vector that will be returned
                // calculate the components of the cross product
		return new Vector(	(p_oW.y * p_oV.z) - (p_oW.z * p_oV.y) ,
                            		(p_oW.z * p_oV.x) - (p_oW.x * p_oV.z) ,
                            		(p_oW.x * p_oV.y) - (p_oW.y * p_oV.x)
                            	);
	}
	
	/**
	 * Normalizes a 3d vector.
	 *
	 * @param p_oV 	The vector to normalize
	 * @return 	true if the normalization was successful, false otherwise.
	 */	
	public inline static function normalize( p_oV:Vector ): Bool
	{
		// -- We get the norm of the vector
#if flash10
		var norm:Float = VectorMath.getNormInvSqrt( p_oV );
#else
		var norm:Float = VectorMath.getNorm( p_oV );
#end
		// -- We escape the process is norm is null or equal to 1
		if( norm == 0 || norm == 1) {
				return false; 
		} else {
#if flash10
				p_oV.x *= norm;
				p_oV.y *= norm;
				p_oV.z *= norm;
#else
				p_oV.x /= norm;
				p_oV.y /= norm;
				p_oV.z /= norm;
#end

				return true;
		}
	}
	
	/**
	 * Calculates the angle between two 3D vectors. 
	 * 
	 * @param p_oV	The first Vector
	 * @param p_oW	The second vector
	 * @return	The angle in radians between the two vectors.
	 */
	public static function getAngle ( p_oV:Vector, p_oW:Vector ):Float
	{
		var ncos:Float = VectorMath.dot( p_oV, p_oW ) / ( VectorMath.getNorm(p_oV) * VectorMath.getNorm(p_oW) );
		var sin2:Float = 1 - ncos * ncos;
		if (sin2<0)
		{
			trace(" wrong "+ncos);
			sin2 = 0;
		}
		//I took long time to find this bug. Who can guess that (1-cos*cos) is negative ?!
		//sqrt returns a NaN for a negative value !
		return  Math.atan2( Math.sqrt(sin2), ncos );
	}
	
	/**
	 * Returns a random vector contained betweeen the first and second values
	 */
	public static function sphrand( inner:Float, outer:Float ):Vector
	{
		//create and normalize a vector
		var v:Vector = new Vector(Math.random()-.5, Math.random()-.5,
		Math.random()-.5);
		v.normalize();
	
		//find a random position between the inner and outer radii
		var r:Float = Math.random();
		r = (outer - inner)*r + inner;
	
		//set the normalized vector to the new radius
		v.scale(r);
	
	   return v;
	}

	/**
	 * Clones a 3D vector.
	 *
	 * @param p_oV 	The vector
	 * @return 	The clone
	 */	
	public static function clone( p_oV:Vector ): Vector
	{
		return new Vector( p_oV.x, p_oV.y, p_oV.z );
	}

}

