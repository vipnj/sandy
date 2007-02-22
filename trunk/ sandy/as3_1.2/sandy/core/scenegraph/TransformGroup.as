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
	import sandy.core.transform.ITransform3D;
    import sandy.view.Camera3D;
    import sandy.core.data.Matrix4;
    import sandy.math.Matrix4Math;
	
	import flash.utils.*;

	/**
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		16.05.2006
	**/
	public class TransformGroup extends Group
	{
		/**
		* Create a new TransformGroup.
		* This class is one of the most important because it represents a node in the tree scene representation in Sandy.
		* It has a matrix which is in fact its Transform3D property matrix.
		* @param [OPTIONNAL] transform Transform3D The transformation to apply to this transformGroup
		*/ 	
		public function TransformGroup( p_sName:String, transform:ITransform3D = null)
		{
			super( p_sName );
			_t = transform;
		}
		
		/**
		 * Add a transformation to the current TransformGroup. This allows to apply a transformation to all the childs of the Node.
		 * @param t		The transformation to add
		 */
		public function setTransform( t:ITransform3D ):void
		{
			_t = t;
			setModified( true );
		}
		
		/**
		 * Get the current TransformGroup transformation. This allows to manipulate the node transformation.
		 * @return	The transformation 
		 */
		public function getTransform():ITransform3D
		{
			return _t;
		}
		
		/**
		 * Get the current TransformGroup transformation. This allows to manipulate the node transformation.
		 * @return	The transformation 
		 */
		public function getMatrix():Matrix4
		{
			return _t ? _t.getMatrix():null;
		}
		/**
		* Allows you to know if this node has been modified (true value) or not (false value). 
		* Mainly usefull for the cache system.
		* After this method call the property hasn't changed it's value. It remains the current returned value.
		* @return	Boolean Value specifying the statut of the node. A true value means the node has been modified, it it should be rendered again
		*/
		override public function isModified():Boolean
		{
			return _modified || _t.isModified();
		}
		
		override public function setModified( b:Boolean ):void
		{
			super.setModified( b );
			
			if (_t)
				_t.setModified( b );
		}
		
		/**
		 * Render the actual node. Object3D's node are rendered, TransformGroup concat (multiply) their matrix to
		 * update the 3D transformations view.
		 */
		override public function render(p_oCamera:Camera3D, p_oViewMatrix:Matrix4, p_bCache:Boolean):void
		{
			var l_oMatrix:Matrix4 = getMatrix();
			var l_bCache:Boolean = p_bCache || _modified;
			var l_oViewMatrix;
			if( l_bCache )
			    _oCacheMatrix = l_oViewMatrix = ( p_oViewMatrix == null ) ? l_oMatrix : (l_oMatrix == null ) ? p_oViewMatrix : Matrix4Math.multiply4x3( p_oViewMatrix, l_oMatrix );
			else
			    l_oViewMatrix = _oCacheMatrix;
			//
			var l_iNode:INode;
			var l_lId:int;
			//
			for( l_lId = 0; l_iNode = _aChilds[l_lId]; l_lId++ )
			{
			    l_iNode.render( p_oCamera, l_oViewMatrix, l_bCache );
			    l_iNode.setModified( false );
			}
		}


		/**
		* 
		*/
		override public function destroy():void
		{
			_t.destroy();
			super.destroy();
		}
		
		/**
		* Get a String represntation of the {@code TransformGroup}.
		* 
		* @return	A String representing the {@code TransformGroup}.
		*/ 
		override public function toString():String
		{
			return getQualifiedClassName(this);
		}
		
		/**
		* The transformation of this TransformGroup
		*/
		private var _t:ITransform3D;

	}

}
