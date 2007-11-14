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

import sandy.core.group.Node;
import sandy.core.group.INode;

/**
 * Class implementing the Abstract class Node.
 * It's the basic class for all the classes used to represent the Groups in Sandy.
 * It is used as a node in the tree scene structure in Sandy, a node without associated transformation in oposition of TransfromGroup.
 * @author		Thomas Pfeiffer - kiroukou
 * @version		1.0
 * @date 		28.03.2006
 **/
class sandy.core.group.Group extends Node implements INode
{
	/**
	* Constructor of Group class.
	* Group is a concrete node object, and it represents a structure of object.
	* 
	* @param	parent
	*/
	public function Group() 
	{
		super();
	}	
	
	public function render( Void ):Void
	{
		;
	}
	public function dispose( Void ):Void
	{
		;
	}
}