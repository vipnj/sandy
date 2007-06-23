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

import com.bourre.events.BubbleEventBroadcaster;

import sandy.bounds.BBox;
import sandy.bounds.BSphere;
import sandy.core.data.Matrix4;
import sandy.core.scenegraph.Camera3D;
import sandy.math.Matrix4Math;
import sandy.view.CullingState;
import sandy.view.Frustum;

/**
 * ABSTRACT CLASS
 * <p>
 * This class is the basis of all the group and Leaf one.
 * It allows all the basic operations you might want to do about trees node.
 * </p>
 * @author		Thomas Pfeiffer - kiroukou
 * @version		2.0
 * @date 		16.03.2007
 **/
class sandy.core.scenegraph.Node
{
	// This property set the cache status of the current node.
	public var changed:Boolean;
	// This property represent the culling state of the current node
	public var culled:CullingState;
	
	public var broadcaster:BubbleEventBroadcaster;
	/**
	* Retuns the unique ID Number that represents the node.
	* This value is very usefull to retrieve a specific Node.
	* This method is FINAL, IT MUST NOT BE OVERLOADED.
	* @param	void
	* @return	Number the node ID.
	*/
	public function get id():Number
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
		return (_parent == n && n != null);
	}
	
	/**
	* Set the parent of a node
	* @param	void
	*/
	public function set parent( n:Node )
	{
		if( n )
		{
			_parent = n;
			broadcaster.parent = n.broadcaster;
			changed = true;
		}
	}
	
	/**
	* Returns the parent node reference
	* @param	void
	* @return Node The parent node reference, which is null if no parents (for exemple for a root object).
	*/
	public function get parent():Node
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
		return ( _parent != null );
	}	
	
	/**
	* Add a new child to this group. a basicGroup can have several childs, and when you add a child to a group, 
	* the child is automatically conencted to it's parent thanks to its parent property.
	* @param	child
	*/
	public function addChild( child:Node ):Void 
	{
		child.parent = this;
		changed =  true ;
		_aChilds.push( child );
		broadcaster.addChild( child.broadcaster );
	}	
	
	/**
	 * Returns all the childs of the current group in an array
	 * @param void
	 * @return Array The array containing all the childs node of this group
	 */
	public function getChildList():Array
	{
		return _aChilds;
	}

	/**
	* Returns the child node with the specified ID
	* @param	index Number The ID of the child you want to get
	* @return 	Node The desired Node or null is no child with this ID has been found
	*/
	public function getChildFromId( id:Number, p_recurs:Boolean ):Node 
	{
		var l:Number = _aChilds.length;
		while( -- l > -1 )
		{
			if( Node(_aChilds[int(l)]).id == id )
			{
				return _aChilds[int(l)];
			}
		}
		if( p_recurs )
		{
			var node:Node = null;
			l = _aChilds.length;
			while( -- l > -1 )
			{
				node = Node(_aChilds[int(l)]).getChildFromId( id, p_recurs );
				if( node != null ) return node;
			}
		}
		return null;
	}

	/**
	* Returns the child node with the specified name
	* @param	index Number The name of the child you want to get
	* @return 	Node The desired Node or null is no child with this name has been found
	*/
	public function getChildByName( pName:String, p_recurs:Boolean ):Node 
	{
		var l:Number = _aChilds.length;
		while( -- l > -1 )
		{
			if( Node(_aChilds[int(l)]).name == pName )
			{
				return _aChilds[int(l)];
			}
		}
		if( p_recurs )
		{
			var node:Node = null;
			l = _aChilds.length;
			while( -- l > -1 )
			{
				node = Node(_aChilds[int(l)]).getChildByName( pName, p_recurs );
				if( node != null ) return node;
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
			if( _aChilds[int(i)].id == pId  )
			{
				_aChilds.splice( i, 1 );
				broadcaster.removeChild( _aChilds[int(i)].broadcaster );
				changed = true;
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
		var l:Number = _aChilds.length;
		for( i = 0; i < l && !found; i++ )
		{
			if( _aChilds[int(i)].name == pName  )
			{
				_aChilds.splice( i, 1 );
				broadcaster.removeChild( _aChilds[int(i)].broadcaster );
				changed = true;
				found = true;
			}
		}
		
		return found;
	}


	/**
	 * Delete all the childs of this node, and also the datas it is actually storing.
	 * Do a recurssive call to child's destroy method.
	 */
	public function destroy():Void 
	{			
		// should we kill all the childs, or just make them childs of current node parent ?
		var l:Number = _aChilds.length;
		while( --l > -1 )
		{
			_aChilds[int(l)].destroy();
			_aChilds[int(l)] = null;	
		}
		_aChilds = null;
		broadcaster = null;
		// the unlink this node to his parent
		if( hasParent() == true ) parent.removeChildById( this._id );
	}

	/**
	 * Remove the current node on the tree.
	 * It makes current node children the children of the current parent node.
	 * The interest of this paramater is that it allows you to update the World3D only once during your destroy/remove call!
	 */
	public function remove() :Void 
	{
		var l:Number = _aChilds.length;
		// first we remove this node as a child of its parent
		// we do not update rigth now, but a little bit later ;)
		parent.removeChildById( this.id );
		// now we make current node children the current parent's node children
		while( --l > -1 )
		{
			parent.addChild( _aChilds[int(l)] );
		}
		_aChilds = null;
		changed = true;
	}

	/**
	 * Hide (false) or make visible( true)  the current object.
	 * The default state is visible (true)
	 */
	public function set visible( b:Boolean ):Void
	{
		_visible = b;
		changed = true;
	}
	
	/**
	 * Get the visibility of the current node.
	 * @return true if node is visible, false otherwise.
	 */
	public function get visible():Boolean
	{
		return _visible;
	}
		
	public function toString():String
	{
		return "sandy.core.scenegraph.Node";
	}

	/**
	 * This method goal is to update the node. For node's with transformation, this method shall
	 * update the transformation taking into account the matrix cache system.
	 */
	public function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):Void
	{
		/* Shall be overriden */
		changed = changed || p_bChanged;
		//
		var l_nLength:Number = _aChilds.length;
		while( --l_nLength > -1 )
		{
			_aChilds[l_nLength].update( p_oModelMatrix, changed );
		}
	}

	
	/**
	 * This method test the current node on the frustum to get its visibility.
	 * If the node and its children aren't in the frustum, the node is set to cull
	 * and it would not be displayed.
	 * This method is also updating the bounding volumes to process the more accurate culling system possible.
	 * First the bounding sphere are updated, and if intersecting, the bounding box are updated to perform a more
	 * precise culling.
	 * [MANDATORY] The update method must be called first!
	 */
	public function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):Void
	{
		if( _visible == false )
		{
			culled = CullingState.OUTSIDE;
		}
		else
		{
			if( p_bChanged || changed )
			{
				if(p_oViewMatrix)
					_oViewCacheMatrix = (_oModelCacheMatrix) ? Matrix4Math.multiply4x3( p_oViewMatrix, _oModelCacheMatrix ) : p_oViewMatrix;
				else
					_oViewCacheMatrix = _oModelCacheMatrix;
				
				if( _oViewCacheMatrix )
				{
					/////////////////////////
			        //// BOUNDING SPHERE ////
			        /////////////////////////
			        _oBSphere.transform( _oViewCacheMatrix );
			        culled = p_oFrustum.sphereInFrustum( _oBSphere );
					//
					if( culled == Frustum.INTERSECT && _oBBox )
					{
			            ////////////////////////
			            ////  BOUNDING BOX  ////
			            ////////////////////////
			            _oBBox.transform( _oViewCacheMatrix );
			            culled = p_oFrustum.boxInFrustum( _oBBox );
					}
				}
			}
		}
		/* FIXME : Shape 3D shall override this method and perform  check to know if object needs clipping or not */
	}
	
	public function render( p_oCamera:Camera3D ):Void
	{
		;/* TO OVERRIDE */
	}

	/**
	* Returns  bounds of the object. [ minimum  value; maximum  value]
	* @param	void
	* @return Return the array containing the minimum  value and maximum  value of the object in the world coordinate.
	*/
	public function getBBox():BBox
	{
		return _oBBox;
	}

	/**
	* Returns  bounding sphere of the object. [ minimum  value; maximum  value]
	* @param	void
	* @return Return the bounding sphere
	*/
	public function getBSphere():BSphere
	{
		return _oBSphere;
	}
		
	////////////////////
	//// PRIVATE PART
	////////////////////
	
	// TODO: private function in original implementation
	public function Node( p_sName:String ) 
	{
		parent = null;
		_aChilds = [];
		_id = Node._ID_++;
		// --
		if(p_sName)  name = p_sName;
		else         name = String( _id.toString() );
		changed = true;
		_visible = true;
		_oBBox = new BBox();
		_oBSphere = new BSphere();
		// --
		broadcaster = new BubbleEventBroadcaster( this );
		// -- 
		_oModelCacheMatrix = null;
		_oViewCacheMatrix = null;
		//
		culled = CullingState.INSIDE;
	}
    		
	private static var _ID_:Number = 0;
	private var _aChilds:Array;
	private var _id:Number;
	private var _parent:Node;
	private var _visible : Boolean;	
	public var name:String;
	// Cached matrix corresponding to the transformation to the 0,0,0 frame system
	private var _oModelCacheMatrix:Matrix4;
	// Cached matrix corresponding to the transformation to the camera frame system
	private var _oViewCacheMatrix:Matrix4;
	private var _oBBox:BBox;
	private var _oBSphere:BSphere;
}
