package examples
{
	import flash.events.*;
	import sandy.core.World3D;
	import sandy.view.Camera3D;
	import examples.BasicExample;
	
	public class MouseControl
	{
		private var engine:*;
		
		private var ANIM_DIM:Number = 900;
		private var _yaw:Number;
		private var _pitch:Number;
		public var _fov:Number;
		private var oldMouseX:Number = -1;
		private var oldMouseY:Number = -1;
		private var boolMouseDown:Boolean = false;
		
		
		public function MouseControl(example:BasicExample)
		{
			_fov = fov(700);
			
			engine = example;
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			engine.stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			engine.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseHandler);
			engine.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			engine.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
		
		public function remove():void
		{
			engine.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			engine.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseHandler);
			engine.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			engine.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			
		}
		
		private function mouseDown(e:MouseEvent):void
		{
			boolMouseDown = true;
		}
		private function mouseUp(e:MouseEvent):void
		{
			boolMouseDown = false;
			oldMouseX = -1;
			oldMouseY = -1;
		}
		
		private function mouseWheelHandler(e:MouseEvent):void
		{
			//trace(_fov + " de: " + e.delta);
			_fov += e.delta;
			if (_fov > 120)
				_fov = 120;
				
			//trace(_fov + " de: " + e.delta);
						
			World3D.getCamera(0).setFocal(foc(_fov));
		}
		
		private function mouseHandler(e:MouseEvent):void
		{
			
			if (boolMouseDown)
			{
				//trace(engine.mouseX + "," + engine.mouseY);
				//var cam:Camera3D = World3D.getCamera(0);
				var cam:Camera3D = World3D.getCurrentCamera();
				var posx:Number = engine.mouseX/6;
				var posy:Number = engine.mouseY/6;
				// init old position
				if (oldMouseX < 0) oldMouseX = posx;
				if (oldMouseY < 0) oldMouseY = posy;
				
				var diffx:Number = (posx - oldMouseX)/2;
				var diffy:Number = (posy - oldMouseY)/2;
				
				if (diffx != 0)
				{
					//trace(cam + "diffx: " + diffx);
					cam.rotateY(diffx);
					_yaw += diffx;
				}
				if (diffy != 0)
				{
					//trace(cam + "diffy: " + diffy);
					cam.tilt(diffy);
					_pitch += diffy;
				}
				
				if (_yaw > 180) 
					_yaw -= 360;
				else 
					if (_yaw < -180) 
						_yaw += 360;
			
				
				oldMouseX = posx;
				oldMouseY = posy;

			
			}
			//trace("_yaw: " + _yaw);
			//	trace("_pitch: " + _pitch);
		}
		
		public function fov(foc:Number):Number	// fov in degrees
		{
			return 360 * Math.atan(ANIM_DIM/(2 * foc)) / Math.PI;
		}
	
		public function foc(fov:Number):Number	// fov in degrees
		{
			return ANIM_DIM / (2 * Math.tan(Math.PI * fov/360));
		}
	}
}