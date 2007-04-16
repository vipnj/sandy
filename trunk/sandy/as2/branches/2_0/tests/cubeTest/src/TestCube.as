import com.bourre.commands.Delegate;
import com.bourre.data.libs.GraphicLib;
import com.bourre.data.libs.GraphicLibLocator;
import com.bourre.log.Logger;
import com.bourre.utils.LuminicTracer;
import com.bourre.visual.FPSLoggerUI;

import flash.display.BitmapData;

import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.TransformGroup;
import sandy.core.World3D;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.ColorMaterial;
import sandy.materials.LineAttributes;
import sandy.materials.Material;
import sandy.primitive.Box;
import sandy.util.BitmapUtil;

import tests.cubeTest.src.TestCube;

/**
 * @author thomaspfeiffer
 */
class TestCube 
{
	private var _mc:MovieClip;
	private var _world:World3D;
	private var box:Box;
	private var box2:Box;
	var tgRotation:TransformGroup;
	private var m_tfPolygonCount:TextField;
	private var m_tfVertexCount:TextField;
	
	public static function main( mc:MovieClip ):Void
	{
		Logger.getInstance().addLogListener( LuminicTracer.getInstance() );
		// --
		var t:TestCube = new TestCube(mc);
		// -- Does not make things faster in AS2 but does in AS3...
		//Matrix4Math.USE_FAST_MATH = true;
	}
	
	public function TestCube( p_oMc:MovieClip )
	{
		_mc = p_oMc;
		m_tfPolygonCount = _mc.createTextField("polygonCount", -1, 400, 20, 70, 20 );
		m_tfPolygonCount.border = true;
		
		m_tfVertexCount = _mc.createTextField("vertexCount", -2, 400, 40, 70, 20 );
		m_tfVertexCount.border = true;
		
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
	}
	
	private function _onReady( Void ):Void
	{
		_world.root = _createScene();
		_world.camera = new Camera3D( 500, 500 );
		//_world.camera.z = -200;
		//_world.camera.x = 200;
		//_world.camera.lookAt( 0, 0, 500 );
		// --
		_world.root.addChild( _world.camera );
		_world.container = _mc;
		_mc.onEnterFrame = Delegate.create( this, _onRender );
	}
	
	private function _createScene( Void ):Group
	{
		// -- variables declaration
		var g:Group = new Group();
		var tgTranslation:TransformGroup = new TransformGroup("translation");
		tgRotation = new TransformGroup("rotation");
		// -- transformations
		tgTranslation.z = 500;
		// -- creation of the materials and apperance
		var b:BitmapData = BitmapUtil.movieToBitmap( GraphicLibLocator.getInstance().getGraphicLib("TEXTURE").getContent(), false );
		var l_oTextureAppearance:Appearance = new Appearance( new BitmapMaterial( b ) ); 
		//
		var l_oMaterial:Material = new ColorMaterial( 0xFF0000, 100 );
		l_oMaterial.lineAttributes = new LineAttributes( 2, 0xFF, 100 );
		var l_oAppearance:Appearance = new Appearance( l_oMaterial ); 
		// -- creation of objects
		box = new Box( "myBox", 50, 50, 50, "quad", 3 );
		box.appearance = l_oTextureAppearance;
		box.rotateZ = 45;
		
		box2 = new Box( "myBox2", 100, 50, 100, "tri", 2 );
		box2.appearance = l_oTextureAppearance;
		box2.z = 100;
		box2.x = 0;
		// -- Tree creation
		tgTranslation.addChild( box );
		tgRotation.addChild( box2 );
		tgTranslation.addChild( tgRotation );
		g.addChild( tgTranslation );
		// --
		return g;
	}
	
	private function _onRender( Void ):Void
	{
		m_tfVertexCount.text = _world.camera['_aVerticesList'].length+" vertices";
		m_tfPolygonCount.text = _world.camera.renderer.getDisplayListLength()+" polygons";
		// --
		tgRotation.rotateY ++;
		//box.pan += 0.5;
		box.rotateX += 0.5;
		//box2.tilt += 0.1;
		//box.scaleX += 0.01;
		//_world.camera.z += 2;
		//_world.camera.x -= 1;
		//_world.camera.y += 0.1;
		//_world.camera.lookAt( 0, 0, 500 );
		_world.render();
	}
}