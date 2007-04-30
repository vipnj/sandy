package com.mir3.display 
{
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	

	/**
	*	@author Mirek Mencel //miras@polychrome.pl 
	*	@date 20.11.2006
	**/
	public class FPSGraph extends Sprite
	{
		internal static const BGCOLOR:uint = 0x171717;
		internal static const GRAPHCOLOR:uint = 0x00FF66;
		
		private var counter:int = 0;
		private var step:int = 5;
		private var lastValue:Number;
		private var graphColor:uint;
		private var maxValue:uint;
		private var graphMask:Shape;
		
		private var active:Shape;
		private var toSwitch:Shape;
		
		
		public function FPSGraph(p_width:int = 100, p_height:int = 55, p_graphColor:uint = GRAPHCOLOR, p_maxValue:uint = 60)
		{
			maxValue = p_maxValue;
			
			step = p_width /10;
			graphColor = p_graphColor;
			
			graphics.beginFill(BGCOLOR, 1);
            graphics.drawRect(0, 0, p_width, p_height);
			graphics.endFill();
			
			//mask
			graphMask = new Shape();
			addChild(graphMask);
			graphMask.graphics.beginFill(BGCOLOR);
            graphMask.graphics.drawRect(0, 0, p_width, p_height);
			graphMask.graphics.endFill();
			this.mask = graphMask;
			
			active = new Shape();
			addChild(active);
			
			active.graphics.lineStyle(1, graphColor, .6);
			active.graphics.moveTo(0, height);
			
			addEventListener( Event.ADDED, onAdded );	
			addEventListener( Event.REMOVED, onRemoved );
		}
		
		private function onAdded( event: Event ): void
		{
			//stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		private function onRemoved( event: Event ): void
		{
			//stage.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		public function addValue(p_value:Number):void 
		{
			if (int(counter+step) > int(graphMask.width))
			{
				if (toSwitch) 
				{
					removeChild(toSwitch);
				}
				
				toSwitch = active;
				active = new Shape();
				addChild(active);
				active.x = counter;
				active.y = 0;
				active.graphics.lineStyle(1, graphColor, .6);
				active.graphics.moveTo(0, getGraphY(lastValue));
				
				counter = 0;
			}
			
			counter+=step;
			
			active.graphics.lineTo(counter, getGraphY(p_value));
			
			if (toSwitch)
			{
				toSwitch.x -= step;
				active.x -= step;
			}
			
			lastValue = p_value;
		}
		
		private function getGraphY(p_value:Number):Number
		{
			return graphMask.height - (graphMask.height/100 * p_value*100/maxValue);
		}
		
	}
}