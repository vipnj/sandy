package 
{
	import demos.*;
	
	import flash.display.Sprite;
	import flash.display.StageScaleMode;

	[SWF(width="640", height="500", backgroundColor="#cccccc", frameRate=25)] 

	public class SandyDemos extends Sprite 
	{
		public function SandyDemos() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			//var demo:InteractionDemo = new InteractionDemo();
			//var demo : PerspectiveCorrectionDemo = new PerspectiveCorrectionDemo();
			//var demo:PanoDemo = new PanoDemo();
			//var demo:LightDemo = new LightDemo();
			//var demo:BugTest = new BugTest();
			//var demo:MaxDemo = new MaxDemo();
			//var demo:ColladaDemo = new ColladaDemo();
			//var demo:AppearanceDemo = new AppearanceDemo();
			//var demo:OutlineDemo = new OutlineDemo();
			//var demo:VertexNormalDemo = new VertexNormalDemo();
			//var demo:ClippingDemo = new ClippingDemo();
			//var demo:RoomDemo = new RoomDemo();
			var demo:SpriteWorld = new SpriteWorld();
			// --
			addChild(demo);
			demo.init();
		}
	}
}
