package sandy.core.data.bvh
{
	import sandy.core.group.TransformGroup;
	import sandy.core.transform.Transform3D;
	import sandy.core.data.bvh.BVHBlockData;
	
	public class BlockSet
	{
		public var identifier:String;
		public var tg:TransformGroup;
		//public var t:Transform3D; 
		public var t:Array; 
		public var bone:BVHBlockData;
	}
}