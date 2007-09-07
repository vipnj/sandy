package sandy.core.data
{
	import sandy.core.face.Face;
	
	public final class DepthBufferData
	{
		public var rFace:Face;
		public var nDepth:Number;
		
		public function DepthBufferData( prFace:Face, pnDepth:Number )
		{
			rFace = prFace;
			nDepth = pnDepth;
		}
	}
}