package sandy.parser
{
	import flash.events.IEventDispatcher;
	import sandy.materials.Appearance;
	
	public interface IParser extends IEventDispatcher
	{
		function parse():void;
		
		function set standardAppearance( p_oAppearance:Appearance ):void;
	}
}