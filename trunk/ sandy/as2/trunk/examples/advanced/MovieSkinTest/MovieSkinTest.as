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
* @mtasc -main MovieSkinTest -swf MovieSkinTest.swf -header 300:300:120:FFFFFF -version 8 -wimp
*/
class MovieSkinTest
{
	private var _mc : MovieClip;
	private var _fps:Number;
	private var _t:Number;
	
	public function MovieSkinTest( mc:MovieClip ) 
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
		var c:MovieSkinTest = new MovieSkinTest( mc );
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
		var mc:MovieClip; var cam:Camera3D;
		mc = _mc.createEmptyMovieClip( 'screen', 1 );
		World3D.getInstance().setContainer( mc );
		cam = new Camera3D( 300, 300 );
		World3D.getInstance().setCamera( cam );
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
		
		var o:Object3D = new Box( 100, 100, 100 );
		var skin:Skin = new MovieSkin( 'texture_anim', true );
		skin.setLightingEnable( true );
		o.setSkin( skin );
		//
		tgRotation.setTransform( rotint );
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
