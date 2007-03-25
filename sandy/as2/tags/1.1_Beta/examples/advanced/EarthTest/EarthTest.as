
import sandy.core.data.*;
import sandy.core.group.*;
import sandy.primitive.*;
import sandy.view.*;
import sandy.core.*;
import sandy.skin.*;
import sandy.util.Ease;
import sandy.core.transform.*;
import sandy.events.*;
import com.bourre.events.BasicEvent;

/**
* @mtasc -main EarthTest -swf EarthTest.swf -header 600:600:120:FFFFFF -version 7 -wimp
*/
class EarthTest 
{
	private var _mc : MovieClip;
	private var _earthRadius:Vector;
	private var _sunPosition:Vector;
	
	private var _fps:Number;
	private var _t:Number;
	private var _t2:Number;
	
	public function EarthTest( mc:MovieClip ) 
	{
		_mc = mc;
		_mc.createTextField('fps', 10000, 0, 20, 50, 20 );
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __refreshFps );
		_t = _t2 = getTimer();
		_fps = 0;
		_earthRadius = new Vector( 200, 0, 0 );
		_sunPosition = new Vector( 0, 0, 500 );
		__start();
	}
	
	private function __refreshFps ( e:BasicEvent ):Void
	{
		var t:Number = getTimer();
		_fps ++;
		if( (t-_t) >= 1000 )
		{
			_mc.fps.text = _fps+' ips';
			_t = getTimer();
			_fps = 0;
		}
	}
	
	public static function main( mc:MovieClip ) : Void 
	{
		if( !mc ) mc = _root;
		var c:EarthTest = new EarthTest( mc );
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
		screen = new ClipScreen( mc, 600, 600 );
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
		rotintEarth.addEventListener( BasicInterpolator.onEndEVENT, this, __yoyo );
		rotintSun.addEventListener( BasicInterpolator.onEndEVENT, this, __yoyo );
		// -- earth
		var earth:Sphere = new Sphere( 10, 3, 'quad' );
		var skinEarth:Skin;
		//skinEarth = new TextureSkin( BitmapData.loadBitmap( "per" ) );
		skinEarth = new SimpleColorSkin( 0x0099FF ); //MixedSkin( 0x0099FF, 100, 0, 100 );
		skinEarth.setLightingEnable( true );
		earth.setSkin( skinEarth );
		// -- sun
		var sun:Object3D = new Sphere( 30, 3, 'quad' );
		var skinSun:Skin;
		//skinSun = new TextureSkin( BitmapData.loadBitmap( "lion" ) );
		skinSun = new SimpleColorSkin( 0xFFFF55 ); //MixedSkin( 0xFFFF00, 100, 0, 100 );
		skinSun.setLightingEnable( true );
		sun.setSkin( skinSun );
		// -- creation of the tree		
		tgRotationEarth.setTransform( rotintEarth );
		tgRotationEarth.addChild( earth );
		//
		tgRotationSun.setTransform( rotintSun );
		tgRotationSun.addChild( sun );
		//
		tgTranslationSun.setTransform( translationSun );
		tgTranslationEarth.setTransform( translationEarth );
		//
		tgTranslationSun.addChild( tgRotationSun );
		tgTranslationEarth.addChild( tgRotationEarth );
		//
		bg.addChild( tgTranslationEarth );
		bg.addChild( tgTranslationSun );
		//
		return bg;
	}
	
	private function __yoyo( e:InterpolationEvent ):Void
	{
		e.getTarget().redo();
	}
	
}
