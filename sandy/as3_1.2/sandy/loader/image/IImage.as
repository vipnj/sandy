package sandy.loader.image {
	import flash.events.IEventDispatcher;
	import flash.display.BitmapData;
	public interface IImage extends IEventDispatcher {
		function getData():Array;
		function getWidth():int;
		function getHeight():int;
		function getDataLength():int
		function getImage():BitmapData;
		function printHeaders():void;
		function load(filename:String):void;
	}
}