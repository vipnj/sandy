package
{

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.ui.Keyboard;
	
	import sandy.core.World3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.Appearance;
	import sandy.materials.VideoMaterial;
	import sandy.primitive.Box;

    [SWF(width="500", height="500", backgroundColor="#FFFFFF", frameRate="120")] 
    
	public class VideoTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;
		
		private var world : World3D;
		private var camera : Camera3D;
		private var keyPressed:Array;
		private var conn : NetConnection;
		private var v1 : Video;
		private var v2 : Video;
		private var stream1 : NetStream;
		private var stream2 : NetStream;
		
		public function VideoTest()
		{
			super();
			
			trace('stage: ' + stage);
			// --
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			// -- INIT
			keyPressed = [];
			connect();
			// -- User interface
			stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);		
		}
		
		public function connect() : void 
		{
			//	accessing the video
			conn = new NetConnection();
            conn.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            conn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			conn.connect( null );			
		}
		
		public function init():void
		{		
			// --
			var l_mcWorld:MovieClip = new MovieClip();
			l_mcWorld.x = (stage.stageWidth - SCREEN_WIDTH) / 2;
			l_mcWorld.y = (stage.stageHeight - SCREEN_HEIGHT) / 2;
			addChild(l_mcWorld);
			world = World3D.getInstance(); 
			world.container = l_mcWorld;
			// --
			world.camera = new Camera3D( SCREEN_WIDTH, SCREEN_HEIGHT );
			world.camera.z = -300;
			// -- create scen
			var quality:uint = 2;
			var quality2:uint = quality * quality * 2;//*2 because of tri
			var g:Group = new Group();
			var box:Shape3D = new Box( "box", 100, 100, 100, "tri", quality );

			v1 = connectStream( "assets/chat.flv", stream1 );
			v2 = connectStream( "assets/experts.flv", stream2 );
			
			
			for( var i:int = 0, j:int = 0; i < box.aPolygons.length-quality2-1; i+=quality2, j++ )
			{
			     for( var k:int = i; k < i+quality2; k ++ )
			     {
			     	box.aPolygons[k].appearance = new Appearance( new VideoMaterial( (j%2)?v1:v2) );
			     	//box.aPolygons[i+1].appearance = new Appearance( new VideoMaterial( (j%2)?v1:v2 ) );
			     }
			}
			//box.enableBackFaceCulling = false;
			// --			
			g.addChild( box );
			world.root = g;
			world.root.addChild( world.camera );
			
			// --
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
			
			
			return;
		}
	
        private function netStatusHandler(event:NetStatusEvent):void 
        {
        	trace( event.info.code );
            switch (event.info.code) 
            {
                case "NetConnection.Connect.Success":
                    init();
                    break;
                case "NetStream.Play.StreamNotFound":
                    trace("Unable to locate video: ");
                    break;
                case "NetStream.Play.Stop":
               		event.target.seek(0);
                	break;
            }
        }
        
        private function connectStream( s : String, str : NetStream ): Video 
        {
			str = new NetStream( conn );
            str.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            str.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler)
            //stream.addEventListener(stream.ON_PLAY_STATUS, netStatusHandler);
			var v : Video = new Video();
			v.attachNetStream( str );
			str.play( s );
			return v;
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void 
        {
            trace("securityErrorHandler: " + event);
        }
        
        private function asyncErrorHandler(event:AsyncErrorEvent):void 
        {
            // ignore AsyncErrorEvent events.
        }

	
		public function __onKeyDown(e:KeyboardEvent):void
		{
            keyPressed[e.keyCode]=true;
        }

        public function __onKeyUp(e:KeyboardEvent):void
        {
           keyPressed[e.keyCode]=false;
        }
  
		private function enterFrameHandler( event : Event ) : void
		{
			var cam:Camera3D = world.camera;
			// --
			if( keyPressed[Keyboard.RIGHT] ) 
			{   
			    cam.rotateY -= 1;
			}
			if( keyPressed[Keyboard.LEFT] )     
			{
			    cam.rotateY += 1;
			}		
			if( keyPressed[Keyboard.UP] )
			{ 
			    cam.moveForward( 2 );
			}
			if( keyPressed[Keyboard.DOWN] )
			{ 
			    cam.moveForward( -2 );
			}	
			world.render();
		}
	}
}



class CustomClient 
{

    public function onMetaData(info:Object):void 
    {
        trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
    }

    public function onCuePoint(info:Object):void 
    {
        trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
    }
}

