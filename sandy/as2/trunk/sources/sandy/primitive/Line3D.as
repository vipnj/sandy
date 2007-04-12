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
import sandy.core.data.Vertex;
import sandy.core.Object3D;
import sandy.core.face.Polygon;
import sandy.primitive.Primitive3D;
import sandy.skin.SimpleLineSkin;


/**
* Line3D
* <p>Line3D, or how to create a simple line in Sandy</p>
* 
* @author		Thomas Pfeiffer - kiroukou
* @author		Bruce Epstein 	- zesuprod
* @since		1.0
* @version		1.2.1
* @date 		12.04.2007 
**/
class sandy.primitive.Line3D extends Object3D implements Primitive3D
{
	/**
	* Constructor
	*
	* <p>This is the constructor to call when you nedd to create a Line3D primitiv.</p>
	*
	* <p>This method will create a complete object with vertex,
	*    and the faces.</p>
	*
	* @param As many parameters as needed points can be passed. However a minimum of 2 vector instance must be given.
	*/
	public function Line3D ( deb:Vector, fin:Vector )
	{
		super ();
		
		if( arguments.length < 2 )
		{
			trace('Line3D::Number of arguments to low');
		}
		else
		{
			for( var i:Number = 0; i < arguments.length; i++ )
			{
				aPoints.push ( new Vertex( arguments[i].x, arguments[i].y, arguments[i].z ) );
			}
			generate ();
		}
	}
	
	/**
	* generate
	* 
	* <p>Generate all is needed to construct the Line3D : </p>
	*/
	public function generate ( Void ) : Void
	{
		// initialisation
		aFaces = [];
		var l:Number = aPoints.length;
		for( var i:Number = 0; i < l-1; i++ )
		{
			addFace( new Polygon( this, aPoints[i], aPoints[i+1] ) );
		}
	}
	
	/**
	* Set a Skin to the Line3D.
	* <p>This method will set the a new skin to the line, but the skin must be a SimpleLineSkin instance.</p>
	* @param	SimpleLineSkin s	The new SimpleLineSkin skin
	* @param	bOverWrite	Boolean, overwrite or not all specific Faces's Skin
	* @return	Boolean True to apply the skin to the non default faces skins , false otherwise (default).
	*/
	public function setSkin( s:SimpleLineSkin, bOverWrite:Boolean ):Boolean
	{
		bOverWrite = (bOverWrite == undefined ) ? false : bOverWrite;
		super.setSkin( s, bOverWrite );
		return true;
	}
	
	/**
	 * The setBackSkin is disabled for this object since it does not have a particular depth.
	 */
	public function setBackSkin( s:SimpleLineSkin, bOverWrite:Boolean):Boolean
	{
		return false;	
	}
	
	/**
	* getPrimitiveName() returns the string "Line3D"
	*/	
	 public function getPrimitiveName (Void):String {
		 return "Line3D";
	 }
	 
	 public function toString (Void):String {
		 return "sandy.primitive." + getPrimitiveName();
	 }

	public function getVertexList(Void):Array
	{  
		return aPoints;
	}
	
	
	/**
	* getSize() returns the number of vertices in a Line3D element.
	* Returns vector where x, y, and z are all equal to the number of vertices in the line
	*/	
	public function getSize (Void):Vector {
		return new Vector (aPoints.length, aPoints.length, aPoints.length);
	}
	

}
