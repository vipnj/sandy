package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import sandy.core.World3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.Shape3D;
	import sandy.events.SandyEvent;
	import sandy.materials.Appearance;
	import sandy.materials.ColorMaterial;
	import sandy.primitive.Box;
	import sandy.core.scenegraph.Sprite2D;
	import sandy.primitive.Cylinder;
	
	public class SimpleTest1 extends Sprite
	{
		private var world : World3D;
		private var camera : Camera3D;
		private var box:Cylinder;
		
		public function SimpleTest1()
		{
			world = World3D.getInstance(); 
			world.container = this;
			
			// create scene
			var g:Group = new Group();
			
			//for(var i:Number=0; i<200; i++) {
				box = new Cylinder( "cylinder", 500, 500, 8, 8, 500);
				box.appearance = new Appearance( new ColorMaterial( 0xffff00) );
				box.x = Math.random() * 500;
				box.y = Math.random() * 500;
				box.z = Math.random() * 500;
				
				g.addChild( box );
			//}
			
			world.root = g;
			
			world.camera = new Camera3D( 1500, 1500 );
			world.camera.z = 300;

			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
		}
		
		private function keyDownHandler( event : KeyboardEvent ) : void
		{
			var camera:Camera3D = world.camera;
trace("keydown");			
			switch( event.keyCode ) {
				case Keyboard.UP:
					camera.moveForward(5);
					break;
				case Keyboard.DOWN:
					camera.moveForward(-5);
					break;
				case Keyboard.LEFT:
					camera.rotateY += 1;
					break;
				case Keyboard.RIGHT:
					camera.rotateY -= 1;
					break;
			}
		}
		
		private function enterFrameHandler( event : Event ) : void
		{
			trace( box.culled +" "+box.name);
			world.render();
		}
	}
}