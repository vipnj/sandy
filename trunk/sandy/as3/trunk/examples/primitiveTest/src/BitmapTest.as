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
	import sandy.materials.ZShaderMaterial;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import sandy.core.data.Vector;
	import sandy.materials.ColorMaterial;
	import sandy.materials.attributes.LineAttributes;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.materials.attributes.LightAttributes;
	import sandy.materials.attributes.OutlineAttributes;
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.PreciseBitmapMaterial;
	import sandy.primitive.Line3D;
	import sandy.materials.WireFrameMaterial;
	import sandy.materials.PerspectiveBitmapMaterial;
	import sandy.materials.QuadBitmapMaterial;

	[SWF(width="640", height="500", backgroundColor="#cccccc", frameRate=120)] 
	public class BitmapTest extends Sprite
	{
		[Embed(source="assets/texture.jpg")]
		private var Texture:Class;
		
		[Embed(source="assets/PTest.gif")]
		private var Texture2:Class;
		
		private var fps: CustomFPS;
		private var stats:TextField = new TextField();
		
		private var m_oScene:World3D;
		private var m_oBox:Box;
		private var m_oSphere:Shape3D;
		private var m_oPlane:Plane3D;
		private var m_oTorus:Torus;
		private var keyPressed:Array = new Array();
		
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
			lCamera.y = 90;
			lCamera.lookAt( 0, 0, 0 );
			m_oScene.root = _createScene3D();
			m_oScene.root.addChild( lCamera );
			//m_oScene.useBright = true;
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
			m_oTorus.rotateY++ ;
			//m_oBox.rotateAxisWithReference( new Vector( 0,1,0), new Vector( -150, 0, 0 ), 1);
			if( m_oSphere.parent is TransformGroup ) 
				(m_oSphere.parent as TransformGroup).rotateY ++;
			m_oScene.render();
			fps.nextFrame();
		}
			
		private function _createScene3D():Group
		{
			var lG:Group = new Group("rootGroup");
			var lTg:TransformGroup = new TransformGroup("rotationPivot");
			
			var l_oLine:Line3D = new Line3D( "myLine", new Vector( - 0, +80, -500 ), new Vector( 0, 0, 800 ) );
			l_oLine.appearance = new Appearance( new WireFrameMaterial( 2, 0xFF0000, 1 ) );
			l_oLine.enableClipping = true;
			// --
			m_oPlane = new Plane3D("myPlane", 300, 300, 1, 1, Plane3D.ZX_ALIGNED, PrimitiveMode.TRI );
			var lPic:Bitmap = new Texture2();
			m_oPlane.appearance = new Appearance( new PreciseBitmapMaterial( lPic.bitmapData, new MaterialAttributes( new LineAttributes() ), 5, 10) );
			//m_oPlane.appearance = new Appearance( new QuadBitmapMaterial( lPic.bitmapData, null, 3 ) );
			//m_oPlane.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData, new MaterialAttributes( new LineAttributes() ) ) );
			//m_oPlane.appearance = new Appearance( new PerspectiveBitmapMaterial( lPic.bitmapData, null, 3 ) );
			//m_oPlane.enableNearClipping = true;
			// --
			m_oTorus = new Torus("myTorus", 30, 15, 6, 6 );
			var lPic2:Bitmap = new Texture();
			m_oTorus.appearance = new Appearance( new ZShaderMaterial(1.5)/*new BitmapMaterial( lPic2.bitmapData )*/ );
			m_oTorus.x = -50;
			m_oTorus.y = 30;
			m_oTorus.z = -120;
			// --
			m_oBox = new Box("myBox", 50, 50, 50, PrimitiveMode.QUAD, 1);
			m_oBox.y = 45;
			m_oBox.appearance = /* new Appearance( new BitmapMaterial( lPic2.bitmapData ) );//*/new Appearance( new ColorMaterial( 0xFF0000, 1, new MaterialAttributes( new LineAttributes() )));
			
	
			// --
			m_oSphere = new Sphere( "myShpere", 50, 10, 10 );
			m_oSphere.y = 50;
			
			var l_oMatAttr:MaterialAttributes = new MaterialAttributes( new LightAttributes(true, 0.2)/*, new LineAttributes()*/ );
			var lMat:BitmapMaterial = new BitmapMaterial( lPic2.bitmapData );
			lMat.attributes = l_oMatAttr;
			lMat.lightingEnable = true;
			m_oSphere.appearance = new Appearance( lMat );//new Appearance( new WireFrameMaterial( 0xFF ) );
			m_oSphere.z = 70;
			// --
			lG.addChild( m_oPlane );
			//lG.addChild( m_oBox );
			lG.addChild( m_oTorus );
			//lG.addChild( l_oLine );
			lG.addChild( lTg );
			lTg.addChild( m_oSphere );
			return lG;
		}
	}
}
