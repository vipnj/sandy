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
import com.bourre.data.libs.LibStack;
import com.bourre.data.libs.LibEvent;

/**
 * @author thomaspfeiffer
 */
class SpriteTest implements IFrameListener 
{
	private var _mc:MovieClip;
	private var _world:World3D;
	
	public static function main( mc:MovieClip ):Void
	{
		Logger.getInstance().addLogListener( LuminicTracer.getInstance() );
		// --
		var t:SpriteTest = new SpriteTest(mc);
	}
	
	public function SpriteTest( p_oMc:MovieClip )
	{
		_mc = p_oMc;
		var fpsUI:FPSLoggerUI = new FPSLoggerUI( _mc, -3 );
		// --
		_world = World3D.getInstance();
		// -- FIRST THING TO INITIALIZE
		_world.container = p_oMc;
		_init();
	}
	
	private function _init( Void ):Void
	{
		var lStack:LibStack = new LibStack();

		var lContainer:MovieClip = _mc.createEmptyMovieClip("texture",_mc.getNextHighestDepth());
		var gl:GraphicLib = new GraphicLib( lContainer, 0, false );
		lStack.enqueue( gl, "TEXTURE", "texture.jpg" );
	
		lStack.addEventListener( LibStack.onTimeOutEVENT, this, _onTimeout);
		lStack.addEventListener( LibStack.onLoadCompleteEVENT, this, _onReady);
		lStack.load();
		Logger.LOG("init :: "+lStack);
	}	
	
	private function _onTimeout( pEvt:LibEvent ):Void
	{
		Logger.LOG("timeout");
	}
	
	private function _onReady( pEvt:LibEvent ):Void
	{
		Logger.LOG("loaded");
		_world.root = _createScene();
		_world.camera = new Camera3D( 500, 500 );
		_world.root.addChild( _world.camera );
		_world.container = _mc;
		
		FPSBeacon.getInstance().addFrameListener( this );
	}
	
	private function _createScene( Void ):Group
	{
		// -- variables declaration
		var gl:GraphicLib = GraphicLibLocator.getInstance().getGraphicLib("TEXTURE");
		var lBmd:BitmapData = BitmapUtil.movieToBitmap( gl.getContent(), true );
		var g:Group = new Group();
		// --
		var l:Number = 100;
		var slice:Number = Math.PI * 2 / l;
		while( --l > -1 )
		{
			var lMc:MovieClip = _mc.createEmptyMovieClip( "sprite_"+l, _mc.getNextHighestDepth() );
			lMc.attachBitmap( lBmd, 0 );
			var l_oSprite:Sprite2D = new Sprite2D("sprite_"+l, lMc, 1 );
			l_oSprite.x = 1000 * Math.cos( l*slice );
			l_oSprite.z = 1000 * Math.sin( l*slice );
			// --
			g.addChild( l_oSprite );
		}
		// --
		return g;
	}

	public function onEnterFrame() : Void 
	{
		var cam:Camera3D = _world.camera;
		// --
		//if(Key.isDown(Key.HOME))   cam.moveForward(1); 
		//if(Key.isDown(Key.END))    cam.moveForward(-5); 
		if ( Key.isDown(Key.UP))   cam.moveForward(5);
		if ( Key.isDown(Key.DOWN)) cam.moveForward(-5);
		if(Key.isDown(Key.LEFT))  
		{
			//Logger.LOG("camera rotate left");
			cam.rotateY += 1; 
		}
		if(Key.isDown(Key.RIGHT))  cam.rotateY -= 1; 		
		// --
		_world.render();
	}
}