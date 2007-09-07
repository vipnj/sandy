package sandy.primitive
{
	import sandy.core.data.Vector;
	import sandy.core.Sprite2D;
	import sandy.core.transform.Transform3D;
	import sandy.skin.*;
	import sandy.core.group.TransformGroup;
	import mx.core.BitmapAsset;
		
	public class Bone3D
	{
		public var name:String;
		public var id:uint;
		public var channels:uint;
		public var channels_count:uint;
		public var joints:Array;
		public var offset:Vector;
		public var rotation:Vector;
		public var ending:Boolean = true;
		public var gfx:Sprite2D;
		public var tg:TransformGroup;
		public var transform:Transform3D;
		
		[Embed(source="../../assets/images/bone.gif")] public var Texture:Class;
		
		/**
	     * This is the constructor to call when you nedd to create an Bone primitive.
	     * <p>This method will create a complete Bone</p>
	     * <p>{@code name} represents the name of the Bone, {@code channelsCount} represent 
	     * count of channels in frame data for thisBone and {@code id} ID of bone in hierarchy. 
	     * When parse frame data, we know get bones ID and correctly pair frames data </p>
	     * 
	     * @param name    	String
	     * @param channelsCount    uint
	     * @param id    uint
	     */
	     
		public function Bone3D(boneName:String, channelsCount:uint, boneID:uint)
		{
			name = boneName;
			channels_count = channelsCount;
			trace("bone["+name+"] => " + channels_count);
			id = boneID;
			joints = [];
			tg = new TransformGroup();
			transform = new Transform3D();
			//var skin:SimpleLineSkin = new SimpleLineSkin();
			var img1:BitmapAsset  = new Texture() as BitmapAsset;
			var skin:TextureSkin = new TextureSkin( img1.bitmapData );
			gfx = new Sprite2D(5);
			gfx.setSkin( skin );
		}
		
		public function addJoint(joint:Bone3D):void
		{
			ending = false;
			joints.push(joint);	
		}
	}
}