package demos
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import sandy.core.Scene3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.events.BubbleEvent;
	import sandy.events.QueueEvent;
	import sandy.events.SandyEvent;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.materials.attributes.OutlineAttributes;
	import sandy.primitive.Plane3D;
	import sandy.primitive.PrimitiveMode;
	import sandy.util.LoaderQueue;
	import sandy.materials.attributes.DashedLineAttributes;
	
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
			queue.add( "texture1", new URLRequest("../assets/textures/may.jpg") );
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
			var l_oMatAtt:MaterialAttributes = new MaterialAttributes( new DashedLineAttributes(2, 0xFF, 1, 20, 5) );//, new OutlineAttributes(3, 0xFF, 1) );
			var l_oMaterialFront:BitmapMaterial = new BitmapMaterial( (queue.data["texture1"] as Bitmap).bitmapData, l_oMatAtt, 4);
			
			l_oMatAtt = new MaterialAttributes( new DashedLineAttributes(2, 0xFF0000, 1) );
			var l_oMaterialBack:BitmapMaterial = new BitmapMaterial( (queue.data["texture2"] as Bitmap).bitmapData, l_oMatAtt, 4);
			// --
			l_oMaterialFront.repeat = true;
			l_oMaterialBack.repeat = true;
			// --
			return new Appearance( l_oMaterialFront, l_oMaterialBack );
		}
		
		private function _createScene3D():Group
		{
			var lG:Group = new Group("rootGroup");
			// --
			m_oPlane = new Plane3D("myPlane", 200, 200, 1, 1, Plane3D.XY_ALIGNED, PrimitiveMode.TRI );
			m_oPlane.enableBackFaceCulling = false;
			m_oPlane.enableEvents = true;
			m_oPlane.addEventListener( MouseEvent.CLICK, onPlaneClick );
			
			m_oPlane.appearance = createAppearance();
			// --
			lG.addChild( m_oPlane );
			// --
			return lG;
		}
		
		private function onPlaneClick( pEvt:BubbleEvent ):void
		{	
			m_nTilingW %= 10; m_nTilingW++;
			m_nTilingH %= 10; m_nTilingH++;
			// --
			(m_oPlane.appearance.frontMaterial as BitmapMaterial).setTiling( m_nTilingW, m_nTilingH );
			(m_oPlane.appearance.backMaterial as BitmapMaterial).setTiling( m_nTilingW, m_nTilingH );
			//m_oPlane.removeEventListener( MouseEvent.CLICK, onPlaneClick );
		}
		
		private function enterFrameHandler( event : Event ) : void
		{
			m_oPlane.rotateX += (stage.width/2 - mouseX)*0.0055;
			m_oPlane.rotateY += (stage.height/2 - mouseY)*0.0055;
			m_oScene.render();
		}
		
		protected var m_nTilingH:int = 1;
		protected var m_nTilingW:int = 1;
	}
}