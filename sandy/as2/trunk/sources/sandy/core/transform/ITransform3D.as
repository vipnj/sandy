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

import com.bourre.events.IEventDispatcher;

import sandy.core.data.Matrix4;
import sandy.core.transform.TransformType;

/**
* Represents a Transformation for an Group.
* <p>The Transform3D is applied to each Object3D into a Group.</p>
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin C�dric - thecaptain
* @version		1.2
* @date 		12.01.2006
* 
**/
interface sandy.core.transform.ITransform3D extends IEventDispatcher
{
	/**
	* Set the transformation as modified or not. Very usefull for the cache transformation system.
	* @param	b Boolean True value means the transformation has been modified, and false the opposite.
	*/
	public function setModified( b:Boolean ):Void;
	
	/**
	* Allows you to know if the transformation has been modified.
	* @param	Void
	* @return Boolean True if the transformation has been modified, false otherwise.
	*/
	public function isModified( Void ):Boolean;
	
	/**
	* Get the type of the Transform3D.
	* 
	* @return	The type of the transformation.
	*/
	public function getType( Void ):TransformType;
	
	/**
	* Get the matrix of the transformation
	* 
	* @return	Matrix4 The matrix
	*/
	public function getMatrix( Void ):Matrix4;
	
	/**
	* Destroy the instance with all the dependent objects/listeners. Important to call this when it is not automatically done.
	* @param	Void
	* @return Void
	*/
	public function destroy( Void ):Void;
}


