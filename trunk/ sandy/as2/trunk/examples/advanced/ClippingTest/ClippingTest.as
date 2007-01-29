import sandy.core.data.Vector;
import sandy.core.group.Group;
import sandy.core.group.TransformGroup;
import sandy.core.transform.PositionInterpolator;
import sandy.core.transform.Transform3D;
import sandy.core.World3D;
import sandy.events.InterpolationEvent;
import sandy.primitive.Plane3D;
import sandy.primitive.Sphere;
import sandy.skin.MixedSkin;
import sandy.util.Ease;
import sandy.view.Camera3D;
import sandy.view.ClipScreen;
import sandy.util.TransformUtil;

/**
 * @author tom
 */
class ClippingTest 
{
	private var _mc : MovieClip;
	private var _fps:Number;
	private var _t:Number;
	private var oPlane:Plane3D;
	
	public function ClippingTest(mc : MovieClip )
	{
		_mc = mc;
		__init ();
	}
	
	public static function main(mc : MovieClip ) : Void
	{
		if ( ! mc ) mc = _root;
		var c : ClippingTest = new ClippingTest(mc);
	}
	
	function __init () : Void
	{
		var screen : ClipScreen = new ClipScreen ( 600, 600);
		World3D.getInstance().setContainer(_mc.createEmptyMovieClip ('screen', 1) );
		var cam : Camera3D = new Camera3D (screen);
		cam.setPosition( 0, 80, -300 );
		World3D.getInstance().setCamera (cam);
		var bg : Group = new Group ();
		World3D.getInstance().setRootGroup (bg);
		createScene (bg);
		_mc.createTextField( 'fps', 10000, 0, 20, 50, 20 );
		_t  = getTimer();
		_fps = 0;
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __refreshFps );
		World3D.getInstance().render();
	}
	

	function __refreshFps ():Void
	{
		if( getTimer() > _t + 1000 )
		{
			_mc.fps.text = _fps+' ips';
			_fps = 0;
			_t = getTimer();
		}
		else _fps++;
		
		var cam:Camera3D = World3D.getInstance ().getCamera();
		// rotation around the global vertical axis
		switch( true )
		{
			case Key.isDown (Key.RIGHT)	: cam.rotateY ( 1 ); 		break;
			case Key.isDown (Key.LEFT)	: cam.rotateY ( -1 ); 		break;
			case Key.isDown (Key.UP)	: cam.moveForward ( 2 ); 	break;
			case Key.isDown (Key.DOWN)	: cam.moveForward ( -2 ); 	break;
			//case Key.isDown (Key.SHIFT)	: cam.tilt ( 1 ); 		break;
			//case Key.isDown (Key.CONTROL) : cam.tilt ( -1 ); 		break;
		}
	}
	
	function createScene (bg : Group) : Void
	{
		var leftWall:Plane3D = new Plane3D( 100, 400, 1);
		leftWall.name = "leftWall";
		var t:Transform3D = TransformUtil.translate(-50,50,0) ;
		t.combineTransform( TransformUtil.rot(90, 0, 90) );
		leftWall.setTransform( t );
		leftWall.enableBackFaceCulling(false);
		leftWall.enableClipping( true );
		
		var rightWall:Plane3D = new Plane3D( 100, 400, 1);
		rightWall.name = "rightWall";
		t = TransformUtil.translate(50,50,0) ;
		t.combineTransform( TransformUtil.rot(90, 0, 90) );
		rightWall.setTransform( t );
		rightWall.enableBackFaceCulling(false);
		rightWall.enableClipping( true );
		
		var floor:Plane3D = new Plane3D( 400, 100, 1);
		floor.name = "floor";
		floor.enableBackFaceCulling(false);
		floor.enableClipping( true );
		
		bg.addChild( leftWall );
		bg.addChild( rightWall );
		bg.addChild( floor );
	}
	
	private function __redo( e:InterpolationEvent ):Void
	{
		e.getTarget().redo();
	}
	
	private function __yoyo( e:InterpolationEvent ):Void
	{
		e.getTarget().yoyo();
	}
			
}