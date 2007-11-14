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

import sandy.core.group.Node;
import sandy.core.group.INode;
import sandy.core.buffer.MatrixBuffer;
import sandy.core.transform.ITransform3D;
import sandy.core.data.Matrix4;


/**
* @author		Thomas Pfeiffer - kiroukou
* @author		Bruce Epstein - zeusprod
* @since		1.0
* @version		1.2.1
* @date 		07.08.2007
**/
class sandy.core.group.TransformGroup extends Node implements INode
{
	/**
	* Create a new TransformGroup.
	* This class is one of the most important because it represents a node in the tree scene representation in Sandy.
	* It has a matrix which is in fact its Transform3D property matrix.
	* @param [OPTIONNAL] transform Transform3D The transformation to apply to this transformGroup
	*/
	public function TransformGroup( transform:ITransform3D, inName:String )  // Changed back to ITransform3D
	{
		super();
		_t = (undefined == transform) ? null : transform;
		setModified( true );
		_bPop = false;
		name = (inName == undefined) ? "TransformGroup name" : inName;
	}

	/**
	 * Add a transformation to the current TransformGroup. This allows to apply a transformation to all the childs of the Node.
	 * @param t		The transformation to add
	 */
	public function setTransform( t:ITransform3D ):Void // Changed back to ITransform3D
	{
		_t = t;
		setModified( true );
	}

	/**
	 * Get the current TransformGroup transformation. This allows to manipulate the node transformation.
	 * @return	The transformation
	 */
	public function getTransform( Void ):ITransform3D // Changed back to ITransform3D
	{
		return _t;
	}

	/**
	* Allows you to know if this node has been modified (true value) or not (false value).
	* Mainly usefull for the cache system.
	* After this method call the property hasn't changed it's value. It remains the current returned value.
	* @return	Boolean Value specifying the statut of the node. A true value means the node has been modified, it it should be rendered again
	*/
	public function isModified( Void ):Boolean
	{
		return _modified || _t.isModified();
	}

	public function setModified( b:Boolean ):Void
	{
		//trace ("TransformGroup setModified " + b + " " +  name);
		super.setModified( b );
		_t.setModified( b );
	}

	/**
	 * Render the actual node. Object3D's node are rendered, TransformGroup concat (multiply) their matrix to
	 * update the 3D transformations view.
	 */
	public function render ( Void ):Void
	{
		if( _t )
		{
			var m:Matrix4 = _t.getMatrix();
			if( m )
			{
				_bPop = true;
				MatrixBuffer.push( m );
			}
		}
	}

	/**
	 * Dispose the actual node. Object3D's node are rendered, TransformGroup concat (multiply) their matrix to
	 * update the 3D transformations view.
	 */
	public function dispose ( Void ):Void
	{
		if( _bPop )
		{
			MatrixBuffer.pop();
			_bPop = false;
		}
	}

	/**
	*
	*/
	public function destroy( Void ):Void
	{
		super.destroy();
		_t.destroy();
	}

	/**
	* Get a String represntation of the {@code TransformGroup}.
	*
	* @return	A String representing the {@code TransformGroup}.
	*/
	public function toString( Void ):String
	{
		return "sandy.core.group.TransformGroup";
	}

	/**
	* The transformation of this TransformGroup
	*/
	private var _t:ITransform3D; // Changed to Transform3D
	private var _bPop:Boolean;

}


