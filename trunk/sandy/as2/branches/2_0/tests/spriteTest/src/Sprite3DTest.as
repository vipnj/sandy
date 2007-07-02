import com.bourre.data.libs.GraphicLib;
import com.bourre.data.libs.GraphicLibLocator;
import com.bourre.data.libs.LibEvent;
import com.bourre.data.libs.LibStack;
import com.bourre.log.Logger;
import com.bourre.transitions.FPSBeacon;
import com.bourre.transitions.IFrameListener;
import com.bourre.transitions.TweenEvent;
import com.bourre.transitions.TweenFPS;
import com.bourre.utils.LuminicTracer;
import com.bourre.visual.FPSLoggerUI;

import sandy.core.data.BezierPath;
import sandy.core.data.Vector;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Sprite3D;
import sandy.core.World3D;
import sandy.materials.Appearance;
import sandy.materials.ColorMaterial;
import sandy.materials.LineAttributes;
import sandy.primitive.Box;
import sandy.primitive.Plane3D;
import sandy.primitive.PrimitiveMode;

/**
 * @author thomaspfeiffer
 */
class tests.spriteTest.src.Sprite3DTest implements IFrameListener 
{
	private var _mc:MovieClip;
	private var _world:World3D;
	private var _path:BezierPath;
	
	public static function main( mc:MovieClip ):Void
	{
		Logger.getInstance().addLogListener( LuminicTracer.getInstance() );
		// --
		var t:Sprite3DTest = new Sprite3DTest(mc);
	}
	
	public function Sprite3DTest( p_oMc:MovieClip )
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
		// --
		var lContainer:MovieClip = _mc.createEmptyMovieClip("texture",_mc.getNextHighestDepth());
		var gl:GraphicLib = new GraphicLib( lContainer, 0, true );
		lStack.enqueue( gl, "SPRITE3D", "180.swf" );
		// --
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

		FPSBeacon.getInstance().addFrameListener( this );
	}

	
	public function onEnterFrame() : Void 
	{
		var cam:Camera3D = _world.camera;
		// -- 
		if ( Key.isDown(Key.UP))   cam.moveForward(5);
		if ( Key.isDown(Key.DOWN)) cam.moveForward(-5);
		if(Key.isDown(Key.LEFT))  cam.rotateY += 1; 
		if(Key.isDown(Key.RIGHT))  cam.rotateY -= 1; 		
		// --
		_world.render();
	}


	private function _createScene( Void ):Group
	{
		var  bg:Group = new Group();
		var lPlane:Plane3D = new Plane3D("floor", 500, 500, 3, Plane3D.YZ_ALIGNED, PrimitiveMode.QUAD );
		lPlane.z = 200;
		lPlane.rotateX = 90;
		lPlane.enableBackFaceCulling = false;
		Logger.LOG("appearance plane");
		lPlane.appearance = new Appearance( new ColorMaterial( 0xCCCCCC, 100, new LineAttributes() ) );
		
		var lSprite:Sprite3D = new Sprite3D("vaisseau", GraphicLibLocator.getInstance().getGraphicLib("SPRITE3D").getContent(), 3, 0 );
		lSprite.z = 200;
		
		var lBox:Box = new Box( "myBox", 50, 50, 50, "quad", 1 );
		lBox.x = 150;
		lBox.z = 280;
		lBox.appearance = new Appearance( new ColorMaterial( 0xCCCCCC, 100, new LineAttributes(2, 0, 100) ) );
		//
		bg.addChild( lPlane );
		bg.addChild( lSprite );
		bg.addChild( lBox );
		//
		_path = new BezierPath();
		_path.addPoint(  0, 50, -500 ) ;
		_path.addPoint( -900, 50, 900 );
		_path.addPoint(  0, 50, 900 );
		_path.addPoint( 900, 50, 1000 );
		_path.addPoint( 0, 50, -500 );
		_path.compile();
		// temporary object to hack the systeme here
		var o:Object = new Object();
		o.easeValue = 0;
		var t:TweenFPS = new TweenFPS( o, 'easeValue', 1, 500, 0, mx.transitions.easing.Elastic.easeOut );
		t.addEventListener(TweenFPS.onMotionFinishedEVENT, this, __onFinish);
		t.addEventListener(TweenFPS.onMotionChangedEVENT, this, __onBezierMoveChanged);
		t.start();	
		
		var tBox:TweenFPS = new TweenFPS( lBox, 'y', 100, 50, 0, mx.transitions.easing.Elastic.easeOut );
		tBox.addEventListener(TweenFPS.onMotionFinishedEVENT, this, __onBoxTweenFinish);
		tBox.start();	
		return bg;
	}

	private function __onBezierMoveChanged( pEvt:TweenEvent ):Void
	{
		var lPos:Vector = _path.getPosition( TweenFPS(pEvt.getTarget()).getTarget().easeValue );
		_world.camera.setPosition( lPos.x, lPos.y, lPos.z );
		_world.camera.lookAt( 0, 0, 200 );
	}
	
	private function __onFinish( pEvt:TweenEvent ):Void
	{
		TweenFPS( pEvt.getTween() ).yoyo();
	}
	
	private function __onBoxTweenFinish( pEvt:TweenEvent ):Void
	{
		TweenFPS( pEvt.getTween() ).yoyo();
	}
}