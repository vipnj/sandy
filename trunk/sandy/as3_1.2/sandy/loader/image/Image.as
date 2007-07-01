package sandy.loader.image {
	import flash.display.BitmapData;
      import flash.utils.ByteArray;
      import flash.utils.Endian;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.*;
	public class Image extends EventDispatcher {
		protected var imageWidth:int;
		protected var imageHeight:int;
		protected var data:Array;
		public static var ONLOADCOMPLETE:String="loadcomplete";

		public function Image(){}
		public function getData():Array {
                    return data;
            }
		public function getWidth():int{
			return imageWidth ;
			}
		public function getHeight():int{
			return imageHeight ;
		}
		public function getDataLength():int {
                return data.length;
		}
		public function load(filename:String):void{
			var request:URLRequest = new URLRequest(filename);
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onLoad);
			loader.load(request);
		}
		protected function onLoad(event:Event):void{
			//override by its child!
		}
	}
}