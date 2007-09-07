package
{
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	public class CustomFPS extends TextField
	{
		private var fs: int;
		private var ms: int;
		
		public function CustomFPS()
		{
			var format: TextFormat = new TextFormat();
			
			format.color = 0x666666;
			format.size = 10;
			format.bold = true;
			format.font = 'Verdana';
			
			textColor = 0xcecece;
			autoSize = "left";
			defaultTextFormat = format;
			
			ms = getTimer();
			fs = 0;
		}
		
		public function nextFrame(): void
		{
			if( getTimer() - 1000 > ms )
			{
				ms = getTimer();
				text = fs.toString();
				fs = 0;
			}
			else
			{
				++fs;
			}
		}
	}
}