package examples
{
	import mx.core.UIComponent;
	
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.events.Event;
	
	import sandy.util.FPS;
	import sandy.util.DebugInfoDisplay;
	import sandy.core.World3D;
		
		
	public class BasicExample extends UIComponent
	{
		protected var t:uint;
		protected const tf:TextField = new TextField();
		protected var fps:FPS;
		protected var debugInfo:DebugInfoDisplay;
		protected var mouseControl:MouseControl;
		protected var keyboardControl:KeyboardControl;
		
		protected var assetsLoaded:Number;
		
		public function BasicExample() 
		{
			t = getTimer();
			fps = new FPS(35);
			debugInfo = new DebugInfoDisplay();
			addEventListener( Event.ENTER_FRAME, __enterFrame );
			//fps.color = 0xFFFFFF;
			addChild(fps);
			addChild(debugInfo);
			debugInfo.y = 20;
		}
		
		public function init():void
		{
			mouseControl = new MouseControl(this);	
			keyboardControl = new KeyboardControl(this);	
		}
		
		public function remove():void
		{
			World3D.getRootGroup().destroy();
			removeEventListener( Event.ENTER_FRAME, __enterFrame );	
			
			mouseControl.remove();
			keyboardControl.remove();
		}
		
		private function __enterFrame( e:Event ):void
		{
			tf.text = (getTimer() - t)+' ms';
			t = getTimer();
		}
		
	}
}