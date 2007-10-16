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

import com.bourre.events.EventBroadcaster;

/**
 * ABSTRACT CLASS
 * <p>
 * This class is the basis of all the group and Leaf one.
 * It allows all the basic operations you might want to do about trees node.
 * </p>
 * @author		Thomas Pfeiffer - kiroukou
 * @author		Bruce Epstein - zeusprod
 * @since		0.1
 * @version		1.2
 * @date 		27.03.2007
 **/
class sandy.core.group.Node extends EventBroadcaster
{
	/*
	 * Name of the node. Default value is its ID number.
	 */
	public var name:String;
	
	/**
	 * Adds passed-in {@code oL} listener for receiving passed-in {@code t} event type.
	 * 
	 * <p>Take a look at example below to see all possible method call.
	 * 
	 * <p>Example
	 * <code>
	 *   var oEB : IEventDispatcher = new EventBroadcaster(this);
	 *   oEB.addEventListener( myClass.onSomethingEVENT, myFirstObject);
	 *   oEB.addEventListener( myClass.onSomethingElseEVENT, this, __onSomethingElse);
	 *   oEB.addEventListener( myClass.onSomehtingElseEVENT, this, Delegate.create(this, __onSomething) );
	 * </code>
	 * 
	 * @param t Name of the Event.
	 * @param oL Listener object.
	 */
	 /*
	public function addEventListener(t:String, oL) : Void
	{
		_oEB.addEventListener.apply( _oEB, arguments );
	}
	*/
	/**
	 * Removes passed-in {@code oL} listener that suscribed for passed-in {@code t} event.
	 * 
	 * <p>Example
	 * <code>
	 *   var oEB : IEventDispatcher = new EventBroadcaster(this);
	 *   oEB.removeEventListener( myClass.onSomethingEVENT, myFirstObject);
	 *   oEB.removeEventListener( myClass.onSomethingElseEVENT, this);
	 * </code>
	 * 
	 * @param t Name of the Event.
	 * @param oL Listener object.
	 */
	 /*
	public function removeEventListener(t:String, oL) : Void
	{
		_oEB.removeEventListener( t, oL );
	}
	*/

	/**
	 * Wrapper for Macromedia {@code EventDispatcher} polymorphism.
	 * 
	 * <p>Example
	 * <code>
	 *   var oEB : IEventDispatcher = new EventBroadcaster(this);
	 *   oEB.dispatchEvent( {type:'onSomething', target:this, param:12} );
	 * </code>
	 * 
	 * @param o Event object.
	 */
	 /*
	public function dispatchEvent(o:Object) : Void
	{
		_oEB.dispatchEvent.apply( _oEB, arguments );
	}
	*/
	/**
	 * Broadcasts event to suscribed listeners.
	 * 
	 * <p>Example using full Pixlib API
	 * <code>
	 *   var oEB : IEventDispatcher = new EventBroadcaster(this);
	 *   var e : IEvent = new BasicEvent( myClass.onSomeThing, this);
	 *   
	 *   oEB.addEventListener( myClass.onSomeThing, this);
	 *   oEB.broadcastEvent( e );
	 * </code>
	 * 
	 * @param e an {@link IEvent} instance
	 */
	 /*
	public function broadcastEvent(e:IEvent) : Void
	{
		_oEB.broadcastEvent.apply( _oEB, arguments );
	}
	*/	
	
	/**
	* Retuns the unique ID Number that represents the node.
	* This value is very usefull to retrieve a specific Node.
	* This method is FINAL, IT MUST NOT BE OVERLOADED.
	* @param	Void
	* @return	Number the node ID.
	*/
	public function getId( Void ):Number
	{
		return _id;
	}
		
	/**
	* Say is the node is the parent of the current node.
	* @param	n The Node you are going to test the patternity
	* @return Boolean  True is the node in argument if the father of the current one, false otherwise.
	*/
	public function isParent( n:Node ):Boolean
	{
		return (_parent == n && n != undefined);
	}
	
	/**
	* Allows you to know if this node has been modified (true value) or not (false value). 
	* Mainly useful for the cache system.
	* @return	Boolean Value specifying the status of the node. A true value means the node has been modified, it it should be rendered again
	*/
	public function isModified( Void ):Boolean
	{
		return _modified;
	}

	/**
	* Allows you to set the modified property of the node.
	* @param b Boolean true means the node is modified, and false the opposite.
	*/
	public function setModified( b:Boolean ):Void
	{
		_modified = b;
	}
	
	/**
	* Set the parent of a node
	* @param	Void
	* @return	Boolean false is nothing has been done, true if the operation succeded
	*/
	public function setParent( n:Node ):Boolean
	{
		if( undefined == n )
		{
			return false;
		}
		else
		{
			_parent = n;
			setModified( true );
			return true;
		}
	}
	
	/**
	* Returns the parent node reference
	* @param	Void
	* @return Node The parent node reference, which is null if no parents (for exemple for a root object).
	*/
	public function getParent( Void ):Node
	{
		return _parent;
	}
	
	/**
	* Allows the user to know if the current node have a parent or not.
	* @param	Void
	* @return Boolean. True is the node has a parent, False otherwise
	*/
	public function hasParent( Void ):Boolean
	{
		return (undefined != _parent);
	}	
	
	/**
	* Add a new child to this group. a basicGroup can have several childs, and when you add a child to a group, 
	* the child is automatically conencted to it's parent thanks to its parent property.
	* @param	child
	*/
	public function addChild( child:Node ): Void 
	{
		child.setParent( this );
		setModified( true );
		_aChilds.push( child );
	}	
	
	/**
	 * Returns all the childs of the current group in an array
	 * @param Void
	 * @return Array The array containing all the childs node of this group
	 */
	public function getChildList ( Void ):Array
	{
		return _aChilds;
	}
	
	/**
	* Returns the child node at the specific index.
	* @param	index Number The ID of the child you want to get
	* @return 	Node The desired Node
	*/
	public function getChild( index:Number ):Node 
	{
		return _aChilds[ index ];
	}

	/**
	* Returns the child node with the specified ID
	* @param	index Number The ID of the child you want to get
	* @return 	Node The desired Node or null is no child with this ID has been found
	*/
	public function getChildFromId( id:Number ):Node 
	{
		var l:Number = _aChilds.length;
		while( -- l > -1 )
		{
			if( Node(_aChilds[l]).getId() == id )
			{
				return _aChilds[l];
			}
		}
		return null;
	}

	/**
	* Returns the child node with the specified name
	* @param	index Number The name of the child you want to get
	* @return 	Node The desired Node or null is no child with this name has been found
	*/
	public function getChildByName( pName:String ):Node 
	{
		var l:Number = _aChilds.length;
		while( -- l > -1 )
		{
			if( Node(_aChilds[l]).name == pName )
			{
				return _aChilds[l];
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
	public function removeChildById( pId:Number ):Boolean 
	{
		var found:Boolean = false;
		var i:Number, l:Number = _aChilds.length;

		for( i = 0; i < l && !found; i++ )
		{
			if( _aChilds[i].getId() == pId  )
			{
				_aChilds.splice( i, 1 );
				setModified( true );
				found = true;
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
		var i:Number;
		for( i = 0; i < _aChilds.length && found == false; i++ )
		{
			if( _aChilds[i].name == pName  )
			{
				_aChilds.splice( i, 1 );
				setModified( true );
				found = true;
			}
		}
		return found;
	}
	
	/**
	 * Delete all the children of this node, and also the data it is actually storing.
	 * Do a recursive call to child's destroy method.
	 */
	public function destroy( Void ):Void 
	{
		// should we kill all the children, or just make them children of current node parent ?
		var l:Number = _aChilds.length;
		while( --l > -1 )
		{
			_aChilds[l].destroy();
			delete _aChilds[l];	
		}
		delete _aChilds;
		// Unlink this node from its parent
		if( hasParent() == true ) _parent.removeChildById( this._id );
		removeAllListeners();
	}
	
	/**
	 * Hide all the children of this node.
	 * Do a recursive call to child's hide method.
	 */
	public function hideChildren (Void):Void {
		var l:Number = _aChilds.length;
		while( --l > -1 )
		{
			_aChilds[l].hide();
			_aChilds[l].hideChildren();
		}
	}
	
	/**
	 * Show all the children of this node.
	 * Do a recursive call to child's show method.
	 */
	public function showChildren (Void):Void {
		var l:Number = _aChilds.length;
		while( --l > -1 )
		{
			_aChilds[l].show();
			_aChilds[l].showChildren();
		}
	}

	/**
	 * Remove the current node on the tree.
	 * It makes current node children the children of the current parent node.
	 * The interest of this paramater is that it allows you to update the World3D only once during your destroy/remove call!
	 */
	public function remove( Void ) : Void 
	{
		//
		var l:Number = _aChilds.length;
		// first we remove this node as a child of its parent
		// we do not update right now, but a little bit later ;)
		_parent.removeChildById( this.getId() );
		// now we make current node children the current parent's node children
		while( --l > -1 )
		{
			_parent.addChild( _aChilds[l] );
		}
		delete _aChilds;
		_parent = null;
		setModified( true );
		removeAllListeners();
	}
	
	////////////////////
	//// PRIVATE PART
	////////////////////
	private function Node() 
	{
		super( this );
		_parent = null;
		_aChilds = [];
		_id = Node._ID_++;
		name = String( _id );
		setModified( true );
		// -- 
	}
	
	private static var _ID_:Number = 0;
	private var _aChilds:Array;
	private var _id:Number;
	private var _parent:Node;
	private var _modified:Boolean = true; // Force refresh the first time this item is drawn.
}
