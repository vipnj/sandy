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



/**
* Represents a Transformation for an Group.
* <p>The Transform3D is applied to each Object3D into a Group.</p>
*  
* @author		Thomas Pfeiffer - kiroukou
* @version		1.2
* @date 		12.01.2006
* 
**/
interface sandy.core.transform.ITransform3D 
{
	/**
	* Destroy the instance with all the dependent objects/listeners. Important to call this when it is not automatically done.
	* @param	Void
	* @return Void
	*/
	public function destroy( Void ):Void;

}


