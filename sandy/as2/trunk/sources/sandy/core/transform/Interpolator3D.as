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
* @author		Thomas Balitout - samothtronicien
* @since		0.1
* @version		1.2.2
* @date 		26.05.2007
* 
**/
interface sandy.core.transform.Interpolator3D extends ITransform3D
{
	public function setDuration ( t:Number ):Void;

	public function yoyo( Void ):Void;

	public function redo( Void ):Void;
	
	public function getFrame( Void ):Number;
	
	public function getPercent( Void ):Number;
	
	public function getProgress( Void ):Number;
	
	public function getDuration ( Void ):Number;
	
	public function getDurationElapsed ( Void ):Number;
	
	public function getDurationRemaining ( Void ):Number;
	
	public function getEndMatrix( Void ):Matrix4;
	
	public function getStartMatrix( Void ):Matrix4;
	
	public function isInitialState( Void ):Boolean;
	
	public function isFinalState( Void ):Boolean;
	
	public function setFinal( Void ):Void;
	
	public function setInitial( Void ):Void;
	
	public function skipNextFrame( Void ):Void;
	
	public function getName( Void ):String;
	
	public function pause( Void ):Void;
	
	public function resume( Void ):Void;
	
	public function isPaused( Void ):Boolean;
	
	public function isFinished( Void ):Boolean;
	
}


