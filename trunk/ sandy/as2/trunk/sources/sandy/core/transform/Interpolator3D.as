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
import sandy.core.transform.ITransform3D;

/**
* Represents a Transformation Interpolator for an Group.
* <p>The Interpolator3D is applied to each Object3D into a Group.</p>
*  
* @author		Thomas Pfeiffer - kiroukou
* @since		0.1
* @version		0.2
* @date 		12.01.2006
* 
**/
interface sandy.core.transform.Interpolator3D extends ITransform3D
{
	/**
	 * setDuration
	 * @param t Number The number of frames that you want the interpolation last
	 * @return
	 */
	public function setDuration ( t:Number ):Void;
	
	/**
	* Make the Interpolator reverse its movement
	*/
	public function yoyo( Void ):Void;
	
	/**
	 * Let the interpolator do a new loop 
	 */
	public function redo( Void ):Void;
	
	public function getFrame( Void ):Number;
	
	/**
	 * Returns the current percent of the Interpolation
	 */
	public function getPercent( Void ):Number;
	
	public function getDuration ( Void ):Number;
	
	public function getDurationElapsed ( Void ):Number;
	
	public function getDurationRemaining ( Void ):Number;
	
	public function getEndMatrix( Void ):Matrix4;
	
	public function getStartMatrix( Void ):Matrix4;
	
	public function pause( Void ):Void;
	public function resume( Void ):Void;
	public function isPaused( Void ):Boolean;
	public function isFinished( Void ):Boolean;
	
}


