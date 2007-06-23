import com.bourre.data.libs.GraphicLib;
import com.bourre.data.libs.GraphicLibLocator;
import com.bourre.log.Logger;
import com.bourre.transitions.IFrameListener;
import com.bourre.transitions.MSBeacon;
import com.bourre.utils.LuminicTracer;
import com.bourre.visual.FPSLoggerUI;

import flash.display.BitmapData;
import flash.filters.GlowFilter;

import sandy.core.face.Polygon;
import sandy.core.scenegraph.ATransformable;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.TransformGroup;
import sandy.core.World3D;
import sandy.events.ObjectEvent;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.ColorMaterial;
import sandy.materials.LineAttributes;
import sandy.primitive.Box;
import sandy.util.BitmapUtil;

import tests.testBench.src.TestBench;

/**
 * @author thomas pfeiffer
 */
class TestBench implements IFrameListener
{	
	private var _mc:MovieClip;
	private var _world:World3D;
	private var box:Box;
	private var obj:ATransformable;
	private var m_oTG:TransformGroup;
	
	public static function main( mc:MovieClip ):Void
	{
		Logger.getInstance().addLogListener( LuminicTracer.getInstance() );
		var t:TestBench = new TestBench(mc);
	}
	// Creat the environment
	public function TestBench( p_oMc:MovieClip )
	{
		_mc = p_oMc;
		// Here we get started.
		_world = World3D.getInstance();
		// Set the canvas to draw on
		_world.container = p_oMc;
		_init();
		// --
		var fpsUI:FPSLoggerUI = new FPSLoggerUI( _mc, -3 );
		MSBeacon.getInstance().addFrameListener( this );
	}
	
	// Initiate the world
	private function _init( Void ):Void
	{
		var gl:GraphicLib = new GraphicLib( _mc.createEmptyMovieClip("texture",0), 0, false );
		gl.setName( "TEXTURE" );
		gl.addEventListener( GraphicLib.onLoadInitEVENT, this, _onReady);
		gl.load( "texture.jpg" );
		gl.execute();
	}
	
	private function _onReady(Void):Void
	{
		// Let's create the object tree ( root node )
		_world.root = _createScene();
		// We need a camera in the world
		_world.camera = new Camera3D(500, 500);
		_world.camera.z = -300;
		_world.root.addChild( _world.camera );		
	}
		
		
	private function getFilters():Array
	{
		var color:Number = 0x33CCFF;
		var alpha:Number = .8;
		var blurX:Number = 35;
		var blurY:Number = 35;
		var strength:Number = 2;
		var quality:Number = 3;
		var inner:Boolean = false;
		var knockout:Boolean = false;
		
		var filter:GlowFilter = new GlowFilter(color, 
		                                        alpha, 
		                                        blurX, 
		                                        blurY, 
		                                        strength, 
		                                        quality, 
		                                        inner, 
		                                        knockout);
		return new Array( filter );
	}
	// Create the objec tree
	private function _createScene( Void ):Group
	{
		var g:Group = new Group();
		m_oTG = new TransformGroup("translation");
		//m_oTG.z = 500;
		// --
		var b:BitmapData = BitmapUtil.movieToBitmap( GraphicLibLocator.getInstance().getGraphicLib("TEXTURE").getContent(), false );
		var l_oMaterial:BitmapMaterial = new BitmapMaterial(b);
		//var l_oMaterial:ColorMaterial = new ColorMaterial( 0xFFCC00, 50 );
		//l_oMaterial.filters = getFilters();
		l_oMaterial.lineAttributes = new LineAttributes( 2, 0, 100 );
		var l_oTextureAppearance:Appearance = new Appearance( l_oMaterial ); 
		// --
		box = new Box( "myBox", 100, 100, 100, "tri", 1 );
		box.useSingleContainer = false;
		box.appearance = l_oTextureAppearance;
		//box.enableClipping = true;
		box.enableBackFaceCulling = true;
		box.enableEvents = true;
		g.broadcaster.addEventListener( ObjectEvent.onPressEVENT, this, onObjectPressed);
		//box.z = -100;
		// --
		m_oTG.addChild( box );
		g.addChild( m_oTG );
		// --
		return g;
	}
	
	public function onObjectPressed( pEvt:ObjectEvent ):Void
	{
		Polygon(pEvt.getTarget()).appearance = new Appearance( new ColorMaterial() );
	}
	
	public function onEnterFrame():Void
	{
		var cam:Camera3D = _world.camera;
		if(Key.isDown(Key.HOME))   cam.moveForward(1); 
		if(Key.isDown(Key.END))    cam.moveForward(-5); 
		//if ( Key.isDown(Key.UP))   cam.moveUpwards(1);
		//if ( Key.isDown(Key.DOWN)) cam.moveUpwards(-1);
		//if(Key.isDown(Key.LEFT))   cam.moveSideways(-1); 
		//if(Key.isDown(Key.RIGHT))  cam.moveSideways(1); 		
		if ( Key.isDown(Key.UP))   m_oTG.roll -=0.5;
		if ( Key.isDown(Key.DOWN)) m_oTG.roll +=0.5;
		if ( Key.isDown(Key.LEFT)) 
		{
			m_oTG.pan -=0.5; 
		}
		if ( Key.isDown(Key.RIGHT))  
		{
			m_oTG.pan +=0.5; 		
		}
		// --
		_world.render();
	}
}