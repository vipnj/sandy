package demos
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import sandy.core.Scene3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.parser.ColladaParser;
	import sandy.parser.Parser;
	import sandy.parser.ParserEvent;
	import sandy.primitive.Sphere;
	
	public final class ColladaDemo extends Sprite
	{

		public function ColladaDemo()
		{;}

		private var m_oScene:Scene3D;
		private var keyPressed:Array = new Array();
		
		public function init():void
		{
			var lCamera:Camera3D = new Camera3D( 640, 480 );
			lCamera.z = -400;
			lCamera.y = 40;
			m_oScene = new Scene3D( "mainScene", this, lCamera );	
			// --
			load();
		}
		
		private function _enableEvents():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
	
		public function __onKeyDown(e:KeyboardEvent):void
		{
            keyPressed[e.keyCode]=true;
        }

        public function __onKeyUp(e:KeyboardEvent):void
        {
           keyPressed[e.keyCode]=false;
        }
  
	  	private function load():void
	  	{
	  		//var l_oParser:ColladaParser = Parser.create( "assets/models/box.DAE", Parser.COLLADA, 1 ) as ColladaParser;
	  		//var l_oParser:ColladaParser = Parser.create( "assets/models/tank3.DAE", Parser.COLLADA, 1 ) as ColladaParser;
	  		//var l_oParser:ColladaParser = Parser.create( "assets/models/Focus.DAE", Parser.COLLADA, 10 ) as ColladaParser;
	  		var l_oParser:ColladaParser = Parser.create( "assets/models/Cube.DAE", Parser.COLLADA, 10 ) as ColladaParser;

			// Important to make Sandy load the textures from DAE file directly
	  		l_oParser.RELATIVE_TEXTURE_PATH = "assets/textures/";
	  		l_oParser.addEventListener( ParserEvent.INIT, _createScene3D );
	  		l_oParser.addEventListener( ParserEvent.FAIL, _onFail );
	  		l_oParser.parse();
	  	}
	  	
	  	private function _onFail( p_oEvt:ParserEvent ):void
		{
			trace("chargement/parsing cancelled");
		}
		
  		private function _createScene3D( p_oEvt:ParserEvent ):void
		{
			m_oScene.root = p_oEvt.group;
			// This is how you can find an object back.
			//var l_oShape:Shape3D = m_oScene.root.getChildByName("Body", true ) as Shape3D;
			//if( l_oShape ) l_oShape.rotateZ = 0;
			
			m_oScene.root.addChild( m_oScene.camera );
			_enableEvents();
		}	
		
		private function enterFrameHandler( event : Event ) : void
		{
			var cam:Camera3D = m_oScene.camera;
			// --
			if( keyPressed[Keyboard.RIGHT] ) 
			{   
			    cam.rotateY -= 5;
			}
			if( keyPressed[Keyboard.LEFT] )     
			{
			    cam.rotateY += 5;
			}		
			if( keyPressed[Keyboard.UP] )
			{ 
			    cam.moveHorizontally( 10 );
			}
			if( keyPressed[Keyboard.DOWN] )
			{ 
			    cam.moveHorizontally( -10 );
			}
			// --
			m_oScene.render();
		}
		
	}
}