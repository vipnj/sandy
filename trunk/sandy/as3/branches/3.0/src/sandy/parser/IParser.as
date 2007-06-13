package sandy.parser
{
	import flash.events.IEventDispatcher;
	
	public interface IParser extends IEventDispatcher
	{
		function parse():void;
	}
}