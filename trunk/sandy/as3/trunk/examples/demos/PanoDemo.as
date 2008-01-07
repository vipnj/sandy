package demos
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import sandy.core.World3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.events.QueueEvent;
	import sandy.events.SandyEvent;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.primitive.SkyBox;
	import sandy.util.LoaderQueue;
	import sandy.util.NumberUtil;
	import sandy.materials.Material;

	public final class PanoDemo extends Sprite
	{
		public function PanoDemo():void
		{
			super();
		}
		
		private var world:World3D = World3D.getInstance();
		private var shape:SkyBox;
		private var planeNames:Array;
		private var polygons:Array;
		private var textures:Array;	
		private var running:Boolean = false;
		private var keyPressed:Array = new Array();
		private var queue:LoaderQueue = new LoaderQueue();
		private var camera:Camera3D;
		
		public function init():void
		{
			world.container = this;
			world.root = createScene();
			camera = world.camera = new Camera3D( 640, 500 );
			world.camera.fov = 60;
			planeNames = [ "GOLD44", "GOLD22" , "GOLD66", "GOLD55","GOLD11" , "GOLD33" ];			
			world.root.addChild( world.camera );
			// --
			loadImages();	
		}
		
		public function __onKeyDown(e:KeyboardEvent):void
		{
            keyPressed[e.keyCode] = true;
            if( e.keyCode == Keyboard.SPACE )
            	stage.displayState = StageDisplayState.FULL_SCREEN;
        }

        public function __onKeyUp(e:KeyboardEvent):void
        {
           keyPressed[e.keyCode] = false;
        }
		
		private function clickHandler( p_oEvt:Event ):void
		{
			running = !running;
		}
		
		//  -- Loading images
		private function loadImages():void
		{
			textures = new Array( planeNames.length );
			// --
			for ( var i:int = 0; i < 6; i++)
			{
				queue.add( planeNames[i], new URLRequest("assets/golden/"+planeNames[i]+".jpg") );
			}
			// --
			queue.addEventListener(SandyEvent.QUEUE_COMPLETE, loadComplete );
			queue.start();
		}
		
		private function getMaterial( p_nId:uint ):Material
		{
			var l_nPrecision:uint = 10;
			var l_oMat:BitmapMaterial = new BitmapMaterial( queue.data[planeNames[p_nId]].bitmapData, null, l_nPrecision );
			l_oMat.repeat = true;
			l_oMat.maxRecurssionDepth = 6;
			return l_oMat;
		}
		
		private function loadComplete( event:QueueEvent ):void 
		{			
			shape.front.appearance = new Appearance( getMaterial(1) );
			shape.back.appearance = new Appearance( getMaterial(0) );
			shape.left.appearance = new Appearance( getMaterial(4) );
			shape.right.appearance = new Appearance( getMaterial(5) );
			shape.top.appearance = new Appearance( getMaterial(3) );
			shape.bottom.appearance = new Appearance(  getMaterial(2) );				
			// --
			
			shape.front.enableClipping = true;
			shape.back.enableClipping = true;
			shape.left.enableClipping = true;
			shape.right.enableClipping = true;
			shape.top.enableClipping = true;
			shape.bottom.enableClipping = true;
			
			/*
			shape.front.enableNearClipping = true;
			shape.back.enableNearClipping = true;
			shape.left.enableNearClipping = true;
			shape.right.enableNearClipping = true;
			shape.top.enableNearClipping = true;
			shape.bottom.enableNearClipping = true;
			*/
			// --
			stage.addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
			// --		
			stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			// --
			running = true;		
		}
		
		// Create the root Group and the object tree 
		private function createScene():Group
		{
			var root:Group = new Group("root");
			shape = new SkyBox( "pano", 300, 1, 1, false );
			root.addChild( shape );
			return root;
		}
		
		private function enterFrameHandler( event : Event ) : void
		{
			if( running )
			{
				// TODO pre compute some values
				camera.rotateZ += 5*(( this.mouseX - (stage.stageWidth/2)  ) / stage.stageWidth);
				camera.tilt = NumberUtil.constrain( camera.tilt + 5*(( this.mouseY - (stage.stageHeight/2) )/stage.stageHeight), -89, 89 );
				//camera.rotateY++;
				//camera.rotateX ++;
				var t:int = getTimer();
				world.render();
				trace(getTimer() - t+" ms");

			}
		}
	}
}