package demos
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.ui.Keyboard;
	
	import sandy.core.World3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.materials.Appearance;
	import sandy.materials.ColorMaterial;
	import sandy.materials.attributes.LightAttributes;
	import sandy.materials.attributes.LineAttributes;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.primitive.Plane3D;
	
	/**
	 * @author tom
	 */
	public class RoomDemo extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 640;
		internal static const SCREEN_HEIGHT:int = 500;
		
		private var _mc : MovieClip;
		private var _fps:Number;
		private var _t:Number;
		private var oPlane:Plane3D;
		private var keyPressed:Array;

		private var world:MovieClip;
		
		public var app:Appearance;// = new Appearance( new ColorMaterial( 0xFF, 1) );
		
		public function RoomDemo()
		{
		}
		
		private function _enableEvents():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			addEventListener( Event.ENTER_FRAME, onRender );
		}
	
	
		public function __onKeyDown(e:KeyboardEvent):void
		{
            keyPressed[e.keyCode]=true;
        }

        public function __onKeyUp(e:KeyboardEvent):void
        {
           keyPressed[e.keyCode]=false;
        }
		
		public function init () : void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			// -- User interfaces
			keyPressed = [];
			World3D.getInstance().container = this;
			// ---
			var cam : Camera3D = new Camera3D (SCREEN_WIDTH, SCREEN_HEIGHT);
			cam.setPosition( 0, 80, -100 );
			World3D.getInstance().camera = cam;
			var bg : Group = new Group ();
			World3D.getInstance().root = bg;
			World3D.getInstance().root.addChild( cam );
			
			World3D.getInstance().light.setDirection( 1, 1, 1 );
			createApperance();
			
			createScene (bg);
			_enableEvents();
		}
		
		
		public function createApperance():Appearance
		{
			var lMat:ColorMaterial = new ColorMaterial( 0xFF, 1, new MaterialAttributes( new LineAttributes(), new LightAttributes() ) );
			lMat.lightingEnable = true;
			app = new Appearance( lMat );
			return app;
		}
		
		private function onRender( e:Event ):void
		{
			var cam:Camera3D = World3D.getInstance ().camera;

			if( keyPressed[Keyboard.RIGHT] ) 
			{   
			    cam.rotateY -= 2; 		
			}
			if( keyPressed[Keyboard.LEFT] )     
			{
			    cam.rotateY += 2; 
			}		
			if( keyPressed[Keyboard.UP] )
			{ 
			    cam.moveForward ( 5 ); 	
			}
			if( keyPressed[Keyboard.DOWN] )
			{ 
			    cam.moveForward ( -5 ); 
			}	
			
			World3D.getInstance().render();
		}
		
		private function createScene (bg : Group) : void
		{
			
			var leftWall:Plane3D = new Plane3D( "leftWall", 500, 100, 1, 1, Plane3D.YZ_ALIGNED, "quad" );
			leftWall.x = -250;
			leftWall.y = 50;
			leftWall.enableClipping = true;
			leftWall.enableBackFaceCulling = false;
			leftWall.appearance = app;
			
			var rightWall:Plane3D = new Plane3D( "rightWall",  500, 100, 1, 1,Plane3D.YZ_ALIGNED, "quad" );
			rightWall.x = 250;
			rightWall.y = 50;
			rightWall.enableClipping = true;
			rightWall.enableBackFaceCulling = false;
			rightWall.appearance = app;
			
			var frontWall:Plane3D = new Plane3D( "frontWall",  100, 500, 1, 1, Plane3D.XY_ALIGNED, "quad" );
			frontWall.z = 250;
			frontWall.y = 50;
			frontWall.enableClipping = true;
			frontWall.enableBackFaceCulling = false;
			frontWall.appearance = app;
			
			var backWall:Plane3D = new Plane3D( "backWall", 100, 500, 1, 1, Plane3D.XY_ALIGNED, "quad" );
			backWall.z = -250;
			backWall.y = 50;
			backWall.enableClipping = true;
			backWall.enableBackFaceCulling = false;
			backWall.appearance = app;
			

			var floor:Plane3D = new Plane3D( "floor", 500, 500, 1, 1, Plane3D.ZX_ALIGNED, "quad" );
			floor.enableClipping = true;
			floor.enableBackFaceCulling = false;
			floor.appearance = app;
			
			var roof:Plane3D = new Plane3D( "roof", 500, 500, 1, 1, Plane3D.ZX_ALIGNED, "quad" );
			roof.y = 100;
			roof.enableClipping = true;
			roof.enableBackFaceCulling = false;
			roof.appearance = app;
			
			
			bg.addChild( leftWall );
			bg.addChild( rightWall );
			bg.addChild( backWall );
			bg.addChild( frontWall );
			bg.addChild( roof );
			bg.addChild( floor );
			
		}
			
	}
}