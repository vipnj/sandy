package demos
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Vector;
	import sandy.core.scenegraph.ATransformable;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.Appearance;
	import sandy.materials.WireFrameMaterial;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.materials.attributes.VertexNormalAttributes;
	import sandy.parser.ParserEvent;
	import sandy.primitive.Sphere;
	
	public final class VertexNormalDemo extends Sprite
	{

		
		public function VertexNormalDemo()
		{
			super();
		}
		
		private var m_oSphere:Sphere;
		private var m_oScene:Scene3D;
		private var keyPressed:Array = new Array();
		
		public function init():void
		{
			var lCamera:Camera3D = new Camera3D( 640, 480 );
			lCamera.z = -200;
			lCamera.y = 0;
			m_oScene = new Scene3D( "mainScene", this, lCamera );	
			// --
			_createScene3D( null );
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
  
  		private function _createMaterialAttributes():MaterialAttributes
  		{
  			return new MaterialAttributes( new VertexNormalAttributes(1, 0xFF, 1 ) );
  		}
  		
	  	
  		private function _createScene3D( p_oEvt:ParserEvent ):void
		{
			m_oScene.root = new Group();
			m_oSphere = new Sphere("mySphere", 30 );
			//m_oSphere.x = 200;
			//m_oSphere.geometryCenter = new Vector( 50, 0, 0 );
			//var l_oSphereMaterial:ColorMaterial = new ColorMaterial( 0xFF0000, 1, _createMaterialAttributes() );
			//l_oSphereMaterial.lightingEnable = true;
			var l_oSphereMaterial:WireFrameMaterial = new WireFrameMaterial( 1, 0, 1, _createMaterialAttributes() );
			m_oSphere.appearance = new Appearance( l_oSphereMaterial  );
			m_oScene.root.addChild( m_oSphere );
			
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
			if( keyPressed[Keyboard.UP] && !keyPressed[Keyboard.SPACE] )
			{ 
			    cam.moveForward( 10 );
			}
			if( keyPressed[Keyboard.DOWN] && !keyPressed[Keyboard.SPACE]  )
			{ 
			    cam.moveForward( -10 );
			}
			
			if( keyPressed[Keyboard.UP] && keyPressed[Keyboard.SPACE]  )
			{ 
			    cam.moveVertically( 10 );
			}
			if( keyPressed[Keyboard.DOWN] && keyPressed[Keyboard.SPACE]  )
			{ 
			    cam.moveVertically( -10 );
			}
			
			m_oSphere.rotateY++;
			// --
			m_oScene.render();
		}
		
	}
}