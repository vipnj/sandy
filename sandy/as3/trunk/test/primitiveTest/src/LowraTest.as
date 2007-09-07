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
			// Creation of the bubble event broadcaster instances
			var lBubbling:BubbleEventBroadcaster = new BubbleEventBroadcaster();
			var lBubbling2:BubbleEventBroadcaster = new BubbleEventBroadcaster();
			// We link the second one as a child of the first one
			lBubbling.addChild( lBubbling2 );
			// They both listen a TEST type event, handled by onTest method, which can receive more parameters
			lBubbling.addEventListener( "TEST", onTest, "toto", "tata" );
			lBubbling2.addEventListener( "TEST", onTest, "age", 15, "titi" );
			// The child broadcaster the test event
			lBubbling2.broadcastEvent( new BubbleEvent("TEST", this) );
			return;
		}
		
		private function onTest( pEvt:BubbleEvent, ...args ):void
		{
			trace("Event reception");
			trace(pEvt );
			trace("isBulling ? :"+pEvt.bubbles);
			trace(pEvt.type);
			trace(args);
		}

	}
}

