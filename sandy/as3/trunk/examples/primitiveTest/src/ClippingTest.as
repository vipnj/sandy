package
{	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import sandy.core.World3D;
	import sandy.core.data.Vector;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.ColorMaterial;
	import sandy.materials.attributes.*;
	import sandy.primitive.Box;
	import sandy.primitive.Cylinder;
	import sandy.primitive.Plane3D;
	import sandy.primitive.PrimitiveMode;

    [SWF(width="800", height="800", backgroundColor="#FFFFFF", frameRate="30")] 
    
	public class ClippingTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 800;
		internal static const SCREEN_HEIGHT:int = 700;
		
		public const radius:uint = 800;
		public const innerRadius:uint = 700;
		
		private var box:Box;
		private var world : World3D;
		private var camera : Camera3D;
		private var keyPressed:Array;
		
		[Embed(source="assets/ouem_el-ma_lake.jpg")]
		private var Texture:Class;
		
		[Embed(source="assets/may.jpg")]
		private var Texture2:Class;
		
		public function ClippingTest()
		{
			super();
			
			trace('stage: ' + stage);
			// --
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			// -- FPS
			//addChild(new FPSMetter(false, 110, stage));
			// -- INIT
			keyPressed = [];
			 init();
			// -- User interface
			stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			
			var tf:TextField = new TextField();
			tf.wordWrap = true;
			tf.width = SCREEN_WIDTH;
			tf.text = "Clipping Demo :: Navigate with direction keys. Go through the box to see the clipping in action. Press SPACE button to enable/disable the accurate clipping";
			tf.y = 700;
			this.addChild( tf );
		}
		
		public function init():void
		{		
			// --
			var l_mcWorld:MovieClip = new MovieClip();
			l_mcWorld.x = (stage.stageWidth - SCREEN_WIDTH) / 2;
			l_mcWorld.y = 0;//(stage.stageHeight - SCREEN_HEIGHT) / 2;
			addChild(l_mcWorld);
			world = World3D.getInstance(); 
			world.container = l_mcWorld;
			// --
			world.camera = new Camera3D( SCREEN_WIDTH, SCREEN_HEIGHT );
			world.camera.y = 100;
			world.camera.z = -innerRadius;
			// -- create scen
			var g:Group = new Group("root");

			var lPlane:Plane3D = new Plane3D( "myPlane", 1500, 1500, 2, 2, Plane3D.ZX_ALIGNED, PrimitiveMode.TRI );
			//lPlane.swapCulling();
			lPlane.enableBackFaceCulling = false;
			lPlane.enableClipping = true;
			lPlane.appearance = new Appearance( new ColorMaterial( 0xd27e02) );
			//lPlane.x = 1000;
			//lPlane.z = 1000;
			lPlane.enableForcedDepth = true;
			lPlane.forcedDepth = 5000000;
			
			var cylinder:Shape3D = new Cylinder( "myCylinder", radius, 600, 15, 8, radius, true, true);
			cylinder.swapCulling();
			cylinder.enableClipping = true;
			cylinder.useSingleContainer = false;
			cylinder.y = 200;
			
			box = new Box( "box", 250, 250, 250, "tri", 2 );
			box.z = 0;
			box.x = 0;
			box.y = 100;
			box.enableBackFaceCulling = false;
			box.enableClipping = true;

			
			var pic:Bitmap = new Texture();
			var pic2:Bitmap = new Texture2();
			
			var lAppearance:Appearance = new Appearance( new BitmapMaterial( pic2.bitmapData ) ,
											 			 new BitmapMaterial( pic.bitmapData ) );
			
			box.appearance = lAppearance;
			//(box.appearance.frontMaterial as ColorMaterial).lightingEnable = true;
			lPlane.appearance = new Appearance( new ColorMaterial() );
			
			cylinder.appearance = new Appearance( new BitmapMaterial( pic2.bitmapData, new MaterialAttributes( new LineAttributes() ) ) );
			//BitmapMaterial(cylinder.appearance.frontMaterial).enableAccurateClipping = true;
			
			// --			
			g.addChild( lPlane ); 
			g.addChild( cylinder );
			g.addChild( box );
			
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
			var oldPos:Vector = cam.getPosition();
			// --
			if( keyPressed[Keyboard.RIGHT] ) 
			{   
			    cam.rotateY -= 5;
			}
			if( keyPressed[Keyboard.LEFT] )     
			{
			    cam.rotateY += 5;
			}		
			if( keyPressed[Keyboard.UP] )
			{ 
			    cam.moveForward( 10 );
			}
			if( keyPressed[Keyboard.DOWN] )
			{ 
			    cam.moveForward( -10 );
			}
			// --
			if( keyPressed[Keyboard.SPACE] )
			{
				var lPlane:Shape3D = world.root.getChildByName("myCylinder", true) as Shape3D;
				//BitmapMaterial(lPlane.appearance.frontMaterial).enableAccurateClipping = !BitmapMaterial(lPlane.appearance.frontMaterial).enableAccurateClipping;
			}
			
			if( cam.getPosition().getNorm() > innerRadius )
				cam.setPosition( oldPos.x, oldPos.y, oldPos.z );
			
			box.rotateX += 1;
			world.render();
	
		}
	}
}

