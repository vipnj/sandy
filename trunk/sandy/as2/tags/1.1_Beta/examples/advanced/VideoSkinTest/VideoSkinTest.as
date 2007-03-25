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
/**
* @mtasc -main VideoSkinTest -swf VideoSkinTest.swf -header 600:300:120:FFFFFF -version 8 -wimp
*/
class VideoSkinTest
{
	private var _mc : MovieClip;
	private var _fps:Number;
	private var _t:Number;
	
	public function VideoSkinTest( mc:MovieClip ) 
	{
		_mc = mc;
		_mc.createTextField('fps', 10000, 0, 20, 50, 20 );
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __refreshFps );
		_t = getTimer();
		_fps = 0;
		__start();
	}

	private function __refreshFps ( e:BasicEvent ):Void
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
		var c:VideoSkinTest = new VideoSkinTest( mc );
	}
	
	
	/**
	 * @param
	 * @return
	 */
	private function __start ( Void ):Void
	{
		var w:World3D = World3D.getInstance();
		_mc.video.attachVideo( Camera.get() );
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
		var rotint:RotationInterpolator = new RotationInterpolator( tgRotation, myEase.create(), 500 );
		// -- listener
		rotint.addEventListener( BasicInterpolator.onEndEVENT, this, __yoyo );
		rotint.addEventListener( BasicInterpolator.onProgressEVENT, this, __playMouse );
		
		var skin:Skin = new VideoSkin( _mc.video );
		//skin.setLightingEnable( true );
		var o:Object3D = new Sphere(100, 3);//( 100, 100, 100 );
		o.setSkin( skin );
		//
		tgRotation.addChild( rotint );
		tgRotation.addChild( o );
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
