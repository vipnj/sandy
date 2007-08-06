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
	import sandy.bounds.BBox;
	import sandy.bounds.BSphere;
	import sandy.core.data.Matrix4;
	import sandy.events.BubbleEventBroadcaster;
	import sandy.view.CullingState;
	import sandy.view.Frustum;
	
	/**
	 * ABSTRACT CLASS - Base class for all nodes in the object tree.
	 * 
	 * <p>Node is the base class for all Group and object nodes, 
	 * and handles all basic operations on a tree node.</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		16.03.2007
	 **/
	public class Node
	{
		// This property set the cache status of the current node.
		public var changed:Boolean;
		// This property represent the culling state of the current node
		public var culled:CullingState;
		
		protected var m_oEB:BubbleEventBroadcaster;

		// The class should not be instatiated, but AS3 doesn't allow private constructors
		
		/**
		 * Creates a node in the object tree of the world.
		 *
		 * <p>This constructor should normally not be called directly - only via its sub classes.</p>
		 *
		 * @param p_sName	A string identifier for this object.
		 */	
		public function Node( p_sName:String = "" ) 
		{
			parent = null;
			_aChilds = [];
			_id = Node._ID_++;
			// --
			if(p_sName)		name = p_sName;
			else         	name = String( _id.toString() );
			changed = true;
			_visible = true;
			_oBBox = new BBox();
			_oBSphere = new BSphere();
			m_oEB = new BubbleEventBroadcaster();
			// -- 
			_oModelCacheMatrix = new Matrix4();
			_oViewCacheMatrix = new Matrix4();
			//
			culled = CullingState.INSIDE;
		}
		
		/**
		 * Access to the broadcaster property.
		 * The broadcaster is the property used to send events to listeners.
		 * This property is a {@BubbleEventBroadcaster} intance.
		 * 
		 * @return The instance of the current node broadcaster.
		 */	
		public function get broadcaster():BubbleEventBroadcaster
		{
			return m_oEB;
		}
		
		/**
		 * Adds listener for specifical event.
		 * 
		 * @param t Name of the Event.
		 * @param oL Listener object.
		 */
		public function addEventListener(e:String, oL:*) : void
		{
			m_oEB.addEventListener.apply(m_oEB, arguments);
		}
		
		/**
		 * Removes listener for specifical event.
		 * 
		 * @param t Name of the Event.
		 * @param oL Listener object.
		 */
		public function removeEventListener(e:String, oL:*) : void
		{
			m_oEB.removeEventListener(e, oL);
		}
	
		// This is a FINAL method, IT CAN NOT BE OVERLOADED.  
		/**
		 * The unique id of this node in the node graph.
		 *
		 * <p>This value is very useful to retrieve a specific Node.</p>
		 */
		final public function get id():Number
		{
			return _id;
		}
			
		/**
		 * Tests if the node passed in the argument is parent of this node.
		 *
		 * @param p_oNode 	The Node you are testing
		 * @return		true if the node in the argument is the parent of this node, false otherwise.
		 */
		public function isParent( p_oNode:Node ):Boolean
		{
			return (_parent == p_oNode && p_oNode != null);
		}
		
		/**
		 * @private
		 */
		public function set parent( p_oNode:Node ):void
		{
			if( p_oNode )
			{
				_parent = p_oNode;
				changed = true;
			}
		}
		
		/**
		 * The parent node of this node.
		 *
		 * <p>The reference is null this nod has no parent (for exemple for a root node).</p>
		 */
		public function get parent():Node
		{
			return _parent;
		}
		
		/**
		 * Tests if this node has a parent.
		 * 
		 * @return 	true if this node has a parent, false otherwise.
		 */
		public function hasParent():Boolean
		{
			return ( _parent != null );
		}	
		
		/**
		 * Adds a new child to this node.
		 *
		 * <p>A node can have several children, and when you add a child to a node, 
		 * it is automatically connected to it's parent through its parent property.</p>
		 *
		 * @param p_oChild	The child node to add
		 */
		public function addChild( p_oChild:Node ):void 
		{
			p_oChild.parent = this;
			changed =  true ;
			_aChilds.push( p_oChild );
			m_oEB.addChild( p_oChild.broadcaster );
		}	
		
		/**
		 * Returns an array with all child nodes of this node.
		 * 
		 * @return 	The array of childs nodes
		 */
		public function getChildList():Array
		{
			return _aChilds;
		}

		/**
		 * The child nodes array of this node
		 */	
		public function get children():Array
		{
			return _aChilds;
		}
		
		/**
		 * Returns the child node with the specified id.
		 *
		 * <p>[<b>Todo</b>: Explain the rational of the recursive variant ]</p>
		 * 
		 * @param p_nId 		The id of the child you want to retrieve
		 * @param p_bRecurs 	Set to true if you want to get the child tree
		 *
		 * @return 		The requested node or null if no child with this is was found
		 */
		public function getChildFromId( p_nId:Number, p_bRecurs:Boolean=false ):Node 
		{
			var l_oNode:Node, l_oNode2:Node;
			for each( l_oNode in _aChilds )
			{
				if( l_oNode.id == p_nId )
				{
					return l_oNode;
				}
			}
			if( p_bRecurs )
			{
				for each( l_oNode in _aChilds )
				{
					l_oNode2 = l_oNode.getChildFromId( p_nId, p_bRecurs );
					if( l_oNode2 != null ) return l_oNode2;
				}
			}
			return null;
		}
	
		/**
		 * Returns the child node with the specified name.
		 *
		 * @param p_sName	The name of the child you want to retrieve
		 * @param p_bRecurs 	Set to true if you want to get the child tree
		 *
		 * @return		The requested node or null if no child with this name was found
		 */
		public function getChildByName( p_sName:String, p_bRecurs:Boolean=false ):Node 
		{
			var l_oNode:Node, l_oNode2:Node;
			for each( l_oNode in _aChilds )
			{
				if( l_oNode.name == p_sName )
				{
					return l_oNode;
				}
			}
			if( p_bRecurs )
			{
				var node:Node = null;
				for each( l_oNode in _aChilds )
				{
					node = l_oNode.getChildByName( p_sName, p_bRecurs );
					if( node != null ) return node;
				}
			}
			return null;
		}
	
		
		/**
		 * Removes the child node with the specified id. 
		 * 
		 * 
		 * <p>All the children of the node you want to remove are lost.<br/>
		 * The link between them and the rest of the tree is broken, and they will not be rendered anymore!</p>
		 * <p>The object itself and its children are still in memory! <br/>
		 * If you want to free them completely, call child.destroy()</p>
		 * 
		 * @param p_nId 	The id of the child you want to remove
		 * @return 		true if the node was removed from node tree, false otherwise.
		 */
		public function removeChildById( p_nId:Number ):Boolean 
		{
			var found:Boolean = false;
			var i:int, l:int = _aChilds.length;
	
			while( i < l && !found )
		    {
				if( _aChilds[int(i)].id == p_nId  )
				{
					broadcaster.removeChild( _aChilds[int(i)].broadcaster);
					_aChilds.splice( i, 1 );
					changed = true;
					found = true;
				}
				i++;
			}
			return found;
		}
		
		/**
		 * Moves this node to another parent node.
		 *
		 * <p>This node is removed from its current parent node, and added as a child of the passed node</p>
		 *
		 * @param p_oNewParent	The node to become parent of this node
		 */
		public function swapParent( p_oNewParent:Node ):void
		{
			if( parent.removeChildById( this.id ) );
				p_oNewParent.addChild( this );
		}
		
		/**
		 * Removes the child nodes with the pecified name.
		 *
		 * <p>All the children of the node you want to remove are lost.<br/>
		 * The link between them and the rest of the tree is broken, and they will not be rendered anymore!</p>
		 * <p>The object itself and its children are still in memory!<br/>
		 * If you want to free them completely, call child.destroy()</p>
		 * 
		 * @param p_sName	The name of the node you want to remove.
		 * @return 		true if the node was removed from node tree, false otherwise.
		 */
		public function removeChildByName( p_sName:String ):Boolean 
		{
			var found:Boolean = false;
			var i:int;
			var l:int = _aChilds.length;
			while( i < l && !found )
			{
				if( _aChilds[int(i)].name == p_sName  )
				{
					broadcaster.removeChild( _aChilds[int(i)].broadcaster );
					_aChilds.splice( i, 1 );
					changed = true;
					found = true;
				}
				i++;
			}
			
			return found;
		}
	
	
		/**
		 * Delete all the child nodes of this node.
		 *
		 * <p>All children of this node are deleted, including all data they are storing.<br/>
		 * The method makes recursive calls to the destroy method of the child nodes.
		 */
		public function destroy():void 
		{			
			// should we kill all the childs, or just make them childs of current node parent ?
			var l:int = _aChilds.length;
			while( --l > -1 )
			{
				_aChilds[int(l)].destroy();
				_aChilds[int(l)] = null;	
			}
			_aChilds = null;
			m_oEB = null;
			
			// the unlink this node to his parent
			if( hasParent() == true ) parent.removeChildById( this._id );
		}
	
		/**
		 * Removes this node from the node tree.
		 * 
		 * <p>The child nodes of this node becomes child nodes of this node's parent.</p>
		 */
		public function remove() :void 
		{
			var l:int = _aChilds.length;
			// first we remove this node as a child of its parent
			// we do not update rigth now, but a little bit later ;)
			parent.removeChildById( this.id );
			// now we make current node children the current parent's node children
			while( --l > -1 )
			{
				parent.addChild( _aChilds[int(l)] );
			}
			_aChilds = null;
			m_oEB = null;
			changed = true;
		}
	
		/**
		 * @private
		 */
		public function set visible( b:Boolean ):void
		{
			_visible = b;
			changed = true;
		}
		/**
		 * Visibility of this node ( associated object ).
		 *
		 * <p>A true value ( the default ) means that the object is visible<br/>
		 * false that it is hidden</p>
		 */	
		public function get visible():Boolean
		{
			return _visible;
		}
			
	
		/**
		 * Updates this node. 
		 * 
		 * <p>For a node with transformation, this method must update the transformation taking into account the matrix cache system.</p>
		 *
		 * <p>[<b>ToDo</b> : Explain the parameters and what the do ]</p>
		 * @param p_oModelMatrix
		 * @param p_bChanged
		 */
		public function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			/* Shall be overriden */
			changed = changed || p_bChanged;
			var l_oNode:Node;
			for each( l_oNode in _aChilds )
				l_oNode.update( p_oModelMatrix, changed );
		}
	
		
		/**
		 * Tests this node against the frustum volume to get its visibility.
		 *
		 * <p>If the node and its children aren't in the frustum, the node is set to cull
		 * and will not be displayed.<br/>
		 * <p>The method also updates the bounding volumes to make a more accurate culling system possible.<br/>
		 * First the bounding sphere is updated, and if intersecting, the bounding box is updated to perform a more
		 * precise culling.</p>
		 * <p><b>[MANDATORY] The update method must be called first!</b></p>
		 *
		 * @param p_oFrustum	The frustum of the current camera
		 * @param p_oViewMatrix	<b>[ToDo: explain]</b>
		 * @param p_bChanged	<b>[ToDo: explain]</b>
		 *
		 */
		public function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			if( _visible == false )
			{
				culled = CullingState.OUTSIDE;
			}
			else
			{
				if( p_bChanged || changed )
				{
					_oViewCacheMatrix.copy( p_oViewMatrix );
					_oViewCacheMatrix.multiply4x3( _oModelCacheMatrix );
				}
			}
		}
		/**
		 * Renders this node.
		 *
		 * <p>Implemented in sub classes</p>
		 *
		 * @param  p_oCamera	The camera of the world
		 */
		public function render( p_oCamera:Camera3D ):void
		{
			;/* TO OVERRIDE */
		}
	
		/**
		 * Returns the bounding box of this object - [ minimum  value; maximum  value].
		 * 
		 * @return 	An array containing the minimum and maximum values of the object in world coordinates.
		 */
		public function getBBox():BBox
		{
			return _oBBox;
		}
	
		/**
		 * Returns the bounding sphere of this object - [ minimum  value; maximum  value].
		 *
		 * @return  The bounding sphere
		 */
		public function getBSphere():BSphere
		{
			return _oBSphere;
		}


		public function toString():String
		{
			return "sandy.core.scenegraph.Node";
		}
			
		////////////////////
		//// PRIVATE PART
		////////////////////
			    		
		private static var _ID_:Number = 0;
		private var _id:Number;
		private var _parent:Node;
		private var _visible : Boolean;	
		public 	var name:String;
		protected var _aChilds:Array;
		// Cached matrix corresponding to the transformation to the 0,0,0 frame system
		protected var _oModelCacheMatrix:Matrix4;
		// Cached matrix corresponding to the transformation to the camera frame system
		protected var _oViewCacheMatrix:Matrix4;
		protected var _oBBox:BBox;
		protected var _oBSphere:BSphere;
	}
}