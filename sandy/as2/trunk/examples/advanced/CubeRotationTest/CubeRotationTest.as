
import sandy.core.data.Vector;
import sandy.core.group.*;
import sandy.primitive.*;
import sandy.view.*;
import sandy.core.*;
import sandy.skin.*;
import sandy.util.Ease;
import sandy.core.transform.*;
import sandy.events.*;
import com.bourre.events.BasicEvent;

import flash.display.BitmapData;
/**
* @mtasc -main CubeRotationTest -swf CubeRotationTest.swf -header 300:300:120:CCCCCC -version 8 -wimp
*/
class CubeRotationTest 
{
	private var _mc : MovieClip;
	private var _b:BitmapData;
	private var _fps:Number;
	private var _t2:Number;
	private var _t:TextField;
	
	public function CubeRotationTest( mc:MovieClip ) 
	{
		_mc = mc;
		_t = _mc.createTextField('fps', 10000, 0, 20, 50, 20 );
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __refreshFps );
		_t2 = getTimer();
		_fps = 0;
		__loadBitmap();
	}
	
	private function __onLoad( e:ParserEvent ):Void
	{
		_t.text = 'Loading...';
	}
	
	private function __loadBitmap():Void
	{
		var mcl:MovieClipLoader = new MovieClipLoader();
		mcl.addListener( this );
		mcl.loadClip( "sandy2.png", _mc.createEmptyMovieClip('tmp', 2 ) );
	}
	
	private function onLoadProgress (target:MovieClip, bytesLoaded:Number, bytesTotal:Number):Void 
	{
		_t.text = 'Texture loading : '+int(100*bytesLoaded/bytesTotal)+' %';
	}

	private function onLoadInit( mc:MovieClip ):Void
	{
		trace('Bitmap ok');
		_b = new BitmapData( mc._width, mc._height );
		_b.draw( mc );
		mc.unloadMovie();
		__start();
	}
	
	private function __refreshFps ( e:BasicEvent ):Void
	{
		_fps ++;
		if( (getTimer()-_t2) >= 1000 )
		{
			_t.text = _fps+' ips';
			_t2 = getTimer();
			_fps = 0;
		}
	}
	
	public static function main( mc:MovieClip ) : Void 
	{
		if( !mc ) mc = _root;
		var c:CubeRotationTest = new CubeRotationTest( mc );
	}
	
	
	/**
	 * @param
	 * @return
	 */
	private function __start ( Void ):Void
	{
		var w:World3D = World3D.getInstance();
		w.setRootGroup( __createScene() );
		__createCams();
		w.render();
	}
	
	/**
	 * @param
	 * @return
	 */
	private function __createCams ( Void ):Void
	{
		var mc:MovieClip;var cam:Camera3D;var screen:ClipScreen;
		mc = _mc.createEmptyMovieClip( 'screen', 1 );
		screen = new ClipScreen( mc, 300, 300 );
		cam = new Camera3D( 700, screen );
		cam.setPosition( 0, 0, 0 );
		//cam.lookAt( _sunPosition.x, _sunPosition.y, _sunPosition.z );
		World3D.getInstance().addCamera( cam );
	}
	

	/**
	 * 
	 * @param
	 * @return
	 */
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
		translation.translate( 0, 0, 500 );
		tgTranslation.setTransform( translation );
		//
		var rotint:RotationInterpolator = new RotationInterpolator( myEase.create(), 500 );
		// -- listener
		rotint.addEventListener( BasicInterpolator.onEndEVENT, this, __yoyo );
		rotint.addEventListener( BasicInterpolator.onProgressEVENT, this, __playMouse );
		// -- earth
		var box:Box = new Box( 100, 80, 50, 'tri', 2 );
		var skin:Skin;
		skin = new TextureSkin( _b );
		//skin = new MixedSkin( 0xFF0000, 100, 0x0, 50, 2 );
		box.setSkin( skin );
		//
		tgRotation.setTransform( rotint );
		tgRotation.addChild( box );
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
