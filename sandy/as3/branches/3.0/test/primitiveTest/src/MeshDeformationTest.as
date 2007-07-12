package
{
	import com.mir3.display.FPSMetter;
	
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
	import sandy.materials.ColorMaterial;
	import sandy.materials.LineAttributes;
	import sandy.primitive.Box;
	import sandy.core.data.Plane;
	import sandy.primitive.Plane3D;
	import sandy.core.data.Vertex;
	import sandy.core.scenegraph.Geometry3D;
	import sandy.primitive.PrimitiveMode;
	import sandy.primitive.Primitive3D;

    [SWF(width="500", height="500", backgroundColor="#FFFFFF", frameRate="120")] 
    
	public class MeshDeformationTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;
		
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
			
			//mObj = new Plane3D("myPlane", 200, 200, 10, 10, Plane3D.XY_ALIGNED, PrimitiveMode.QUAD );
			mObj = new Box("myBox", 100, 100, 100, "quad", 2 );
			
			mObj.z = 400;
			mObj.enableBackFaceCulling = false;
			mObj.appearance = new Appearance( new ColorMaterial( 0xFF0000, 100, new LineAttributes()) ,
											 	new ColorMaterial( 0x00FF, 100, new LineAttributes( 1, 0x00FF00)) );
			// --			
			tg.addChild( mObj );
			g.addChild( tg );
			world.root = g;
			world.root.addChild( world.camera );
			
			
			var lGeometry:Geometry3D = mObj.geometry;
			for each (var lVertex:Vertex in mObj.geometry.aVertex )
			{
				lVertex.x += Math.random()*10 - Math.random()*10;
				lVertex.y += Math.random()*10 - Math.random()*10;
				lVertex.z += Math.random()*10 - Math.random()*10;
			}
			mObj.geometry = lGeometry;
			
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

