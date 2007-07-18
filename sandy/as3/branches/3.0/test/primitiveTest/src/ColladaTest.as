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
	
	[SWF(width="500", height="500", backgroundColor="#FFFFFF", frameRate="120")] 
	
	public class ColladaTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;    
		
		private var world : World3D;
		private var camera : Camera3D;
		private var model:Shape3D;
		
		[Embed(source="assets/texture.jpg")]
		private var Texture:Class;
		
		[Embed(source="assets/corps.dae", mimeType="application/octet-stream")]
		private var MyCollada:Class;
		
		public function ColladaTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			_init();
			_createScene();
		}
		
		private function _init():void
		{		
			var l_mcWorld:MovieClip = new MovieClip();
			l_mcWorld.x = (stage.stageWidth - SCREEN_WIDTH) / 2;
			l_mcWorld.y = (stage.stageHeight - SCREEN_HEIGHT) / 2;
			addChild(l_mcWorld);
			//
			world = World3D.getInstance(); 
			world.container = l_mcWorld;
			// --
			camera = world.camera = new Camera3D( SCREEN_WIDTH, SCREEN_HEIGHT );
			camera.z = -500;
			return;
		}
		
		private function _createScene():void
		{
			//var lParser:IParser = Parser.create( new MyCollada(), Parser.COLLADA, 30 );
			var lParser:IParser = Parser.create( "assets/puppet_corps.3ds", Parser.MAX_3DS, 30 );
			lParser.addEventListener( ParserEvent.onInitEVENT, _initRender );
			lParser.addEventListener( ParserEvent.onFailEVENT, _failInit );
			lParser.parse();
		}
		
		private function _failInit( pEvt:ParserEvent ):void
		{
			trace("model can't get parsed");
		}
		
		private function _initRender( pEvt:ParserEvent ):void
		{
			var lGroup:Group = Group( pEvt.group );
			world.root = lGroup;
			world.root.addChild( camera );
			model = lGroup.getChildList()[0];//.getChildList()[0];
			
			var pic:Bitmap = new Texture();
			var l_oTextureAppearance:Appearance = new Appearance( new BitmapMaterial( pic.bitmapData ) ); 
			
			model.appearance = l_oTextureAppearance; //new Appearance( new ColorMaterial( 0xCCCCCC ) );
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}

		private function enterFrameHandler( event : Event ) : void
		{
			world.render();	
		}
		
	}
}