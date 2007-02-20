package 
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.events.*;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.display.StageScaleMode;
	
	import sandy.core.data.Vector;
	import sandy.core.scenegraph.Group;
	import sandy.core.transform.Transform3D;
	import sandy.core.World3D;
	import sandy.primitive.Plane3D;
	import sandy.skin.MixedSkin;
	import sandy.skin.Skin;
	import sandy.skin.SimpleColorSkin;
	import sandy.view.Camera3D;
	import sandy.util.TransformUtil;
	import sandy.events.SandyEvent;
	import sandy.core.Object3D;
	
	import com.mir3.display.FPSMetter;
	import com.mir3.utils.KeyManager;

    [SWF(width="500", height="600", backgroundColor="#FFFFFF", frameRate=120)] 
			
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
		private var keyPressed:Array;

		private var world:MovieClip;
		
		public function ClippingTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			// -- User interfaces
			stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			// -- FPS
			addChild(new FPSMetter(false, 110, stage));
			// -- STATS
			//addChild(new SceneStats(false, false, false, stage));			
			// - INIT
			keyPressed = [];
			
			init();
		}
		
		public function __onKeyDown(e:KeyboardEvent):void
		{
            keyPressed[e.keyCode]=true;
        }
        
        public function __onKeyUp(e:KeyboardEvent):void
        {
            keyPressed[e.keyCode]=false;
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
			cam.setPosition( 0, 80, -100 );
			World3D.getInstance().setCamera (cam);
			var bg : Group = new Group ();
			World3D.getInstance().setRootGroup (bg);
			
			createScene (bg);
			
			World3D.getInstance().addEventListener( SandyEvent.RENDER, onRender );
			World3D.getInstance().render();
		}
		
		private function onRender( e:Event ):void
		{
			var cam:Camera3D = World3D.getInstance ().getCamera();

			if( keyPressed[Keyboard.RIGHT] ) 
			{   
			    cam.rotateY ( 1 ); 		
			}
			if( keyPressed[Keyboard.LEFT] )     
			{
			    cam.rotateY ( -1 ); 
			}		
			if( keyPressed[Keyboard.UP] )
			{ 
			    cam.moveForward ( 2 ); 	
			}
			if( keyPressed[Keyboard.DOWN] )
			{ 
			    cam.moveForward ( -2 ); 
			}	
			if( keyPressed[Keyboard.ENTER] )   
			{  
			    var l_oW:World3D = World3D.getInstance();
			    var l_oG:Group = l_oW.getRootGroup();
			    var l_oPlane:Object3D = Object3D( l_oG.getChild( 0 ) );//l_oG.getChildByName("floor") );
			    if( l_oPlane ) l_oPlane.destroy();
			    
			    keyPressed[Keyboard.ENTER] = 0;
			}

		}
		
		private function createScene (bg : Group) : void
		{
			var s:Skin = new MixedSkin( 0x995500, 100 );
			
			var leftWall:Plane3D = new Plane3D( 100, 500, 1, "quad" );
			leftWall.name = "leftWall";
			var t:Transform3D = TransformUtil.translate(-250,50,0) ;
			t.combineTransform( TransformUtil.rot(90, 0, 90) );
			leftWall.setTransform( t );
			leftWall.enableClipping( true );
			leftWall.enableBackFaceCulling(false);
			leftWall.setSkin( s );
			
			var rightWall:Plane3D = new Plane3D( 100, 500, 1, "quad" );
			rightWall.name = "rightWall";
			t = TransformUtil.translate(250,50,0) ;
			t.combineTransform( TransformUtil.rot(90, 0, 90) );
			rightWall.setTransform( t );
			rightWall.enableClipping( true );
			rightWall.enableBackFaceCulling(false);
			rightWall.setSkin( s );
			
			var frontWall:Plane3D = new Plane3D( 500, 100, 1, "quad" );
			frontWall.name = "frontWall";
			t = TransformUtil.translate(0,50,250) ;
			t.combineTransform( TransformUtil.rot(90, 90, 0) );
			frontWall.setTransform( t );
			frontWall.enableClipping( true );
			frontWall.enableBackFaceCulling(false);
			frontWall.setSkin( s );
			
			var backWall:Plane3D = new Plane3D( 500, 100, 1, "quad" );
			backWall.name = "backWall";
			t = TransformUtil.translate(0,50,-250) ;
			t.combineTransform( TransformUtil.rot(90, 90, 0) );
			backWall.setTransform( t );
			backWall.enableClipping( true );
			backWall.enableBackFaceCulling(false);
			backWall.setSkin( s );
			

			var floorSkin:Skin = new SimpleColorSkin( 0x993300, 100 );
			var floor:Plane3D = new Plane3D( 500, 500, 1, "quad" );
			floor.name = "floor";
			floor.enableBackFaceCulling(false);
			floor.enableClipping( true );
			floor.setSkin( floorSkin );
			
			var roofSkin:Skin = new SimpleColorSkin( 0x888888, 100 );
			var roof:Plane3D = new Plane3D( 500, 500, 1, "quad" );
			roof.name = "roof";
			t = TransformUtil.translate(0,100,0);
			roof.setTransform( t );
			roof.enableBackFaceCulling(false);
			roof.enableClipping( true );
			roof.setSkin( roofSkin );
			
			
			bg.addChild( leftWall );
			bg.addChild( rightWall );
			bg.addChild( backWall );
			bg.addChild( frontWall );
			bg.addChild( roof );
			bg.addChild( floor );
			
		}
			
	}
}