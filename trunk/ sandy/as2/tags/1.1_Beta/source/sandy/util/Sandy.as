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

import sandy.view.*;
import sandy.core.*;
import sandy.core.group.*;
/**
* Sandy
* An utility class which goal is to simplify the creation of Sandy's applications.
* It creates a camera , a screen and a fps counter.
* To use it you have to extend your application class (if you decided to work with classes) from this one and to create
* a createScene method that has the following prototype:
* youApp.createScene( bg:BranchGroup ):Void;
* @author Thomas PFEIFFER / kiroukou
* @version 1.0
*/
class sandy.util.Sandy
{
	private var _mc : MovieClip;
	private var _fps:Number;
	private var _t:Number;
	
	public static var DIMX:Number = 300;
	public static var DIMY:Number = 300;
	public static var FOCALE:Number = 700;
	
	public function Sandy( mc:MovieClip ) 
	{
		_mc = mc;
		_mc.createTextField( 'fps', 10000, 0, 20, 50, 20 );
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __refreshFps );
		_t  = getTimer();
		_fps = 0;
		__start();
	}
	
	/**
	* Method to overload in your application. In this method you have to create your scene graph and use the argument bg as
	* the tree's root.
	* @param	bg
	*/
	public function createScene( bg:Group ):Void
	{
		// to implement in childs classes.
	}
	
	/**
	* Returns the MovieClip used to draw everything in.
	* @param	Void
	* @return MovieClip The container MovieClip
	*/
	public function getMovie( Void ):MovieClip
	{
		return _mc;
	}
	
	public function getCamera( Void ):Camera3D
	{
		return World3D.getInstance().getCamera( 0 );
	}
	
	///////////////
	/// PRIVATE 
	///////////////
	private function __start ( Void ):Void
	{
		var w:World3D = World3D.getInstance();
		__createCams();
		var bg:Group = new Group();
		createScene( bg );
		World3D.getInstance().setRootGroup( bg );
	}

	private function __createCams ( Void ):Void
	{
		var mc:MovieClip;var cam:Camera3D;var screen:ClipScreen;
		mc = _mc.createEmptyMovieClip( 'screen', 1 );
		screen = new ClipScreen( mc, Sandy.DIMX, Sandy.DIMY );
		cam = new Camera3D( Sandy.FOCALE, screen );
		World3D.getInstance().addCamera( cam );
	}
	
	private function __refreshFps ():Void
	{
		if( getTimer() > _t + 1000 )
		{
			_mc.fps.text = _fps+' ips';
			_fps = 0;
			_t = getTimer();
		}
		else _fps++;
	}
}
