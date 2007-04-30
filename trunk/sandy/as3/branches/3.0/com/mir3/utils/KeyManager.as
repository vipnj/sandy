package com.mir3.utils
{
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.display.Stage;
	
	
	public class KeyManager
	{
		private static var stage:Stage;
		
		
		public static function initStage(p_stage:Stage):void 
		{
			stage = p_stage;
		}
		
		public static function addKeyDown(p_handler:Function):void 
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, p_handler);
		}
		
		public static function removeKeyDown(p_handler:Function):void 
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, p_handler)
		}
		
		public static function addKeyUp(p_handler:Function):void 
		{
			stage.addEventListener(KeyboardEvent.KEY_UP, p_handler);
		}
		
		public static function removeKeyUp(p_handler:Function):void 
		{
			stage.addEventListener(KeyboardEvent.KEY_UP, p_handler);
		}
	}
}