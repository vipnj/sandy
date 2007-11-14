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

import sandy.core.face.IPolygon;
import sandy.skin.SkinType;

import com.bourre.events.IEventDispatcher;

/**
* Represent a skin for a Face in an Object3D.
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Nicolas Coevoet - [ NikO ]
* @author		Tabin C�dric - thecaptain
* @version		0.2
* @date 		12.01.2006 
**/
interface sandy.skin.Skin extends IEventDispatcher
{
	/**
	* Prepare the Face drawing of the Object3D into a MovieClip.
	* <p>This method can be called when the {@link mb.sandy.view.IScreen#render(Array)}
	* is executed, depending of the type of the Skin that must be applyed to the Face. /p>
	* <p>{@code mc} represent the MovieClip where the Face must be displayed. The
	* {@code f} represents the face which is calling the Skin. The skin can call all the public properties of the face</p>
	* 
	* @param	f		The face calling the skin method
	* @param	mc		The MovieClip
	*/
	public function begin( f:IPolygon, mc:MovieClip ):Void;
	
	/**
	* Finish the Face drawing of the Object3D into a MovieClip.
	* <p>This method can be called when the {@link mb.sandy.view.IScreen#render(Array)}
	* is executed, depending of the type of the Skin that must be applyed to the Face. /p>
	* <p>{@code mc} represent the MovieClip where the Face must be displayed. The
	* {@code f} represents the face which is calling the Skin. The skin can call all the public properties of the face</p>
	* 
	* @param	f		The face calling the skin method
	* @param	mc		The MovieClip
	*/
	public function end( f:IPolygon, mc:MovieClip ):Void;

	/**
	 * setLightingEnable. Prepare the skin to use the world light or not. The default value is false.
	 * @param	bool	Boolean	true is the skin use the light of the world, false if no.
	 * @return	Void
	 */
	public function setLightingEnable ( bool:Boolean ):Void;
	
	/**
	 * getType, returns the type of the skin
	 * @param Void
	 * @return	The appropriate SkinType
	 */
	 public function getType ( Void ):SkinType;
}
