package
{
	import flash.display.Sprite;
	import sandy.parser.Parser;
	import sandy.parser.IParser;
	import sandy.parser.ParserEvent;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.Appearance;
	import sandy.materials.ColorMaterial;
	import flash.events.Event;
	import sandy.core.scenegraph.Camera3D;
	import flash.display.MovieClip;
	import sandy.core.World3D;
	import flash.display.StageScaleMode;
	import sandy.materials.BitmapMaterial;
	import flash.display.Bitmap;
	
	[SWF(width="1000", height="600", backgroundColor="#FFFFFF", frameRate="120")] 
	
	public class ColladaTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 1000;
		internal static const SCREEN_HEIGHT:int = 600;    
		
		internal static const SCREEN_WIDTH2:int = 500;
		internal static const SCREEN_HEIGHT2:int = 300;    
		
		private var world : World3D;
		private var camera : Camera3D;
		private var model:Shape3D;
		private var container:MovieClip;
		private var nLoaded:uint = 0;
		[Embed(source="assets/plane_texture.png")]
		private var PlaneTexture:Class;
		
		[Embed(source="assets/ball_texture.png")]
		private var BallTexture:Class;
		
		//[Embed(source="assets/ball.dae", mimeType="application/octet-stream")]
		//private var MyCollada:Class;
		
		public function ColladaTest()
		{
			stage.quality = "MEDIUM";
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			_init();
			_createScene();
		}
		
		private function _init():void
		{		
			container = new MovieClip();
			//container.x = (stage.stageWidth) - SCREEN_WIDTH / 2;
			//container.y = (stage.stageHeight) - SCREEN_HEIGHT  / 2;
			addChild(container);
			//
			world = World3D.getInstance(); 
			world.container = container;
			// --
			camera = world.camera = new Camera3D( SCREEN_WIDTH, SCREEN_HEIGHT );
			camera.z = -100;
			camera.y = 100;
	
			world.root = new Group();
			world.root.addChild( camera  );
			return;
		}
		
		private function _createScene():void
		{
			var lParser:IParser = Parser.create( "assets/ball.dae"/*new MyCollada()*/, Parser.COLLADA, 1 );
			lParser.addEventListener( ParserEvent.onInitEVENT, _initRender );
			lParser.addEventListener( ParserEvent.onFailEVENT, _failInit );
			lParser.parse();
			
			var lParser2:IParser = Parser.create( "assets/plane.dae"/*new MyCollada()*/, Parser.COLLADA, 1 );
			lParser2.addEventListener( ParserEvent.onInitEVENT, _initRender );
			lParser2.addEventListener( ParserEvent.onFailEVENT, _failInit );
			lParser2.parse();
		}
		
		private function _failInit( pEvt:ParserEvent ):void
		{
			trace("model can't get parsed");
		}
		
		private function _initRender( pEvt:ParserEvent ):void
		{
			var lGroup:Group = Group( pEvt.group );
			world.root.addChild( lGroup.getChildList()[0].getChildList()[0] );

			if( ++nLoaded == 2 )
				addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}

		private function enterFrameHandler( event : Event ) : void
		{
			camera.x += ((container.mouseX - SCREEN_WIDTH2)* 30 - camera.x) / 40;
			camera.z += ((container.mouseY - SCREEN_HEIGHT2)* 30 - camera.z) / 40;
			// --
			camera.lookAt( 0, 0, 0 );
			// --
			world.render();	
		}
		
	}
}