package 
{
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	
	import demos.*;

	[SWF(width="640", height="500", backgroundColor="#cccccc", frameRate=25)] 

	public class Sandy extends Sprite 
	{
		public function Sandy() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var demo:InteractionDemo = new InteractionDemo();
			//var demo : PerspectiveCorrectionDemo = new PerspectiveCorrectionDemo();
			//var demo:PanoDemo = new PanoDemo();
			// --
			addChild(demo);
			demo.init();
		}
	}
}
