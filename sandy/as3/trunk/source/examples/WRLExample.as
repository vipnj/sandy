package examples
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.ui.Keyboard;
	
	import mx.core.BitmapAsset;
	import mx.core.UIComponent;
	
	import sandy.core.*;
	import sandy.core.data.*;
	import sandy.core.face.*;
	import sandy.core.group.*;
	import sandy.core.transform.*;
	import sandy.events.*;
	import sandy.primitive.*;
	import sandy.skin.*;
	import sandy.util.*;
	import sandy.view.*;
 	import sandy.math.*;
 	
 	import examples.BasicExample;
 	
	public class WRLExample extends BasicExample
	{
		private var shuttle:Object3D;
		//private var video:CustomVideo;
		
		private static var CUBE_DIM:uint 		= 100;
		private static var ANIM_DIM:uint 		= 800;
		private static var CUBE_QUALITY:uint 	= 2;
		private var cube:Box;
		
		[Embed(source="../assets/images/textureShuttle.jpg")] public var Texture:Class;
	    
		public function WRLExample()
		{
			super();
		}
		
		public override function init():void
		{
			super.init();
			
			// we will wait for 2 assets to load or initialize
			assetsLoaded = 1;
			
			shuttle = new Object3D();
			
			var parser:WrlParser = new WrlParser();
			parser.addEventListener( WrlParser.onInitEVENT, __onObjectInitialized );
			parser.addEventListener( WrlParser.onFailEVENT, __onObjectFailed );
			//there are files without MESH_TFACELIST, what then
			// e.g tetra.ase
			parser.parse( shuttle, "assets/models/avion2.wrl" );
			
			/*
			video = new CustomVideo();
			video.addEventListener( CustomVideo.onInitEVENT, __onObjectInitialized );
			video.source = "../assets/videos/carCrash.flv";
			video.init();
			video.play();
			*/
			
			
			
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
			var cam:Camera3D = new Camera3D( 700, screen);
			// we move the camera backward to be able to see the object placed at 0,0,0
			cam.setPosition(0, 0, -500);

			// we add the camera to the world
			World3D.addCamera( cam );
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
			var tg1:TransformGroup = new TransformGroup();
			var tg2:TransformGroup = new TransformGroup();
			var ease:Ease = new Ease();
			var rot_int:RotationInterpolator = new RotationInterpolator( ease.create(), 100 );
			rot_int.addEventListener( TransformEvent.onEndEVENT, __yoyo );
			rot_int.addEventListener( InterpolationEvent.onProgressEVENT, __playMouse );
			
			tg1.setTransform( rot_int );
			
		
			var mixedSkin:MixedSkin = new MixedSkin( 0x996633, 1, 0x332211, 1, 1 );
			var img:BitmapAsset  = new Texture() as BitmapAsset;
//			var s:Skin = new MovieSkin( null,  false );
			var colorSkin:Skin = new SimpleColorSkin( 0xFF0000, 0.4 );
			var lineSkin1:Skin = new SimpleLineSkin( 0.1,0xFF8800, 0.5 );
			var lineSkin2:Skin = new SimpleLineSkin( 0.1,0x008800, 0.05 );
			var ts:TextureSkin = new TextureSkin( img.bitmapData );
			//var videoSkin:VideoSkin = new VideoSkin( video.video );
			var lightSkin:ZLightenSkin = new ZLightenSkin( 0xFF0000 );
			//lightSkin.enableBlendMode(false);
			
			//o.aFaces[0].setSkin(ts);
			shuttle.setSkin( mixedSkin );
			//o1.setSkin( ts );
			//o2.setSkin( ts );
			// Now we simply link the Object leaf to the root node, and finish the tree creation
			//tg1.addChild( box );
			tg1.addChild( shuttle );
			//tg1.addChild( shuttle );
			//tg2.addChild( shuttle );
			//tg.addChild( o1 );
			//tg.addChild( o2 );
			bg.addChild( tg1 );
			//bg.addChild( tg2 );
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
			var difX:Number = (300 - mouseX)/100;
			var difY:Number = (300 - mouseY)/100;
			var dist:Number = Math.sqrt( difX*difX  + difY*difY );
			
			var int:RotationInterpolator = (e.target as RotationInterpolator);
			var v:Vector = int.getAxisOfRotation();
			trace(v);
			var newRotVector:Vector = new Vector( -difY, difX, 0 );
			
			var diff:Vector = VectorMath.sub(newRotVector, v);
			var res:Vector = VectorMath.scale( diff, 0.1);
			
//			k = k + n * (k-v)
			int.setAxisOfRotation(  VectorMath.addVector(v, res) );
			int.setDuration( 200 / dist );
		}	
		
		/*
		private function keyDownHandler(e:KeyboardEvent):void
		{
			var newMS:Number = getTimer();
			if (newMS - 1000 > _ms)
			{
				_ms = newMS;
				_tf.text = _fps + " fps";
				_fps = 0;
			}
			else
			{
				_fps++;
			}
	
			
			var cam:Camera3D = World3D.getCamera(0);
			trace("keyDownHandler + " + cam + " e: " + e.keyCode)
			switch(e.keyCode)
			{
				case Keyboard.RIGHT:
					cam.rotateY(5);		// yaw
					_yaw += 5;
					break;
				
				case Keyboard.LEFT:
					cam.rotateY(-5);	// yaw
					_yaw -= 5;
					break;
			
				case Keyboard.UP:
					cam.tilt(5);		// pitch (not really but OK since we don't roll)
					_pitch += 5;
					break;
			
				case Keyboard.DOWN:
					cam.tilt(-5);		// pitch (not really but OK since we don't roll)
					_pitch -= 5;
					break;
			
				case Keyboard.SHIFT:
					_fov -= 10;
					cam.setFocal(foc(_fov));	// zoom
					trace(_fov);
					break;
			
				case Keyboard.CONTROL:
					_fov += 10;
					cam.setFocal(foc(_fov));	// zoom
					trace(_fov);
					break;
			}
	
			if (_yaw > 180) _yaw -= 360;
			else if (_yaw < -180) _yaw += 360;
			
			
		}*/
	}
}
