package examples
{
	import flash.events.*;
	import flash.ui.Keyboard;
	
	import sandy.core.World3D;
	import sandy.view.Camera3D;	
	
	public class KeyboardControl
	{
		private var engine:*;
		
		public function KeyboardControl(example:BasicExample)
		{
			engine = example;
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			engine.stage.addEventListener(KeyboardEvent.KEY_UP, keyDownHandler);
		}
		
		public function remove():void
		{
			engine.stage.removeEventListener(KeyboardEvent.KEY_UP, keyDownHandler);
		}
		
		
	
		private function keyDownHandler(e:KeyboardEvent):void
		{
			var camList:Array = World3D.getCameraList();
			var len:uint = camList.length;
			
			if ( (e.keyCode > 48) && (e.keyCode < 56))
			{
				var id:uint = e.keyCode - 48
				if (id < len)
				{
					var cam:Camera3D = World3D.getCamera(id);
					trace("camera: " + cam);
					cam.getScreen().setCamera(cam);
					trace("current camera: " + World3D.getCurrentCamera());
				}
			}
			switch(e.keyCode)
			{
				case Keyboard.RIGHT:
					break;
				
				case Keyboard.LEFT:
					break;
			
				case Keyboard.UP:
					break;
			
				case Keyboard.DOWN:
					break;
			
				case Keyboard.SHIFT:
					break;
			
				case Keyboard.CONTROL:
					break;
			}
			
		}
	}
}