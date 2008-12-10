﻿/*# ***** BEGIN LICENSE BLOCK *****Copyright the original author or authors.Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");you may not use this file except in compliance with the License.You may obtain a copy of the License at	http://www.mozilla.org/MPL/MPL-1.1.htmlUnless required by applicable law or agreed to in writing, softwaredistributed under the License is distributed on an "AS IS" BASIS,WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.See the License for the specific language governing permissions andlimitations under the License.# ***** END LICENSE BLOCK ******/package sandy.core.scenegraph{	import sandy.bounds.BBox;	import sandy.bounds.BSphere;	import sandy.core.Scene3D;	import sandy.core.data.Matrix4;	import sandy.events.BubbleEventBroadcaster;	import sandy.materials.Appearance;	import sandy.view.CullingState;	import sandy.view.Frustum;	/**	 * ABSTRACT CLASS - Base class for all nodes in the object tree.	 *	 * <p>The base class for all Group and object nodes,	 * that handles all basic operations on a tree node.</p>	 *	 * @author		Thomas Pfeiffer - kiroukou	 * @version		3.0	 * @date 		16.03.2007	 **/	public class Node	{		/**		 * This property represent the culling state of the current node.		 * This state is defined during the culling phasis as it refers to the position of the object against the viewing frustum.		 */		public var culled:CullingState = CullingState.OUTSIDE;		/**		 * Name of this node.		 * If no name is specified, the unique ID of the node will be used		 */		public var name:String;				/**		 * The children of this node are stored inside this array.		 * IMPORTANT: Use this property mainly as READ ONLY. To add, delete or search a specific child, you can use the specific method to do that		 */		public const children:Array = new Array();				/**		 *  Cached matrix corresponding to the transformation to the 0,0,0 frame system		 */		public const modelMatrix:Matrix4 = new Matrix4();				/**		 * Cached matrix corresponding to the transformation to the camera frame system		 */		public const viewMatrix:Matrix4 = new Matrix4();				/**		 * The bounding box of this node		 * IMPORTANT: Do not modify it unless you perfectly know what you are doing		 */		public var boundingBox:BBox = new BBox();				/**		 * The bounding sphere of this node		 * IMPORTANT: Do not modify it unless you perfectly know what you are doing		 */		public var boundingSphere:BSphere = new BSphere();				/**		 * The unique id of this node in the node graph.		 * <p>This value is very useful to retrieve a specific node.</p>		 */		public const id:uint = _ID_++;				/**		 * Specify the visibility of this node.		 * If true, the node is visible, if fase, it will not be displayed.		 */		public var visible : Boolean = true;				/**		 * Creates a node in the object tree of the world.		 *		 * <p>This constructor should normally not be called directly, only from a sub class.</p>		 *		 * @param p_sName	A string identifier for this object.		 */		public function Node( p_sName:String = "" )		{			parent = null;			// --			if( p_sName && p_sName != "" ) 			{				name = p_sName;			}			else			{				name = (id).toString();			}			// --			changed = true;			m_oEB = new BubbleEventBroadcaster( this );			// --			culled = CullingState.INSIDE;			scene = null;			boundingBox.reset();			boundingSphere.reset();		}		/**		 * The broadcaster		 *		 * <p>The broadcaster is used to send events to listeners.<br />		 * This property is a BubbleEventBroadcaster.</p>		 *		 * @return The instance of the current node broadcaster.		 */		public function get broadcaster():BubbleEventBroadcaster		{			return m_oEB;		}				/**		 * Adds a listener for the specified event.		 *		 * @param p_sEvt Name of the Event.		 * @param p_oL Listener object.		 */		public function addEventListener(p_sEvt:String, p_oL:*) : Boolean		{			return m_oEB.addEventListener.apply(p_sEvt, arguments);		}		/**		 * Removes a listener for the specified event.		 *		 * @param p_sEvt Name of the Event.		 * @param oL Listener object.		 */		public function removeEventListener(p_sEvt:String, p_oL:*) : void		{			m_oEB.removeEventListener(p_sEvt, p_oL);		}		/**		 * Tests if the node passed in the argument is parent of this node.		 *		 * @param p_oNode 	The node you are testing		 * @return		true if the node in the argument is the parent of this node, false otherwise.		 */		public function isParent( p_oNode:Node ):Boolean		{			return (_parent == p_oNode && p_oNode != null);		}		/**		 * Make all the Shape3D and descendants children react to this value.		 * @param p_bUseSingleContainer if true, the whole objects will use a container to display the geometry into, otherwise, a specific container will be given to each polygon 		 */		public function set useSingleContainer( p_bUseSingleContainer:Boolean ):void		{			for each( var l_oNode:Node in children )			{				l_oNode.useSingleContainer = p_bUseSingleContainer;			}		}				/**		 * Change the backface culling state to all the shapes objects in the children list		 */		public function set enableBackFaceCulling( b:Boolean ):void		{			for each( var l_oNode:Node in children )			{				l_oNode.enableBackFaceCulling = b;			}		}				/**		 * Change the interactivity of all the children		 */		public function set enableInteractivity( p_bState:Boolean ):void		{			for each( var l_oNode:Node in children )			{				l_oNode.enableInteractivity = p_bState;			}		}				/**		 * Enable event handling to all the children objects that can broadcast bubbling events		 */		public function set enableEvents( b:Boolean ):void		{			for each( var l_oNode:Node in children )			{				l_oNode.enableEvents = b;			}		}				/**		 * Set that appearance to all the children of that node		 */		public function set appearance( p_oApp:Appearance ):void		{			for each( var l_oNode:Node in children )			{				l_oNode.appearance = p_oApp;			}		}				/**		 * @private		 */		public function set parent( p_oNode:Node ):void		{			if( p_oNode )			{				_parent = p_oNode;				changed = true;			}		}		/**		 * The parent node of this node.		 *		 * <p>The reference is null if this nod has no parent (for exemple for a root node).</p>		 */		public function get parent():Node		{			return _parent;		}		/**		 * Tests if this node has a parent.		 *		 * @return 	true if this node has a parent, false otherwise.		 */		public function hasParent():Boolean		{			return ( _parent != null );		}		/**		 * Adds a new child to this node.		 *		 * <p>A node can have several children, and when you add a child to a node,		 * it is automatically connected to the parent node through its parent property.</p>		 *		 * @param p_oChild	The child node to add		 */		public function addChild( p_oChild:Node ):void		{			if( p_oChild.hasParent() )			{				p_oChild.parent.removeChildByName( p_oChild.name );				}			// --			p_oChild.parent = this;			changed =  true ;			children.push( p_oChild );			if( p_oChild.broadcaster ) m_oEB.addChild( p_oChild.broadcaster );			if( scene ) p_oChild.scene = scene;					}		/**		 * Returns the child node with the specified name.		 *		 * @param p_sName	The name of the child you want to retrieve		 * @param p_bRecurs 	Set to true if you want to search the the children for the requested node		 *		 * @return		The requested node or null if no child with this name was found		 */		public function getChildByName( p_sName:String, p_bRecurs:Boolean=false ):Node		{			var l_oNode:Node;			for each( l_oNode in children )			{				if( l_oNode.name == p_sName )				{					return l_oNode;				}			}			if( p_bRecurs )			{				var node:Node = null;				for each( l_oNode in children )				{					node = l_oNode.getChildByName( p_sName, p_bRecurs );					if( node != null )					{						 return node;					}				}			}			return null;		}		/**		 * Moves this node to another parent node.		 *		 * <p>This node is removed from its current parent node, and added as a child of the specified node</p>		 *		 * @param p_oNewParent	The node to become parent of this node		 */		public function swapParent( p_oNewParent:Node ):void		{			if( parent.removeChildByName( this.name ) );				p_oNewParent.addChild( this );		}		/**		 * Removes the child node with the specified name.		 *		 * <p>All children of the node you want to remove are lost.<br/>		 * The link between them and the rest of the tree is broken, and they will not be rendered anymore!</p>		 * <p>The object itself and its children are still in memory!<br/>		 * If you want to free them completely, call child.destroy()</p>		 *		 * @param p_sName	The name of the node you want to remove.		 * @return 		true if the node was removed from node tree, false otherwise.		 */		public function removeChildByName( p_sName:String ):Boolean		{			var found:Boolean = false;			var i:int;			var l:int = children.length;			while( i < l && !found )			{				if( children[int(i)].name == p_sName  )				{					broadcaster.removeChild( children[int(i)].broadcaster );					children.splice( i, 1 );					changed = true;					found = true;				}				i++;			}			return found;		}		/**		 * Delete this node and all its child nodes.		 *		 * <p>This node nad all its child nodes are deleted, including all data they are storing.<br/>		 * The method makes recursive calls to the destroy method of the child nodes.		 */		public function destroy():void		{			// the unlink this node to his parent			if( hasParent() == true ) parent.removeChildByName( name );			// should we kill all the childs, or just make them childs of current node parent ?			var l_aTmp:Array = children.concat();			for each( var lNode:Node in l_aTmp )			{				lNode.destroy();			}			children.splice(0);			m_oEB = null;			scene = null;		}		/**		 * Removes this node from the node tree, saving its child nodes.		 *		 * <p>NOTE that remove method only remove the current node and NOT its children!<br />		 * To remove the current node and all its children please refer to the destroy method.</p>		 * <p>The child nodes of this node becomes child nodes of this node's parent.</p>		 */		public function remove() :void		{			// first we remove this node as a child of its parent			// we do not update rigth now, but a little bit later ;)			parent.removeChildByName( name );						// now we make current node children the current parent's node children			var l_aTmp:Array = children.concat();			for each( var lNode:Node in l_aTmp )			{				parent.addChild( lNode );			}			children.splice(0);			m_oEB = null;			changed = true;		}		/**		 * Updates this node.		 *		 * <p>For a node with transformation, this method update the transformation taking into account the matrix cache system.</p>		 *		 * @param p_oScene The current scene		 * @param p_oModelMatrix		 * @param p_bChanged		 */		public function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):void		{			culled = CullingState.INSIDE;			// --			if( boundingBox )				boundingBox.uptodate = false;			if( boundingSphere ) 				boundingSphere.uptodate = false;						/* Shall be overriden */			changed = changed || p_bChanged;			var l_oNode:Node;			for each( l_oNode in children )			{				l_oNode.update( p_oModelMatrix, changed );			}		}		/**		 * Tests this node against the frustum volume to get its visibility.		 *		 * <p>If the node and its children aren't in the frustum, the node is set to cull		 * and will not be displayed.<br/>		 * <p>The method also updates the bounding volumes, to make a more accurate culling system possible.<br/>		 * First the bounding sphere is updated, and if intersecting, the bounding box is updated to perform a more		 * precise culling.</p>		 * <p><b>[MANDATORY] The update method must be called first!</b></p>		 *		 * @param p_oScene	The current scene which is rendered		 * @param p_oFrustum	The frustum of the current camera.		 * @param p_oViewMatrix	The matrix which maps object local coordinates into camera coordinates.		 * @param p_bChanged	Flag which specifies if parent transformation have changed to enable the matrix cache system when set to false.		 *		 */		public function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void		{			if( visible == false )			{				culled = CullingState.OUTSIDE;			}			else			{				// --				boundingBox.reset();				for each( var node:Node in children )		 			boundingBox.merge(node.boundingBox);		 		boundingSphere.resetFromBox( boundingBox );		 		// --				if( p_bChanged || changed )				{					viewMatrix.copy( p_oViewMatrix );					viewMatrix.multiply4x3( modelMatrix );				}			}		}						/**		 * Reference to the scene is it linked to.		 * Initialized at null.		 */		public function set scene( p_oScene:Scene3D ):void		{		 	m_oScene = p_oScene;		 	for each( var node:Node in children )		 		node.scene = m_oScene;		}		 		public function get scene():Scene3D		{		 	return m_oScene;		}		protected var m_oScene:Scene3D = null;				/**		 * Performs an operation on this node and all of its children.		 * 		 * <p>Traverses the subtree made up of this node and all of its children.		 * While traversing the subtree, individual operations are performed 		 * on entry and exit of each node of the subtree.</p>		 * <p>Implements the visitor design pattern: 		 * Using the visitor design pattern, you can define a new operation on Node		 * and its subclasses without having to change the classes and without having		 * to take care of traversing the node tree.</p>		 * 		 * @example		 * <listing version="3.0">		 *     var mySpecialOperation:SpecialOperation = new SpecialOperation;		 * 		 *     mySpecialOperation.someParameter = 0.8;		 *     someTreeNode.perform(mySpecialOperation);		 *     trace(mySpecialOperation.someResult);		 * 		 *     mySpecialOperation.someParameter = 0.2;		 *     someOtherTreeNode.perform(mySpecialOperation);		 *     trace(mySpecialOperation.someResult);		 * </listing>		 * 		 * @param  p_iOperation   The operation to be performed on the node subtree		 */ 		public function perform( p_iOperation:INodeOperation ):void 		{			p_iOperation.performOnEntry( this );						// perform operation on all child nodes			for each( var l_oChild:Node in children ) 			{				l_oChild.perform( p_iOperation );			}							p_iOperation.performOnExit( this );		}		/**		 * Returns a string representation of this object		 *		 * @return	The fully qualified name of this class		 */		public function toString():String		{			return "sandy.core.scenegraph.Node";		}		////////////////////		//// PRIVATE PART		////////////////////		private static var _ID_:uint = 0;		private var _parent:Node;		protected var m_oEB:BubbleEventBroadcaster;		/**		 * This property set the cache status of the current node.		 * IMPORTANT Currently this property isn't used!		 */		public var changed:Boolean = false;	}}