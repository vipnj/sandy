package 
{

	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.events.*;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import sandy.core.data.Vector;
	import sandy.core.group.Group;
	import sandy.core.group.TransformGroup;
	import sandy.core.transform.PositionInterpolator;
	import sandy.core.transform.RotationInterpolator;
	import sandy.core.transform.Transform3D;
	import sandy.core.transform.Sequence3D;
	import sandy.core.World3D;
	import sandy.core.Object3D;
	import sandy.events.SandyEvent;
	import sandy.primitive.Plane3D;
	import sandy.primitive.Sphere;
	import sandy.skin.MixedSkin;
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
	public class SequenceTest extends Sprite
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
		
		
		
		public function SequenceTest()
		{
			// _ User interfaces
			KeyManager.initStage(stage);
			KeyManager.addKeyDown(keyDown);
			//KeyManager.addKeyUp(keyUp);
			
			// _ FPS
			fps = new FPSMetter(false, 110, stage);
			addChild(fps);
			
			// _ STATS
			addChild(new SceneStats(false, false, false, stage));
			
			init();
		}
		
		
		private function init () : void
		{
			// ___	THIS HAS TO BE DONE ON THE VERY BEGINNING
			//		NO OBJECT WILL BE CREATED WITHOUT THESE LINES
			world = new MovieClip();
			world.x = (stage.stageWidth - SCREEN_WIDTH) / 2;
			world.y = (stage.stageHeight - SCREEN_HEIGHT) / 2;
			addChild(world);
			World3D.getInstance().setContainer(world);
			// ---
			
			// _ Screen & Camera settings
			var screen : ClipScreen = new ClipScreen( SCREEN_WIDTH, SCREEN_HEIGHT, 0x222222);
			var cam : Camera3D = new Camera3D (screen);
			cam.setPosition( 0, 0, -100 );
			World3D.getInstance().setCamera (cam);
			
			// _ Scene
			var bg : Group = new Group ();
			World3D.getInstance().setRootGroup (bg);
			createScene(bg);
			
			// _ Start
			World3D.getInstance().render();
		}
		
		private function createScene (bg : Group) : void
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
			S1.addEventListener(MouseEvent.MOUSE_UP, __pauseAndResume);
			S1.addEventListener(MouseEvent.ROLL_OVER, __setRollOverSkin);
			S1.addEventListener(MouseEvent.ROLL_OUT, __setRollOutSkin);

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
			seq.addEventListener (SandyEvent.END, __redo );

			var tgTranslation4 : TransformGroup = new TransformGroup ();
			var translation4 : Transform3D = new Transform3D ();
			translation4.translate (0, 0, 200);
			tgTranslation4.setTransform (translation4);
			tg1.addChild(S1);	
			tgTranslation4.addChild(tg1);
			bg.addChild(tgTranslation4);
		}
		
		private function __redo( e:Event ):void
		{
			e.target.redo();
		}
		
		private function __yoyo( e:Event ):void
		{
			e.target.yoyo();
		}
		
		private function __pauseAndResume( e:Event ):void
		{
			if(_paused) seq.resume();
			else  seq.pause();
			_paused = !_paused;
		}

		private function __setRollOverSkin( e:Event ):void
		{
			S1.setSkin( SphereSkinRollOver );
			S1.setBackSkin( SphereSkinRollOver );
		}

		private function __setRollOutSkin( e:Event ):void
		{
			S1.setSkin( SphereSkinRollOut );
			S1.setBackSkin( SphereSkinRollOut );
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
				
	}
}