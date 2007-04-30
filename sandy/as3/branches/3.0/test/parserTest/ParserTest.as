package
{
	import com.mir3.display.FPSMetter;
	import com.mir3.utils.KeyManager;
	
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
	
	import sandy.core.World3D;
	import sandy.core.data.*;
	import sandy.math.*;
	import sandy.core.scenegraph.*;
	import sandy.materials.*;
	import sandy.primitive.*;
	import sandy.parser.Parser;
	import sandy.parser.IParser;
	import sandy.parser.ParserEvent;
	
	[SWF(width="800", height="800", backgroundColor="#FFFFFF", frameRate=120)] 
	/**
	 * @author thomaspfeiffer
	 */
	public class ParserTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 800;
		internal static const SCREEN_HEIGHT:int = 800;

		private var _world:World3D;
		private var timer:Timer;
		private var m_oShape:Shape3D;
		
		[Embed(source="assets/texrin2.jpg")]
		private var Texture:Class;
		
		public function ParserTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			// -- FPS
			addChild( new FPSMetter(false, 120, stage) );
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
			var l_iParser:IParser = Parser.parse("assets/Rhino.ASE");
			l_iParser.addEventListener( ParserEvent.onInitEVENT, _createScene );
			l_iParser.parse();
		}
		
		private function _createScene( p_eEvent:ParserEvent ):void
		{
			_world.root = p_eEvent.group;
			m_oShape = _world.root.getChildFromId( 1 ) as Shape3D;
			//var l_oApp:Appearance = new Appearance( new ColorMaterial( 0xFF ) );
			var pic:Bitmap = new Texture();
			var l_oApp:Appearance = new Appearance( new BitmapMaterial( pic.bitmapData ) ); 
			m_oShape.appearance = l_oApp;
			// --
			_world.camera = new Camera3D( SCREEN_WIDTH, SCREEN_HEIGHT );
			_world.camera.z = -8000;
			_world.root.addChild( _world.camera );
			// --
			timer.start();
		}
	
		private function onEnterFrame( event: Event ): void
		{
			m_oShape.rotateX -= 0.005 * (SCREEN_HEIGHT/2 - this.mouseY);
			m_oShape.rotateY += 0.005 * (SCREEN_WIDTH/2 - this.mouseX);
			_world.render();
		}
	}
}