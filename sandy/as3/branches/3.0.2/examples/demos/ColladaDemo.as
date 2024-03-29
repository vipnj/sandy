package demos
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import sandy.core.Scene3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.parser.Parser;
	import sandy.parser.Parser3DS;
	import sandy.parser.ParserEvent;
	
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
			lCamera.y = 80;
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
  
  		private function get appearance():Appearance
  		{
  			//var l_oMaterial:ColorMaterial = new ColorMaterial( 0xFF, 1, new MaterialAttributes(/* new GouraudAttributes( true, 0.1 ) */) );
  			var l_oMaterial:BitmapMaterial = new  BitmapMaterial( new BitmapData(1,1,false,0xFF), new MaterialAttributes(/* new GouraudAttributes( true, 0.1 ) */) );
  			//l_oMaterial.lightingEnable = true;
  			return new Appearance ( l_oMaterial );
  		}
  		
	  	private function load():void
	  	{
	  		//var l_oParser:ColladaParser = Parser.create( "assets/models/box.DAE", Parser.COLLADA, 1 ) as ColladaParser;
	  		//var l_oParser:ColladaParser = Parser.create( "assets/models/tank3.DAE", Parser.COLLADA, 1 ) as ColladaParser;
	  		//var l_oParser:ColladaParser = Parser.create( "assets/models/Focus.DAE", Parser.COLLADA, 10 ) as ColladaParser;
	  	//	var l_oParser:ColladaParser = Parser.create( "assets/models/complice_01.DAE", Parser.COLLADA, 1 ) as ColladaParser;
		var l_oParser:Parser3DS = Parser.create( "assets/models/impreza.3ds", Parser.MAX_3DS, 30 ) as Parser3DS;
			// Important to make Sandy load the textures from DAE file directly
	  		//l_oParser.RELATIVE_TEXTURE_PATH = "assets/textures/";
	  		l_oParser.standardAppearance = appearance;
	  		l_oParser.addEventListener( ParserEvent.INIT, _createScene3D );
	  		l_oParser.addEventListener( ParserEvent.FAIL, _onFail );
	  		l_oParser.addEventListener( ParserEvent.PROGRESS, _onProgress );
	  		l_oParser.parse();
	  	}
	  	
	  	private function _onProgress( p_oEvt:ParserEvent ):void
	  	{
	  	    trace( p_oEvt.percent );
	  	}
	  	
	  	private function _onFail( p_oEvt:ParserEvent ):void
		{
			trace("chargement/parsing cancelled");
		}
		
  		private function _createScene3D( p_oEvt:ParserEvent ):void
		{
			m_oScene.root = p_oEvt.group;
			//m_oScene.root.enableBackFaceCulling = false;
			// This is how you can find an object back.
			//var l_oShape:Shape3D = m_oScene.root.getChildByName("Body", true ) as Shape3D;
			//if( l_oShape ) l_oShape.rotateZ = 0;
			//var l_oShape:Shape3D = p_oEvt.group.children[0];
			//l_oShape.enableEvents = true;
			//l_oShape.addEventListener( MouseEvent.MOUSE_OVER, onShapeEvent );
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