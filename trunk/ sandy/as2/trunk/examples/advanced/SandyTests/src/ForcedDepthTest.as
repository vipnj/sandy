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

/**
 * @author tom
 */
class ForcedDepthTest 
{
	private var _mc : MovieClip;
	private var _fps:Number;
	private var _t:Number;
	private var oPlane:Plane3D;
	
	public function ForcedDepthTest(mc : MovieClip )
	{
		_mc = mc;
		__init ();
	}
	
	public static function main(mc : MovieClip ) : Void
	{
		if ( ! mc ) mc = _root;
		var c : ForcedDepthTest = new ForcedDepthTest(mc);
	}
	
	function __init () : Void
	{
		var screen : ClipScreen = new ClipScreen ( 600, 300);
		World3D.getInstance().setContainer(_mc.createEmptyMovieClip ('screen', 1) );
		var cam : Camera3D = new Camera3D (screen);
		World3D.getInstance().setCamera (cam);
		var bg : Group = new Group ();
		World3D.getInstance().setRootGroup (bg);
		createScene (bg);
		_mc.createTextField( 'fps', 10000, 0, 20, 50, 20 );
		_t  = getTimer();
		_fps = 0;
		Key.addListener(this);
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __refreshFps );
		World3D.getInstance().render();
	}
	
	function onKeyDown( Void ):Void
	{
		oPlane.enableForcedDepth( !oPlane.isForcedDepthEnable() );
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
	
	function createScene (bg : Group) : Void
	{
		var oSphereSkinRollOut = new MixedSkin( 0xFF2222, 50, 0, 100, 1);
		var oPlaneSkin = new MixedSkin( 0xFF, 100, 0, 100, 2 );
		
		var oS1 = new Sphere( 20, 6, 'quad' );
		oS1.setSkin( oSphereSkinRollOut );
		oPlane = new Plane3D(800, 400, 1, 'quad' );
		oPlane.setSkin( oPlaneSkin );
		
		oPlane.enableForcedDepth(true);
		oPlane.setForcedDepth( 2 );

		var ease1 : Ease = new Ease();
		ease1.linear();
		
		var tg1: TransformGroup = new TransformGroup ();
		var pos = new PositionInterpolator(ease1.create() , 100, new Vector(0,10,-300), new Vector(0,10,200));
		
		tg1.setTransform(pos);
		pos.addEventListener (InterpolationEvent.onEndEVENT, this, __yoyo );
		var tgTranslation4 : TransformGroup = new TransformGroup ();
		var translation4 : Transform3D = new Transform3D ();
		translation4.translate (0, -100, 600);
		tgTranslation4.setTransform (translation4);
		tg1.addChild(oS1);
		tgTranslation4.addChild(tg1);
		tgTranslation4.addChild( oPlane );
		bg.addChild(tgTranslation4);
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