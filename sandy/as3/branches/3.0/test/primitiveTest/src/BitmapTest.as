package 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;
	
	import sandy.core.World3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.TransformGroup;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.primitive.Box;
	import sandy.primitive.Plane3D;
	import sandy.primitive.PrimitiveMode;
	import sandy.primitive.Sphere;
	import sandy.primitive.Torus;

	[SWF(width="640", height="500", backgroundColor="#FFFFFF", frameRate=120)] 
	public class BitmapTest extends Sprite
	{
		[Embed(source="assets/liquid-metal.jpg")]
		private var Texture:Class;
		
		[Embed(source="assets/binpatt1.png")]
		private var Texture2:Class;
		
		private var fps: CustomFPS;
		private var stats:TextField = new TextField();
		
		private var m_oScene:World3D;
		private var m_oBox:Box;
		private var m_oSphere:Sphere;
		private var m_oPlane:Plane3D;
		private var m_oTorus:Torus;
		
		public function BitmapTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			//stage.align = StageAlign.TOP_LEFT;
			// --
			fps = new CustomFPS();
			fps.y = 480;
			addChild( fps );
			
			stats.y = 480;
			stats.x = 50;
			stats.width = 300;
			addChild( stats );
			// --
			var lCamera:Camera3D = new Camera3D( 640, 480 );
			m_oScene = World3D.getInstance();
			m_oScene.container = this;
			m_oScene.camera = lCamera ;
			lCamera.z = -400;
			lCamera.y = 100;
			lCamera.lookAt( 0, 0, 0 );
			m_oScene.root = _createScene3D();
			m_oScene.root.addChild( lCamera );
			// --
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function _createScene3D():Group
		{
			var lG:Group = new Group("rootGroup");
			var lTg:TransformGroup = new TransformGroup("rotationPivot");
			// --
			m_oPlane = new Plane3D("myPlane", 300, 300, 5, 8, Plane3D.ZX_ALIGNED, PrimitiveMode.TRI );
			var lPic:Bitmap = new Texture2();
			m_oPlane.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );
			// --
			m_oTorus = new Torus("myTorus", 30, 15, 6, 6 );
			var lPic2:Bitmap = new Texture();
			m_oTorus.appearance = new Appearance( new BitmapMaterial( lPic2.bitmapData ) );
			m_oTorus.x = -50;
			m_oTorus.y = 30;
			m_oTorus.z = -120;
			// --
			m_oBox = new Box("myBox", 50, 50, 50, PrimitiveMode.TRI, 5);
			m_oBox.y = 45;
			m_oBox.appearance = new Appearance( new BitmapMaterial( lPic2.bitmapData ) );//new Appearance( new ColorMaterial( 0xFF0000, new LineAttributes() ));
			// --
			m_oSphere = new Sphere( "myShpere", 30, 10, 10 );
			m_oSphere.y = 50;
			m_oSphere.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );//new Appearance( new WireFrameMaterial( 0xFF ) );
			m_oSphere.z = 70;
			// --
			lG.addChild( m_oPlane );
			lG.addChild( m_oBox );
			lG.addChild( m_oTorus );
			lG.addChild( lTg );
			lTg.addChild( m_oSphere );
			return lG;
		}
		
		private function enterFrameHandler( event : Event ) : void
		{
			m_oBox.rotateX ++;
			m_oTorus.rotateY++ ;
			(m_oSphere.parent as TransformGroup).rotateY ++;
			m_oScene.render();
			// --
		//	stats.text = "Displayed polygons count:"+m_oScene.camera.nbPolygons+" Projected vertices count="+m_oScene.camera.nbVertices;
			fps.nextFrame();
		}
	}
}
