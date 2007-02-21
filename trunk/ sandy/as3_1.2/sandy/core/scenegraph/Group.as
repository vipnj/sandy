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
	import sandy.core.scenegraph.Node;
	import sandy.core.scenegraph.INode;
    import sandy.view.Camera3D;
    import sandy.core.data.Matrix4;

	/**
	 * Class implementing the Abstract class Node.
	 * It's the basic class for all the classes used to represent the Groups in Sandy.
	 * It is used as a node in the tree scene structure in Sandy, a node without associated transformation in oposition of TransfromGroup.
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		1.0
	 * @date 		28.03.2006
	 **/
	public class Group extends Node implements INode
	{
		/**
		* Constructor of Group class.
		* Group is a concrete node object, and it represents a structure of object.
		* 
		* @param	parent
		*/
		public function Group( p_sName:String=null ) 
		{
			super( p_sName );
		}
		
		public function render(p_oCamera:Camera3D, p_oViewMatrix:Matrix4, p_bCache:Boolean):void
		{  
			var l_bCache:Boolean = p_bCache || _modified;
			//
			var l_iNode:INode;
			var l_nId:int;
			var l_nLength:int = _aChilds.length;
			//
			for( l_nId = 0; l_iNode = _aChilds[l_nId]; l_nId++ )
			    l_iNode.render( p_oCamera, p_oViewMatrix, l_bCache );
		}
	}
}