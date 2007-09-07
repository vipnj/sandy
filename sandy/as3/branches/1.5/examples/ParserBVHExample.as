package examples
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import mx.core.BitmapAsset;
	import mx.core.UIComponent;
	
	import sandy.core.*;
	import sandy.core.data.*;
	import sandy.core.data.bvh.*;
	import sandy.core.face.*;
	import sandy.core.group.*;
	import sandy.core.transform.*;
	import sandy.events.*;
	import sandy.math.*;
	import sandy.primitive.*;
	import sandy.skin.*;
	import sandy.util.*;
	import sandy.view.*;
 	
	public class ParserBVHExample extends BasicExample
	{
		private var biped:Biped;
		
		private static var CUBE_DIM:uint 		= 100;
		private static var ANIM_DIM:uint 		= 800;
		private static var CUBE_QUALITY:uint 	= 2;
		private var cube:Box;
		
		public function ParserBVHExample()
		{
			super();
		}
		
		public override function init():void
		{
			super.init();
			
			// we will wait for 1 asset to load or initialize
			assetsLoaded = 1;
			
			biped = new Biped();
			var motion:MotionData = new MotionData("walk");
			biped.addAnimation(motion);
					
			var parser:ParserBVH = new ParserBVH();
			parser.addEventListener( ParserBVH.onInitEVENT, __onObjectInitialized );
			parser.addEventListener( ParserBVH.onFailEVENT, __onObjectFailed );
			parser.parse( biped, motion, "assets/mocaps/037.bvh");
			//parser.parse( biped, motion, "assets/mocaps/AudioMotion Female Walk.bvh");
			
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
			cam.setPosition(0, 100, 600);
			cam.lookAt(0,0,0);

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

			var tgBiped:TransformGroup = new TransformGroup();
			var tgMotion:TransformGroup = new TransformGroup();
			var ls:Skin = new SimpleLineSkin( 1,0xFF8800, 1 );
			
			var ease:Ease = new Ease();
			
			var motion_int:MotionCaptureInterpolator = new MotionCaptureInterpolator(biped, ease.create());
			
			var rot_int:RotationInterpolator = new RotationInterpolator( ease.create(), 100 );
			rot_int.addEventListener( TransformEvent.onEndEVENT, __yoyo );
			rot_int.addEventListener( InterpolationEvent.onProgressEVENT, __playMouse );
					
			tgMotion.setTransform( motion_int );
			//tgBiped.setTransform( rot_int );
			
			biped.generate(tgBiped,ls)
			
			tgMotion.addChild(tgBiped);
			
			bg.addChild(tgMotion);
			
			
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
			//trace(v);
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
