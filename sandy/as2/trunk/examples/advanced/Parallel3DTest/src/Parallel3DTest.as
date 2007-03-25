import com.bourre.log.Logger;
import com.bourre.utils.LuminicTracer;

import sandy.core.data.Vector;
import sandy.core.group.Group;
import sandy.core.group.TransformGroup;
import sandy.core.transform.Parallel3D;
import sandy.core.transform.PositionInterpolator;
import sandy.core.transform.RotationInterpolator;
import sandy.core.transform.Transform3D;
import sandy.core.World3D;
import sandy.events.InterpolationEvent;
import sandy.events.ObjectEvent;
import sandy.primitive.Sphere;
import sandy.skin.MixedSkin;
import sandy.skin.Skin;
import sandy.util.Ease;
import sandy.view.Camera3D;

class Parallel3DTest
{
	private var _mc : MovieClip;
	
	private var _fps:Number;
	private var _t:Number;
	
	private var _paused:Boolean;
	private var S1:Sphere;
	private var SphereSkinRollOver:Skin;
	private var SphereSkinRollOut:Skin;
	private var par:Parallel3D;
	
	function init () : Void
	{
		World3D.getInstance().setContainer(_mc.createEmptyMovieClip ('screen', 1));
		var cam : Camera3D = new Camera3D (600, 300);
		cam.setPosition (0, 0, -500);
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
			par.yoyo();
		}
		else if(Key.getCode() == 82)
		{
			trace("Test::redo");
			par.redo();
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
		S1.enableBackFaceCulling( false );
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
		
		par = new Parallel3D ();
		
		rotint = new RotationInterpolator (ease1.create () , 200, 0, 360);
		rotint.setAxisOfRotation(new Vector(0,1,1));
		rotint.setPointOfReference(new Vector(50,0,0));
		par.addChild(rotint);
		
		par.addChild(new PositionInterpolator(ease1.create() , 300, new Vector(0,0,0), new Vector(300,0,0)));
		
		tg1.setTransform(par);
		
		par.addEventListener (InterpolationEvent.onEndEVENT, this, __yoyo );
		
		tg1.addChild(S1);
	
		
		bg.addChild(tg1);
	}
	
	public function Parallel3DTest(mc : MovieClip )
	{
		// Ajouter LuminicTracer comme écouteur.
		Logger.getInstance().addLogListener( LuminicTracer.getInstance() );

		_mc = mc;
		init ();
	}
	
	public static function main(mc : MovieClip ) : Void
	{
		if ( ! mc ) mc = _root;
		var c : Parallel3DTest = new Parallel3DTest(mc);
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
		if(_paused) par.resume();
		else  par.pause();
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
