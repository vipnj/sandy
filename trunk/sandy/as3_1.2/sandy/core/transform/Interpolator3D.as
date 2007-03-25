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

package sandy.core.transform {

	import sandy.core.data.Matrix4;
	
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
	public interface Interpolator3D
	{
		/**
		 * setDuration
		 * @param t Number The number of frames that you want the interpolation last
		 * @return
		 */
		function setDuration ( t:Number ):void;
		
		/**
		* Make the Interpolator reverse its movement
		*/
		function yoyo():void;
		
		/**
		 * Let the interpolator do a new loop 
		 */
		function redo():void;
		
		function getFrame():Number;
		
		/**
		 * Returns the current percent of the Interpolation
		 */
		function getPercent():Number;
		
		function getProgress():Number;
		
		function getDuration ():Number;
		
		function getDurationElapsed ():Number;
		
		function getDurationRemaining ():Number;
		
		function getEndMatrix():Matrix4;
		
		function getStartMatrix():Matrix4;
		
		function pause():void;
		function resume():void;
		
		function isPaused():Boolean;
		function isFinished():Boolean;
		
	}
}