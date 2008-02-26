package demos
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import sandy.core.Scene3D;
	import sandy.core.scenegraph.ATransformable;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.attributes.*;
	import sandy.parser.IParser;
	import sandy.parser.Parser;
	import sandy.parser.ParserEvent;
	
	public final class MaxDemo extends Sprite
	{	
		public static const PHONG:String = "phong";	
		public static const GOURAUD:String = "gouraud";	
		public static const FLAT:String = "flat";	
		public static const NONE:String = "none";	
		
		public function MaxDemo()
		{
			super();
		}
		[Embed(source="../assets/textures/textureKitty.jpg")]
		private var Texture:Class;
		
		[Embed( source="../assets/models/kitty.ase", mimeType="application/octet-stream" )]
		private var Kitty:Class;
		
		private var m_oScene:Scene3D;
		private var keyPressed:Array = new Array();
		
		public function init():void
		{
			var lCamera:Camera3D = new Camera3D( 640, 480 );
			lCamera.z = -300;
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
  
  		private function _createMaterialAttributes( p_sType:String ):MaterialAttributes
  		{
  			var l_oAttr:ALightAttributes = null;
  			switch( p_sType )
  			{
  				case GOURAUD:
  					l_oAttr = new GouraudAttributes( true, 0.2 );
  					break;
  				case  PHONG:
  					l_oAttr = new PhongAttributes( true, 0.2 );
  					//l_oAttr.diffuse = 0.3;
  					l_oAttr.specular = 0.5;
  					l_oAttr.gloss = 20;
  					break;
  				case FLAT:
  					l_oAttr = new LightAttributes( true, 0.2 );
  					break;
  				case NONE:
  				default :
  					l_oAttr = null
  					break;
  			}
  			// --
  			return new MaterialAttributes( l_oAttr/*, new OutlineAttributes( 1, 0xFF00, 1 )*//*, new VertexNormalAttributes(10, 1, 0xFF, 1 )*/ );
 
  		}
  		
	  	private function _createAppearance( p_sType:String ):Appearance
	  	{
	  		var l_oBitmap:Bitmap = new Texture();
	  		var l_oMat:BitmapMaterial = new BitmapMaterial( l_oBitmap.bitmapData, _createMaterialAttributes(p_sType) );
	  		l_oMat.lightingEnable = true;
	  		return new Appearance( l_oMat );
	  	}
	  	
	  	private function load():void
	  	{
	  		//var l_oParser:IParser = Parser.create( "assets/models/SpaceFighter02.3ds", Parser.MAX_3DS );`
	  		var l_oParser:IParser = Parser.create( new Kitty(), Parser.ASE, 0.2 );
	  		l_oParser.standardAppearance = _createAppearance( PHONG );
	  		l_oParser.addEventListener( ParserEvent.INIT, _createScene3D );
	  		l_oParser.parse();
	  	}
	  	
  		private function _createScene3D( p_oEvt:ParserEvent ):void
		{
			m_oScene.root = p_oEvt.group;
			m_oScene.root.addChild( m_oScene.camera );
			// --
			var l_oKitty:Shape3D = m_oScene.root.children[0];
			
			var l_oKitty2:Shape3D = l_oKitty.clone("kitty2");
			l_oKitty2.x = -100;
			l_oKitty2.appearance = _createAppearance( GOURAUD );
			
			var l_oKitty3:Shape3D = l_oKitty.clone("kitty3");
			l_oKitty3.x = 100;
			l_oKitty3.appearance = _createAppearance( FLAT );
			// --
			m_oScene.root.addChild( l_oKitty2 );
			m_oScene.root.addChild( l_oKitty3 );
			// --
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
			for each( var l_oShape:ATransformable in m_oScene.root.children )
			{
				if( l_oShape is Shape3D )
					l_oShape.rotateY++;
			}
			//cam.setPerspectiveProjection( 0, 0, 0, 0 );
			// --
			m_oScene.render();
		}
		
	}
}