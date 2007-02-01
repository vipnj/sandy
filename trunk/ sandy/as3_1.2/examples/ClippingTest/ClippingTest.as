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
	import sandy.core.transform.Transform3D;
	import sandy.core.World3D;
	import sandy.events.InterpolationEvent;
	import sandy.primitive.Plane3D;
	import sandy.primitive.Sphere;
	import sandy.skin.MixedSkin;
	import sandy.skin.Skin;
	import sandy.skin.SimpleColorSkin;
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
	public class ClippingTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;
		
		private var _mc : MovieClip;
		private var _fps:Number;
		private var _t:Number;
		private var oPlane:Plane3D;
		
		private var world:MovieClip;
		
		public function ClippingTest()
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
			cam.setPosition( 0, 80, -300 );
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
			var s:Skin = new MixedSkin( 0x00FF88, 100 );
			var leftWall:Plane3D = new Plane3D( 100, 500, 1, "tri");
			leftWall.name = "leftWall";
			var t:Transform3D = TransformUtil.translate(-250,50,0) ;
			t.combineTransform( TransformUtil.rot(90, 0, 90) );
			leftWall.setTransform( t );
			leftWall.enableClipping( true );
			leftWall.enableBackFaceCulling(false);
			leftWall.setSkin( s );
			
			var rightWall:Plane3D = new Plane3D( 100, 500, 1, "tri");
			rightWall.name = "rightWall";
			t = TransformUtil.translate(250,50,0) ;
			t.combineTransform( TransformUtil.rot(90, 0, 90) );
			rightWall.setTransform( t );
			rightWall.enableClipping( true );
			rightWall.enableBackFaceCulling(false);
			rightWall.setSkin( s );
			
			var frontWall:Plane3D = new Plane3D( 500, 100, 1, "tri");
			frontWall.name = "frontWall";
			t = TransformUtil.translate(0,50,250) ;
			t.combineTransform( TransformUtil.rot(90, 90, 0) );
			frontWall.setTransform( t );
			frontWall.enableClipping( true );
			frontWall.enableBackFaceCulling(false);
			frontWall.setSkin( s );
			
			var backWall:Plane3D = new Plane3D( 500, 100, 1, "tri");
			backWall.name = "backWall";
			t = TransformUtil.translate(0,50,-250) ;
			t.combineTransform( TransformUtil.rot(90, 90, 0) );
			backWall.setTransform( t );
			backWall.enableClipping( true );
			backWall.enableBackFaceCulling(false);
			backWall.setSkin( s );
			

			var floorSkin:Skin = new SimpleColorSkin( 0x999999, 100 );
			var floor:Plane3D = new Plane3D( 500, 500, 1, "tri");
			floor.name = "floor";
			floor.enableBackFaceCulling(false);
			floor.enableClipping( true );
			floor.setSkin( floorSkin );
			
			bg.addChild( leftWall );
			bg.addChild( rightWall );
			bg.addChild( backWall );
			bg.addChild( frontWall );
			bg.addChild( floor );
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