package Sprite2DTest
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
	import sandy.core.transform.Transform3D;
	import sandy.core.World3D;
	import sandy.core.scenegraph.Object3D;
	import sandy.core.scenegraph.Sprite2D;
	import sandy.events.SandyEvent;
	import sandy.primitive.Plane3D;
	import sandy.skin.MovieSkin;
	import sandy.skin.Skin;
	import sandy.view.Camera3D;

	import com.mir3.display.FPSMetter;
	import com.mir3.display.SceneStats;
	import com.mir3.utils.KeyManager;
	
	/**
	 * @author tom
	 */
	public class Sprite2DTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;
		internal static const NUM_ELEMENTS:int = 1000;
		
		private var _mc : MovieClip;
		private var _fps:Number;
		private var _t:Number;
		private var oPlane:Plane3D;
		
		private var world:MovieClip;
		private var _earthRadius:Vector;
		private var _sunPosition:Vector;
		
		
		
		public function Sprite2DTest()
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
			cam.setPosition( 0, 0, -100 );
			World3D.getInstance().setCamera (cam);
			
			var bg : Group = new Group ();
			World3D.getInstance().setRootGroup (bg);
			
			createScene(bg);
			
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
				case Keyboard.UP	: 	cam.moveForward ( 3 );
										break;
				case Keyboard.DOWN	: 	cam.moveForward ( -3 ); 	
										break;
										
				//case Key.isDown (Key.SHIFT)	: cam.tilt ( 1 ); 		break;
				//case Key.isDown (Key.CONTROL) : cam.tilt ( -1 ); 		break;
			}
		}
		
		private function createScene (bg : Group) : void
		{
			var skin:MovieSkin = new MovieSkin( 'arbre2.gif', true );
			//var skin:MovieSkin = new MovieSkin( 'sandy2.png', true );
		
			for( var i:int = 0; i < NUM_ELEMENTS; i++ )
			{
				var s:Sprite2D = new Sprite2D("Sprite_"+i, 1);
				s.setSkin( skin );
				var trans:Transform3D = new Transform3D();
				trans.translate( Math.random() * 1000 - 500, 0, Math.random() * 2000 - 1000 );
				//trans.translate( 0, 0, 100 );
				s.setTransform( trans );
				bg.addChild( s );
			}	
			
		}
				
	}
}