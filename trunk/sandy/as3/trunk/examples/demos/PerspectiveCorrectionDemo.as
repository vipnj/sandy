package demos
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import sandy.core.World3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.attributes.LineAttributes;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.primitive.Plane3D;
	import sandy.primitive.PrimitiveMode;


	public final class PerspectiveCorrectionDemo extends Sprite
	{
		[Embed(source="assets/grille.jpg")]
		private var Texture2:Class;
		
		private var m_oScene:World3D;
		private var m_oPlane:Plane3D;
		private var keyPressed:Array = new Array();
		
		public function PerspectiveCorrectionDemo()
		{
			super();
		}
		
		public function init():void
		{
			var lCamera:Camera3D = new Camera3D( 640, 480 );
			m_oScene = World3D.getInstance();
			m_oScene.container = this;
			m_oScene.camera = lCamera ;
			lCamera.z = -400;
			lCamera.y = 90;
			lCamera.lookAt( 0, 0, 0 );
			m_oScene.root = _createScene3D();
			m_oScene.root.addChild( lCamera );
			// --
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
			m_oScene.render();
		}
			
		private function _createScene3D():Group
		{
			var lG:Group = new Group("rootGroup");

			m_oPlane = new Plane3D("myPlane", 300, 300, 1, 1, Plane3D.ZX_ALIGNED, PrimitiveMode.TRI );
			m_oPlane.enableNearClipping = true;
			var lPic:Bitmap = new Texture2();
			var l_oMaterial:BitmapMaterial = new BitmapMaterial( lPic.bitmapData, new MaterialAttributes( new LineAttributes() ), 5);
			m_oPlane.appearance = new Appearance( l_oMaterial );

			// --
			lG.addChild( m_oPlane );

			return lG;
		}
	}
}
