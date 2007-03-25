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
* @since		0.1
* @version		1.0
* @date 		15/12/2006
*/
class sandy.core.data.Vertex extends Vector
{
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
	* Create a new {@code Vertex} Instance.
	* If no
	* @param px the x position number
	* @param py the y position number
	* @param pz the z position number
	* 
	*/
	public function Vertex(px:Number, py:Number,pz:Number)
	{
		super(px,py,pz);
		// -- 
		wx = px; 
		wy = py; 
		wz = pz;
		// --
		sy = sx = sz = 0;
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
		return "Vertex : x:"+x+" y:"+y+" z:"+z+"\nwx:"+wx+" wy:"+wy+" wz:"+wz+"\nsx:"+sx+" sy:"+sy;
	}
}

