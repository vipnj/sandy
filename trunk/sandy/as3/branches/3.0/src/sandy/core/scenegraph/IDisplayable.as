package sandy.core.scenegraph
{
	import flash.display.DisplayObject;
	
	
	public interface IDisplayable
	{
		function get container():*;	
		function get depth():Number;	
		function display( p_oContainer:DisplayObject = null ):void;
	}
}