package examples
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.ui.Keyboard;
	
	import mx.core.BitmapAsset;
	
	
	import sandy.core.*;
	import sandy.core.light.*;
	import sandy.core.data.*;
	import sandy.core.face.*;
	import sandy.core.group.*;
	import sandy.core.transform.*;
	import sandy.events.*;
	import sandy.primitive.*;
	import sandy.skin.*;
	import sandy.util.*;
	import sandy.view.*;

 	import examples.BasicExample;
 	
	public class AnimationExample extends BasicExample
	{
		private var kitty:Object3D;
		private var video:CustomVideo;
		
			
		//STUFF for kitty
		private var _ad:AnimationData;
		private var _move:Boolean;
		private var distance:Number;
		//private var _t:TextField;
		private var circlePlace1:Number=220;
	
		//STUFF for CubicPanorama
		// the six bitmaps that will constitute the cubic view
		private static var CUBE_DIM:uint 		= 900;
		private static var ANIM_DIM:uint 		= 800;
		private static var CUBE_QUALITY:uint 	= 3;
		private var cube:Box;
		private var _planes:Array;

		
		[Embed(source="../assets/images/textureKitty.jpg")] public var TextureKitty:Class;
		[Embed(source="../assets/images/grass.jpg")] public var TextureGrass:Class;

		public function AnimationExample()
		{
			super();
		}
		
		public override function init():void
		{
			super.init();
			
			// we will wait for 2 assets to load or initialize
			assetsLoaded = 1;
			
			_ad = new AnimationData();
			
			kitty = new Object3D();
			
			var parser:AseParser = new AseParser();
			parser.addEventListener( AseParser.onInitEVENT, __onObjectInitialized );
			//parser.addEventListener( AseParser.onFailEVENT, __onObjectFailed );
			//there are files without MESH_TFACELIST, what then
			// e.g tetra.ase
			parser.parse( kitty, "assets/models/kitty.ase" );
		
			
		}
		private function __onObjectInitialized( e:Event ):void
		{
			assetsLoaded--;
			trace('Object initialized ' + assetsLoaded);
			
			if (assetsLoaded < 1)
			{
				loadAnimation();
				//start();
			}
		}
		
		private function loadAnimation( ):void
		{
			var saParser:SaParser = new SaParser();
			saParser.addEventListener( SaParser.onInitEVENT, __animationInitialized );
			//SaParser.addEventListener( SaParser.onLoadEVENT, this, __onLoad );
			//SaParser.addEventListener( SaParser.onProgressEVENT, this, __onSaProgress );
			saParser.parse( _ad, 'assets/animation/animationKitty.sa' );
		}
		private function __animationInitialized( e:Event ):void
		{
			start()
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

			cam.setFocal(this.mouseControl.foc(this.mouseControl._fov));
			distance = 1800;
			cam.setPosition(Math.cos(circlePlace1*Math.PI/360)*distance, distance-1000, Math.sin(circlePlace1*Math.PI/360)*distance);
			cam.lookAt(1, 200, 1);
		
			// we add the camera to the world
			World3D.addCamera( cam );
			
			//var l:Lighmaybe bt3D = new Light3D( new Vector(1,0,0), 20 );
			//World3D.setLight( l );
			
			
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
			var myEase:Ease = new Ease();
			//myEase.linear();
			
			//
			//
			var tgAnimationKitty:TransformGroup = new TransformGroup();
			var tgLandscape:TransformGroup = new TransformGroup();
			
			var int:VertexInterpolator = new VertexInterpolator( kitty, myEase.create(), [_ad] );
			int.addEventListener( TransformEvent.onEndEVENT, __yoyo );
			//
	
			var grass:Plane3D = new Plane3D(3000,3000,8,'tri');
			
			var img1:BitmapAsset  = new TextureKitty() as BitmapAsset;
			var img2:BitmapAsset  = new TextureGrass() as BitmapAsset;
			//var img2:BitmapAsset  = new TextureMoon() as BitmapAsset;
//			var s:Skin = new MovieSkin( null,  false );
			//var colorSkin:Skin = new SimpleColorSkin( 0x880000, 1 );
			//var lineSkin1:Skin = new SimpleLineSkin( 0.1,0xFF8800, 0.5 );
			//var lineSkin2:Skin = new SimpleLineSkin( 0.1,0x008800, 0.05 );
			var ts1:TextureSkin = new TextureSkin( img1.bitmapData );
			var tsGrass:TextureSkin = new TextureSkin( img2.bitmapData );
			//var ts2:TextureSkin = new TextureSkin( img2.bitmapData );
			
			//var videoSkin:VideoSkin = new VideoSkin( video.video );
			var lightSkin:ZLightenSkin = new ZLightenSkin( 0xffffff );
			//lightSkin.enableBlendMode(false);
			
			
			kitty.setSkin( ts1 );
			grass.setSkin( tsGrass );

			//translationEarth
			// -- creation of the tree		
			tgAnimationKitty.setTransform( int );
			tgAnimationKitty.addChild( kitty );
			
			var grassTranslation:Transform3D = new Transform3D();
			grassTranslation.translate( 0,-90,0 );
			
			tgLandscape.setTransform( grassTranslation );
			tgLandscape.addChild( grass );
			//
			bg.addChild( tgAnimationKitty );
			bg.addChild( tgLandscape );

		}
		
		
	
	
		
		private function __yoyo( e:Event ):void
		{
			(e.target as VertexInterpolator).redo();
		}
		
		private function __playMouse( e:Event ):void
		{
			var difX:Number = 300 - mouseX;
			var difY:Number = 300 - mouseY;
			var dist:Number = Math.sqrt( difX*difX  + difY*difY );
			(e.target as RotationInterpolator).setAxisOfRotation( new Vector( -difY, difX, 0 ) );
			(e.target as RotationInterpolator).setDuration( 10000 / dist );
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
