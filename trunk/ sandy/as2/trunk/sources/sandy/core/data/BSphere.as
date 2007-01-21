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

import sandy.core.Object3D;
import sandy.math.VectorMath;
import sandy.core.data.Vector;

/**
* Bounding Sphere object used to clip the object faster.
* 
* <p>Create a bounding Sphere that contains the whole object</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @since		0.3
* @version		0.1
* @date 		22.02.2006
*/
class sandy.core.data.BSphere
{
	public var center:Vector;
	public var radius:Number;
	public var owner:Object3D;
	
	/**
	 * Create a BSphere object, representing a Bounding Sphere volume englobing the 3D object passed in parameters.
	 * Verry usefull for clipping and so performance !
	 * @param obj Object3D The object that you want to add a bounding Sphere volume.
	 */
	public static function create( obj:Object3D ):BSphere
	{
		// we say that the object is centered in 0,0,0 to simplify the computations. But this should be optimize later
		var max:Number = -1;
		var a:Array = obj.aPoints;
		var l:Number = a.length;
		while( --l > -1 )
		{
			// --
			if( VectorMath.getNorm( a[l] ) > max )	max =  VectorMath.getNorm( a[l] );
		}
		return new BSphere( obj, new Vector(), max );
	}
	
	/**
	* <p>Create a new {@code BSphere} Instance</p>
	* 
	* @param	pos	The center of the sphere
	* @param	radius	THe radius of the Sphere
	*/ 	
	public function BSphere( obj:Object3D, ppos:Vector, pradius:Number )
	{
		owner	= obj;
		center 	= ppos; 
		radius 	= pradius || 0; 
	}
	
	/**
	* Get a String represntation of the {@code BSphere}.
	* 
	* @return	A String representing the Bounding Sphere
	*/ 	
	public function toString(Void):String
	{
		return "Bounding Sphere \ncenter : "+center+"\nradius : "+radius;
	}
}

