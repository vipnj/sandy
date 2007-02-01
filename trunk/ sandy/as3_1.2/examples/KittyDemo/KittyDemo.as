package {

	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.events.*;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
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
	import sandy.parser.*;
	
	import com.mir3.display.FPSMetter;
	import com.mir3.display.SceneStats;
	import com.mir3.utils.KeyManager;

	
	public class KittyDemo extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;
		
		private var world:MovieClip;
		private var _b:BitmapData;
		
		private var tf:TextField;
		private var _t:Number;
		private var _ad:AnimationData;
		private var _o:Object3D;
		private var _cam:Camera3D;
		private var _move:Boolean;
		private var distance:Number;
		private var circlePlace1:Number=0;
		private var _yaw:Number = 0;
		private var _pitch:Number = 0;
		
		public function KittyDemo()
		{
			// -- User interfaces
			KeyManager.initStage(stage);
			KeyManager.addKeyDown(keyDown);
			KeyManager.addKeyUp(keyUp);
			
			// -- FPS
			fps = new FPSMetter(false, 110, stage);
			addChild(fps);
			
			// -- STATS
			addChild(new SceneStats(false, false, false, stage));
			
			// -- Info TextField
			tf = new TextField();
			tf.x = 5;
			tf.y = 5;
			addChild(tf);
			
			initSandy();
			
			var loader:URLLoaderQueue = new URLLoaderQueue(["texture.jpg"], URLLoaderQueue.BITMAP);
			loader.addEventListener(SandyEvent.ALL_FINISHED, initAse);
			loader.load();
		}
		
		private function initAse(p_event:Event):void
		{
			// Save reference to loaded texture
			_b = p_event.target.getResources()[0].bitmapData;
			
			// Load model from ASE file
			aseParser = new AseParser();
			aseParser.addEventListener( SandyEvent.PARSING_PROGRESS, __onAseProgress );
			aseParser.addEventListener( SandyEvent.LOAD, __onLoad );
			aseParser.addEventListener( SandyEvent.FINISHED, init );
			
			_o = new Object3D();
			aseParser.parse( _o, "world.ase" );
		}

		private function initSandy():void
		{
			// +++	THIS HAS TO BE DONE ON THE VERY BEGINNING
			//		NO OBJECT WILL BE CREATED WITHOUT THESE LINES
			world = new MovieClip();
			world.x = (stage.stageWidth - SCREEN_WIDTH) / 2;
			world.y = (stage.stageHeight - SCREEN_HEIGHT) / 2;
			addChild(world);
			World3D.getInstance().setContainer(world);
			// ---
			
			
			var screen:ClipScreen = new ClipScreen( SCREEN_WIDTH, SCREEN_HEIGHT, 0x222222);
			var cam:Camera3D = new Camera3D( screen );
			World3D.getInstance().setCamera( cam );
		}
		
		private function init(p_event:Event)
		{	
			trace("Initializing scene...");
			trace("Kitty: " + _o);
			
			var g:Group = new Group();
			
			World3D.getInstance().setRootGroup( g );
			
			createScene(g);
			
			World3D.getInstance().render();
		}

		
		public function createScene( bg:Group ):void
		{
			var cam:Camera3D = World3D.getInstance().getCamera();
			distanceH = distance = 0;
			//cam.setPosition(Math.cos(circlePlace1*Math.PI/60)*distanceH, distance , Math.sin(circlePlace1*Math.PI/360)*distanceH);
			cam.setPosition( 0, 0, 0);
			cam.lookAt(0, 0, 1000);
			
			
			tg = new TransformGroup();
			t = new Transform3D();
			t.translate( 0, 0, 1000);
			//t.translate( 0, 0, 100);
			tg.setTransform( t );
			
			//var skin:TextureSkin = new TextureSkin( _b );
			//skin.setTransparency( 60 );
			//skin.setLightingEnable( true );
			
			//var skin:Skin = new SimpleColorSkin( 0x00F0FF, 100 );
			//skin.setLightingEnable( true );
			//_o.setSkin( skin );
			
			//_o = new Box(100,100,100, ' tri');
			
			tg.addChild( _o );
			bg.addChild( tg );
			
			World3D.getInstance().render();
		}
		
		private function __onLoad( p_event:Event ):void
		{
			tf.text = 'Loading...';
		}
		
		private function __onAseProgress( p_event:Event ):void
		{
			tf.text = "Object parsing : " + p_event.target.progress + " %";
		}
		
		private function __yoyo( p_event:Event ):void
		{
			p_event.target.redo();
		}
		
		private function keyDown(e:KeyboardEvent):void
		{
			var cam:Camera3D = World3D.getInstance().getCamera();

			if (e.keyCode == Keyboard.RIGHT)
			{
				cam.rotateY(5);		// yaw
				_yaw += 5;
			}
			if (e.keyCode == Keyboard.LEFT)
			{
				cam.rotateY(-5);	// yaw
				_yaw -= 5;
			}
			if (e.keyCode == Keyboard.UP)
			{
				cam.tilt(5);		// pitch (not really but OK since we don't roll)
				_pitch += 5;
			}
			if (e.keyCode == Keyboard.DOWN)
			{
				cam.tilt(-5);		// pitch (not really but OK since we don't roll)
				_pitch -= 5;
			}
			if (e.keyCode == Keyboard.SHIFT)
			{
				_fov -= 10;
				cam.setFocal(foc(_fov));	// zoom
				trace(_fov);
			}
			if (e.keyCode == Keyboard.CONTROL)
			{
				_fov += 10;
				cam.setFocal(foc(_fov));	// zoom
				trace(_fov);
			}

			if (_yaw > 180) _yaw -= 360;
			else if (_yaw < -180) _yaw += 360;
		}
		
		private function keyUp(p_event:Event):void
		{
			
		}
		
		private function fov(foc:Number):Number	// fov in degrees
		{
			return 360 * Math.atan(SCREEN_WIDTH/(2 * foc)) / Math.PI;
		}

		private function foc(fov:Number):Number	// fov in degrees
		{
			return SCREEN_WIDTH / (2 * Math.tan(Math.PI * fov/360));
		} 
	}
}