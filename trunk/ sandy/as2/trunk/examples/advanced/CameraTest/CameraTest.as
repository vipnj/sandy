import sandy.core.data.*;
import sandy.core.group.*;
import sandy.primitive.*;
import sandy.core.*;
import sandy.skin.*;
import sandy.util.Ease;
import sandy.core.transform.*;
import sandy.events.InterpolationEvent;
import sandy.util.*;
import sandy.view.Camera3D;
import sandy.view.ClipScreen;

/**
* @mtasc -main CameraTest -swf CameraTest.swf -header 300:300:120:FFFFFF -version 8 -wimp -trace org.flashdevelop.utils.FlashConnect.mtrace org/flashdevelop/utils/FlashConnect.as 
*/
class CameraTest
{
	/**
	* Entry point for MTASC compilation. If no Movieclip is given, _root will be choose.
	* @param	mc
	*/
	public static function main( mc:MovieClip ) : Void 
	{
		if( !mc ) mc = _root;
		var c = new CameraTest ( mc );
	}
	
	public function CameraTest( mc:MovieClip )
	{
		super( mc );
		init();
	}

	public function init()
	{
		var screen:ClipScreen = new ClipScreen( 300, 300 );
		var cam:Camera3D = new Camera3D( screen );
		cam.setPosition( 0, 0, -500 );
		World3D.getInstance().setCamera( cam );
		var g:Group = new Group();
		createScene(g);
		World3D.getInstance().setRootGroup( g );
		World3D.getInstance().render();
	}

	
	public function createScene( bg:Group ):Void
	{
		var e:Ease = new Ease();
		e.linear();
		// --
		var tg:TransformGroup = new TransformGroup();
		//
		var t:Transform3D = new Transform3D();
		t.translate( 0, 10 , 400 );
		tg.setTransform( t );
		//
		var o:Object3D, skin:Skin;
		o = new Sprite3D(3, 0);
		skin = new MovieSkin( "180.swf", true );
		o.setSkin( skin );
		//
		tg.addChild( o );
		bg.addChild( tg );
		//
		tg = new TransformGroup();
		t = new Transform3D();
		t.translate( 0, -40 , 400 );
		tg.setTransform( t );
		o = new Box( 300, 2, 300, 'quad' );
		skin = new SimpleColorSkin( 0xFF0000, 100 );
		o.setSkin( skin );
		tg.addChild( o );
		bg.addChild( tg );
		//
		tg = new TransformGroup();
		o = new Box( 30, 30, 30, 'quad' );
		skin = new SimpleColorSkin( 0xFF, 100 );
		skin.setLightingEnable( true );
		o.setSkin( skin );
		var ease:Ease = new Ease();
		ease.bounce(1);
		ease.easingOutToBackIn();
		var posint:PositionInterpolator = new PositionInterpolator( ease.create(), 150, new Vector(50, 0, 500), new Vector( 50, 60, 500 ) );
		posint.addEventListener( InterpolationEvent.onEndEVENT, this, __onCubeEnd );
		tg.addChild( o );
		tg.setTransform( posint );
		bg.addChild( tg );

		var path:BezierPath = new BezierPath();
		path.addPoint(  0, 50, -500 ) ;
		path.addPoint( -900, 50, 900 );
		path.addPoint(  0, 50, 900 );
		path.addPoint( 900, 50, 1000 );
		path.addPoint( 0, 50, -500 );
		path.compile();
		var int:PathInterpolator = new PathInterpolator( e.create(), 600, path );
		int.addEventListener( InterpolationEvent.onProgressEVENT, 	this, __onCamMove );
		int.addEventListener( InterpolationEvent.onEndEVENT, 		this, __onCamMoveEnd );
		World3D.getInstance().getCamera().setInterpolator( int );

	}
	
	private function __onCamMove( e:InterpolationEvent ):Void
	{
		World3D.getInstance().getCamera().lookAt( 0, 0, 400 );
	}
	private function __onCamMoveEnd( e:InterpolationEvent ):Void
	{
		e.getTarget().yoyo();
	}

	private function __onCubeEnd( e:InterpolationEvent ):Void
	{
		e.getTarget().redo();
	}
}
