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
 
/**
* Math functions for {@link Vector4}.
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin C�dric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @since		0.1
* @version		0.2
* @date 		12.01.2006 
**/
class sandy.math.VectorMath
{
	
	/**
	 * Compute the norm of the {@code Vector}.
	 *
	 * @param {@code v} a {@code Vector}.
	 * @return the norm of the {@code Vector}.
	 */
	public static function getNorm( v:Vector ):Number
	{
		return Math.sqrt( v.x*v.x + v.y*v.y + v.z*v.z );
	}
	
	/**
	 * Compute the oposite of the {@code Vector}.
	 *
	 * @param {@code v} a {@code Vector}.
	 * @return a {@code Vector}.
	 */
	public static function negate( v:Vector ): Vector
	{
		return new Vector( - v.x, - v.y, - v.z );
	}
	
	/**
	 * Compute the addition of the two {@code Vector}.
	 *
	 * @param {@code v} a {@code Vector}.
	 * @param {@code w} a {@code Vector}.
	 * @return The resulting {@code Vector}.
	 */
	public static function addVector( v:Vector, w:Vector ): Vector
	{
		return new Vector( 	v.x + w.x ,
                           	v.y + w.y ,
                           	v.z + w.z );
	}
	
	/**
	 * Compute the substraction of the two {@code Vector}.
	 *
	 * @param {@code v} a {@code Vector}.
	 * @param {@code w} a {@code Vector}.
	 * @return The resulting {@code Vector}.
	 */
	public static function sub( v:Vector, w:Vector ): Vector
	{
		return new Vector(	v.x - w.x ,
                            v.y - w.y ,
                            v.z - w.z );
	}
	
	/**
	 * Compute the power of the current vector
	 *
	 * @param {@code v} a {@code Vector}.
	 * @param {@code pow} a {@code Number}.
	 * @return The resulting {@code Vector}.
	 */
	public static function pow( v:Vector, pow:Number ): Vector
	{
		return new Vector(	Math.pow( v.x, pow ) ,
                            Math.pow( v.x, pow ) ,
                            Math.pow( v.x, pow ) );
	}
	/**
	 * Compute the multiplication of the {@code Vector} and the scalar.
	 *
	 * @param {@code v} a {@code Vector}.
	 * @param {@code n a {@code Number}.
	 * @return The resulting {@code Vector}.
	 */
	public static function scale( v:Vector, n:Number ): Vector
	{
		return new Vector(	v.x * n ,
                            v.y * n ,
                            v.z * n );
	}
	
	/**
	 * Compute the dot product of the two {@code Vector}.
	 *
	 * @param {@code v} a {@code Vector}.
	 * @param {@code w} a {@code Vector}.
	 * @return the dot procuct of the 2 {@code Vector}.
	 */
	public static function dot( v: Vector, w: Vector):Number
	{
		return ( v.x * w.x + v.y * w.y + w.z * v.z );
	}
	
	/**
	 * Compute the cross product of the two {@code Vector}.
	 *
	 * @param {@code v} a {@code Vector}.
	 * @param {@code w} a {@code Vector}.
	 * @return the {@code Vector} resulting of the cross product.
	 */
	public static function cross(w:Vector, v:Vector):Vector
	{
		// cross product vector that will be returned
                // calculate the components of the cross product
		return new Vector( 	(w.y * v.z) - (w.z * v.y) ,
                            (w.z * v.x) - (w.x * v.z) ,
                            (w.x * v.y) - (w.y * v.x));
	}
	
	/**
	 * Normalize the {@code Vector}.
	 *
	 * @param {@code v} a {@code Vector}.
	 * @return a Boolean true for success, false for mistake.
	 */	
	public static function normalize( v:Vector ): Boolean
	{
		// -- We get the norm of the vector
		var norm:Number = VectorMath.getNorm( v );
		// -- We escape the process is norm is null or equal to 1
		if( norm == 0 || norm == 1) return false;
		v.x /= norm;
		v.y /= norm;
		v.z /= norm;

		return true;
	}
	
	/**
	* Returns the angle in radian between the two 3D vectors. The formula used here is very simple.
	* It comes from the definition of the dot product between two vectors.
	* @param	v	Vector	The first Vector
	* @param	w	Vector	The second vector
	* @return 	Number	The angle in radian between the two vectors.
	*/
	public static function getAngle ( v:Vector, w:Vector ):Number
	{
		var ncos:Number = VectorMath.dot( v, w ) / ( VectorMath.getNorm(v) * VectorMath.getNorm(w) );
		var sin2:Number = 1 - ncos * ncos;
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
	 * clone the {@code Vector}.
	 *
	 * @param {@code v} a {@code Vector}.
	 * @return a clone of the Vector passed in parameters
	 */	
	public static function clone( v:Vector ): Vector
	{
		return new Vector( v.x, v.y, v.z );
	}

}