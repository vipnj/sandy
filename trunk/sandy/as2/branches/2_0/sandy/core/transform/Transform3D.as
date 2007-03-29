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
import sandy.core.transform.TransformType;

/**
* Transform3D
* This class helps you to create some transformations to apply to a transformGroup. This way you will be able
* to transform a whole group of objects, to create the effect you want.
* @author		Thomas Pfeiffer - kiroukou
* @since		1.0
* @version		1.0
* @date 		20.05.2006
*/
class sandy.core.transform.Transform3D
{
	/**
	 * Create a new Transform3D instance. An identity matrix is created by default, and the transform type is NONE.
	 */
	public function Transform3D ( Void )
	{
		matrix = null;//Matrix4.createIdentity();
		type = TransformType.NONE;
	}
					
	/**
	* Destroy the node by removing all the listeners and deleting the matrix instance.
	* @param	Void
	*/
	public function destroy( Void ):Void
	{
		if( matrix) delete matrix;
	}

	public var matrix:Matrix4;
	public var type:TransformType;

}
