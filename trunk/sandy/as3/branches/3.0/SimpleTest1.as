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
	
	public class SimpleTest1 extends Sprite
	{
		private var world : World3D;
		private var camera : Camera3D;
		
		public function SimpleTest1()
		{
			world = World3D.getInstance(); 
			world.container = this;
			
			// create scene
			var g:Group = new Group();
			var box:Shape3D = new Box( "box", 100, 100, 100, "tri", 2 );
			box.appearance = new Appearance( new ColorMaterial( 0xffff000) );
			box.enableClipping = true;
						
			g.addChild( box );
			
			world.root = g;
			
			world.camera = new Camera3D( 500, 500 );
			world.root.addChild( world.camera );
			world.camera.z = -300;
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
		}
		
		private function keyDownHandler( event : KeyboardEvent ) : void
		{
			var camera:Camera3D = world.camera;
			
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
			world.render();
		}
	}
}