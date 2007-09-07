package examples
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import flash.ui.Keyboard;
	
	import mx.core.BitmapAsset;
	import mx.core.UIComponent;
	
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
 	
	public class SphereExample extends BasicExample
	{
		private var shuttle:Object3D;
		private var video:CustomVideo;
		
		private var _earthRadius:Vector;
		private var _sunPosition:Vector;
	
		[Embed(source="../assets/images/earthTexture.jpg")] public var TextureEarth:Class;
		[Embed(source="../assets/images/moonTexture.jpg")] public var TextureMoon:Class;
		[Embed(source="../assets/images/space.jpg")] public var TextureSpace:Class;
		
    
		public function SphereExample()
		{
			super()
			
			var img1:BitmapAsset  = new TextureSpace() as BitmapAsset;
			addChild(img1);
			img1.y = 0;
			fps.color = 0xFFFFFF;
			
		}
		
		public override function init():void
		{
			super.init();
			
			// we will wait for 2 assets to load or initialize
			assetsLoaded = 0;
			
			_earthRadius = new Vector( 200, 0, 0 );
			_sunPosition = new Vector( 0, 0, 500 );
			
			start();
			
			
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
			
			//var l:Light3D = new Light3D( new Vector(1,0,0), 20 );
			//World3D.setLight( l );
			
			
			// we create the root node.
			var bg:Group = new Group();
			// and set it as the root node of the world.
			World3D.setRootGroup( bg );
			// and we lauch the scene creation
			createScene ( bg );
			// and now that everything is created, we can launch the world rendering.
			World3D.render( this );
			
			setChildIndex(fps, numChildren-1);
		}
		 
		private function createScene( bg:Group ):void
		{
			var myEase:Ease = new Ease();
			
			var translationEarth:Transform3D = new Transform3D();
			var translationSun:Transform3D = new Transform3D();
			translationSun.translate( _sunPosition.x, _sunPosition.y, _sunPosition.z );
			translationEarth.translate( _sunPosition.x - _earthRadius.x, _sunPosition.y - _earthRadius.y/2, _sunPosition.z - _earthRadius.z/2 );
			//
			var tgRotationEarth:TransformGroup, tgRotationSun:TransformGroup;
			var tgTranslationEarth:TransformGroup, tgTranslationSun:TransformGroup;
			tgRotationEarth = new TransformGroup();
			tgRotationSun 	= new TransformGroup();
			tgTranslationEarth 	= new TransformGroup();
			tgTranslationSun 	= new TransformGroup();
			//
			var rotintEarth:RotationInterpolator 	= new RotationInterpolator( myEase.create(), 300 );
			rotintEarth.setPointOfReference( _earthRadius );
			var rotintSun:RotationInterpolator 		= new RotationInterpolator( myEase.create(), 1000 );
			// -- listener
			rotintEarth.addEventListener( TransformEvent.onEndEVENT, __yoyo );
			rotintSun.addEventListener( TransformEvent.onEndEVENT, __yoyo );
	
			// We create our object. It is a cube of 50 pixels
			//var o:Sprite2D = new Sprite2D();
			var moon:Object3D = new Sphere ( 100, 5 );
			var earth:Object3D = new Sphere ( 35, 6 );
			
			
			
			//var mixedSkin:MixedSkin = new MixedSkin( 0x996633, 0.3, 0x332211, 0.13, 1 );
			var img1:BitmapAsset  = new TextureEarth() as BitmapAsset;
			var img2:BitmapAsset  = new TextureMoon() as BitmapAsset;
//			var s:Skin = new MovieSkin( null,  false );
			var colorSkin:Skin = new SimpleColorSkin( 0x880000, 1 );
			var lineSkin1:Skin = new SimpleLineSkin( 0.1,0xFF8800, 0.5 );
			//var lineSkin2:Skin = new SimpleLineSkin( 0.1,0x008800, 0.05 );
			var ts1:TextureSkin = new TextureSkin( img1.bitmapData );
			var ts2:TextureSkin = new TextureSkin( img2.bitmapData );
			
			//var videoSkin:VideoSkin = new VideoSkin( video.video );
			//var lightSkin:ZLightenSkin = new ZLightenSkin( 0xFF0000 );
			//lightSkin.enableBlendMode(false);
			
			//o.aFaces[0].setSkin(ts);
			//o.setSkin( lightSkin );
			
			// TODO: there is some strange bug
			// if both sides are picture, or video all are ok
			// but if 1 side is video, and 2nd picture.... picture is screwed
			
			earth.setSkin( ts2 );
			moon.setSkin( ts1 );

			// -- creation of the tree		
			tgRotationEarth.setTransform( rotintEarth );
			tgRotationEarth.addChild( earth );
			//
			tgRotationSun.setTransform( rotintSun );
			tgRotationSun.addChild( moon );
			//
			tgTranslationSun.setTransform( translationSun );
			tgTranslationEarth.setTransform( translationEarth );
			//
			tgTranslationSun.addChild( tgRotationSun );
			tgTranslationEarth.addChild( tgRotationEarth );
			//
			bg.addChild( tgTranslationEarth );
			bg.addChild( tgTranslationSun );

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
		
	
		private function __enterFrame( e:Event ):void
		{
			tf.text = (getTimer() - t)+' ms';
			t = getTimer();
		}
		
		private function __yoyo( e:Event ):void
		{
			(e.target as RotationInterpolator).redo();
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
