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
	import mx.containers.Panel;


	public class InteractionTest extends Sprite
	{
		private var m_oScene:Scene3D;
		private var m_oPlane:Shape3D;
		
	//	[Embed(source="../assets/textures/texture2.jpg")]
		//private var Texture:Class;
		
		private var m_oApp:Application;
		public function InteractionTest( p_oApp:Application )
		{
			m_oApp = p_oApp;
			init();
		}
		
		public function init():void
		{
			var lCamera:Camera3D = new Camera3D( 640, 240 );
			m_oScene = new Scene3D("scene", this, lCamera,  _createScene3D() );
			// --
			lCamera.z = -200;
			// --
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
	
		
		private function enterFrameHandler( event : Event ) : void
		{
			m_oPlane.rotateY += 0.5;
			m_oScene.render();
		}
			
		private function _createScene3D():Group
		{
			var lG:Group = new Group("rootGroup");
			
			m_oPlane = new Plane3D("plane", 200, 100, 1, 1, Plane3D.XY_ALIGNED );
			m_oPlane.rotateZ = 90;
			m_oPlane.enableBackFaceCulling  = false;
			m_oPlane.enableInteractivity = true;
			
			//var l_oTexture:Bitmap = new Texture();
			//var l_oMat:Material = new BitmapMaterial( l_oTexture.bitmapData, l_oAttr, 3 );
			var l_oObject:TextArea = m_oApp.getChildByName("textArea") as TextArea;
			var l_oObject2:Panel = m_oApp.getChildByName("myPanel") as Panel;

			var l_oMat:MovieMaterial = new MovieMaterial( l_oObject, 60, null );
			l_oMat.smooth = true;
			var l_oMat2:MovieMaterial = new MovieMaterial( l_oObject2, 60, null );
			l_oMat2.smooth = true;
			
			l_oMat.precision = 2;
			l_oMat2.precision = 2;
			
			m_oPlane.appearance = new Appearance( l_oMat, l_oMat2 );
			
			lG.addChild( m_oPlane );

			return lG;
		}
	
	}
}