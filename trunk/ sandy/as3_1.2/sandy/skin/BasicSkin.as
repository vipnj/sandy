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
package sandy.skin {
		
	import sandy.skin.SkinType;
	import sandy.skin.Skin;
	import flash.events.EventDispatcher;
	import flash.display.DisplayObject;
	
	import sandy.events.SandyEvent;
	import sandy.core.face.IPolygon;
	import sandy.core.World3D;
	import sandy.core.light.Light3D;

	import flash.events.Event;
	
	/**
	 * ABSTRACT CLASS
	 * <p>
	 * This class is the basis of all the skins. It is abstract so that mean you can't instanciate this class.
	 * </p>
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		1.0
	 * @version		1.0
	 * @date 		23.06.2006
	 **/
	public class BasicSkin	extends EventDispatcher implements Skin
	{
		
		//////////////////
		// PROPERTIES
		//////////////////
		protected var _filters:Array;
		protected var _useLight : Boolean;
		private var _id:Number;
		private static var _ID_:Number = 0;

		protected var updateEvent:Event = new Event(SandyEvent.UPDATE);
		
		
		
		/**
		* Returns the type of SKin you are using.
		* For the BasicSkin class, this value is set to NONE
		* @param	void
		* @return SkinType The type constant which represents your skin.
		*/
		public function getType():SkinType
		{
			return SkinType.NONE;
		}
		
		/**
		 * setLightingEnable. Prepare the skin to use the world light or not. The default value is false.
		 * @param	bool	Boolean	true is the skin use the light of the world, false if no.
		 * @return	void
		 */
		public function setLightingEnable ( bool:Boolean ):void
		{
			if( _useLight != bool )
			{
				_useLight = bool;
				dispatchEvent( updateEvent );
			}		
		}
		
		/**
		* Set the value of the array of filters you want to apply to the object faces.
		* Warning : This is only available since Flash8.
		* @param	a Array the array containing the filters you want to apply, or an empty array if you want to clear the filters.
		*/
		public function set filters( a:Array )
		{
			_filters = a;
			dispatchEvent( updateEvent );
		}
		
		/**
		* Get the array of filters you are applying to the object faces.
		* Warning : This is only available since Flash8.
		* @return	Array the array containing the filters you are using, or an empty array if you don't apply anything
		*/
		public function get filters():Array
		{
			return _filters;
		}
		
		
		//////////////////
		// PRIVATE
		//////////////////	
		// TODO: privat ein original implementation
		public function BasicSkin()
		{
			super();
			_filters = [];
			_useLight = false;
			
			_id = _ID_++;
			World3D.getInstance().addEventListener( SandyEvent.LIGHT_ADDED, __onLightAdded );

		}
		
		private function __onLightAdded( e:Event ):void
		{
			World3D.getInstance().getLight().addEventListener( SandyEvent.LIGHT_UPDATE, __onLightUpdated );
		}
		
		private function __onLightUpdated( e:Event ):void
		{	
			if( _useLight )
				dispatchEvent( updateEvent );
		}

		
		///////////////////
		// SKIN
		///////////////////
		public function begin( f:IPolygon, mc:DisplayObject ):void
		{
			;
		}
		
		public function end( f:IPolygon, mc:DisplayObject ):void
		{
			;
		}
	}
}

class SingletonBlocker {}	