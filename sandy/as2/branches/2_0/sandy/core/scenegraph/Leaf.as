
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
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Node;


/**
* <p>Abstract class used to represent the Leaf of the Sandy's scene tree.
* This class should not be used directly, except for typing purpose.
* This class is basically the same as the Node one, except that your can't add/remove some children </p>
 * @author		Thomas Pfeiffer - kiroukou
 * @version		1.0
 * @date 		16.05.2006
 **/
class sandy.core.scenegraph.Leaf extends Node
{
	
	public function Leaf( p_sName:String ) 
	{
		super( p_sName );
	}

	/**
	 * Do nothing since a leaf is the lower part of a tree. It cannot have a child.
	 * @param n Node The Node to set as a child of the current node. But it will not be done !
	 * @return
	 */
	public function addChild ( child:Node ):Void
	{
		;// nothing here
	}
		
	/**
	 * Returns a null value because a Laef doesn't have a child.
	 * @param void
	 * @return Array a null value
	 */
	public function getChildList():Array
	{
		return null;
	}

	/**
	* Does nothing since a Leaf doesn't have some children. Return false.
	* @param	child Node The node you want to remove.
	* @return Boolean Return everytime false value;
	*/
	public function removeChildById( pId:Number ):Boolean 
	{
		return false;
	}
	
	public function removeChildByName( pName:String ):Boolean 
	{
		return false;
	}		
}
