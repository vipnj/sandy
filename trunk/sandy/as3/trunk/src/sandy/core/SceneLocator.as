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

package sandy.core
{
	import flash.utils.Dictionary;

	public class SceneLocator
	{

		private static var _oI	: SceneLocator;
		private var _m		 	: Dictionary;

		public function SceneLocator( access : PrivateConstructorAccess )
		{
			_m = new Dictionary( true );
		}

		public static function getInstance() : SceneLocator
		{
			if ( !_oI ) _oI = new SceneLocator( new PrivateConstructorAccess() );
			return _oI
		}


		/**
		 * Get the Scene3D object by using its name
		 * @param	key : String, name of the scene you want to get
		 * @return	Scene3D
		 */
		public function getScene( key : String ) : Scene3D
		{
			if ( !(isRegistered( key )) ) trace( "Can't locate scene instance with '" + key + "' name in " + this );
			return _m[ key ] as Scene3D;
		}

		/**
		 * Check if the scene is registered already
		 * @param	key : String, name
		 * @return	Boolean
		 */
		public function isRegistered( key : String ) : Boolean
		{
			return _m[ key ] == null;
		}

		/**
		 * Register a scene to the SceneLocator
		 * @param	key : String, name of the scene to register
		 * @param	o	: Scene3D, object to register
		 * @return	Boolean
		 */
		public function registerScene( key : String, o : Scene3D ) : Boolean
		{
			if ( isRegistered( key ) )
			{
				trace( "scene instance is already registered with '" + key + "' name in " + this );
				return false;

			}
			else
			{
				_m[ key ] = o;
				return true;
			}
		}

		/**
		 * Unregister a scene
		 * @param	key : String, name of the scene to unregister
		 */
		public function unregisterScene( key : String ) : void
		{
			_m[ key ] = null;
		}

	}
}

internal final class PrivateConstructorAccess {}
