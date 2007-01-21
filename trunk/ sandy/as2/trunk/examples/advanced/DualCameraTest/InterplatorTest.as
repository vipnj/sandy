import sandy.core.data.*;
import sandy.core.group.*;
import sandy.primitive.*;
import sandy.view.*;
import sandy.core.*;
import sandy.skin.*;
import sandy.util.Ease;
import sandy.core.transform.*;
import sandy.events.*;

class InterpolatorTest 
{
	private var _mc : MovieClip;
	var tgRotation:TransformGroup;
	var rotation:Transform3D;
	
	public function InterpolatorTest( mc:MovieClip ) 
	{
		_mc = mc;
		__start();
	}
	
	public static function main( mc:MovieClip ) : Void 
	{
		if( !mc ) mc = _root;
		var i:InterpolatorTest = new InterpolatorTest( mc );
	}
	
	/**
	 * 
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
	 * 
	 * @param
	 * @return
	 */
	private function __createCams ( Void ):Void
	{
		var mc:MovieClip;var cam:Camera3D;var screen:ClipScreen;
		
		mc = _mc.createEmptyMovieClip( 'screen', 1 );
		World3D.getInstance().setContainer( mc );
		screen = new ClipScreen( 300, 300 );
		cam = new Camera3D( screen );
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
		myEase.quadraticBezier( 2 );
 		myEase.easingOut( 1 );
		// -- translation
		var tgTranslation:TransformGroup = new TransformGroup();
		var translation:Transform3D = new Transform3D();
		translation.translate( 0, 0, 600 );
		tgTranslation.setTransform( translation );
		// translation to set the sphere position 	
		var tgTranslationSphere:TransformGroup = new TransformGroup();
		var posint:PositionInterpolator = new PositionInterpolator( myEase.create(), 200, new Vector(-50,-50,-50), new Vector( 50, 50, 50 ) );
		posint.addEventListener( InterpolationEvent.onEndEVENT, this, __yoyo );
		// scale of the cube
		var tgScaleCube:TransformGroup = new TransformGroup();
		var scaleint:ScaleInterpolator = new ScaleInterpolator( myEase.create(), 200, new Vector( 1, 1, 1), new Vector( 3, 0.5, 3));
		scaleint.addEventListener( InterpolationEvent.onEndEVENT, this, __yoyo );
		// -- rotation
		tgRotation = new TransformGroup();
		var rotint:RotationInterpolator = new RotationInterpolator( myEase.create(), 200 );
		// -- listener
		rotint.addEventListener( InterpolationEvent.onEndEVENT, this, __yoyo );
		// -- box
		var box:Object3D = new Box( 20, 20, 20 );
		box.name = "Box";
		var skin:Skin = new SimpleColorSkin( 0xFF0000 );
		skin.setLightingEnable( true );
		box.setSkin( skin );
		var sphere:Object3D = new Sphere( 15, 2, 'quad' );
		sphere.name = "Sphere";
		skin = new SimpleColorSkin( 0x00FF00 );
		skin.setLightingEnable( true );
		sphere.setSkin( skin );
		// -- creation of the tree	
		tgScaleCube.addChild( box );
		tgTranslationSphere.addChild( sphere );
		//		
		tgRotation.setTransform( rotint );
		tgTranslationSphere.setTransform( posint );
		tgScaleCube.setTransform( scaleint );
		//
		tgRotation.addChild( tgTranslationSphere );
		tgRotation.addChild( tgScaleCube );
		//
		tgTranslation.addChild( tgRotation );
		bg.addChild( tgTranslation );
		//
		return bg;
	}
	
	private function __yoyo( e:InterpolationEvent )
	{
		e.getTarget().yoyo();
	}
	
}
