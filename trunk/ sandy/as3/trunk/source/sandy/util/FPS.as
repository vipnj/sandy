package sandy.util
{
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.events.Event;
   import flash.utils.getTimer;

	public class FPS extends Sprite 
	{
		private var fpsText: TextField;
		private var ms:int;
		private var fr:int;
		public var maxFPS:int;
		
		public function FPS(max:int = 24) 
		{
			maxFPS = max;
			fpsText = new TextField();
			fpsText.textColor = 0xaa0000;
			fpsText.autoSize = 'left';

			addChild( fpsText );
			ms = getTimer();
			fr = 0;

			addEventListener( Event.ENTER_FRAME, render );

		}
        
        private function render( event: Event ): void
		{
			//-- fps
			fr++;
			if( ms + 1000 < getTimer() )
			{
				fpsText.text = "FPS: " + fr.toString() + " / " + maxFPS.toString();
				fr = 0;
				ms = getTimer();
			}
		}
	
		public function set color(n:uint):void
		{
			fpsText.textColor = n;
		}
	}
}