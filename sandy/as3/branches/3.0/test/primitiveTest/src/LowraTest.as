package
{	
	
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.*;
	
	import sandy.events.BubbleEvent;
	import sandy.events.BubbleEventBroadcaster;
	import sandy.commands.Delegate;
	import sandy.events.EventBroadcaster;
	

    [SWF(width="500", height="500", backgroundColor="#FFFFFF", frameRate="120")] 
    
	public class LowraTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;
		
		public function LowraTest()
		{
			super();
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			init();
		}
		
		public function init():void
		{		
			var lEB:EventBroadcaster = new EventBroadcaster();
			var f:Function = Delegate.create( toString2, "je suis un test" );
			
			var lBubbling:BubbleEventBroadcaster = new BubbleEventBroadcaster();
			var lBubbling2:BubbleEventBroadcaster = new BubbleEventBroadcaster();
			
			lBubbling.addChild( lBubbling2 );
			
			lBubbling.addEventListener( "TEST", onTest );
			lBubbling2.addEventListener( "TEST", onTest );
			
			lBubbling2.broadcastEvent( new BubbleEvent("TEST", this) );
			return;
		}
		
		private function onTest( pEvt:BubbleEvent ):void
		{
			trace("reception d'un evennement");
			trace(pEvt );
			trace("isBulling ? :"+pEvt.bubbles);
			trace(pEvt.type);
		}
		
		private function toString2( p_sContent:String ):String
		{
			return "LowraTest::"+p_sContent;
		}
	}
}

