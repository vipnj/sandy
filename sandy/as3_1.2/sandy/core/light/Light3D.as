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

package sandy.core.light {

	import sandy.core.data.Vector;
	import sandy.util.NumberUtil;
	import sandy.events.SandyEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	
	/**
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		02.06.2006
	* 
	**/
	public class Light3D extends EventDispatcher
	{
		
		/*
		* Maximum value accepted. If the default value (150) seems too big or too small for you, you can change it.
		*/
		public static var MAX_POWER:int = 150;

		/**
		 * Create a new {@code Light3D}.
		 * 
		 * @param	p		A {@code Vector4} for the {@code Light3D} position.
		 * @param	nCol	Color of the Light3D.
		 * 
		 */
		public function Light3D ( d:Vector, pow:Number )
		{
			_dir = d;
			setPower( pow );
		}
		
		/**
		 * The the power of the light. A number between 0 and MAX_POWER is necessary. 
		 * The highter the power of the light is, the less the shadows are visibles.
		 * @param n Number a Number between 0 and MAX_POWER. This number is the light intensity.
		 */
		public function setPower( n:Number )
		{
			_power =  NumberUtil.constrain( n, 0, Light3D.MAX_POWER );
			dispatchEvent( lightUpdateEvent );
		}
		
		/**
		 * Returns the power of the light.
		 * @return Number a number between 0 - MAX_POWER.
		 */
		public function getPower():Number
		{
			return _power;
		}
		
		public function getDirectionVector():Vector
		{
			return _dir;
		}
		
		/**
		 * Set the position of the {@code Light3D}.
		 * 
		 * @param	x	the x coordinate
		 * @param	y	the y coordinate
		 * @param	z	the z coordinate
		 */	
		public function setDirection( x:Number, y:Number, z:Number ):void
		{
			_dir.x = x; _dir.y = y; _dir.z = z;
			dispatchEvent( lightUpdateEvent );
		}
		
		public function setDirectionVector( pDir:Vector ):void
		{
			_dir = pDir;
			dispatchEvent( lightUpdateEvent );
		}
		
		public function destroy():void
		{
			;
		}

		// Direction of the light. It is 3D vector. Please refer to the Light tutorial to learn more about Sandy's lights.
		private var _dir:Vector;	
		private var _power : Number;
		
		// Events
		private var lightUpdateEvent:Event = new Event(SandyEvent.LIGHT_UPDATE);
		
	}
}