import sandy.core.group.Group;
import sandy.primitive.*;
import sandy.view.*;
import sandy.core.*;
import sandy.skin.MovieSkin;

// Use this class as follows:
// new ExternalMovieSkin11();

class ExternalMovieSkin11 {
	private var bg:Group;
	private var _externalFile;
	
	function ExternalMovieSkin11 (externalFile) {
		_externalFile = externalFile;
		init();
	}
	
	private function init( Void ):Void
	{
		// External MovieSkin example for Sandy 1.1.
		// Create the camera
		// Give it a focal distance and a reference to the viewing screen.
		var _clip_mc = _root.createEmptyMovieClip("_clip_mc", _root.getNextHighestDepth());
		var screen_cs:ClipScreen = new ClipScreen(_clip_mc, 500, 500, 0x0000);
		var cam = new Camera3D(500, screen_cs);
		
		
		// Position the camera up and away from the origin and have it point at (0,0,0)
		cam.translate(150, 150, -200);
		cam.lookAt(0,0,0);
		
		// Add the camera to the world
		World3D.getInstance().addCamera(cam);
		
		// Creat the root group.
		bg = new Group();
		
		// Set the root group of the world
		World3D.getInstance().setRootGroup(bg);
		
		// Add objects to the scene (see below)
		createScene(bg);
		
		// Render the world.
		World3D.getInstance().render();
	}
	
	private function createScene( bg:Group ):Void {
		var _mcl = new MovieClipLoader();
		_mcl.addListener(this);
		// Load the external URL into a temporary clip.
		// It will invoke onLoadInit();
		_root.createEmptyMovieClip("container", _root.getNextHighestDepth());
		_mcl.loadClip(_externalFile, _root.container);
	}
		
	private function onLoadInit (target:MovieClip):Void  { 
		// Hide the container clip.
		_root.container._visible = false;
		var skin1:MovieSkin = new MovieSkin(target, false);
		var o1:Object3D = new Plane3D(100, 100, 2, "tri");
		o1.setSkin(skin1);
		bg.addChild( o1 );
	}
}
