package 
{

	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.events.*;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import sandy.core.data.Vector;
	import sandy.core.group.Group;
	import sandy.core.group.TransformGroup;
	import sandy.core.transform.PositionInterpolator;
	import sandy.core.transform.RotationInterpolator;
	import sandy.core.transform.Transform3D;
	import sandy.core.World3D;
	import sandy.core.Object3D;
	import sandy.events.SandyEvent;
	import sandy.primitive.Plane3D;
	import sandy.primitive.Sphere;
	import sandy.primitive.Box;
	import sandy.skin.MixedSkin;
	import sandy.skin.MovieSkin;
	import sandy.skin.SimpleColorSkin;
	import sandy.skin.Skin;
	import sandy.util.Ease;
	import sandy.view.Camera3D;
	import sandy.view.ClipScreen;
	import sandy.util.TransformUtil;

	import com.mir3.display.FPSMetter;
	import com.mir3.display.SceneStats;
	import com.mir3.utils.KeyManager;
	
	
	
	/**
	 * @author tom
	 */
	public class MovieSkinTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;
		
		private var _mc : MovieClip;
		private var _fps:Number;
		private var _t:Number;
		private var oPlane:Plane3D;
		
		private var world:MovieClip;
		private var _earthRadius:Vector;
		private var _sunPosition:Vector;
		
		
		
		public function MovieSkinTest()
		{
			// -- User interfaces
			KeyManager.initStage(stage);
			KeyManager.addKeyDown(keyDown);
			//KeyManager.addKeyUp(keyUp);
			
			// -- FPS
			fps = new FPSMetter(false, 110, stage);
			addChild(fps);
			
			// -- STATS
			addChild(new SceneStats(false, false, false, stage));
			
			
			init();
		}
		
		
		private function init () : void
		{
			// +++	THIS HAS TO BE DONE ON THE VERY BEGINNING
			//		NO OBJECT WILL BE CREATED WITHOUT THESE LINES
			world = new MovieClip();
			world.x = (stage.stageWidth - SCREEN_WIDTH) / 2;
			world.y = (stage.stageHeight - SCREEN_HEIGHT) / 2;
			addChild(world);
			World3D.getInstance().setContainer(world);
			// ---
			
			var screen : ClipScreen = new ClipScreen( SCREEN_WIDTH, SCREEN_HEIGHT, 0x222222);
			var cam : Camera3D = new Camera3D (screen);
			cam.setPosition( 0, 0, -50 );
			World3D.getInstance().setCamera (cam);
			var bg : Group = new Group ();
			World3D.getInstance().setRootGroup (bg);
			
			createScene (bg);
			
			World3D.getInstance().render();
		}
		

		private function keyDown(e:KeyboardEvent):void
		{
			
			var cam:Camera3D = World3D.getInstance ().getCamera();
			
			switch( e.keyCode )
			{
				case Keyboard.RIGHT	:	cam.rotateY ( 1 ); 		
										break;
				case Keyboard.LEFT	: 	cam.rotateY ( -1 ); 		
										break;
				case Keyboard.UP	: 	cam.moveForward ( 2 ); 	
										break;
				case Keyboard.DOWN	: 	cam.moveForward ( -2 ); 	
										break;
										
				//case Key.isDown (Key.SHIFT)	: cam.tilt ( 1 ); 		break;
				//case Key.isDown (Key.CONTROL) : cam.tilt ( -1 ); 		break;
			}
		}
		
		private function createScene (bg : Group) : void
		{
			// -- interpolator
			var myEase:Ease = new Ease();
			
			//
			var tgRotation:TransformGroup;
			var tgTranslation:TransformGroup;
			tgRotation = new TransformGroup();
			tgTranslation = new TransformGroup();
			//
			var translation:Transform3D = new Transform3D();
			translation.translate( 0, 0, 300 );
			tgTranslation.setTransform( translation );
			//
			//
			var rotint:RotationInterpolator = new RotationInterpolator( myEase.create(), 500 );
			
			// -- listener
			rotint.addEventListener( SandyEvent.END, __yoyo );
			rotint.addEventListener( SandyEvent.PROGRESS, __playMouse );
			
			var o:Object3D = new Box( 100, 100, 100);
			trace(o);
			var skin:Skin = /*new SimpleColorSkin(0xFFFF00);//*/ new MovieSkin( 'texture_anim');
			skin.setLightingEnable( true );
			o.setSkin( skin );
			
			//
			tgRotation.setTransform( rotint );
			tgRotation.addChild( o );
			tgTranslation.addChild( tgRotation );
			bg.addChild( tgTranslation );
			
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
			RotationInterpolator(e.target).setDuration( 100000 / dist );
		}					
	}
}