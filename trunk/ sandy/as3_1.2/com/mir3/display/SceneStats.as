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
	public class SceneStats extends Sprite
	{
		private static var GRAPH_WIDTH:int = 50;
		private static var GRAPH_HEIGHT:int = 13;
		
		private var fps:TextField;
		private var graph: FPSGraph;
		private var line: Shape;
		private var lineFull: Shape;
		private var globalStage: Stage;
		
		private var isSilent: Boolean;
		
		private var sw: Number;
		private var maxValue: int;
		private var sh: Number;
		private var maxBarWidth: Number;
		
		
		
		public function SceneStats(p_silent:Boolean = false, p_graph:Boolean = true, p_bar:Boolean = false, p_stage:Stage = null)
		{
			isSilent = p_silent;
			
			if (isSilent)
			{
				visible = false;
				KeyManager.addKeyDown(tabKeyDown);
				KeyManager.addKeyUp(tabKeyUp);
			}
			
			maxValue = 8000; // max number of faces
			
			if (p_graph)
			{
				// _ FPS History
				graph = new FPSGraph(GRAPH_WIDTH, GRAPH_HEIGHT, 0xEEEEEE, maxValue);
				graph.x = 1;
				graph.y = 1;
				addChild(graph);
			}
			
			var format: TextFormat = new TextFormat();
			format.color = 0xEEEEEE;
			format.size = 9;
			format.bold = true;
			format.font = '_sans';
			
			// _ Num of faces
			fps = new TextField();
			fps.x = width + 3;
			addChild(fps);
			fps.autoSize = "left";
			fps.defaultTextFormat = format;
			fps.antiAliasType = AntiAliasType.ADVANCED;
			fps.text = "ZBuffer: ____ faces,  ____ 2d,  ____ 3D";
			
			graphics.beginFill(0x000000, 1);
            graphics.drawRect(0, 0, width+1, GRAPH_HEIGHT+2);
			graphics.endFill();
			
			var l_barXPos:Number = width + 1;
			
			if (p_bar)
			{
				line = new Shape();
				addChild(line);
				line.x = l_barXPos;
			}
			
			
			maxBarWidth = 300;
			
			if (p_stage)
			{
				globalStage = p_stage;
				
				// -- Stage resizing
				p_stage.scaleMode = StageScaleMode.NO_SCALE;
				p_stage.align = StageAlign.BOTTOM;
				p_stage.addEventListener(Event.RESIZE, stageResized);
				
				
				if (p_bar)
					maxBarWidth = p_stage.stageWidth - line.x - 10;
				
				x = 5; /*p_stage.stageWidth - fps.width - 5;*/
				y = p_stage.stageHeight - 7 - height * 2;
			}
			
			if (p_bar)
			{
				lineFull = new Shape();
				lineFull.x = l_barXPos;
				addChild(lineFull);
				
				drawBarBackground();
				drawBar();
			}
			
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
			update();
		}
		
		private function update():void
		{
			var l_faces:int = 0;//ZBuffer.getFacesNum();
			var l_sprites2d:int =0;// ZBuffer.getSprites2DNum();
			var l_sprites3d:int = 0;//ZBuffer.getSprites3DNum();
			
			fps.text = "ZBuffer: " +	l_faces + " faces,  " + 
										l_sprites2d + " 2D,  " + 
										l_sprites3d + " 3D";
			
			if (graph)
				graph.addValue(l_faces);
				
			if (line)
				line.scaleX = l_faces/maxValue;
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
			sw = globalStage.stageWidth;
			sh = globalStage.stageHeight;
			
			x = 5;
			y = sh - 7 - height * 2;
			
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