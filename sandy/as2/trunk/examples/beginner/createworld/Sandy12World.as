import sandy.core.data.*;
import sandy.core.group.Group;
import sandy.primitive.*;
import sandy.view.*;
import sandy.core.*;
import sandy.skin.MixedSkin;
import sandy.util.*;
import sandy.core.transform.*;
import sandy.events.*;

// Use this class as follows:
// new Sandy12World();

class Sandy12World {

private static var bg:Group;

	function Sandy12World () {
		init();
	}
	
	private function init( Void ):Void
	{
		// This sets up what you need for a Sandy 1.2 World
		// Create the camera
		var cam = new Camera3D(500, 500);
		
		// Position the camera up and away from the origin and have it point at (0,0,0)
		cam.translate(250, 250, -500);
		cam.lookAt(0,0,0);
		
		// Add the camera to the world
		World3D.getInstance().setCamera(cam);
		// Creat the root group.
		bg = new Group();
		
		// Set the root group of the world
		World3D.getInstance().setRootGroup(bg);
		
		// Add a primitive object to the scene (see below)
		createScene(bg);
		
		// Render the world.
		World3D.getInstance().render();
	}
	
	private function createScene(bg:Group):Void
	{
		// Create a box and add it to the world's rootgroup.
		var o1:Box = new Box( 100, 100, 100, "tri", 2);
		var skin1:MixedSkin = new MixedSkin(0xff0000, 50, 0, 100, 2);
		o1.setSkin(skin1);
		bg.addChild(o1);
	}
}
