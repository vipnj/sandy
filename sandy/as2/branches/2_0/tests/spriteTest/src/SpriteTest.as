import com.bourre.data.libs.GraphicLib;
import com.bourre.data.libs.GraphicLibLocator;
import com.bourre.log.Logger;
import com.bourre.transitions.FPSBeacon;
import com.bourre.transitions.IFrameListener;
import com.bourre.utils.LuminicTracer;
import com.bourre.visual.FPSLoggerUI;

import flash.display.BitmapData;

import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Sprite2D;
import sandy.core.scenegraph.TransformGroup;
import sandy.core.World3D;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.ColorMaterial;
import sandy.materials.LineAttributes;
import sandy.materials.Material;
import sandy.math.Matrix4Math;
import sandy.util.BitmapUtil;

/**
 * @author thomaspfeiffer
 */
class tests.spriteTest.src.SpriteTest implements IFrameListener 
{
	private var _mc:MovieClip;
	private var _world:World3D;
	
	public static function main( mc:MovieClip ):Void
	{
		Logger.getInstance().addLogListener( LuminicTracer.getInstance() );
		// --
		var t:SpriteTest = new SpriteTest(mc);
		// -- Does not make things a lot faster in AS2 but does in AS3...
		Matrix4Math.USE_FAST_MATH = true;
	}
	
	public function SpriteTest( p_oMc:MovieClip )
	{
		_mc = p_oMc;
		
		var fpsUI:FPSLoggerUI = new FPSLoggerUI( _mc, -3 );
		//
		_world = World3D.getInstance();
		// FIRST THING TO INITIALIZE
		_world.container = p_oMc;
		_init();
	}
	
	private function _init( Void ):Void
	{
		var gl:GraphicLib = new GraphicLib( _mc.createEmptyMovieClip("texture",0), 0, false );
		gl.setName( "TEXTURE" );
		gl.addEventListener( GraphicLib.onLoadInitEVENT, this, _onReady);
		gl.load( "texture.jpg" );
		gl.execute();
		FPSBeacon.getInstance().addFrameListener( this );
	}	

	
	private function _onReady( Void ):Void
	{
		_world.root = _createScene();
		_world.camera = new Camera3D( 500, 500 );
		_world.root.addChild( _world.camera );
		_world.container = _mc;
	}
	
	private function _createScene( Void ):Group
	{
		// -- variables declaration
		var g:Group = new Group();
		var tgTranslation:TransformGroup = new TransformGroup("translation");
		// -- transformations
		tgTranslation.z = 500;
		// -- creation of the materials and apperance
		var b:BitmapData = BitmapUtil.movieToBitmap( GraphicLibLocator.getInstance().getGraphicLib("TEXTURE").getContent(), false );
		var l_oTextureAppearance:Appearance = new Appearance( new BitmapMaterial( b ) ); 
		// --
		var l_oMaterial:Material = new ColorMaterial( 0xFF0000, 100 );
		l_oMaterial.lineAttributes = new LineAttributes( 10, 0xFF, 100 );
		var l_oAppearance:Appearance = new Appearance( l_oMaterial ); 
		// --
		var l_oSprite:Sprite2D = new Sprite2D();
		l_oSprite.appearance = l_oTextureAppearance;
		
		var l_oSprite2:Sprite2D = new Sprite2D();
		l_oSprite2.x = -100;
		l_oSprite2.appearance = l_oAppearance;
		// --
		tgTranslation.addChild( l_oSprite );
		tgTranslation.addChild( l_oSprite2 );
		g.addChild( tgTranslation );
		// --
		return g;
	}
	

	public function onEnterFrame() : Void 
	{
		var cam:Camera3D = _world.camera;
		// --
		//if(Key.isDown(Key.HOME))   cam.moveForward(1); 
		//if(Key.isDown(Key.END))    cam.moveForward(-5); 
		if ( Key.isDown(Key.UP))   cam.moveForward(3);
		if ( Key.isDown(Key.DOWN)) cam.moveForward(-3);
		if(Key.isDown(Key.LEFT))   cam.rotateY += 1; 
		if(Key.isDown(Key.RIGHT))  cam.rotateY -= 1; 		
		// --
		_world.render();
	}

}