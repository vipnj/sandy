package sandy.events
{
	import com.bourre.collection.Collection;
	import com.bourre.events.EventBroadcaster;
	
	import flash.events.Event;
	

	public final class BubbleEventBroadcaster extends EventBroadcaster
	{
		private var m_oParent:BubbleEventBroadcaster = null;
		
		public function BubbleEventBroadcaster(target:*=null)
		{
			super(target);
		}
		
		public function set parent( pEB:BubbleEventBroadcaster ):void
		{
			m_oParent = pEB;
		}
		
		public function get parent():BubbleEventBroadcaster
		{
			return m_oParent;
		}


		/**
		 * Starts receiving bubble events from passed-in child.
		 * 
		 * @param child a {@link BubbleEventBroadcaster} instance that will send bubble events.
		 */
		public function addChild( child : BubbleEventBroadcaster ) : void
		{
			child.parent = this;
		}
		
		/**
		 * Stops receiving bubble events from passed-in child.
		 * 
		 * @param child a {@link BubbleEventBroadcaster} instance that will stop
		 * to send bubble events.
		 */
		public function removeChild( child : BubbleEventBroadcaster ) : void
		{
			child.parent = null;
		}
		
		public override function broadcastEvent( e : Event ) : void
		{
			super.broadcastEvent( e );
			if( e is BubbleEvent )
			{
				var lEvt:BubbleEvent = e as BubbleEvent;
				// --
				if ( lEvt.isBubbling && parent )
				{
					parent.broadcastEvent( lEvt );
				}
			}
		}
		
	}
}