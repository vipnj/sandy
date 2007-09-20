package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.*;
	
	import sandy.core.World3D;
	import sandy.core.data.*;
	import sandy.core.scenegraph.*;
	import sandy.events.BubbleEvent;
	import sandy.materials.*;
	import sandy.materials.attributes.LineAttributes;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.math.*;
	import sandy.primitive.*;
	
	[SWF(width="500", height="500", backgroundColor="#FFFFFF", frameRate=120)] 
	/**
	 * @author thomaspfeiffer
	 */
	public class PrimitiveTest extends Sprite
	{
		internal static const SCREEN_WIDTH:int = 500;
		internal static const SCREEN_HEIGHT:int = 500;
		
		[Embed(source="../assets/texture.jpg")]
		private var Texture:Class;

		private var _mc:Sprite;
		private var _world:World3D;
		private var box:Box;
		private var hedra:Hedra;
		private var tgRotation:TransformGroup;
		
		public function PrimitiveTest()
		{
			Matrix4Math.USE_FAST_MATH = true;
			_mc = this;
			// --
			stage.scaleMode = StageScaleMode.NO_SCALE ;
			// --
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
			//
			_world = World3D.getInstance();
			// FIRST THING TO INITIALIZE
			_world.container = this;
			_init();
		}
		
		private function _init():void
		{
			_world.camera = new Camera3D( SCREEN_WIDTH, SCREEN_HEIGHT );
			_world.camera.z = 1500;
			_world.root = _createScene();
			_world.camera.lookAt( 0, 0, 0 );
			//_world.root.addChild( _world.camera );
		}
		
		private function _createScene():Group
		{
			// -- variables declaration
			var g:Group = new Group();
			var tgTranslation:TransformGroup = new TransformGroup("translation");
			tgRotation = new TransformGroup("rotation");
			// -- transformations
			tgTranslation.z = 500;
			// -- creation of the materials and apperance
			var pic:Bitmap = new Texture();
			var l_oTextureAppearance:Appearance = new Appearance( new BitmapMaterial( pic.bitmapData ) ); 
			// -- creation of objects
			box = new Box( "myBox", 50, 50, 50, "quad", 3 );
			box.appearance = l_oTextureAppearance;
			box.rotateZ = 45;
			box.useSingleContainer = true;
			box.enableEvents = true;
			
			// MODIFICATION, we directly access the node instead of the broadcaster
			g.addEventListener( MouseEvent.ROLL_OVER, _onBoxRollOver );
			
			hedra = new Hedra( "myHedra", 50, 50, 100 );
			hedra.appearance = l_oTextureAppearance;
			hedra.y = 50;
			hedra.x = 20;
			
			var l_oCylinder:Cylinder = new Cylinder("myCylinder", 50, 50, 6, 1, 50 );
			//l_oCylinder.enableBackFaceCulling = false;
			l_oCylinder.rotateX = 45;
			l_oCylinder.z = -150;
			l_oCylinder.appearance = l_oTextureAppearance;
			
			var l_oTorus:Torus = new Torus("myTorus", 70, 40, 6, 6 );
			//l_oCylinder.enableBackFaceCulling = false;
			l_oTorus.x = -150;
			l_oTorus.rotateX = 90;
			l_oTorus.appearance = l_oTextureAppearance;	
	
			var l_oSphere:Sphere = new Sphere("mySphere", 60, 6, 4 );
			l_oCylinder.enableBackFaceCulling = false;
			l_oSphere.z = 150;
			l_oSphere.appearance = l_oTextureAppearance;	
			
			var l_oCone:Cone = new Cone("myCone", 60, 40, 8, 1 );
			//l_oCylinder.enableBackFaceCulling = false;
			l_oCone.y = -50;
			l_oCone.x = -30;
			l_oCone.appearance = l_oTextureAppearance;	
				
			// --
			var line:Line3D = new Line3D( "myLine", new Vector( 50, 50), new Vector( 100, 50 ), new Vector( 100, 100 ), new Vector( 75, 50 ), new Vector( 50, 100 ), new Vector( 50, 50 ) );
			line.appearance = new Appearance( new ColorMaterial( 0, 0, new MaterialAttributes( new LineAttributes( 1, 0xFF ) ) ) );
			// -- Tree creation

			tgTranslation.addChild( box );
			tgTranslation.addChild( hedra );
			tgTranslation.addChild( line );
			tgTranslation.addChild( l_oCylinder );
			tgTranslation.addChild( l_oTorus );
			tgTranslation.addChild( l_oSphere );
			tgTranslation.addChild( l_oCone );
			tgTranslation.addChild( tgRotation );
			tgRotation.addChild( _world.camera );
			g.addChild( tgTranslation );
			// --
			return g;
		}
	
		private function _onBoxRollOver( pEvent:BubbleEvent ):void
		{
			trace( pEvent );
		}
		
		private function enterFrameHandler( event : Event ) : void
		{
			tgRotation.rotateX ++;
			box.rotateX += 0.5;
			_world.render();
		}
	}
}