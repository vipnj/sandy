package sandy.core.data.bvh
{
	import sandy.core.group.TransformGroup;
	import sandy.core.data.bvh.ChannelData;
	
	public class BVHBlockData
	{
		public var identifier:String = null;
		public var offsetX:Number;
		public var offsetY:Number;
		public var offsetZ:Number;
		public var channels:Array = new Array();
		public var transformGroup:TransformGroup = new TransformGroup(); 
		
		public function addChannel(name:String):void
		{
			if (name != null)
			{
				channels.push(new ChannelData(name));	
			}
		}
		
		public function getChannel(name:String):ChannelData
		{
			var retChannel:ChannelData;
			
			for each (var channel:ChannelData in channels)
			{
				if (channel.channelName == name)
				{
					retChannel = channel
					break;
				}
			}
			return retChannel;
		}
			
	}
}