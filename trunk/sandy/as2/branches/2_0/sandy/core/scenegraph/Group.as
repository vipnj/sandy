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
import sandy.view.CullingState;
import sandy.view.Frustum;

/**
 * Class implementing the Abstract class Node.
 * It's the basic class for all the classes used to represent the Groups in Sandy.
 * It is used as a node in the tree scene structure in Sandy, a node without associated transformation in oposition of TransfromGroup.
 * @author		Thomas Pfeiffer - kiroukou
 * @version		1.0
 * @date 		28.03.2006
 **/
 
class sandy.core.scenegraph.Group extends Node
{
	/**
	* Constructor of Group class.
	* Group is a concrete node object, and it represents a structure of object.
	* 
	* @param	parent
	*/
	public function Group( p_sName:String ) 
	{
		super( p_sName );
	}

	/**
	 * This method goal is to update the node. For node's with transformation, this method shall
	 * update the transformation taking into account the matrix cache system.
	 */
	public function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):Void
	{
		super.update( p_oModelMatrix, p_bChanged );
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
		// TODO
		// Parse the children, take their bounding volume and merge it with the current node recurssively. 
		// After that call the super cull method to get the correct cull value.		
		var l_oNode:Node;
		var l_nId:Number;
		var l_nLength:Number = _aChilds.length;
		changed = p_bChanged || changed;
		//
		for( l_nId = 0; l_oNode = _aChilds[l_nId]; l_nId++ )
		{
		    l_oNode.cull( p_oFrustum, p_oViewMatrix, changed || l_oNode.changed );
		}
		// --
		super.cull( p_oFrustum, p_oViewMatrix, changed );
	}
	
	public function render( p_oCamera:Camera3D ):Void
	{
		var l_oNode:Node;
		var l_nId:Number;
		var l_nLength:Number = _aChilds.length;
		// --
		for( l_nId = 0; l_oNode = _aChilds[l_nId]; l_nId++ )
		{
		    if( l_oNode.culled != Frustum.OUTSIDE )
		    	l_oNode.render( p_oCamera );
		    // --
		    l_oNode.changed = false; // default value is set to not changed.
		    l_oNode.culled = CullingState.INSIDE; // Default value is inside.
		}
	}
	
}
