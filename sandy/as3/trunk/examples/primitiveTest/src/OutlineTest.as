package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import sandy.core.World3D;
	import sandy.core.data.*;
	import sandy.core.scenegraph.*;
	import sandy.materials.*;
	import sandy.materials.attributes.LineAttributes;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.materials.attributes.OutlineAttributes;
	import sandy.parser.*;
	import sandy.primitive.Cylinder;
	import sandy.primitive.Plane3D;
	import sandy.primitive.Sphere;

	[SWF(width="400", height="400", backgroundColor='#FFFFFF', frameRate='30')]
	
	public class OutlineTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 400;
		internal static const SCREEN_HEIGHT:int = 400;    
		
		internal static const SCREEN_WIDTH2:int = 200;
		internal static const SCREEN_HEIGHT2:int = 200;
		
		private var world:World3D;
		private var capsule:Shape3D;
		private var camera : Camera3D;
		private var m_nAngle:Number = 0;
		
		[Embed(source="assets/may.jpg")]
		private var Texture:Class;
		
		public function OutlineTest()
		{
			init();
		}
		
		private function init():void
		{
			// -- set up the 3d world
			world = World3D.getInstance();
			world.container = this;
			world.root = new Group( "rootGroup" );
			camera = world.camera = new Camera3D( 400, 400 );
			world.camera.y = 50;
			world.camera.z = -600;
			world.root.addChild( world.camera );
			initScene();
		}

		
		private function initScene( ):void
		{
		
			var lSphere2:Sphere = new Sphere("mySphere2", 100, 10, 10 );
			lSphere2.x = 100;
			lSphere2.z = -300;
			lSphere2.y = 100;
			lSphere2.appearance = new Appearance(
				new ColorMaterial( 0xff, 100, new MaterialAttributes( new LineAttributes(), new OutlineAttributes(8, 0xFFFF) ) )
			);
			world.root.addChild( lSphere2 );
			
			
			capsule = new Sphere("mySphere", 100, 10, 10 );
			capsule.y = 100;
			capsule.x = -200;
			capsule.z = -200;
			capsule.appearance = new Appearance(
				new OutlineMaterial( 8, 0xffff00, 100 )
			);
			// -- add the collada object to the world
			world.root.addChild( capsule );
		
			var lPic:Bitmap = new Texture();
			var lSphere3:Sphere = new Sphere("mySphere3", 100, 10, 10 );
			lSphere3.x = -200;
			lSphere3.z = 100;
			lSphere3.y = 100;
			lSphere3.appearance = new Appearance(
				new BitmapMaterial( lPic.bitmapData, new MaterialAttributes( new OutlineAttributes(5, 0xFF) ) )
			);
			world.root.addChild( lSphere3 );
			
			var l_oCylinder:Cylinder = new Cylinder("myCylinder", 100, 200, 6, 6, 100 );
			l_oCylinder.appearance = new Appearance(
				new OutlineMaterial( 15, 0x00FF, 100 )
			);
			l_oCylinder.z = 200;
			l_oCylinder.x = 200;
			l_oCylinder.y = 150;
			world.root.addChild( l_oCylinder );
			/*
			var l_oTorus:Torus = new Torus("myTorus", 70, 20, 16, 6 );
			l_oTorus.appearance = new Appearance(
				new OutlineMaterial( 10, 0xFF00, 100 )
			);
			l_oTorus.z = -300;
			l_oTorus.x = -300;
			l_oTorus.y = 100;
			world.root.addChild( l_oTorus );
			*/
			var l_oPlane:Plane3D = new Plane3D( "myPlane", 800, 800, 6, 6, Plane3D.ZX_ALIGNED );
			l_oPlane.appearance = new Appearance(
				new OutlineMaterial( 5, 0xff0000, 100, new MaterialAttributes(  new LineAttributes() ) )
			);
			world.root.addChild( l_oPlane );
			// -- start animating
			//world.render();
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function enterFrameHandler( event:Event ):void
		{			
			//capsule.rotateY++;
			// -- render the world
			m_nAngle += ((this.mouseX - SCREEN_WIDTH2)* 4 - camera.x) / 3000;
			camera.x = 800 * Math.cos( m_nAngle );
			camera.z = 800 * Math.sin( m_nAngle );
			camera.y += (( SCREEN_HEIGHT2 - this.mouseY )* 4 - camera.y) / 30;
			camera.y = Math.max( 0, camera.y );
			// --
			camera.lookAt( 0, 0, 0 );
			world.render();
		}
	
	}
}