
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
    
	import flash.utils.*;

	/**
	* <p>Abstract class used to represent the Leaf of the Sandy's scene tree.
	* This class should not be used directly, except for typing purpose.
	* This class is basically the same as the Node one, except that your can't add/remove some children </p>
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		1.0
	 * @date 		16.05.2006
	 **/
	public class Leaf extends Node implements INode
	{
		
		public function Leaf() 
		{
			super();
		}

		/**
		 * Do nothing since a leaf is the lower part of a tree. It cannot have a child.
		 * @param n Node The Node to set as a child of the current node. But it will not be done !
		 * @return
		 */
		override public function addChild ( child:INode ):void
		{
			;// nothing here
		}
			
		/**
		 * Returns a null value because a Laef doesn't have a child.
		 * @param void
		 * @return Array a null value
		 */
		override public function getChildList():Array
		{
			return null;
		}
		
		/**
		* Returns a null tovalue since a Leaf doesn't have a child
		* @param	index Number The ID of the child you want to get
		* @return 	Node The desired Node
		*/
		override public function getChild( index:int ):INode 
		{
			return null;
		}

		/**
		* Does nothing since a Leaf doesn't have some children. Return false.
		* @param	child Node The node you want to remove.
		* @return Boolean Return everytime false value;
		*/
		override public function removeChild( pId:int ):Boolean 
		{
			return false;
		}
		
		override public function removeChildByName( pName:String ):Boolean 
		{
			return false;
		}
		
		public function dispose():void
		{
			;
		}
		
		public function render(p_oCamera:Camera3D, p_oViewMatrix:Matrix4, p_bCache:Boolean):void
		{
			;
		}
		
	}
}