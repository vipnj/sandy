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

package sandy.core.scenegraph 
{
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;

	/**
	 * ABSTRACT CLASS
	 * <p>
	 * This class is the basis of all the group and Leaf one.
	 * It allows all the basic operations you might want to do about trees node.
	 * </p>
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		1.0
	 * @date 		16.05.2006
	 **/
	public class Node extends EventDispatcher
	{
		/**
		* Retuns the unique ID Number that represents the node.
		* This value is very usefull to retrieve a specific Node.
		* This method is FINAL, IT MUST NOT BE OVERLOADED.
		* @param	void
		* @return	Number the node ID.
		*/
		public function getId():int
		{
			return _id;
		}
			
		/**
		* Say is the node is the parent of the current node.
		* @param	n The Node you are going to test the patternity
		* @return Boolean  True is the node in argument if the father of the current one, false otherwise.
		*/
		public function isParent( n:INode ):Boolean
		{
			return (_parent == n && n != null);
		}
		
		/**
		* Allows you to know if this node has been modified (true value) or not (false value). 
		* Mainly usefull for the cache system.
		* @return	Boolean Value specifying the statut of the node. A true value means the node has been modified, it it should be rendered again
		*/
		public function isModified():Boolean
		{
			return _modified
		}

		/**
		* Allows you to set the modified property of the node.
		* @param b Boolean true means the node is modified, and false the opposite.
		*/
		public function setModified( b:Boolean ):void
		{
			_modified = b;
		}
		
		/**
		* Set the parent of a node
		* @param	void
		* @return	Boolean false is nothing has been done, true if the operation succeded
		*/
		public function setParent( n:INode ):Boolean
		{
			if( n )
			{
				_parent = n;
				setModified( true );
				return true;
			}
			else
			{
				return false;
			}
		}
		
		/**
		* Returns the parent node reference
		* @param	void
		* @return Node The parent node reference, which is null if no parents (for exemple for a root object).
		*/
		public function getParent():INode
		{
			return _parent;
		}
		
		/**
		* Allows the user to know if the current node have a parent or not.
		* @param	void
		* @return Boolean. True is the node has a parent, False otherwise
		*/
		public function hasParent():Boolean
		{
			return _parent || false;
		}	
		
		/**
		* Add a new child to this group. a basicGroup can have several childs, and when you add a child to a group, 
		* the child is automatically conencted to it's parent thanks to its parent property.
		* @param	child
		*/
		public function addChild( child:INode ):void 
		{
			child.setParent( INode(this) );
			setModified( true );
			_aChilds.push( child );
		}	
		
		/**
		 * Returns all the childs of the current group in an array
		 * @param void
		 * @return Array The array containing all the childs node of this group
		 */
		public function getChildList ():Array
		{
			return _aChilds;
		}
		
		/**
		* Returns the child node at the specific index.
		* @param	index Number The ID of the child you want to get
		* @return 	Node The desired Node
		*/
		public function getChild( index:int ):INode 
		{
			return _aChilds[ index ];
		}

				/**
		* Returns the child node with the specified ID
		* @param	index Number The ID of the child you want to get
		* @return 	Node The desired Node or null is no child with this ID has been found
		*/
		public function getChildFromId( id:int ):INode 
		{
			var l:int = _aChilds.length;
			while( -- l > -1 )
			{
				if( Node(_aChilds[int(l)]).getId() == id )
				{
					return _aChilds[int(l)];
				}
			}
			return null;
		}

		/**
		* Returns the child node with the specified name
		* @param	index Number The name of the child you want to get
		* @return 	Node The desired Node or null is no child with this name has been found
		*/
		public function getChildByName( pName:String ):INode 
		{
			var l:int = _aChilds.length;
			while( -- l > -1 )
			{
				if( Node(_aChilds[int(l)]).name == pName )
				{
					return _aChilds[int(l)];
				}
			}
			return null;
		}

		
		/**
		* Remove the child given in arguments. Returns true if the node has been removed, and false otherwise.
		* All the children of the node you want to remove are lost. The link between them and the rest of the tree is broken.
		* They will not be rendered anymore!
		* But the object itself and his children are still in memory! If you want to free them completely, use child.destroy();
		* @param	child Node The node you want to remove.
		* @return Boolean True if the node has been removed from the list, false otherwise.
		*/
		public function removeChild( pId:int ):Boolean 
		{
			var found:Boolean = false;
			var i:int, l:int = _aChilds.length;
			if( pId > 0 && pId < l )
			{
				for( i = 0; i < l && !found; i++ )
			    {
    				if( _aChilds[int(i)].getId() == pId  )
    				{
    					_aChilds.splice( pId, 1 );
    					setModified( true );
    					found = true;
    				}
    			}
			}
			
			return found;
		}
		
		/**
		* Remove the child given in arguments. Returns true if the node has been removed, and false otherwise.
		* All the children of the node you want to remove are lost. The link between them and the rest of the tree is broken.
		* They will not be rendered anymore!
		* But the object itself and his children are still in memory! If you want to free them completely, use child.destroy();
		* @param	child Node The name of the node you want to remove.
		* @return Boolean True if the node has been removed from the list, false otherwise.
		*/
		public function removeChildByName( pName:String):Boolean 
		{
			var found:Boolean = false;
			var i:int;
			var l:int = _aChilds.length;
			for( i = 0; i < l && !found; i++ )
			{
				if( _aChilds[int(i)].name == pName  )
				{
					_aChilds.splice( i, 1 );
					setModified( true );
					found = true;
				}
			}
			
			return found;
		}
		


		/**
		 * Delete all the childs of this node, and also the datas it is actually storing.
		 * Do a recurssive call to child's destroy method.
		 */
		public function destroy() : void 
		{
			// the unlink this node to his parent
			if( hasParent() == true ) _parent.removeChild( this._id );
			
			// should we kill all the childs, or just make them childs of current node parent ?
			var l:int = _aChilds.length;
			while( --l > -1 )
			{
				_aChilds[int(l)].destroy();
				_aChilds[int(l)] = null;	
			}
			_aChilds = null;
			_parent = null;
		}

		/**
		 * Remove the current node on the tree.
		 * It makes current node children the children of the current parent node.
		 * The interest of this paramater is that it allows you to update the World3D only once during your destroy/remove call!
		 */
		public function remove() : void 
		{
			var l:int = _aChilds.length;
			// first we remove this node as a child of its parent
			// we do not update rigth now, but a little bit later ;)
			_parent.removeChild( this.getId() );
			// now we make current node children the current parent's node children
			while( --l > -1 )
			{
				_parent.addChild( _aChilds[int(l)]);
			}
			_aChilds = null;
			_parent = null;
			setModified( true );
		}
	
		
		override public function toString():String
		{
			return getQualifiedClassName(this);
		}
		
		////////////////////
		//// PRIVATE PART
		////////////////////
		
		// TODO: private function in original implementation
		public function Node() 
		{
			super( this );
			_parent = null;
			_aChilds = [];
			_id = Node._ID_++;
			name = String( _id );
			setModified( true );
			// -- 
		}
		
		internal static var _ID_:Number = 0;
		protected var _aChilds:Array;
		private var _id:Number;
		protected var _parent:INode;
		protected var _modified:Boolean;
		public var name:String;
	}
}