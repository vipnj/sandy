package sandy.core.scenegraph
{
	import flash.display.Sprite;
	
	public interface IDisplayable
	{
		function get container():Sprite;	
		function get depth():Number;	
		function display():void;
	}
}