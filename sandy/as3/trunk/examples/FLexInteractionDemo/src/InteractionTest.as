package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.TextArea;
	import mx.core.Application;
	
	import sandy.core.Scene3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.Appearance;
	import sandy.materials.MovieMaterial;
	import sandy.primitive.Plane3D;


	public class InteractionTest extends Sprite
	{
		private var m_oScene:Scene3D;
		private var m_oPlane:Shape3D;
		
		[Embed(source="../assets/textures/texture2.jpg")]
		private var Texture:Class;
		
		private var m_oApp:Application;
		public function InteractionTest( p_oApp:Application )
		{
			m_oApp = p_oApp;
			init();
		}
		
		public function init():void
		{
			var lCamera:Camera3D = new Camera3D( 640, 480 );
			m_oScene = new Scene3D("scene", this, lCamera,  _createScene3D() );
			// --
			lCamera.z = -400;
			// --
			m_oApp.stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			m_oApp.stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
	
		private function onKeyUp( p_oEvt:KeyboardEvent ):void
		{
			if( p_oEvt.keyCode == Keyboard.LEFT )
				m_oPlane.rotateY--;
			if( p_oEvt.keyCode == Keyboard.RIGHT )
				m_oPlane.rotateY++;
		}
		
		private function onKeyDown( p_oEvt:KeyboardEvent ):void
		{
			;
		}
		
		private function enterFrameHandler( event : Event ) : void
		{
			m_oScene.render();
		}
			
		private function _createScene3D():Group
		{
			var lG:Group = new Group("rootGroup");
			
			m_oPlane = new Plane3D("plane", 200, 100, 1, 1, Plane3D.XY_ALIGNED );
			m_oPlane.rotateZ = 90;
			m_oPlane.enableEvents = true;
			m_oPlane.enableInteractivity = true;
			
			var l_oTexture:Bitmap = new Texture();
			//var l_oMat:Material = new BitmapMaterial( l_oTexture.bitmapData, l_oAttr, 3 );
			var l_oObject:TextArea = m_oApp.getChildByName("textArea") as TextArea;

			var l_oMat:MovieMaterial = new MovieMaterial( l_oObject, 40, null );
			l_oMat.smooth = true;
			m_oPlane.appearance = new Appearance( l_oMat );
			
			lG.addChild( m_oPlane );

			return lG;
		}
	
	}
}