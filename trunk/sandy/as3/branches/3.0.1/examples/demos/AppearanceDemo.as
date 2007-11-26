package demos
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import sandy.core.Scene3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.events.QueueEvent;
	import sandy.events.SandyEvent;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.attributes.LineAttributes;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.primitive.Plane3D;
	import sandy.primitive.PrimitiveMode;
	import sandy.util.LoaderQueue;
	
	public final class AppearanceDemo extends Sprite
	{
		public function  AppearanceDemo()
		{
			super();
		}	
		
		private var m_oScene:Scene3D;
		private var m_oPlane:Plane3D;
		private var queue:LoaderQueue = new LoaderQueue();
		
		public function init():void
		{
			queue.add( "texture1", new URLRequest("../assets/textures/texture3.jpg") );
			queue.add( "texture2", new URLRequest("../assets/textures/texture5.jpg") );
			// --
			queue.addEventListener(SandyEvent.QUEUE_COMPLETE, sceneInit );
			queue.start();
		}
		
		private function sceneInit( event:QueueEvent ):void
		{
			// -- creation of the camera
			var lCamera:Camera3D = new Camera3D( 640, 480 );
			lCamera.z = -400;
			lCamera.y = 100;
			lCamera.lookAt( 0, 0, 0 );
			// -- creation of the scene and link the camera to it
			var lRootNode:Group = _createScene3D();
			lRootNode.addChild( lCamera );
			// -- creation of the scene
			m_oScene = new Scene3D( "myScene", this, lCamera, lRootNode );
			// -- set the enterframe even to update our demo
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		
		private function createAppearance():Appearance
		{
			var l_oMaterialFront:BitmapMaterial = new BitmapMaterial( (queue.data["texture1"] as Bitmap).bitmapData, new MaterialAttributes( new LineAttributes(3, 0xFF, 1) ), 4);
			var l_oMaterialBack:BitmapMaterial = new BitmapMaterial( (queue.data["texture2"] as Bitmap).bitmapData, null, 4);
			return new Appearance( l_oMaterialFront, l_oMaterialBack );
		}
		
		private function _createScene3D():Group
		{
			var lG:Group = new Group("rootGroup");
			// --
			m_oPlane = new Plane3D("myPlane", 200, 200, 1, 1, Plane3D.ZX_ALIGNED, PrimitiveMode.TRI );
			m_oPlane.enableBackFaceCulling = false;
			//m_oPlane.swapCulling();
			m_oPlane.appearance = createAppearance();
			// --
			lG.addChild( m_oPlane );
			// --
			return lG;
		}
		
		private function enterFrameHandler( event : Event ) : void
		{
			m_oPlane.rotateX += (stage.width/2 - mouseX)*0.0055;
			m_oPlane.rotateY += (stage.height/2 - mouseY)*0.0055;
			m_oScene.render();
		}
		
	}
}