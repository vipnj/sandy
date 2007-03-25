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
package sandy.core.transform 
{
	import sandy.core.data.Matrix4;
	import sandy.core.transform.TransformType;

	/**
	* Represents a Transformation for an Group.
	* <p>The Transform3D is applied to each Object3D into a Group.</p>
	*  
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.2
	* @date 		12.01.2006
	* 
	**/
	public interface ITransform3D
	{
		/**
		* Set the transformation as modified or not. Very usefull for the cache transformation system.
		* @param	b Boolean True value means the transformation has been modified, and false the opposite.
		*/
		function setModified( b:Boolean ):void;
		
		/**
		* Allows you to know if the transformation has been modified.
		* @param	void
		* @return Boolean True if the transformation has been modified, false otherwise.
		*/
		function isModified():Boolean;
		
		/**
		* Get the type of the Transform3D.
		* 
		* @return	The type of the transformation.
		*/
		function getType():TransformType;
		
		/**
		* Destroy the instance with all the dependent objects/listeners. Important to call this when it is not automatically done.
		* @param	void
		* @return void
		*/
		function destroy():void;
		
		function get matrix():Matrix4;
		
		function set matrix( p_matrix:Matrix4 ):void;
		
	}
}