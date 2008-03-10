///////////////////////////////////////////////////////////
//  INode.as
//  Macromedia ActionScript Implementation of the Interface INode
//  Generated by Enterprise Architect
//  Created on:      27-VII-2006 14:39:01
//  Original author: Thomas Pfeiffer - kiroukou
///////////////////////////////////////////////////////////
package sandy.core.group
{
	/**
	 * @created 27-VII-2006 12:46:48
	 * @author 	Thomas Pfeiffer - kiroukou
	 * @version 1.0
	 * @date 	05.08.2006
	 */
	public interface INode
	{
		/**
		* Retuns the unique ID Number that represents the node.
		* This value is very usefull to retrieve a specific Node.
		* This method is FINAL, IT MUST NOT BE OVERLOADED.
		* @param	Void
		* @return	Number the node ID.
		*/
		function getId():uint;
		
		/**
		* Say is the node is the parent of the current node.
		* @param	n The Node you are going to test the patternity
		* @return Boolean  True is the node in argument if the father of the current one, false otherwise.
		*/
		function isParent( n:Node ):Boolean;
		
		/**
		* Allows you to know if this node has been modified (true value) or not (false value). 
		* Mainly usefull for the cache system.
		* @return	Boolean Value specifying the statut of the node. A true value means the node has been modified, it it should be rendered again
		*/
		function isModified():Boolean;
	
		/**
		* Allows you to set the modified property of the node.
		* @param b Boolean true means the node is modified, and false the opposite.
		*/
		function setModified( b:Boolean ):void;
		
		/**
		* Set the parent of a node
		* @param	Void
		* @return	Boolean false is nothing has been done, true if the operation succeded
		*/
		function setParent( n:Node ):Boolean;
		
		/**
		* Returns the parent node reference
		* @param	Void
		* @return Node The parent node reference, which is null if no parents (for exemple for a root object).
		*/
		function getParent():Node;
		
		/**
		* Allows the user to know if the current node have a parent or not.
		* @param	Void
		* @return Boolean. True is the node has a parent, False otherwise
		*/
		function hasParent():Boolean;	
		
		/**
		* Add a new child to this group. a basicGroup can have several childs, and when you add a child to a group, 
		* the child is automatically conencted to it's parent thanks to its parent property.
		* @param	child
		*/
		function addChild( child:Node ):void;	
		
		/**
		 * Returns all the childs of the current group in an array
		 * @param Void
		 * @return Array The array containing all the childs node of this group
		 */
		function getChildList ():Array;
		
		/**
		* Returns the child node at the specific index.
		* @param	index Number The ID of the child you want to get
		* @return 	Node The desired Node
		*/
		function getChild( index:uint ):Node;
	
		/**
		* Remove the child given in arguments. Returns true if the node has been removed, and false otherwise.
		* All the children of the node you want to remove are lost. The link between them and the rest of the tree is broken.
		* They will not be rendered anymore!
		* But the object itself and his children are still in memory! If you want to free them completely, use child.destroy();
		* @param	child Node The node you want to remove.
		* @return Boolean True if the node has been removed from the list, false otherwise.
		*/
		function removeChild( child:Node ):Boolean;
	
		/**
		 * Delete all the childs of this node, and also the datas it is actually storing.
		 * Do a recurssive call to child's destroy method.
		 */
		function destroy():void;
	
		/**
		 * Remove the current node on the tree.
		 * It makes current node children the children of the current parent node.
		 * The interest of this paramater is that it allows you to update the World3D only once during your destroy/remove call!
		 */
		function remove():void ;
		
		/**
		 * Method corresponding to the render call that will be followed by the dispose methode
		 */ 
		function render():void;
		
		/**
		 * Method called after the render call. Should free everything use in the render
		 */ 
		function dispose():void;

	}//end INode

}