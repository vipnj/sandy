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

package sandy.core.data 
{
	/**
	* Point in 3D world.
	* 
	* <p>A Vector is the representation of a position into a 3D space.</p>
	*
	* @author		Thomas Pfeiffer - kiroukou
	* @author		Mirek Mencel
	* @author		Tabin Cédric - thecaptain
	* @author		Nicolas Coevoet - [ NikO ]
	* @author		Bruce Epstein - zeusprod - truncated toString output to 2 decimals
	* @since		0.1
	* @version		2.0.1
	* @date 		12.04.2007
	*/
	import sandy.util.NumberUtil;
	
	public final class Vector
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
	
		/**
		* <p>Create a new {@code Vector} Instance</p>
		* 
		* @param	px	the x coordinate
		* @param	py	the y coordinate
		* @param	pz	the z coordinate
		*/ 	
		public function Vector(px:Number=0, py:Number=0, pz:Number=0)
		{
			x = px;
			y = py;
			z = pz;
		}
		
		
		public function clone():Vector
		{
		    var l_oV:Vector = new Vector( x, y, z );
		    return l_oV;
		}
		
		public function copy( p_oVector:Vector ):void
		{
			x = p_oVector.x;
			y = p_oVector.y;
			z = p_oVector.z;
		}
	
		/**
		 * Compute the norm of the {@code Vector}.
		 *
		 * @param {@code v} a {@code Vector}.
		 * @return the norm of the {@code Vector}.
		 */
		public function getNorm():Number
		{
			return Math.sqrt( x*x + y*y + z*z );
		}
		
		/**
		 * Compute the oposite of the {@code Vector}.
		 *
		 * @param {@code v} a {@code Vector}.
		 * @return a {@code Vector}.
		 */
		public function negate( v:Vector ): Vector
		{
			return new Vector( - x, - y, - z );
		}
		
		/**
		 * Compute the addition of the two {@code Vector}.
		 *
		 * @param {@code v} a {@code Vector}.
		 * @param {@code w} a {@code Vector}.
		 * @return nothing
		 */
		public function add( v:Vector ):void
		{
			x += v.x;
			y += v.y;
			z += v.z;
		}
		
		/**
		 * Compute the substraction of the two {@code Vector}.
		 *
		 * @param {@code v} a {@code Vector}.
		 * @param {@code w} a {@code Vector}.
		 * @return The resulting {@code Vector}.
		 */
		public function sub( v:Vector ):void
		{
			x -= v.x;
			y -= v.y;
			z -= v.z;
		}
		
		/**
		 * Compute the power of the current vector
		 *
		 * @param {@code v} a {@code Vector}.
		 * @param {@code pow} a {@code Number}.
		 * @return The resulting {@code Vector}.
		 */
		public function pow( pow:Number ):void
		{
			x = Math.pow( x, pow );
	        y = Math.pow( y, pow );
	        z = Math.pow( z, pow );
		}
		/**
		 * Compute the multiplication of the {@code Vector} and the scalar.
		 *
		 * @param {@code v} a {@code Vector}.
		 * @param {@code n a {@code Number}.
		 * @return The resulting {@code Vector}.
		 */
		public function scale( n:Number ):void
		{
			x *= n;
			y *= n;
			z *= n;
		}
		
		/**
		 * Compute the dot product of the two {@code Vector}.
		 *
		 * @param {@code v} a {@code Vector}.
		 * @param {@code w} a {@code Vector}.
		 * @return the dot procuct of the 2 {@code Vector}.
		 */
		public function dot( w: Vector):Number
		{
			return ( x * w.x + y * w.y + z * w.z );
		}
		
		/**
		 * Compute the cross product of the two {@code Vector}.
		 *
		 * @param {@code v} a {@code Vector}.
		 * @param {@code w} a {@code Vector}.
		 * @return the {@code Vector} resulting of the cross product.
		 */
		public function cross( v:Vector):Vector
		{
			// cross product vector that will be returned
	        // calculate the components of the cross product
			return new Vector( 	(y * v.z) - (z * v.y) ,
	                            (z * v.x) - (x * v.z) ,
	                            (x * v.y) - (y * v.x));
		}
		
		/**
		 * Normalize the {@code Vector}.
		 *
		 * @param {@code v} a {@code Vector}.
		 * @return a Boolean true for success, false for mistake.
		 */	
		public function normalize():void
		{
			// -- We get the norm of the vector
			var norm:Number = getNorm();
			// -- We escape the process is norm is null or equal to 1
			if( norm == 0 || norm == 1) return;
			x /= norm;
			y /= norm;
			z /= norm;
		}
		
		/**
		* Returns the angle in radian between the two 3D vectors. The formula used here is very simple.
		* It comes from the definition of the dot product between two vectors.
		* @param	v	Vector	The first Vector
		* @param	w	Vector	The second vector
		* @return 	Number	The angle in radian between the two vectors.
		*/
		public function getAngle ( w:Vector ):Number
		{
			var ncos:Number = dot( w ) / ( getNorm() * w.getNorm() );
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
		* Get a String represntation of the {@code Vector}.
		* 
		* @return	A String representing the {@code Vector}.
		*/ 	
		public function toString(decPlaces:Number=0):String
		{
			if (decPlaces == 0) 
			{
				decPlaces = 0.01;
			}
			// Round display to two decimals places
			// Returns "{x, y, z}"
			return "{" + NumberUtil.roundTo(x, decPlaces) + ", " + 
						 NumberUtil.roundTo(y, decPlaces) + ", " + 
						 NumberUtil.roundTo(z, decPlaces) + "}";
		}
		
		public function equals(p_vector:Vector):Boolean
		{
			return (p_vector.x == x && p_vector.y == y && p_vector.z == z);
		}
	
		// Useful for XML output
		public function serialize(decPlaces:Number=0):String
		{
			if (decPlaces == 0) 
			{
				decPlaces = .01
			}
			//returns x,y,x
			return  (NumberUtil.roundTo(x, decPlaces) + "," + 
					 NumberUtil.roundTo(y, decPlaces) + "," + 
					 NumberUtil.roundTo(z, decPlaces));
		}
		
		// Useful for XML output
		public function deserialize(convertFrom:String):void
		{
			var tmp:Array = convertFrom.split(",");
			if (tmp.length != 3) 
			{
				trace ("Unexpected length of string to deserialize into a vector " + convertFrom);
			}
			
			x = tmp[0];
			y = tmp[1];
			z = tmp[2];
		}
	}
}