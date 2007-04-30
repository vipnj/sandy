package
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import com.mir3.display.FPSMetter;
	//import com.mir3.display.SceneStats;
	import com.mir3.utils.KeyManager;
	
	import sandy.core.World3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.Shape3D;
	import sandy.events.SandyEvent;
	import sandy.materials.Appearance;
	import sandy.materials.ColorMaterial;
	import sandy.materials.LineAttributes;
	import sandy.primitive.Box;

    [SWF(width="500", height="500", backgroundColor="#FFFFFF", frameRate=120)] 
    
	public class SimpleTest1 extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;
		
		private var world : World3D;
		private var camera : Camera3D;
		private var keyPressed:Array;
		
		public function SimpleTest1()
		{
			super();
			// --
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			// -- FPS
			addChild(new FPSMetter(false, 110, stage));
			// -- INIT
			keyPressed = [];
			// -- User interface
			stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			// --
			_init();
			// --
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function _init():void
		{
			// --
			var l_mcWorld:MovieClip = new MovieClip();
			l_mcWorld.x = (stage.stageWidth - SCREEN_WIDTH) / 2;
			l_mcWorld.y = (stage.stageHeight - SCREEN_HEIGHT) / 2;
			addChild(l_mcWorld);
			world = World3D.getInstance(); 
			world.container = l_mcWorld;
			// --
			world.camera = new Camera3D( SCREEN_WIDTH, SCREEN_HEIGHT );
			world.camera.z = -300;
			// -- create scene
			var g:Group = new Group();
			var box:Shape3D = new Box( "box", 100, 100, 100, "tri", 2 );
			box.appearance = new Appearance(new ColorMaterial( 0xff00, 20, new LineAttributes( 2, 0xFF0000, 100 ) ),
											new ColorMaterial( 0xFF, 50, new LineAttributes( 2, 0xFF00, 100 ) ) );
			box.enableBackFaceCulling = false;
			// --			
			g.addChild( box );
			world.root = g;
			world.root.addChild( world.camera );
			// --
			return;
		}
	
		public function __onKeyDown(e:KeyboardEvent):void
		{
            keyPressed[e.keyCode]=true;
        }
        
        public function __onKeyUp(e:KeyboardEvent):void
        {
            keyPressed[e.keyCode]=false;
        }
  
		private function enterFrameHandler( event : Event ) : void
		{
			var cam:Camera3D = world.camera;
			// --
			if( keyPressed[Keyboard.RIGHT] ) 
			{   
			    cam.rotateY -= 1;
			}
			if( keyPressed[Keyboard.LEFT] )     
			{
			    cam.rotateY += 1;
			}		
			if( keyPressed[Keyboard.UP] )
			{ 
			    cam.moveForward( 2 );
			}
			if( keyPressed[Keyboard.DOWN] )
			{ 
			    cam.moveForward( -2 );
			}	
			world.render();
		}
	}
}
