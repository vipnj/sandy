import sandy.core.group.Group;
import sandy.primitive.*;
import sandy.view.*;
import sandy.core.*;
import sandy.skin.MovieSkin;
import sandy.events.*;

// Use this class as follows:
// new ExternalMovieSkin12("externalExample.swf");

class ExternalMovieSkin12 {

	private var bg:Group;
	private var _externalFile;
	function ExternalMovieSkin12 (externalFile) {
		_externalFile = externalFile;
		init();
	}
	
	private function init( Void ):Void
	{
		// External MovieSkin example for Sandy 1.2.
		// Create the camera
		var cam = new Camera3D(500, 500);
		
		// Position the camera up and away from the origin and have it point at (0,0,0)
		cam.translate(150, 150, -200);
		cam.lookAt(0,0,0);
		// Add the camera to the world
		World3D.getInstance().setCamera(cam);
		
		// Creat the root group.
		bg = new Group();
		// Set the root group of the world
		World3D.getInstance().setRootGroup(bg);
		// Add objects to the scene (see below)
		createScene(bg);
		// Render the world.
		World3D.getInstance().render();
	}
	
	private function createScene(bg:Group):Void {
		var skin1:MovieSkin;
		skin1 = new MovieSkin(_externalFile, false);
		skin1.addEventListener(SkinEvent.onUpdateEVENT, this, onLoadInit);
	}
		
	private function onLoadInit (target:Object) {
		var o1:Object3D = new Plane3D(100, 100, 2, "tri");
		o1.setSkin(target._oT);
		bg.addChild(o1);
	}
}
