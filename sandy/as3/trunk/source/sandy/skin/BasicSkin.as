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
package sandy.skin
{
	import flash.events.EventDispatcher;
	
	import sandy.events.SkinEvent;
	import sandy.skin.SkinType;
	
	/**
	 * ABSTRACT CLASS
	 * <p>
	 * This class is the basis of all the skins. It is abstract so that mean you can't instanciate this class.
	 * </p>
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		1.0
	 * @date 		05.08.2006
	 **/
	internal class BasicSkin extends EventDispatcher
	{
		/**
		 *  The Transformation end Event. Broadcasted when the Interpolation is finished
		 */
		public static const onUpdateEVENT:String = SkinEvent.onUpdateEVENT;
		
		/**
		 * Returns the type of SKin you are using.
		  * For the BasicSkin class, this value is set to NONE
		 * @param	Void
		 * @return SkinType The type constant which represents your skin.
		 */
		public function getType():uint
		{
			return SkinType.NONE;
		}
		
		/**
		 * setLightingEnable. Prepare the skin to use the world light or not. The default value is false.
		 * @param	bool	Boolean	true is the skin use the light of the world, false if no.
		 * @return	Void
		 */
		public function setLightingEnable ( bool:Boolean ):void
		{
			if( _useLight != bool )
			{
				_useLight = bool;
				dispatchEvent( _eOnUpdate );
			}		
		}
		
		/**
		* Set the value of the array of filters you want to apply to the object faces.
		* Warning : This is only available since Flash8.
		* @param	a Array the array containing the filters you want to apply, or an empty array if you want to clear the filters.
		*/
		public function set filters( a:Array ):void
		{
			_filters = a;
			dispatchEvent( _eOnUpdate );
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
		function BasicSkin()
		{
			super();
			_eOnUpdate 	= new SkinEvent( SkinEvent.onUpdateEVENT, getType() );
			_filters 	= new Array();
			_useLight 	= false;
		}
		
		//////////////////
		// PROPERTIES
		//////////////////
		protected var _filters:Array;
		protected var _useLight:Boolean;
		protected var _eOnUpdate:SkinEvent;
		
	}

}