package {

	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.*;
	
	import sandy.core.group.*;
	import sandy.primitive.*;
	import sandy.core.*;
	import sandy.core.data.*;
	import sandy.skin.*;
	import sandy.util.Ease;
	import sandy.core.transform.*;
	import sandy.events.*;
	import sandy.util.*;
	import sandy.view.Camera3D;
	import sandy.view.ClipScreen;
	 
	import com.mir3.display.FPSMetter;
	import com.mir3.display.SceneStats;
	import com.mir3.utils.KeyManager;

	public class CameraTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;
		
		private var world:MovieClip;
		
		public function CameraTest()
		{
			// -- User interfaces
			KeyManager.initStage(stage);
			
			// -- FPS
			addChild(new FPSMetter(false, 110, stage));
			
			// -- STATS
			addChild(new SceneStats(false, false, false, stage));			
			
			
			init();
		}

		public function init()
		{
			world = new MovieClip();
			world.x = (stage.stageWidth - SCREEN_WIDTH) / 2;
			world.y = (stage.stageHeight - SCREEN_HEIGHT) / 2;
			addChild(world);
			World3D.getInstance().setContainer(world);
			
			var screen:ClipScreen = new ClipScreen( SCREEN_WIDTH, SCREEN_HEIGHT, 0x222222);
			var cam:Camera3D = new Camera3D( screen );
			cam.setPosition( 0, 0, -500 );
			World3D.getInstance().setCamera( cam );
			
			var g:Group = new Group();
			
			createScene(g);
			
			World3D.getInstance().setRootGroup( g );
			
			World3D.getInstance().render();
		}

		
		public function createScene( bg:Group ):void
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
			o = new Sprite3D(1, 0);
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
			o = new Box( 40, 40, 40, 'quad');
			skin = new SimpleColorSkin( 0x0000FF, 100 );
			skin.setLightingEnable( true );
			o.setSkin( skin );
			var ease:Ease = new Ease();
			ease.bounce(1);
			ease.easingOutToBackIn();
			var posint:PositionInterpolator = new PositionInterpolator( ease.create(), 150, new Vector(50, 0, 500), new Vector( 50, 60, 500 ) );
			posint.addEventListener( SandyEvent.END, __onCubeEnd );
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
			
			var pInt:PathInterpolator = new PathInterpolator( e.create(), 600, path );
			pInt.addEventListener( SandyEvent.PROGRESS, __onCamMove );
			pInt.addEventListener( SandyEvent.END, __onCamMoveEnd );
			World3D.getInstance().getCamera().setInterpolator( pInt );
		}
		
		private function __onCamMove( e:Event ):void
		{
			World3D.getInstance().getCamera().lookAt( 0, 0, 400 );
		}
		private function __onCamMoveEnd( e:Event ):void
		{
			e.target.yoyo();
		}

		private function __onCubeEnd( e:Event ):void
		{
			e.target.redo();
		}
	}
}