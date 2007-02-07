import sandy.core.data.Vector;
import sandy.core.group.Group;
import sandy.core.group.TransformGroup;
import sandy.core.transform.PositionInterpolator;
import sandy.core.transform.RotationInterpolator;
import sandy.core.transform.Sequence3D;
import sandy.core.transform.Transform3D;
import sandy.core.World3D;
import sandy.events.InterpolationEvent;
import sandy.events.ObjectEvent;
import sandy.primitive.Sphere;
import sandy.skin.MixedSkin;
import sandy.skin.Skin;
import sandy.util.Ease;
import sandy.view.Camera3D;

/**
* @mtasc -main Test_Custom -swf Test_Custom.swf -header 600:300:120:FFFFFF -version 8 -wimp
*/
class Sequence3DTest
{
	private var _mc : MovieClip;
	private var _fps:Number;
	private var _t:Number;
	private var _paused:Boolean;
	private var S1:Sphere;
	private var SphereSkinRollOver:Skin;
	private var SphereSkinRollOut:Skin;
	private var seq:Sequence3D;
	
	function init () : Void
	{
		World3D.getInstance().setContainer(_mc.createEmptyMovieClip ('screen', 1));
		var cam : Camera3D = new Camera3D (600, 300);
		cam.setPosition (0, 0, 0);
		World3D.getInstance().setCamera (cam);
		var bg : Group = new Group ();
		World3D.getInstance().setRootGroup (bg);
		createScene (bg);
		_mc.createTextField( 'fps', 10000, 0, 20, 50, 20 );
		_t  = getTimer();
		_fps = 0;
		_paused = false;
		Key.addListener(this);
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __refreshFps );
		World3D.getInstance().render();
	}

	private function onKeyDown(Void):Void
	{
		//trace("onKeyDown :: getAscii : "+Key.getAscii()+";getCode : "+Key.getCode() );
		if(Key.getCode() == 89)
		{
			trace("Test::yoyo");
			seq.yoyo();
		}
		else if(Key.getCode() == 82)
		{
			trace("Test::redo");
			seq.redo();
		}
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
	
	function createScene (bg : Group) : Void
	{
		SphereSkinRollOut = new MixedSkin( 0xFF2222, 50, 0, 100, 1);
		//SphereSkinRollOut.setLightingEnable(true);
		SphereSkinRollOver = new MixedSkin( 0x22FF22, 30, 0, 100, 1);
		//SphereSkinRollOver.setLightingEnable(true);
		S1 = new Sphere( 20, 6, 'quad' );
		S1.enableBackFaceCulling(false);
		S1.setSkin( SphereSkinRollOut );
		S1.setBackSkin( SphereSkinRollOut );
		S1.enableEvents(true);
		S1.addEventListener(ObjectEvent.onPressEVENT, this, __pauseAndResume);
		S1.addEventListener(ObjectEvent.onRollOverEVENT, this, __setRollOverSkin);
		S1.addEventListener(ObjectEvent.onRollOutEVENT, this, __setRollOutSkin);

		var ease1 : Ease = new Ease();
		ease1.linear();
		var rotint : RotationInterpolator;
		var tg1: TransformGroup = new TransformGroup ();

		seq = new Sequence3D ();
		seq.addChild(new PositionInterpolator(ease1.create() , 20, new Vector(0,0,0), new Vector(-50,-50,0)));		
		rotint = new RotationInterpolator (ease1.create () , 50, 0, 180);
		rotint.setAxisOfRotation(new Vector(0,0,-1));
		rotint.setPointOfReference(new Vector(0,-50,0));
		seq.addChild(rotint);

		seq.addChild(new PositionInterpolator(ease1.create() , 20, new Vector(0,0,0), new Vector(-50,50,0)));	
		seq.addChild(new PositionInterpolator(ease1.create() , 20, new Vector(0,0,0), new Vector(-50,-50,0)));

		rotint = new RotationInterpolator (ease1.create () , 50, 0, 180);
		rotint.setAxisOfRotation(new Vector(0,0,-1));
		rotint.setPointOfReference(new Vector(0,-50,0));
		seq.addChild(rotint);
		
		seq.addChild(new PositionInterpolator(ease1.create() , 20, new Vector(0,0,0), new Vector(-50,50,0)));
		tg1.setTransform(seq);	
		seq.addEventListener (InterpolationEvent.onEndEVENT, this, __redo );

		var tgTranslation4 : TransformGroup = new TransformGroup ();
		var translation4 : Transform3D = new Transform3D ();
		translation4.translate (0, 0, 200);
		tgTranslation4.setTransform (translation4);
		tg1.addChild(S1);	
		tgTranslation4.addChild(tg1);
		bg.addChild(tgTranslation4);
	}

	public function Sequence3DTest(mc : MovieClip )
	{
		_mc = mc;
		init ();
	}

	public static function main(mc : MovieClip ) : Void
	{
		if ( ! mc ) mc = _root;
		var c : Sequence3DTest = new Sequence3DTest(mc);
	}

	private function __redo( e:InterpolationEvent ):Void
	{
		e.getTarget().redo();
	}

	private function __yoyo( e:InterpolationEvent ):Void
	{
		e.getTarget().yoyo();
	}

	private function __pauseAndResume( e:ObjectEvent ):Void
	{
		if(_paused) seq.resume();
		else  seq.pause();
		_paused = !_paused;
	}

	private function __setRollOverSkin( e:ObjectEvent ):Void
	{
		S1.setSkin( SphereSkinRollOver );
		S1.setBackSkin( SphereSkinRollOver );
	}

	private function __setRollOutSkin( e:ObjectEvent ):Void
	{
		S1.setSkin( SphereSkinRollOut );
		S1.setBackSkin( SphereSkinRollOut );
	}
}

