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
import sandy.util.TransformUtil;
import sandy.skin.Skin;
import sandy.skin.SimpleColorSkin;

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
		World3D.getInstance().setContainer(_mc.createEmptyMovieClip ('screen', 1) );
		var cam : Camera3D = new Camera3D (600, 600);
		cam.setPosition( 0, 80, 0 );
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
		var s:Skin = new MixedSkin( 0x00FF88, 100 );
		var leftWall:Plane3D = new Plane3D( 100, 500, 1, "tri");
		leftWall.name = "leftWall";
		var t:Transform3D = TransformUtil.translate(-250,50,0) ;
		t.combineTransform( TransformUtil.rot(90, 0, 90) );
		leftWall.setTransform( t );
		leftWall.enableClipping( true );
		leftWall.enableBackFaceCulling(false);
		leftWall.setSkin( s );
		
		var rightWall:Plane3D = new Plane3D( 100, 500, 1, "tri");
		rightWall.name = "rightWall";
		t = TransformUtil.translate(250,50,0) ;
		t.combineTransform( TransformUtil.rot(90, 0, 90) );
		rightWall.setTransform( t );
		rightWall.enableClipping( true );
		rightWall.enableBackFaceCulling(false);
		rightWall.setSkin( s );
		
		var frontWall:Plane3D = new Plane3D( 500, 100, 1, "tri");
		frontWall.name = "frontWall";
		t = TransformUtil.translate(0,50,250) ;
		t.combineTransform( TransformUtil.rot(90, 90, 0) );
		frontWall.setTransform( t );
		frontWall.enableClipping( true );
		frontWall.enableBackFaceCulling(false);
		frontWall.setSkin( s );
		
		var backWall:Plane3D = new Plane3D( 500, 100, 1, "tri");
		backWall.name = "backWall";
		t = TransformUtil.translate(0,50,-250) ;
		t.combineTransform( TransformUtil.rot(90, 90, 0) );
		backWall.setTransform( t );
		backWall.enableClipping( true );
		backWall.enableBackFaceCulling(false);
		backWall.setSkin( s );
		

		var floorSkin:Skin = new SimpleColorSkin( 0x999999, 100 );
		var floor:Plane3D = new Plane3D( 500, 500, 1, "tri");
		floor.name = "floor";
		floor.enableBackFaceCulling(false);
		floor.enableClipping( true );
		floor.setSkin( floorSkin );
		
		bg.addChild( leftWall );
		bg.addChild( rightWall );
		bg.addChild( backWall );
		bg.addChild( frontWall );
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