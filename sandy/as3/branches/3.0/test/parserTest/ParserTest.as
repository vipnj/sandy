package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.text.TextFieldAutoSize;
		
	import sandy.core.World3D;
	import sandy.core.data.*;
	import sandy.math.*;
	import sandy.core.scenegraph.*;
	import sandy.materials.*;
	import sandy.primitive.*;
	import sandy.parser.Parser;
	import sandy.parser.IParser;
	import sandy.parser.ParserEvent;
	
	[SWF(width="500", height="500", backgroundColor="#FFFFFF", frameRate=120)] 
	/**
	 * @author thomaspfeiffer
	 */
	public class ParserTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;

		private var _world:World3D;
		private var timer:Timer;
		private var m_oShape:Shape3D;
		
		private var fps: CustomFPS;
		
		[Embed(source="assets/texrin2.jpg")]
		private var Texture:Class;
		
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
			_init();
			//-- browser booster
			timer = new Timer(16);
			timer.addEventListener( TimerEvent.TIMER, onEnterFrame );
		}
		
		private function _init():void
		{
			//var l_iParser:IParser = Parser.create("assets/Rhino.ASE");
			var l_iParser:IParser = Parser.create("assets/octopus.3ds", Parser.MAX_3DS );
			//var l_iParser:IParser = Parser.create( "assets/car07.3ds" );
			l_iParser.addEventListener( ParserEvent.onInitEVENT, _createScene );
			l_iParser.parse();
		}
		
		private function _createScene( p_eEvent:ParserEvent ):void
		{
			_world.root = p_eEvent.group;
			m_oShape = _world.root.getChildFromId( 1 ) as Shape3D;
			//var l_oApp:Appearance = new Appearance( new WireFrameMaterial(2, 0xFF) );
			var l_oApp:Appearance = new Appearance( new ColorMaterial( 0xFF, 100, new LineAttributes() ) );
			//var pic:Bitmap = new Texture();
			//var l_oApp:Appearance = new Appearance( new BitmapMaterial( pic.bitmapData ) ); 
			m_oShape.appearance = l_oApp;
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
			m_oShape.rotateX += (stage.width/2 - mouseX)/100;
			m_oShape.rotateY += (stage.height/2 - mouseY)/100;
			_world.render();
			fps.nextFrame();
		}
	}
}