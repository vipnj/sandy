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
* Vertex of a 3D mesh.
* 
* <p>A vertex is a point which can be represented in differents coordinates. 
* 	It leads to some extra properties specific to the vertex</p>
* 
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @since		0.1
* @version		0.3
* @date 		27.03.2006
*/
class sandy.core.data.Vertex extends Vector
{
	/**
	* properties used to store transformed coordinates in the local frame of the object
	*/
	public var tx:Number;
	public var ty:Number;
	public var tz:Number;
	
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

	/**
	* Create a new {@code Vertex} Instance.
	* If no
	* @param px the x position number
	* @param py the y position number
	* @param pz the z position number
	* @param ptx [optional] the transformed x position number. If no value, px value is set.
	* @param pty [optional] the transformed y position number. If no value, py value is set.
	* @param ptz [optional] the transformed z position number. If no value, pz value is set.
	* 
	*/
	public function Vertex(px:Number, py:Number,pz:Number, ptx:Number, pty:Number, ptz:Number)
	{
		super(px,py,pz);
		// --
		tx = (undefined == ptx) ? px : ptx; 
		ty = (undefined == pty) ? py : pty; 
		tz = (undefined == ptz) ? pz : ptz; 
		// -- 
		wx = tx; 
		wy = ty; 
		wz = tz;
		// --
		sy = sx = 0;
	}

	/**
	* Returns a vector representing the vertex in the transformed coordinate system
	* @param	Void
	* @return	Vector	a Vector
	*/
	public function getTransformVector( Void ):Vector
	{
		return new Vector( tx, ty, tz );
	}
	
	/**
	* Returns a vector representing the vertex in the world coordinate
	* @param	Void
	* @return	Vector	a Vector
	*/
	public function getWorldVector( Void ):Vector
	{
		return new Vector( wx, wy, wz );
	}
	
	/**
	* Get a String represntation of the {@code Vertex}.
	* 
	* @return	A String representing the {@code Vertex}.
	*/
	public function toString( Void ):String
	{
		return "Vertex : x:"+x+" y:"+y+" z:"+z+"\ntx:"+tx+" ty:"+ty+" tz:"+tz+"\nwx:"+wx+" wy:"+wy+" wz:"+wz+" \nsx:"+sx+" sy:"+sy;
	}
}

