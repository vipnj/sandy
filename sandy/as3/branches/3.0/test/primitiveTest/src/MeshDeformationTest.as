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
	import sandy.core.data.Vertex;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.Shape3D;
	import sandy.core.scenegraph.TransformGroup;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.primitive.Plane3D;
	import sandy.primitive.PrimitiveMode;
	import sandy.materials.LineAttributes;

    [SWF(width="500", height="500", backgroundColor="#FFFFFF", frameRate="120")] 
    
	public class MeshDeformationTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;
		
		[Embed(source="../assets/texture.jpg")]
		private var Texture:Class;
		
		private var world : World3D;
		private var camera : Camera3D;
		private var keyPressed:Array;
		private var mObj:Shape3D;
		
		public function MeshDeformationTest()
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
			var quality:uint = 3;
			var g:Group = new Group("root");
			var tg:TransformGroup = new TransformGroup("translation");
			
			var pic:Bitmap = new Texture();
			var l_oTextureAppearance:Appearance = new Appearance( new BitmapMaterial( pic.bitmapData, new LineAttributes() ) ); 
			l_oTextureAppearance.frontMaterial.lightingEnable = true;
			
			mObj = new Plane3D("myPlane", 200, 200, 2, 1, Plane3D.YZ_ALIGNED, PrimitiveMode.TRI );
			//mObj = new Box("myBox", 100, 100, 100, "quad", 2 );
			
			mObj.z = 400;
			mObj.enableBackFaceCulling = false;
			//mObj.appearance = new Appearance( new ColorMaterial( 0xFF0000, 100, new LineAttributes()) ,
			//								  new ColorMaterial( 0x00FF, 100, new LineAttributes( 1, 0x00FF00)) );
			mObj.appearance = l_oTextureAppearance;
			mObj.appearance.frontMaterial.lightingEnable = true;
			// --			
			tg.addChild( mObj );
			g.addChild( tg );
			world.root = g;
			world.root.addChild( world.camera );
			

			for each (var lVertex:Vertex in mObj.geometry.aVertex )
			{
				lVertex.x += Math.random()*10 - Math.random()*10;
				lVertex.y += Math.random()*10 - Math.random()*10;
				lVertex.z += Math.random()*10 - Math.random()*10;
			}
			
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
			if( keyPressed[Keyboard.RIGHT] ) 
			{   
			    mObj.rotateY -= 1;
			}
			if( keyPressed[Keyboard.LEFT] )     
			{
			    mObj.rotateY += 1;
			}		
			if( keyPressed[Keyboard.UP] )
			{ 
			    mObj.rotateX += 1;
			}
			if( keyPressed[Keyboard.DOWN] )
			{ 
			    mObj.rotateX -= 1;
			}
			
			world.render();	
		}
	}
}

