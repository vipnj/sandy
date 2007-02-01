package {

	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
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

	
	public class CubeRotationTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 300;
		internal static const SCREEN_HEIGHT:int = 300;
		
		private var world:MovieClip;
		private var _b:BitmapData;
		
		public function CubeRotationTest()
		{
			// -- User interfaces
			KeyManager.initStage(stage);
			
			// -- FPS
			addChild(new FPSMetter(false, 110, stage));
			
			// -- STATS
			addChild(new SceneStats(false, false, false, stage));
			
			
			var loader:URLLoaderQueue = new URLLoaderQueue(["right.jpg"], URLLoaderQueue.BITMAP);
			loader.addEventListener(SandyEvent.ALL_FINISHED, init);
			loader.load();
		}

		public function init(p_event:Event)
		{
			_b = p_event.target.getResources()[0].bitmapData;
			
			world = new MovieClip();
			world.x = (stage.stageWidth - SCREEN_WIDTH) / 2;
			world.y = (stage.stageHeight - SCREEN_HEIGHT) / 2;
			addChild(world);
			World3D.getInstance().setContainer(world);
			
			var screen:ClipScreen = new ClipScreen( SCREEN_WIDTH, SCREEN_HEIGHT, 0x222222);
			var cam:Camera3D = new Camera3D( screen );
			cam.setPosition( 0, 0, 0 );
			World3D.getInstance().setCamera( cam );
			
			var g:Group = new Group();
			createScene(g);
			
			World3D.getInstance().setRootGroup( g );
			World3D.getInstance().render();
		}

		
		public function createScene( bg:Group ):void
		{
			
			// -- interpolator
			var myEase:Ease = new Ease();
			//
			var tgRotation:TransformGroup;
			var tgTranslation:TransformGroup;
			tgRotation 	= new TransformGroup();
			tgTranslation	= new TransformGroup();
			
			//
			var translation:Transform3D = new Transform3D();
			translation.translate( 0, 0, 200 );
			tgTranslation.setTransform( translation );
			
			//
			var rotint:RotationInterpolator = new RotationInterpolator( myEase.create(), 500 );
			
			// -- listener
			rotint.addEventListener( SandyEvent.END, __yoyo );
			rotint.addEventListener( SandyEvent.PROGRESS, __playMouse );
			
			// -- earth
			var box:Box = new Box( 100, 80, 50, 'tri', 2 );
			var skin:TextureSkin;
			skin = new TextureSkin( _b );
			skin.setTransparency(90);
			//skin = new MixedSkin( 0xFF0000, 100, 0x0, 50, 2 );
			box.setSkin( skin );
			//
			tgRotation.setTransform( rotint );
			tgRotation.addChild( box );
			tgTranslation.addChild( tgRotation );
			bg.addChild( tgTranslation );
			
			World3D.getInstance().render();
		}
		
		private function __yoyo( e:Event ):void
		{
			e.target.redo();
		}
		
		private function __playMouse( e:Event ):void
		{
			var difX:Number = 150 - world.mouseX;
			var difY:Number = 150 - world.mouseY;
			var dist:Number = Math.sqrt( difX*difX  + difY*difY );
			
			RotationInterpolator(e.target).setAxisOfRotation( new Vector( -difY, difX, 0 ) );
			RotationInterpolator(e.target).setDuration( 10000 / dist );
		}	
	}
}