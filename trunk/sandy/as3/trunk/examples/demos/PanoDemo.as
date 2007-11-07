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

	public final class PanoDemo extends Sprite
	{
		public function PanoDemo():void
		{
			super();
		}
		
		private var m_nTotal:int = 0;
		private var m_nIteration:int = 0;
		
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

		private function loadComplete( event:QueueEvent ):void 
		{
			shape.front.appearance = new Appearance( new BitmapMaterial( (queue.data[planeNames[1]] as Bitmap).bitmapData ) );
			shape.back.appearance = new Appearance( new BitmapMaterial( queue.data[planeNames[0]].bitmapData ) );
			shape.left.appearance = new Appearance( new BitmapMaterial( queue.data[planeNames[4]].bitmapData ) );
			shape.right.appearance = new Appearance( new BitmapMaterial( queue.data[planeNames[5]].bitmapData ) );
			shape.top.appearance = new Appearance( new BitmapMaterial( queue.data[planeNames[3]].bitmapData ) );
			shape.bottom.appearance = new Appearance( new BitmapMaterial( queue.data[planeNames[2]].bitmapData ) );				
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
			shape = new SkyBox( "pano", 300, 10, 10, false );
			//shape.bottom.enableBackFaceCulling = false;
			root.addChild( shape );
			return root;
		}
		
		private function enterFrameHandler( event : Event ) : void
		{
			if( running )
			{
				// TODO pre compute some values
				camera.rotateY -= 5*(( this.mouseX - (stage.stageWidth/2)  ) / stage.stageWidth);
				camera.tilt = NumberUtil.constrain( camera.tilt + 5*(( this.mouseY - (stage.stageHeight/2) )/stage.stageHeight), -89, 89 );

				if( m_nIteration == 1000 )
				{
					trace( (m_nTotal / 1000)+" ms de rendu moyen");
				}
				else
				{
					m_nIteration ++;
					var t:int = getTimer();
					world.render();
					m_nTotal += ( getTimer() - t );
				}
			}
		}
	}
}