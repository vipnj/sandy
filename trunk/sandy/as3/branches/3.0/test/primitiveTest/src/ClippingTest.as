package
{
	import com.mir3.display.FPSMetter;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.ui.Keyboard;
	
	import sandy.core.World3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.Shape3D;
	import sandy.core.scenegraph.TransformGroup;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.ColorMaterial;
	import sandy.materials.LineAttributes;
	import sandy.primitive.Box;

    [SWF(width="500", height="500", backgroundColor="#FFFFFF", frameRate="120")] 
    
	public class ClippingTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;
		
		private var world : World3D;
		private var camera : Camera3D;
		private var keyPressed:Array;
		
		[Embed(source="assets/texture.jpg")]
		private var Texture:Class;
		
		public function ClippingTest()
		{
			super();
			
			trace('stage: ' + stage);
			// --
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			// -- FPS
			addChild(new FPSMetter(false, 110, stage));
			// -- INIT
			keyPressed = [];
			 init();
			// -- User interface
			stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);		
		}
		
		public function init():void
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
			// -- create scen
			var quality:uint = 1;
			var g:Group = new Group("root");
			var tg:TransformGroup = new TransformGroup("translation");
			var box:Shape3D = new Box( "box", 100, 100, 100, "tri", quality );
			box.z = 400;
			box.enableBackFaceCulling = false;
			box.enableClipping = true;
			box.useSingleContainer = true;
			
			var pic:Bitmap = new Texture();
			box.appearance = new Appearance( new BitmapMaterial( pic.bitmapData ) ,
											 new ColorMaterial( 0x00FF, 100, new LineAttributes( 1, 0x00FF00)) );
			// --			
			tg.addChild( box );
			g.addChild( tg );
			world.root = g;
			world.root.addChild( world.camera );
			// --
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
			
			
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
			// --
			if( !keyPressed[Keyboard.SPACE] )
			{
				Shape3D(world.root.getChildByName("box", true)).rotateX += 1;
				world.render();	
			}
		}
	}
}

