import sandy.core.data.*;
import sandy.core.group.*;
import sandy.primitive.*;
import sandy.view.*;
import sandy.core.*;
import sandy.skin.*;
import sandy.util.Ease;
import sandy.core.transform.*;
import sandy.events.*;

/**
* @mtasc -main PlaneBackTest -swf PlaneBackTest.swf -header 300:300:120:FFFFFF -version 6 -wimp
*/
class PlaneBackTest
{
	public static function main( mc:MovieClip ):Void
	{
		if( !mc ) mc = _root;
		var ins:PlaneBackTest = new PlaneBackTest( mc );
	}
	
	private function PlaneBackTest( mc:MovieClip )
	{
		_mc = mc;
		__start();
	}
	
	private function __start():Void
	{
		var mc:MovieClip = _mc.createEmptyMovieClip( 'screen', 1 );
		var w:World3D = World3D.getInstance();
		w.setRootGroup( __createScene() );
		var screen:IScreen = new ClipScreen( mc, 300, 300 );
		var c:Camera3D = new Camera3D( 700, screen );
		w.addCamera( c );
		w.render();
	}
	
	private function __createScene ( Void ):Group
	{
		var bg:Group = new Group();
		//
		var translation:Transform3D = new Transform3D();
		translation.translate( 0 , 0, 300 );
		//
		var tgTranslation:TransformGroup;
		tgTranslation = new TransformGroup();
		var tgRotation:TransformGroup;
		tgRotation = new TransformGroup();
		// -- interpolator
		var myEase:Ease = new Ease();
		var rotint:RotationInterpolator = new RotationInterpolator( tgRotation, myEase.create(), 300 );
		rotint.setAxisOfRotation( new Vector( 1, 1, 1 ) );
		// -- listener
		rotint.addEventListener( BasicInterpolator.onEndEVENT, this, __yoyo );
		rotint.addEventListener( BasicInterpolator.onProgressEVENT, this, __playMouse );
		// --
		var o:Object3D = new Plane3D( 100, 100, 4, 'quad' );
		o.enableBackFaceCulling = false
		// --
		var skin:Skin;
		//skin = new TextureSkin( BitmapData.loadBitmap( 'texture' ) );
		//skin = new ZLightenSkin( 0x00FF00 );
		skin = new SimpleColorSkin( 0x999999, 100 );
		//skin = new MixedSkin( 0xFF0000, 100, 0x0, 50, 2 );
		skin.setLightingEnable( true );
		o.setSkin( skin );
		// --
		//skin = new ZLightenSkin();
		skin = new MixedSkin( 0xFF0000, 100, 0x0, 50, 2 );
		o.setBackSkin( skin );
		//
		tgRotation.addChild( rotint );
		tgRotation.addChild( o );
		//
		tgTranslation.setTransform( translation );
		//
		tgTranslation.addChild( tgRotation );
		//
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
	
	private var _mc:MovieClip;
}
