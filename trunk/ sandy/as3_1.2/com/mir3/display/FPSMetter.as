package com.mir3.display 
{
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.text.AntiAliasType;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	
	import com.mir3.utils.KeyManager;
	import com.mir3.display.FPSGraph;
	
	
	
	/**
	*	@author Mirek Mencel //miras@polychrome.pl 
	*	@date 20.11.2006
	**/
	public class FPSMetter extends Sprite
	{
		private static var GRAPH_WIDTH:int = 50;
		private static var GRAPH_HEIGHT:int = 13;
		
		private var fps:TextField;
		private var graph: FPSGraph;
		private var line: Shape;
		private var lineFull: Shape;
		
		private var fs: int;
		private var ms: int;
		private var prevFrameTime: int;
		private var frameTime: int;
		private var isSilent: Boolean;
		
		private var sw: Number;
		private var maxValue: int;
		private var sh: Number;
		private var maxBarWidth: Number;
		
		
		
		public function FPSMetter(p_silent:Boolean = false, p_maxValue:int = 140 /*flash 9 max fps you can set up is 120*/, p_stage:Stage = null)
		{
			isSilent = p_silent;
			
			if (isSilent)
			{
				visible = false;
				KeyManager.addKeyDown(tabKeyDown);
				KeyManager.addKeyUp(tabKeyUp);
			}
			
			maxValue = p_maxValue;
			
			// _ FPS History
			graph = new FPSGraph(GRAPH_WIDTH, GRAPH_HEIGHT, 0xEEEEEE, p_maxValue);
			graph.x = 1;
			graph.y = 1;
			addChild(graph);
			
			var format: TextFormat = new TextFormat();
			format.color = 0x111111;
			format.size = 9;
			format.bold = true;
			format.font = '_sans';
			
			// _ FPS
			fps = new TextField();
			fps.x = width + 3;
			addChild(fps);
			fps.autoSize = "left";
			fps.defaultTextFormat = format;
			fps.antiAliasType = AntiAliasType.ADVANCED;
			fps.text = "000 fps  [000 ms]";
			
			graphics.beginFill(0xFFFF00, 1);
            graphics.drawRect(0, 0, width+1, GRAPH_HEIGHT+2);
			graphics.endFill();
			
			var l_barXPos:Number = width + 1;
			
			line = new Shape();
			addChild(line);
			line.x = l_barXPos;
			
			ms = getTimer();
			fs = prevFrameTime = 0;
			
			maxBarWidth = maxValue*3;
			
			if (p_stage)
			{
				// -- Stage resizing
				//p_stage.scaleMode = StageScaleMode.NO_SCALE;
				p_stage.align = StageAlign.TOP_LEFT;
				p_stage.addEventListener(Event.RESIZE, stageResized);
				
				maxBarWidth = p_stage.stageWidth - line.x - 10;
				
				x = 5; /*p_stage.stageWidth - fps.width - 5;*/
				y = p_stage.stageHeight - height - 5;
			}
			
			lineFull = new Shape();
			lineFull.x = l_barXPos;
			addChild(lineFull);
			
			drawBarBackground();
			drawBar();
			
			addEventListener( Event.ADDED, onAdded );	
			addEventListener( Event.REMOVED, onRemoved );
		}
		
		private function onAdded( event: Event ): void
		{
			stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		private function onRemoved( event: Event ): void
		{
			stage.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		private function onEnterFrame( event: Event ): void
		{
			time = getTimer();
			frameTime = time - prevFrameTime;
			
			
			if( time - 1000 >= ms )
			{
				ms = getTimer();
				update();
				fs = 0;
			}
			else
			{
				++fs;
			}
			
			prevFrameTime = time;
		}
		
		private function update():void
		{
			fps.text = fs.toString() + " fps  [" + frameTime.toString() + " ms]";
			graph.addValue(fs);
			
			line.scaleX = fs/maxValue;
		}
		
		private function tabKeyDown(p_event:KeyboardEvent):void
		{
			//trace('p_event.charCode: ' + p_event.keyCode)
			if (p_event.keyCode == 70)
			{
				visible = true;
			}
		}
		
		private function tabKeyUp(p_event:KeyboardEvent):void
		{
			visible = false;
		}
		
		private function stageResized(p_event:Event):void
		{
			sw = stage.stageWidth;
			sh = stage.stageHeight;
			
			x = 5;
			y = sh - height - 5;
			
			maxBarWidth = sw - lineFull.x - 10;
			
			drawBarBackground();
			drawBar();
		}
		
		private function drawBarBackground():void
		{
			if (lineFull) 
			{
				lineFull.graphics.clear();
				lineFull.graphics.beginFill(0xEEEEEE, 0.1);
				lineFull.graphics.drawRect(0, 0, maxBarWidth, GRAPH_HEIGHT+2);
				lineFull.graphics.endFill();
			}
		}
		
		private function drawBar():void
		{
			if (line)
			{
				line.graphics.clear();
				line.graphics.beginFill(0xEEEEEE, 1);
				line.graphics.drawRect(0, 0, maxBarWidth, height);
				line.graphics.endFill();
			}
		}

	}
}