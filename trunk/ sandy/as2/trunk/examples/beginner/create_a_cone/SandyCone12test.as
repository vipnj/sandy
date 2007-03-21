// Sandy 1.2 testbed for the Cone class.
import sandy.core.World3D;
import sandy.view.Camera3D;
import sandy.primitive.Conic;
import sandy.primitive.Cone;
import sandy.primitive.Cylinder;
import sandy.core.group.Group;
import sandy.skin.MixedSkin;

var _rootGroup:Group;
var cam:Camera3D;

function initWorld():Void {
	_mc = _root;

	var world:World3D = World3D.getInstance(); // Our 3D world
	
	// 1.2 no need for ClipScreen
	// Create a camera, so we can see our world.
	cam = new Camera3D(300, 300);  // 1.2 uses height and width instead
	cam.setPosition(250, 250, -500);
	
	cam.lookAt(0, 0, 0);
	
	// Attach the camera to the world. 1.2 uses setCamera instead of addCamera.
	world.setCamera(cam);
	
	// Create the root group and attach it to the world.
	_rootGroup = new Group();
		
	world.setRootGroup(_rootGroup);

	createScene();

	// Finally we start rendering the world
	world.render();
}
	
function createScene() {
	// Known bug - doesn't render end faces in quad mode in 1.2
	//var coneObj:Cylinder = new Cylinder(50, 80, 8, "tri", false, true);
	//var coneObj:Conic = new Conic(80, 50, 200, 8, "tri", false, false, false, false);
	var coneObj:Cone = new Cone(50, 200, 8, false, false, false);
	
	var skin:MixedSkin = new MixedSkin (0xff0000, 50, 0, 200, 2);
	coneObj.setSkin(skin);
	coneObj.setBackSkin(skin);
	coneObj.enableBackFaceCulling(false);
	_rootGroup.addChild(coneObj);
}


initWorld();