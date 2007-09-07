package sandy.core.data.bvh
{
	public dynamic class ChannelData extends Array
	{
		public var channelName:String;
		//public var data:String;
		
		public function ChannelData(name:String = "channel") 
		{
			this.channelName = name;
		}
	}
}