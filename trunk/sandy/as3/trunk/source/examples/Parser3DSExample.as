package examples
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	import mx.core.BitmapAsset;
	import mx.core.UIComponent;
	
	import sandy.core.*;
	import sandy.core.data.*;
	import sandy.core.face.*;
	import sandy.core.group.*;
	import sandy.core.transform.*;
	import sandy.events.*;
	import sandy.math.*;
	import sandy.primitive.*;
	import sandy.skin.*;
	import sandy.util.*;
	import sandy.util._3ds.*;
	import sandy.view.*;
 	
	public class Parser3DSExample extends BasicExample
	{
		private var scene:Array;
		private var keyframer:Array;
		//private var video:CustomVideo;
		
		private static var CUBE_DIM:uint 		= 100;
		private static var ANIM_DIM:uint 		= 800;
		private static var CUBE_QUALITY:uint 	= 2;
		private var cube:Box;
		
		[Embed(source="../assets/images/car07.jpg")] public var Texture:Class;
	    
		public function Parser3DSExample()
		{
			super();
		}
		
		public override function init():void
		{
			super.init();
			
			// we will wait for 2 assets to load or initialize
			assetsLoaded = 1;
			
			scene = new Array();
			keyframer = new Array();
						
			var parser:Parser3DS = new Parser3DS();
			parser.addEventListener( Parser3DS.onInitEVENT, __onObjectInitialized );
			parser.addEventListener( Parser3DS.onFailEVENT, __onObjectFailed );
			//there are files without MESH_TFACELIST, what then
			// e.g tetra.ase
			parser.parse( scene, "assets/models/kd2.3ds", keyframer);
			
		}
		
		private function start():void
		{	
			World3D.init( );
			var screen_container:Sprite = new Sprite();
			
			addChild( screen_container );
			// screen creation, the object where objects will be displayed.
			//var screen:ClipScreen = new ClipScreen( screen_container, 600, 600 );
			var screen:BitmapScreen = new BitmapScreen( screen_container, 600, 600 );
			// we create our camera
			//var cam:Camera3D = new Camera3D( 700, screen, "left or right :)");
			var cam1:Camera3D = new Camera3D( 700, screen, "top");
			//var cam2:Camera3D = new Camera3D( 700, screen, "front");
			// we move the camera backward to be able to see the object placed at 0,0,0
			//cam.setPosition(0, 0, 700);
			//cam.lookAt(0,0,0);
			
			cam1.setPosition(0, 700, 0);
			cam1.lookAt(0,0,100);
			
			//cam2.setPosition(700, 0, 0);
			//cam2.lookAt(0,0,0);

			// we add the camera to the world
			//World3D.addCamera( cam2 );
			//World3D.addCamera( cam1 );
			World3D.addCamera( cam1 );
			// we create the root node.
			var bg:Group = new Group();
			// and set it as the root node of the world.
			World3D.setRootGroup( bg );
			// and we lauch the scene creation
			createScene ( bg );
			// and now that everything is created, we can launch the world rendering.
			World3D.render( this );
		}
		 
		private function createScene( bg:Group ):void
		{

			var tgLines:TransformGroup = new TransformGroup();
			//var tg2:TransformGroup = new TransformGroup();
			var ease:Ease = new Ease();
			
			var ls1:Skin = new SimpleLineSkin( 1,0xFF8800, 1 );
			var ls2:Skin = new SimpleLineSkin( 1,0x88ff00, 1 );
			var ls3:Skin = new SimpleLineSkin( 1,0x0088ff, 1);
			var ls4:Skin = new SimpleLineSkin( 1,0x000000, 1);
			
			var len:int = 100;
			
			
			var grid:Grid3D = new Grid3D(tgLines, new Vector(0,0,0), new Vector(500,100,500), new Vector(20,50,20) );

			
			var rot_int:RotationInterpolator = new RotationInterpolator( ease.create(), 100 );
			rot_int.addEventListener( TransformEvent.onEndEVENT, __yoyo );
			rot_int.addEventListener( InterpolationEvent.onProgressEVENT, __playMouse );
								
			for (var i:String in scene)
			{
				var tg:TransformGroup = new TransformGroup();
				var tg2:TransformGroup = new TransformGroup();
			
				var o:Object3D = scene[i];
				var anim:Keyframer = keyframer[i];
				
				if (anim != null)
				{
					/*if (i == "Box03")
					{
						anim.tracePositionFrames();
						anim.traceRotationFrames();
						anim.traceScaleFrames();
					}*/
					var key_int:KeyframeInterpolator = new KeyframeInterpolator( o, ease.create(), anim );
	
					var rot_int2:RotationInterpolator = new RotationInterpolator( ease.create(), 100 );
					rot_int2.addEventListener( TransformEvent.onEndEVENT, __yoyo );
					rot_int2.addEventListener( InterpolationEvent.onProgressEVENT, __playMouse );
					
					tg.setTransform( key_int );
					tg2.setTransform( rot_int2 );
					
					var mixedSkin:MixedSkin = new MixedSkin( 0x996633, 1, 0x332211, 1, 1 );
					o.setSkin( mixedSkin );
					tg.addChild( o );
					tg2.addChild( tg )
					
					bg.addChild( tg2 );
				}
				
				
//				bg.addChild( tg2 );
			}
			
			var tgRot:TransformGroup = new TransformGroup();
			tgRot.setTransform( rot_int );
			
			tgRot.addChild(tgLines);
			
			bg.addChild(tgRot);
			
		}
		
		private function __onObjectInitialized( e:Event ):void
		{
			assetsLoaded--;
			trace('Object initialized ' + assetsLoaded);
			
			if (assetsLoaded < 1)
			{
				start();
			}
		}
		
		private function __onObjectFailed( e:Event ):void
		{
			trace('Loading problem');
		}
		
	
	
		private function __yoyo( e:Event ):void
		{
			(e.target as RotationInterpolator).redo();
		}
		
		private function __playMouse( e:Event ):void
		{
			var difX:Number = (300 - mouseX)/1000;
			var difY:Number = (300 - mouseY)/1000;
			var dist:Number = Math.sqrt( difX*difX  + difY*difY );
			
			var int:RotationInterpolator = (e.target as RotationInterpolator);
			var v:Vector = int.getAxisOfRotation();
			//trace(v);
			var newRotVector:Vector = new Vector( -difY, difX, 0 );
			
			var diff:Vector = VectorMath.sub(newRotVector, v);
			var res:Vector = VectorMath.scale( diff, 0.1);
			
//			k = k + n * (k-v)
			int.setAxisOfRotation(  VectorMath.addVector(v, res) );
			int.setDuration( 200 / dist );
		}	
		
		
		
	}
}
