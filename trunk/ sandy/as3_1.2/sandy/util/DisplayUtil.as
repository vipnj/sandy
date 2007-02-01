package sandy.util 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	
	public class DisplayUtil
	{
		public static function replaceObject(p_target:DisplayObject, p_replacement:DisplayObject):DisplayObject
		{
			var l_parent:DisplayObjectContainer = p_target.parent;
			var l_index:int = l_parent.getChildIndex(p_target);
			l_parent.removeChild(p_target);
			l_parent.addChildAt(p_replacement, l_index);
			
			return p_replacement;
		}
		
		public static function swapObjectWithIndex(p_target:DisplayObject, p_index:int):DisplayObject
		{
			var l_parent:DisplayObjectContainer = p_target.parent;
			var l_currentIndex:int;
			
			l_currentIndex = l_parent.getChildIndex(p_target);
			if (l_currentIndex != p_index) 
			{
				//trace("Swapping object " + l_currentIndex + " with " + p_index);
				l_parent.swapChildrenAt(l_currentIndex, p_index);
			}
		}
	}
}