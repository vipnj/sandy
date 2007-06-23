import com.bourre.log.PixlibStringifier;
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
class sandy.core.data.Vector
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
	public function Vector(px:Number, py:Number, pz:Number)
	{
		x = px||0;
		y = py||0;
		z = pz||0;
	}
	
	
	public function clone():Vector
	{
	    var l_oV:Vector = new Vector( x, y, z );
	    return l_oV;
	}
	
	public function copy( p_oVector:Vector ):Void
	{
		x = p_oVector.x;
		y = p_oVector.y;
		z = p_oVector.z;
	}
	
	/**
	* Get a String represntation of the {@code Vector}.
	* 
	* @return	A String representing the {@code Vector}.
	*/ 	
	public function toString(decPlaces:Number):String
	{
		//return "sandy.core.data.Vector" + "("+x+","+y+","+z+ ")\n"+PixlibStringifier.stringify( this );;

		if (decPlaces == undefined) {
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
	public function serialize(decPlaces:Number):String
	{
		if (decPlaces == undefined) {
			decPlaces = .01;
		}
		//returns x,y,x
		return  (NumberUtil.roundTo(x, decPlaces) + "," + 
				 NumberUtil.roundTo(y, decPlaces) + "," + 
				 NumberUtil.roundTo(z, decPlaces));
	}
	
	// Useful for XML output
	public static function deserialize(convertFrom:String):Vector
	{
		var tmp:Array = convertFrom.split(",");
		if (tmp.length != 3) {
			trace ("Unexpected length of string to deserialize into a vector " + convertFrom);
		}
		return  new Vector (tmp[0], tmp[1], tmp[2]);
	}
}
