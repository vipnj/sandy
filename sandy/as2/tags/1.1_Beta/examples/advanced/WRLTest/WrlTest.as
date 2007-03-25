
import sandy.core.data.Vector;
import sandy.core.group.*;
import sandy.view.*;
import sandy.core.*;
import sandy.skin.*;
import sandy.util.Ease;
import sandy.core.transform.*;
import sandy.events.*;
import sandy.util.WrlParser;

/**
* @mtasc -main WrlTest -swf WrlTest.swf -header 300:300:120:FFFFFF -version 8 -wimp
*/
class WrlTest
{
	private var _mc : MovieClip;
	private var _fps:Number;
	private var _t:Number;
	private var _t2:Number;
	private var _o:Object;
	
	public function WrlTest( mc:MovieClip ) 
	{
		_mc = mc;
		_mc.createTextField('fps', 10000, 0, 20, 50, 20 );
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __refreshFps );
		_t = _t2 = getTimer();
		_fps = 0;
		_o = new Object3D();
		
		WrlParser.addEventListener( WrlParser.onInitEVENT, this, __onObjectInitialized );
		WrlParser.addEventListener( WrlParser.onLoadEVENT, this, __onObjectLoad );
		WrlParser.addEventListener( WrlParser.onFailEVENT, this, __onObjectFailed );
		//WrlParser.parse( _o, 'teillere.WRL' );
		//WrlParser.parse( Object3D(_o), 'anneau3D.WRL' );
		WrlParser.parse(  Object3D(_o), '2cubes.WRL' );
		//WrlParser.export( '2cubes.WRL' );
	}
	
	private function __onObjectInitialized( e ):Void
	{
		trace('Object initialized');
		trace(_o.aPoints.length);
		__start();
	}
	
	private function __onObjectLoad( e ):Void
	{
		trace('Object loading');
	}
	
	private function __onObjectFailed( e ):Void
	{
		trace('Loading problem');
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
		var c:WrlTest = new WrlTest( mc );
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
		translation.translate( 0, 0, 300 );
		tgTranslation.setTransform( translation );
		//
		var rotint:RotationInterpolator = new RotationInterpolator( myEase.create(), 500 );
		// -- listener
		rotint.addEventListener( InterpolationEvent.onEndEVENT, this, __yoyo );
		rotint.addEventListener( InterpolationEvent.onProgressEVENT, this, __playMouse );
		
		var skin:Skin = new ZLightenSkin( 0xFF0000 );
		//var skin:Skin = new MixedSkin( 0xFFCC00, 100 );
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
