package test.parserTest
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import sandy.core.World3D;
	import sandy.core.data.*;
	import sandy.core.scenegraph.*;
	import sandy.materials.*;
	import sandy.math.*;
	import sandy.parser.IParser;
	import sandy.parser.Parser;
	import sandy.parser.ParserEvent;
	import sandy.primitive.*;
	import sandy.parser.ColladaParser;
	
	[SWF(width="500", height="500", backgroundColor="#FFFFFF", frameRate=120)] 
	/**
	 * @author thomaspfeiffer
	 */
	public class ParserTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 700;
		internal static const SCREEN_HEIGHT:int = 700;

		private var _world:World3D;
		private var timer:Timer;
		private var m_oShape:Shape3D;
		
		private var fps: CustomFPS;
		
		[Embed(source="assets/texrin2.jpg")]
		private var Texture:Class;
		[Embed(source="assets/collada/multi-mesh-2texture.dae", mimeType="application/octet-stream")]
		private var MyCollada:Class;
//		[Embed(source="assets/Rhino.ASE", mimeType="application/octet-stream")]
//		private var MyRhino:Class;
		
		public function ParserTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			// -- FPS
			fps = new CustomFPS();
			fps.y = 12;
			addChild( fps );
			// --
			_world = World3D.getInstance();
			_world.container = this;
			
			//-- browser booster
			timer = new Timer(16);
			timer.addEventListener( TimerEvent.TIMER, onEnterFrame );
			
			_init();
		}
		
		private function _init():void
		{
//			var l_iParser:IParser = Parser.create("assets/Rhino.ASE");
//			var l_iParser:IParser = Parser.create( new MyRhino(), Parser.ASE );
//			var l_iParser:IParser = Parser.create("assets/octopus.3ds", Parser.MAX_3DS );
			var l_iParser:IParser = Parser.create( new MyCollada(), Parser.COLLADA );
//			var l_iParser:IParser = Parser.create( "assets/collada/mycone.dae", Parser.COLLADA );
			//var l_iParser:IParser = Parser.create( "assets/car07.3ds" );
			l_iParser.addEventListener( ParserEvent.onInitEVENT, _createScene );
//			l_iParser.RELATIVE_TEXTURE_PATH = "assets/collada";
			ColladaParser( l_iParser ).RELATIVE_TEXTURE_PATH = "assets/collada";
			l_iParser.parse();
		}
		
		private function _createScene( p_eEvent:ParserEvent ):void
		{
			_world.root = p_eEvent.group;

//			m_oShape = _world.root.getChildFromId( 1 ) as Shape3D;
			//var l_oApp:Appearance = new Appearance( new WireFrameMaterial(2, 0xFF) );
//			var l_oApp:Appearance = new Appearance( new ColorMaterial( 0xFF, 100, new LineAttributes() ) );
			//var pic:Bitmap = new Texture();
			//var l_oApp:Appearance = new Appearance( new BitmapMaterial( pic.bitmapData ) ); 
//			m_oShape.appearance = l_oApp;
			//m_oShape.rotateX = 180;
			//m_oShape.rotateY = 90;

			// --
			_world.camera = new Camera3D( SCREEN_WIDTH, SCREEN_HEIGHT );
			_world.camera.z = -200;
			_world.root.addChild( _world.camera );
			// --
			timer.start();
		}
	
		private function onEnterFrame( event: Event ): void
		{
//			m_oShape.rotateX += (stage.width/2 - mouseX)/100;
	//		m_oShape.rotateY += (stage.height/2 - mouseY)/100;
			_world.render();
			fps.nextFrame();
		}
	}
}