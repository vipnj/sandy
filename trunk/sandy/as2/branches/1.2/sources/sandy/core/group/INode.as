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
/**
 * @author		Thomas Pfeiffer - kiroukou
 * @version		1.0
 * @date 		16.05.2006
 **/
interface sandy.core.group.INode
{

	/**
	* Retuns the unique ID Number that represents the node.
	* This value is very usefull to retrieve a specific Node.
	* This method is FINAL, IT MUST NOT BE OVERLOADED.
	* @param	Void
	* @return	Number the node ID.
	*/
	public function getId( Void ):Number;
	
	/**
	* Say is the node is the parent of the current node.
	* @param	n The Node you are going to test the patternity
	* @return Boolean  True is the node in argument if the father of the current one, false otherwise.
	*/
	public function isParent( n:Node ):Boolean;
	
	/**
	* Allows you to know if this node has been modified (true value) or not (false value). 
	* Mainly usefull for the cache system.
	* @return	Boolean Value specifying the statut of the node. A true value means the node has been modified, it it should be rendered again
	*/
	public function isModified( Void ):Boolean;

	/**
	* Allows you to set the modified property of the node.
	* @param b Boolean true means the node is modified, and false the opposite.
	*/
	public function setModified( b:Boolean ):Void;
	
	/**
	* Set the parent of a node
	* @param	Void
	* @return	Boolean false is nothing has been done, true if the operation succeded
	*/
	public function setParent( n:Node ):Boolean;
	
	/**
	* Returns the parent node reference
	* @param	Void
	* @return Node The parent node reference, which is null if no parents (for exemple for a root object).
	*/
	public function getParent( Void ):Node;
	
	/**
	* Allows the user to know if the current node have a parent or not.
	* @param	Void
	* @return Boolean. True is the node has a parent, False otherwise
	*/
	public function hasParent( Void ):Boolean;	
	
	/**
	* Add a new child to this group. a basicGroup can have several childs, and when you add a child to a group, 
	* the child is automatically conencted to it's parent thanks to its parent property.
	* @param	child
	*/
	public function addChild( child:Node ): Void;	
	
	/**
	 * Returns all the childs of the current group in an array
	 * @param Void
	 * @return Array The array containing all the childs node of this group
	 */
	public function getChildList ( Void ):Array;
	
	public function getChildByName( pName:String ):Node;
	/**
	* Returns the child node at the specific index.
	* @param	index Number The ID of the child you want to get
	* @return 	Node The desired Node
	*/
	public function getChild( index:Number ):Node;

	/**
	* Remove the child given in arguments. Returns true if the node has been removed, and false otherwise.
	* All the children of the node you want to remove are lost. The link between them and the rest of the tree is broken.
	* They will not be rendered anymore!
	* But the object itself and his children are still in memory! If you want to free them completely, use child.destroy();
	* @param	child Node The node you want to remove.
	* @return Boolean True if the node has been removed from the list, false otherwise.
	*/
	public function removeChildById( id:Number ):Boolean;

	public function removeChildByName( pName:String ):Boolean;
	
	/**
	 * Delete all the childs of this node, and also the datas it is actually storing.
	 * Do a recurssive call to child's destroy method.
	 */
	public function destroy( Void ) : Void;

	/**
	 * Remove the current node on the tree.
	 * It makes current node children the children of the current parent node.
	 * The interest of this paramater is that it allows you to update the World3D only once during your destroy/remove call!
	 */
	public function remove( Void ) : Void ;
	
	public function render( Void ):Void;
	public function dispose( Void ):Void;
}
