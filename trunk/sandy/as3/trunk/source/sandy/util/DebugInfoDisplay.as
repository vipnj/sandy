package sandy.util
{

   	import flash.display.Sprite;
   	import flash.text.TextField;
   	import flash.events.Event;
   	import flash.utils.getTimer;
	import flash.system.System;
	
	import sandy.core.World3D;
	import sandy.core.Object3D;
	import sandy.core.group.TransformGroup;
	
	public class DebugInfoDisplay extends Sprite 
	{
		private var tf: TextField;
		private var vertices:uint;
		private var faces:uint;
		private var rendered_faces:uint;
		
		public function DebugInfoDisplay() 
		{
			tf = new TextField();
			tf.textColor = 0xaa0000;
			tf.autoSize = 'left';

			addChild( tf );
			vertices = 0;
			faces = 0;
			rendered_faces = 0;

			addEventListener( Event.ENTER_FRAME, render );

		}
        
        private function render( event: Event ): void
		{
			
			var childs:Array = new Array();
			var cameras:Array = new Array();
			
			if (World3D.getRootGroup() != null)
			{
				childs = World3D.getRootGroup().getChildList();
				vertices = 0;
				faces = 0;
				for (var i:String in childs)
				{
					var child:TransformGroup = childs[i];
					var childs2:Array = child.getChildList();
					
					for (var j:String in childs2)
					{
						//var child3:Object3D = childs2[j];
						//vertices += child3.aPoints.length;
						//faces += child3.aFaces.length;
					}
				}
			}
			if (World3D.getCameraList() != null)
			{
				cameras = World3D.getCameraList();
			}
			tf.text = "Memory: " + int(System.totalMemory/1024) + "\n";
			tf.appendText("Scene vertices: " + vertices.toString() + "\n");
			tf.appendText("Scene faces: " + faces.toString() + "\n");
			tf.appendText("Scene rendered faces: " + rendered_faces.toString() + "\n");
			tf.appendText("Scene cameras: " + cameras.length.toString() + "\n");
			tf.appendText("Scene objects: " + childs.length.toString() + "\n");

		}
	
		public function set color(n:uint):void
		{
			tf.textColor = n;
		}
	}
}