import sandy.core.data.Vector;
import sandy.core.group.Group;
import sandy.core.group.TransformGroup;
import sandy.core.Object3D;
import sandy.core.transform.Transform3D;
import sandy.core.World3D;
import sandy.events.ObjectEvent;
import sandy.primitive.Box;
import sandy.skin.MixedSkin;
import sandy.view.Camera3D;
import sandy.primitive.Cylinder;
import sandy.primitive.Sphere;

/**
 * @author tom
 */
class SmoothRotationTest 
{
	private var _mc : MovieClip;
	private var _fps:Number;
	private var _t:Number;
	private var _interaction:Boolean;
	private var o:Object3D;
	private var tg:TransformGroup;
	private static var WIDTH:Number = 300;
	private static var HEIGHT:Number = 300;
	private var _rotAxis:Vector;
	private var _oldMousePos:Vector;
	private var tr:Transform3D;
	private static var SPEED_COEF:Number = 1;
	
	public function SmoothRotationTest(mc:MovieClip )
	{
		_mc = mc;
		_interaction = false;
		_rotAxis = new Vector();
		_oldMousePos = new Vector( WIDTH/2, HEIGHT/2, 0);
		tr = new Transform3D();
		Mouse.addListener(this);
		__init ();
	}
	
	public static function main(mc:MovieClip ):Void
	{
		if ( ! mc ) mc = _root;
		var c : SmoothRotationTest = new SmoothRotationTest(mc);
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
	}
		
	function __init ():Void
	{
		_mc.createTextField( 'fps', 10000, 0, 20, 50, 20 );
		_t  = getTimer();
		_fps = 0;
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __refreshFps );
		// --
		World3D.getInstance().setContainer(_mc.createEmptyMovieClip ('screen', 1));
		var cam : Camera3D = new Camera3D (WIDTH, HEIGHT);
		cam.setPosition (0, 0, -500);
		World3D.getInstance().setCamera (cam);
		// --
		tg = new TransformGroup();
		var bg : Group = new Group ();
		var oSkin = new MixedSkin( 0xFF, 100, 0, 100, 2 );
		o = new Sphere( 80, 8, "quad");
		o.enableEvents(true);
		o.addEventListener(ObjectEvent.onPressEVENT, this, _onBoxPress);
		o.addEventListener(ObjectEvent.onReleaseEVENT, this, _onBoxRelease);
		o.addEventListener(ObjectEvent.onReleaseOutsideEVENT, this, _onBoxRelease);
		o.setSkin( oSkin );
		tg.addChild( o );
		bg.addChild( tg );
		World3D.getInstance().setRootGroup (bg);
		// --
		World3D.getInstance().render();
	}
	
	private function _onBoxPress( e:ObjectEvent ):Void
	{
		trace('interaction Enabled');
		_oldMousePos.x = WIDTH/2  - _mc._xmouse;;
		_oldMousePos.y = HEIGHT/2 - _mc._ymouse;
		_interaction = true;
	}
	
	private function _onBoxRelease( e:ObjectEvent ):Void
	{
		trace('interaction Disabled');
		_interaction = false;
	}
	
	private function onMouseMove( Void ):Void
	{
		if( _interaction )
		{
			var x:Number, y:Number, difX:Number, difY:Number;
			x = WIDTH/2  - _mc._xmouse;
			y = HEIGHT/2 - _mc._ymouse;
			difX = (x - _oldMousePos.x)*SPEED_COEF;
			difY = (y - _oldMousePos.y)*SPEED_COEF;
			_rotAxis.x += difY;
			_rotAxis.y += difX;
			tr.rot(_rotAxis.x, _rotAxis.y, 0);
			tg.setTransform( tr );
			_oldMousePos.x = x;
			_oldMousePos.y = y;
		}
	}
}
