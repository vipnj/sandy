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
 	
 	import examples.BasicExample;
 	
	public class CubicPanorama extends BasicExample
	{
				
		//STUFF for CubicPanorama
		// the six bitmaps that will constitute the cubic view
		private static var CUBE_DIM:uint 		= 900;
		private static var ANIM_DIM:uint 		= 800;
		private static var CUBE_QUALITY:uint 	= 4;
		private var cube:Box;
		private var _planes:Array;
		
		
		[Embed(source="../assets/images/textureShuttle.jpg")] public var Texture:Class;
		
		[Embed(source="../assets/images/straight_ahead.jpg")] public var TextureFront:Class;
	    [Embed(source="../assets/images/down.jpg")] public var TextureDown:Class;
	    [Embed(source="../assets/images/behind.jpg")] public var TextureBehind:Class;
	    [Embed(source="../assets/images/up.jpg")] public var TextureUp:Class;
	    [Embed(source="../assets/images/left.jpg")] public var TextureLeft:Class;
	    [Embed(source="../assets/images/right.jpg")] public var TextureRight:Class;
	    
		public function CubicPanorama()
		{
			super();
			fps.color = 0xFFFFFF;

			
			_planes = [TextureFront, TextureBehind, TextureDown, TextureUp, TextureLeft, TextureRight];
		}
		
		public override function init():void
		{
			super.init();
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
			var cam:Camera3D = new Camera3D( 300, screen);
			// we move the camera backward to be able to see the object placed at 0,0,0
			cam.setPosition(0, 0, 0);

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
			
			setChildIndex(fps, numChildren-1);
		}
		
		private function createScene ( bg:Group ):void
		{
			var g:Group = new Group();	
			cube = new Box( CUBE_DIM, CUBE_DIM, CUBE_DIM, 'tri', CUBE_QUALITY );
			
			var a:Array = cube.aFaces;
			//for( var i:Number = 0,j:Number = 1; i < a.length; i+=(2*CUBE_QUALITY*CUBE_QUALITY-2), j++ )
			var pow:Number = Math.pow(2,(CUBE_QUALITY-1));
			var step:Number = pow*pow;
			for( var i:Number = 0,j:Number = 1; i < a.length; i+=step, j++ )
			{
				var f:Face;
				var skin:Skin;
				var  pl:Number = int((j+1)/2) -1;
				trace("\ta ["+a.length+"] i: ["+i+"]["+step+"] j: [" + j + "] pl: ["+pl+"]");
				var img:BitmapAsset  = new _planes[pl]() as BitmapAsset;
				
				skin = new TextureSkin( img.bitmapData ); 
				// --
				//for(var k:Number = 0; k < 2*CUBE_QUALITY*CUBE_QUALITY; k++ )
				for(var k:Number = 0; k < step; k++ )
				{
					if (a[i+k] != null)
					{
						f = a[i+k];
						f.setSkin( skin );
					} else {
						trace((i+k) + " not found");
					}
				}
			}
			
			cube.swapCulling();

			bg.addChild( cube );
		}
		
		
	

		/*
		public override function keyDownHandler(event:KeyboardEvent):void
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
	
		private function fov(foc:Number):Number	// fov in degrees
		{
			return 360 * Math.atan(ANIM_DIM/(2 * foc)) / Math.PI;
		}
	
		private function foc(fov:Number):Number	// fov in degrees
		{
			return ANIM_DIM / (2 * Math.tan(Math.PI * fov/360));
		}
		
	
	}
}
