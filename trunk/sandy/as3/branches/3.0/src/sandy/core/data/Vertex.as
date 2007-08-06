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
	import sandy.util.NumberUtil;
	
	/**
	* Vertex of a 3D mesh.
	* 
	* <p>A vertex is a point which can be represented in differents coordinates. 
	* 	It leads to some extra properties specific to the vertex</p>
	* 
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		15/12/2006
	*/
	public final class Vertex
	{
		private static var ID:uint = 0;
		public const id:uint = ID ++;
		
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		/**
		* properties used to store transformed coordinates in the World coordinates
		*/
		public var wx:Number;
		public var wy:Number;
		public var wz:Number;
		
		/**
		* properties used to store transformed coordinates in screen World.
		*/ 
		public var sx:Number;
		public var sy:Number;
		public var sz:Number;
		
		/**
		 * State if the verte has allready been projected or not
		 * Default value is set to false.
		 */
		public var projected:Boolean = false;
		
		/**
		 * Number of polygons this vertex belongs to.
		 * Default value is 0.
		 */
		public var nbFaces:uint = 0;
		
		/**
		* Create a new {@code Vertex} Instance.
		* If no
		* @param px the x position number
		* @param py the y position number
		* @param pz the z position number
		* 
		*/
		public function Vertex( p_nx:Number=0, p_ny:Number=0, p_nz:Number=0, ...rest )
		{
			x = p_nx;
			y = p_ny;
			z = p_nz;
			// -- 
			wx = (rest[0])?rest[0]:x; 
			wy = (rest[1])?rest[1]:y;  
			wz = (rest[2])?rest[2]:z; 
			// --
			sy = sx = sz = 0;
		}
		
		/**
		* Returns a vector representing the vertex in the world coordinate
		* @param	void
		* @return	Vector	a Vector
		*/
		public function getWorldVector():Vector
		{
			return new Vector( wx, wy, wz );
		}
			
	    public function getVector():Vector
	    {
	        return new Vector( x, y, z );
	    }
	    
		public function clone():Vertex
		{
		    var l_oV:Vertex = new Vertex( x, y, z );
		    l_oV.wx = wx;    l_oV.sx = sx;
		    l_oV.wy = wy;    l_oV.sy = sy;
		    l_oV.wz = wz;    l_oV.sz = sz;
		    return l_oV;
		}
	
		public function clone2():Vertex
		{
		    return new Vertex( wx, wy, wz );
		}
			
		static public function createFromVector( p_v:Vector ):Vertex
		{
		    return new Vertex( p_v.x, p_v.y, p_v.z );
		}
	
	 	public function equals(p_vertex:Vertex):Boolean
		{
			return Boolean( p_vertex.x  ==  x && p_vertex.y  ==  y && p_vertex.z  ==  z && 
							p_vertex.wx == wx && p_vertex.wy == wy && p_vertex.wz == wz && 
							p_vertex.sx == wx && p_vertex.sy );
		}

		public function copy( p_oVector:Vertex ):void
		{
			x = p_oVector.x;
			y = p_oVector.y;
			z = p_oVector.z;
			wx = p_oVector.wx;
			wy = p_oVector.wy;
			wz = p_oVector.wz;
			sx = p_oVector.sx;
			sy = p_oVector.sy;
			sz = p_oVector.sz;
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
		public function negate( v:Vertex ): Vertex
		{
			return new Vertex( - x, - y, - z, -wx, -wy, -wz);
		}
		
		/**
		 * Compute the addition of the two {@code Vertex}.
		 *
		 * @param {@code v} a {@code Vertex}.
		 * @param {@code w} a {@code Vertex}.
		 * @return nothing
		 */
		public function add( v:Vertex ):void
		{
			x += v.x;
			y += v.y;
			z += v.z;
			
			wx += v.wx;
			wy += v.wy;
			wz += v.wz;
		}
		
		/**
		 * Compute the substraction of the two {@code Vertex}.
		 *
		 * @param {@code w} a {@code Vertex}.
		 * @return The resulting {@code Vertex}.
		 */
		public function sub( v:Vertex ):void
		{
			x -= v.x;
			y -= v.y;
			z -= v.z;
			wx -= v.wx;
			wy -= v.wy;
			wz -= v.wz;
		}
		
		/**
		 * Compute the power of the current Vertex
		 *
		 * @param {@code v} a {@code Vertex}.
		 * @param {@code pow} a {@code Number}.
		 * @return The resulting {@code Vertex}.
		 */
		public function pow( pow:Number ):void
		{
			x = Math.pow( x, pow );
	        y = Math.pow( y, pow );
	        z = Math.pow( z, pow );
	        wx = Math.pow( wx, pow );
	        wy = Math.pow( wy, pow );
	        wz = Math.pow( wz, pow );
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
			wx *= n;
			wy *= n;
			wz *= n;
		}
		
		/**
		 * Compute the dot product of the two {@code Vertex}.
		 *
		 * @param {@code w} a {@code Vertex}.
		 * @return the dot procuct of the 2 {@code Vertex}.
		 */
		public function dot( w: Vertex):Number
		{
			return ( x * w.x + y * w.y + z * w.z );
		}
		
		/**
		 * Compute the cross product of the two {@code Vertex}.
		 *
		 * @param {@code v} a {@code Vertex}.
		 * @param {@code w} a {@code Vertex}.
		 * @return the {@code Vertex} resulting of the cross product.
		 */
		public function cross( v:Vertex):Vertex
		{
			// cross product vector that will be returned
	        // calculate the components of the cross product
			return new Vertex( 	(y * v.z) - (z * v.y) ,
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
			
			wx /= norm;
			wy /= norm;
			wz /= norm;
		}
		
		/**
		* Returns the angle in radian between the two 3D vectors. The formula used here is very simple.
		* It comes from the definition of the dot product between two vectors.
		* @param	v	Vector	The first Vector
		* @param	w	Vector	The second vector
		* @return 	Number	The angle in radian between the two vectors.
		*/
		public function getAngle ( w:Vertex ):Number
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
						 NumberUtil.roundTo(z, decPlaces) + ", " + 
						 NumberUtil.roundTo(wx, decPlaces) + ", " + 
						 NumberUtil.roundTo(wy, decPlaces) + ", " + 
						 NumberUtil.roundTo(wz, decPlaces) + ", " + 
						 NumberUtil.roundTo(sx, decPlaces) + ", " + 
						 NumberUtil.roundTo(sy, decPlaces) + ", " + 
						 NumberUtil.roundTo(sz, decPlaces) + "}";
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
					 NumberUtil.roundTo(z, decPlaces) + "," +
					 NumberUtil.roundTo(wx, decPlaces) + "," + 
					 NumberUtil.roundTo(wy, decPlaces) + "," + 
					 NumberUtil.roundTo(wz, decPlaces) + "," +
					 NumberUtil.roundTo(sx, decPlaces) + "," + 
					 NumberUtil.roundTo(sy, decPlaces) + "," + 
					 NumberUtil.roundTo(sz, decPlaces) );
		}
		
		// Useful for XML output
		public function deserialize(convertFrom:String):void
		{
			var tmp:Array = convertFrom.split(",");
			if (tmp.length != 9) 
			{
				trace ("Unexpected length of string to deserialize into a vector " + convertFrom);
			}
			
			x = tmp[0];
			y = tmp[1];
			z = tmp[2];
			
			wx = tmp[3];
			wy = tmp[4];
			wz = tmp[5];
			
			sx = tmp[6];
			sy = tmp[7];
			sz = tmp[8];
		}

		
	}
}