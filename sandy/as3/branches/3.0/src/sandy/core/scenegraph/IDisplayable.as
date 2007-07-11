package sandy.core.scenegraph
{
	import flash.display.Sprite;
	
	public interface IDisplayable
	{
		function clear():void;
		function get container():Sprite;	
		function get depth():Number;	
		function display( p_oContainer:Sprite = null ):void;
	}
}