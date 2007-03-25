package sandy.events
{
	import flash.events.Event;
	
	
	public class LoaderEvent extends Event
	{
		public var data:*;
		public var url:String;
		
		
		public function LoaderEvent(p_event:String, p_url:String, p_data:*)
		{
			super(p_event);
			
			data = p_data;
			url = p_url;
		}
	}
}