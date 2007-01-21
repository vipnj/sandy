
import flash.display.BitmapData;

import sandy.core.group.Group;
import sandy.core.group.TransformGroup;
import sandy.core.Sprite2D;
import sandy.core.transform.Transform3D;
import sandy.core.World3D;
import sandy.skin.MovieSkin;
import sandy.view.Camera3D;
import sandy.view.ClipScreen;

class Sprite2DTest 
{
	private var _mc : MovieClip;
	private var _mcLoader:MovieClipLoader;
	private var _bmp:BitmapData;
	private var _fps:Number;
	private var _t:Number;

	private static var NUM_ELEMENTS:Number = 60;

	public function Sprite2DTest( mc:MovieClip ) 
	{
		_mc = mc;
		_mcLoader = new MovieClipLoader();
		_mcLoader.addListener(this);
		_mc.createTextField( 'fps', 10000, 0, 20, 50, 20 );
		_t  = getTimer();
		_fps = 0;
		//loadClip('arbre2.gif');
		//if( mc.texture instanceof MovieClip )	__start( _mc );
		//else									loadClip('arbre2.gif');
		__start();
	}
	
	private function __refreshFps():Void
	{
		if( getTimer() > _t + 1000 )
		{
			_mc.fps.text = _fps+' ips';
			_fps = 0;
			_t = getTimer();
		}
		else _fps++;
		__onRender();
	}
	
	public static function main( mc:MovieClip ) : Void 
	{
		if( !mc ) mc = _root;
		var c:Sprite2DTest = new Sprite2DTest( mc );
	}
	
 	
	private function __start ():Void
	{
		__createCams();
		var g:Group = __createScene( _mc );
		
		var w:World3D = World3D.getInstance();
		w.setRootGroup( g );
		w.addEventListener( World3D.onRenderEVENT, this, __refreshFps );
		w.render();
	}
	
	private function __createCams ( Void ):Void
	{
		var mc:MovieClip = _mc.createEmptyMovieClip( 'screen', 2 );
		World3D.getInstance().setContainer( mc );
		var screen:ClipScreen = new ClipScreen( 300, 300 );
		var cam:Camera3D = new Camera3D( screen );
		cam.setPosition( 0, 0, 0 );
		World3D.getInstance().setCamera( cam );
/*		
		var mc2:MovieClip = _mc.createEmptyMovieClip( 'screen2', 3 );
		mc2._x = 300;
		var screen2:ClipScreen = new ClipScreen( mc2, 300, 300 );
		var cam2:Camera3D = new Camera3D( screen2 );
		//cam2.setPerspectiveProjection(90, 1, 10, 1000 );
		cam2.setPosition( 0, 200, 200 );
		cam2.lookAt( 0, 30, -100 );
		World3D.getInstance().addCamera( cam2 );
*/
		
	}

	private function __onRender ( e ):Void
	{
		var cam:Camera3D = World3D.getInstance().getCamera();
		// rotation around the global vertical axis
		switch( true )
		{
			case Key.isDown (Key.RIGHT)	: cam.rotateY ( 3 ); 		break;
			case Key.isDown (Key.LEFT)	: cam.rotateY ( -3 ); 		break;
			case Key.isDown (Key.UP)	: cam.moveForward ( 2 ); 	break;
			case Key.isDown (Key.DOWN)	: cam.moveForward ( -2 ); 	break;
			//case Key.isDown (Key.SHIFT)	: cam.tilt ( 1 ); 		break;
			//case Key.isDown (Key.CONTROL) : cam.tilt ( -1 ); 		break;
		}
	}

	private function __createScene ( mc:MovieClip ):Group
	{
		var skin:MovieSkin = new MovieSkin( 'arbre2.gif' );
		//var skin:SimpleLineSkin = new SimpleLineSkin(2, 0, 80);
		//skin.setLightingEnable(true);

		var bg:Group 		 = new Group();
		var tgL:TransformGroup = new TransformGroup();		
        var i: Number;
		
		for( i = 0; i < Sprite2DTest.NUM_ELEMENTS; i++ )
		{
			var s:Sprite2D = new Sprite2D();
			//var s:Box = new Box( 10, 10, 10, 'quad' );
			s.enableClipping( true );
			
			s.setSkin( skin );
			var tgT:TransformGroup = new TransformGroup();
			var trans:Transform3D = new Transform3D();
			trans.translate( Math.random() * 2000 - 1000, 0, Math.random() * 2000 - 1000  );
			tgT.setTransform( trans );
			tgT.addChild( s );
			bg.addChild( tgT );
		}
	
		return bg;
	}
}