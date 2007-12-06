package demos
{
	import flash.display.Sprite; 
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;
	import flash.display.BitmapData;	
	import flash.ui.Keyboard;
//	import fl.controls.Slider;
//	import fl.events.SliderEvent;
	import sandy.core.World3D;
	import sandy.core.data.Vector;
	import sandy.core.scenegraph.*;
	import sandy.materials.*;
	import sandy.materials.attributes.*;	
	import sandy.primitive.*;

	/**
	 * OutlineTest is a simple demo to show OutlineMaterial
	 * @author petit@petitpub.com
	 */
	public class OutlineDemo extends Sprite
	{
		private var world:World3D;
		private var camera:Camera3D;
		private var box:Shape3D;
		private var moving:Boolean = false;
		private var material:Material;
		private var movie:MovieClip;
		
		public function OutlineDemo()
		{;}
		
		public function init():void
		{
			world = World3D.getInstance();
			world.container = this;
			world.root = createScene();
			
			camera = new Camera3D( 200, 200 );
			world.camera = camera;
			camera.z = -200;
			world.root.addChild( camera );
			Key.initialize(stage);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );			
		}
		// Should we move our box or not?
		private function downHandler(e:Event){
			moving = true;
		}
		private function upHandler(e:Event){
			moving = false;
		}

		// Create the root Group and the object tree 
		private function createScene():Group
		{
			var root:Group = new Group();
			box = new Sphere( 'box', 60 ); //,, 60, 60, PrimitiveMode.TRI, 2 

			//material = new OutlineMaterial( 3, 0x96EF3A, 0.3); // alpha < 1 -> no lines
			var materialAttr:MaterialAttributes = new MaterialAttributes ( new OutlineAttributes( 3, 0xFF, 0.2 ));
			material = new ColorMaterial(  0xFFFF99, 0.4, materialAttr);
			var app:Appearance = new Appearance( material );
			box.useSingleContainer = false;
			box.appearance = app;
			//box.enableBackFaceCulling = false;
			box.enableNearClipping = true;
			root.addChild( box );
			return root;
		}
	
		private function enterFrameHandler( event : Event ) : void
		{
			if ( moving ) {
				box.rotateY += ( mouseX - 100 )/20;
				box.rotateX += ( mouseY - 100 )/20;
			}
			if (Key.isDown(Keyboard.UP)) {
				camera.moveForward(2);
			}
			if (Key.isDown(Keyboard.DOWN)) {
				camera.moveForward(-2);	
			}
			world.render();
		}
	}
}