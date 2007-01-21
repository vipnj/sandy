import sandy.core.data.Vector;
import sandy.core.group.*;
import sandy.view.*;
import sandy.core.*;
import sandy.skin.*;
import sandy.util.Ease;
import sandy.core.transform.*;
import sandy.events.*;
import sandy.util.AseParser;

import flash.display.BitmapData;

/**
* @mtasc -main AseTest -swf AseTest.swf -header 300:300:20:FFFFFF -version 8 -wimp
*/
class AseTest
{
	private var _mc : MovieClip;
	private var _fps:Number;
	private var _t:Number;
	private var _t2:Number;
	private var _o:Object3D;
	
	public function AseTest( mc:MovieClip ) 
	{
		_mc = mc;
		_mc.createTextField('fps', 10000, 0, 20, 50, 20 );
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __refreshFps );
		_t = _t2 = getTimer();
		_fps = 0;
		_o = new Object3D();
		
		AseParser.addEventListener( AseParser.onInitEVENT, this, __onObjectInitialized );
		AseParser.addEventListener( AseParser.onFailEVENT, this, __onObjectFailed );
		AseParser.parse( _o, 'shuttle.ASE' );
		//AseParser.export( 'gun.ase' );
		//__start();
	}
	
	private function __onObjectInitialized( e ):Void
	{
		trace('Objet initializé');
		__start();
	}
	
	private function __onObjectFailed( e ):Void
	{
		trace('Probleme de chargement');
	}
	
	private function __refreshFps ( e ):Void
	{
		if( getTimer() > _t + 1000 )
		{
			_mc.fps.text = _fps+' ips';
			_fps = 0;
			_t = getTimer();
		}
		else _fps++;
	}
	
	public static function main( mc:MovieClip ) : Void 
	{
		if( !mc ) mc = _root;
		var c:AseTest = new AseTest( mc );
	}
	
	private function __start ( Void ):Void
	{
		var w:World3D = World3D.getInstance();
		w.setRootGroup( __createScene() );
		__createCams();
		w.render();
	}

	private function __createCams ( Void ):Void
	{
		var mc:MovieClip;var cam:Camera3D;var screen:ClipScreen;
		mc = _mc.createEmptyMovieClip( 'screen', 1 );
		World3D.getInstance().setContainer( mc );
		screen = new ClipScreen( 300, 300 );
		cam = new Camera3D(screen );
		World3D.getInstance().setCamera( cam );
	}
	
	private function __createScene ( Void ):Group
	{
		var bg:Group = new Group();
		// -- interpolator
		var myEase:Ease = new Ease();
		//
		var tgRotation:TransformGroup;
		var tgTranslation:TransformGroup;
		tgRotation 	= new TransformGroup();
		tgTranslation	= new TransformGroup();
		//
		var translation:Transform3D = new Transform3D();
		translation.translate( 0, 0, 150 );
		tgTranslation.setTransform( translation );
		//
		var rotint:RotationInterpolator = new RotationInterpolator( myEase.create(), 500 );
		// -- listener
		rotint.addEventListener( TransformEvent.onEndEVENT, this, __yoyo );
		rotint.addEventListener( InterpolationEvent.onProgressEVENT, this, __playMouse );

		var skin:Skin;
		skin = new TextureSkin( BitmapData.loadBitmap( 'texture' ) );
		_o.setSkin( skin );
		//
		tgRotation.setTransform( rotint );
		tgRotation.addChild(  Object3D(_o) );
		tgTranslation.addChild( tgRotation );
		bg.addChild( tgTranslation );
		//
		return bg;
	}
	
	private function __yoyo( e:InterpolationEvent ):Void
	{
		e.getTarget().redo();
	}
	
	private function __playMouse( e:InterpolationEvent ):Void
	{
		var difX:Number = 150 - _mc._xmouse;
		var difY:Number = 150 - _mc._ymouse;
		var dist:Number = Math.sqrt( difX*difX  + difY*difY );
		RotationInterpolator(e.getTarget()).setAxisOfRotation( new Vector( -difY, difX, 0 ) );
		RotationInterpolator(e.getTarget()).setDuration( 10000 / dist );
	}	
}
