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
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.TransformGroup;
	//import sandy.core.transform.PositionInterpolator;
	import sandy.core.transform.RotationInterpolator;
	import sandy.core.transform.Transform3D;
	import sandy.core.World3D;
	import sandy.core.Object3D;
	//import sandy.core.Sprite3D;
	import sandy.events.SandyEvent;
	import sandy.primitive.Plane3D;
	import sandy.primitive.Sphere;
	//import sandy.skin.MovieSkin;
	import sandy.skin.SimpleColorSkin;
	import sandy.skin.Skin;
	import sandy.util.Ease;
	import sandy.view.Camera3D;
	//import sandy.util.TransformUtil;

	import com.mir3.display.FPSMetter;
	import com.mir3.display.SceneStats;
	import com.mir3.utils.KeyManager;
	
	
	/**
	 * @author tom
	 */
	public class EarthTest extends Sprite
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
		
		
		
		public function EarthTest()
		{
			// -- User interfaces
			KeyManager.initStage(stage);
			KeyManager.addKeyDown(keyDown);
			//KeyManager.addKeyUp(keyUp);
			
			// -- FPS
			addChild(new FPSMetter(false, 110, stage));
			
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
			
			var cam : Camera3D = new Camera3D (SCREEN_WIDTH, SCREEN_HEIGHT);
			cam.setPosition( 0, 0, -50 );
			World3D.getInstance().setCamera (cam);
			var bg : Group = new Group ();
			World3D.getInstance().setRootGroup (bg);
			
			for (var i:int = 0; i<30; i++) {
				createScene(bg);
			}
			
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
			_earthRadius = new Vector( 200, 0, 100 );
			_sunPosition = new Vector( 0, 0, 500 );
			
			
			// -- interpolator
			var myEase:Ease = new Ease();
			
			//
			var translationEarth:Transform3D = new Transform3D();
			var translationSun:Transform3D = new Transform3D();
			translationSun.translate( _sunPosition.x, _sunPosition.y, _sunPosition.z );
			translationEarth.translate( _sunPosition.x - _earthRadius.x, _sunPosition.y - _earthRadius.y/2, _sunPosition.z - _earthRadius.z/2 );
			
			//
			var tgRotationEarth:TransformGroup, tgRotationSun:TransformGroup;
			var tgTranslationEarth:TransformGroup, tgTranslationSun:TransformGroup;
			tgRotationEarth = new TransformGroup();
			tgRotationSun 	= new TransformGroup();
			tgTranslationEarth 	= new TransformGroup();
			tgTranslationSun 	= new TransformGroup();
			
			//
			var rotintEarth:RotationInterpolator 	= new RotationInterpolator( myEase.create(), 300 );
			rotintEarth.setPointOfReference( _earthRadius );
			var rotintSun:RotationInterpolator 		= new RotationInterpolator( myEase.create(), 1000 );
			
			// -- listener
			rotintEarth.addEventListener( SandyEvent.END, __redo );
			rotintSun.addEventListener( SandyEvent.END, __redo );
			
			// -- earth
			var earth:Sphere = new Sphere( 10, 3, 'quad' );
			var skinEarth:Skin;
			//skinEarth = new TextureSkin( BitmapData.loadBitmap( "per" ) );
			skinEarth = new SimpleColorSkin( 0x0099FF ); //MixedSkin( 0x0099FF, 100, 0, 100 );
			skinEarth.setLightingEnable( true );
			earth.setSkin( skinEarth );
			
			// -- sun
			var sun:Object3D = new Sphere( 30, 3, 'quad' );
			var skinSun:Skin;
			//skinSun = new TextureSkin( BitmapData.loadBitmap( "lion" ) );
			skinSun = new SimpleColorSkin( 0xFFFF55 ); //MixedSkin( 0xFFFF00, 100, 0, 100 );
			skinSun.setLightingEnable( true );
			sun.setSkin( skinSun );
			
			// -- creation of the tree		
			tgRotationEarth.setTransform( rotintEarth );
			tgRotationEarth.addChild( earth );
			//
			tgRotationSun.setTransform( rotintSun );
			tgRotationSun.addChild( sun );
			//
			tgTranslationSun.setTransform( translationSun );
			tgTranslationEarth.setTransform( translationEarth );
			//
			tgTranslationSun.addChild( tgRotationSun );
			tgTranslationEarth.addChild( tgRotationEarth );
			//
			bg.addChild( tgTranslationEarth );
			bg.addChild( tgTranslationSun );
			
		}
		
		private function __redo( e:Event ):void
		{
			e.target.redo();
		}
		
		private function __yoyo( e:Event ):void
		{
			e.target.yoyo();
		}
				
	}
}