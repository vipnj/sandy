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

package sandy.core.light 
{
	import flash.events.EventDispatcher;
	
	import sandy.core.data.Vector;
	import sandy.events.SandyEvent;
	import sandy.util.NumberUtil;
		
	[Event(name="lightUpdated", type="sandy.events.SandyEvent")]
	
       	/**
	 * The Light3D class is used for creating the light of the world.
	 * 
	 * <p>The light in Sandy is a light source at infinity, emitting parallel whit light.<br/>
	 * The direction of light and the intensity can be varied</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class Light3D extends EventDispatcher
	{
		
		/**
		 * Maximum intensity value.
		 */
		public static var MAX_POWER:Number = 150;
	
		/**
		 * Creates a new light source.
		 * 
		 * @param p_oD		The direction of the emitted light.
		 * @param p_nPow	Intensity of the emitted light.
		 * 
		 */
		public function Light3D ( p_oD:Vector, p_nPow:Number )
		{
			_dir = p_oD;
			setPower( p_nPow );
		}
		
		/**
		 * Sets the the intensity of the light. 
		 *
		 * @param p_nPow 	Intensity of the emitted light.
		 */
		public function setPower( p_nPow:Number ):void
		{
			_power =  NumberUtil.constrain( p_nPow, 0, Light3D.MAX_POWER );
			dispatchEvent(new SandyEvent(SandyEvent.LIGHT_UPDATED));
		}
		
		/**
		 * Returns the intensity of the light.
		 *
		 * @return 	The intensity as a number between 0 - MAX_POWER.
		 */
		public function getPower():Number
		{
			return _power;
		}
		
		/**
		 * Returns the direction of the light.
		 *
		 * @return 	The light direction
		 */
		public function getDirectionVector():Vector
		{
			return _dir;
		}
		
		/**
		 * Sets the direction of the light using components.
		 * 
		 * @param p_nX	the x component
		 * @param p_nY	the y component
		 * @param p_nZ	the z component
		 */	
		public function setDirection( p_nX:Number, p_nY:Number, p_nZ:Number ):void
		{
			_dir.x = p_nX; _dir.y = p_nY; _dir.z = p_nZ;
			dispatchEvent(new SandyEvent(SandyEvent.LIGHT_UPDATED));
		}
		
		/**
		 * Sets the direction of the light using the vector.
		 * 
		 * @param p_oDir	The direction of the light
		 */	
		public function setDirectionVector( p_oDir:Vector ):void
		{
			_dir = p_oDir;
			dispatchEvent(new SandyEvent(SandyEvent.LIGHT_UPDATED));
		}
		
		public function destroy():void
		{
			;
		}
	
		// Direction of the light. It is 3D vector. 
		//Please refer to the Light tutorial to learn more about Sandy's lights.
		private var _dir:Vector;	
		private var _power : Number;
	}
}