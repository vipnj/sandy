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
// new create_a_first_box();

class create_a_first_box {

private  static var bg:Group;

	function create_a_first_box () {
		init();
	}
	
	private function init( Void ):Void
	{
		// Create-a-bnox example for Sandy 1.2. Differs from the 1.1 version.
		// Create the camera
		var cam:Camera3D = new Camera3D( 300, 300);
		// Position the camera up and away from the origin and have it point at (0,0,0)
		cam.translate(50,150,-150);
		cam.lookAt(0,0,0);
		// Add the camera to the world
		World3D.getInstance().setCamera( cam );
		// Creat the root group.
		bg = new Group();
		// Set the root group of the world
		World3D.getInstance().setRootGroup( bg );
		// Add objects to the scene (see below)
		createScene( bg );
		// Render the world.
		World3D.getInstance().render();
	}
	
	private function createScene( bg:Group ):Void
	{
		// Create a cube.
		var o1:Object3D = new Box( 50, 50, 50, "tri", 3);
		
		var skin1:MixedSkin = new MixedSkin(0xff0000, 50, 0, 100, 2);
		o1.setSkin(skin1);
	
		bg.addChild( o1 );
	}
}
