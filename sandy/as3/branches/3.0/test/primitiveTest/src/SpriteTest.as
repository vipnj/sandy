package
{
	import com.mir3.display.FPSMetter;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.ByteArray;
	
	import sandy.core.World3D;
	import sandy.core.data.*;
	import sandy.core.scenegraph.*;
	import sandy.materials.*;
	import sandy.math.*;
	import sandy.primitive.*;
	import sandy.util.NumberUtil;
	
	[SWF(width="500", height="500", backgroundColor="#FFFFFF", frameRate=120)] 
	/**
	 * @author thomaspfeiffer
	 */
	public class SpriteTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;
		internal static const NUMBER:int = 60;
		internal static const RADIUS:int = 200;
		
		public const swfFile:String = "assets/texture.jpg";


		private var _mc:Sprite;
		private var _world:World3D;
		private var tgRotation:TransformGroup;
		
		public function SpriteTest()
		{
			Matrix4Math.USE_FAST_MATH = true;
			_mc = this;
			// --
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			// -- FPS
			addChild(new FPSMetter(false, 110, stage));
			// --
			_world = World3D.getInstance();
			// FIRST THING TO INITIALIZE
			_world.container = this;
			_init();
		}
		
		private function _init():void
		{
			_world.camera = new Camera3D( SCREEN_WIDTH, SCREEN_HEIGHT );
			_createScene();
			//
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp );
		}
		
		private function onMouseDown( e:Event ):void
		{m_bMouseIsDown = true;}
		private function onMouseUp( e:Event ):void
		{m_bMouseIsDown = false;}
		
		private function _createScene():void
		{
            var loader:URLLoader = new URLLoader();
            configureListeners(loader);
            loader.dataFormat = URLLoaderDataFormat.BINARY;
            var request:URLRequest = new URLRequest( swfFile );
            try
            {
                loader.load(request);
            }
            catch (error:Error)
            {
                trace("Unable to load requested document.");
            }
        }
 
        private function configureListeners(dispatcher:IEventDispatcher):void
        {
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }
 
        private function ioErrorHandler(event:IOErrorEvent):void 
        {
            trace("ioErrorHandler: " + event);
        }
        
        private function completeHandler(event:Event):void
        {
            var g:Group = new Group();
            var loader:URLLoader = URLLoader(event.target);
            var lStep:Number = 2*Math.PI / NUMBER;
			for( var i:int = 0; i < NUMBER; i++ )
			{
				var lSprite:Sprite2D = createSprite( loader );
				lSprite.x = /*Math.random() * 4000 * (Math.random()-0.5);*/Math.cos( i * lStep ) * RADIUS;
				lSprite.z = /*Math.random() * 4000 * (Math.random()-0.5);*/Math.sin( i * lStep ) * RADIUS;
				g.addChild( lSprite );
			}
			// --
			_world.root = g;
			_world.root.addChild( _world.camera );
			//
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function createSprite( pLoader:URLLoader ):Sprite2D
		{
            var data:ByteArray = (pLoader.data as ByteArray );
            // --
            var l:Loader = new Loader();
            l.loadBytes( data );
       		// --
            return new Sprite2D("sprite", l, 0.2);
		}
	
		private function enterFrameHandler( event : Event ) : void
		{
			_world.camera.rotateY -= 0.01 * (_mc.mouseX - SCREEN_WIDTH/2);
			_world.camera.tilt = NumberUtil.constrain( 0.01 * (_mc.mouseY - SCREEN_HEIGHT/2), -45, 45 );
			if( m_bMouseIsDown ) _world.camera.moveHorizontally( 5 );
			_world.render();
		}
		
		
		private var m_bMouseIsDown:Boolean = false;
	}
}