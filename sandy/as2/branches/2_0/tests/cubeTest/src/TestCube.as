import com.bourre.data.libs.GraphicLib;
import com.bourre.data.libs.GraphicLibLocator;
import com.bourre.log.Logger;
import com.bourre.transitions.IFrameListener;
import com.bourre.transitions.MSBeacon;
import com.bourre.utils.LuminicTracer;
import com.bourre.visual.FPSLoggerUI;

import flash.display.BitmapData;

import sandy.core.data.Vector;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.TransformGroup;
import sandy.core.World3D;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.ColorMaterial;
import sandy.materials.LineAttributes;
import sandy.materials.Material;
import sandy.math.Matrix4Math;
import sandy.primitive.Box;
import sandy.primitive.Cone;
import sandy.primitive.Cylinder;
import sandy.primitive.Hedra;
import sandy.primitive.Line3D;
import sandy.primitive.Sphere;
import sandy.primitive.Torus;
import sandy.util.BitmapUtil;

import tests.cubeTest.src.TestCube;
import com.bourre.transitions.FPSBeacon;

/**
 * @author thomaspfeiffer
 */
class TestCube implements IFrameListener
{
	private var _mc:MovieClip;
	private var _world:World3D;
	private var box:Box;
	private var hedra:Hedra;
	var tgRotation:TransformGroup;
	private var m_tfPolygonCount:TextField;
	private var m_tfVertexCount:TextField;
	
	public static function main( mc:MovieClip ):Void
	{
		Logger.getInstance().addLogListener( LuminicTracer.getInstance() );
		// --
		var t:TestCube = new TestCube(mc);
		// -- Does not make things a lot faster in AS2 but does in AS3...
		Matrix4Math.USE_FAST_MATH = true;
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
		// -- we register to a pulsing event that simple
		//MSBeacon.getInstance().setFPS( 120 );
		MSBeacon.getInstance().addFrameListener( this );
		//FPSBeacon.getInstance().addFrameListener( this );
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
		
		hedra = new Hedra( "myHedra", 50, 50, 100 );
		hedra.appearance = l_oTextureAppearance;
		hedra.y = 50;
		hedra.x = 20;
		
		var l_oCylinder:Cylinder = new Cylinder("myCylinder", 50, 50, 6, 1, 50 );
		//l_oCylinder.enableBackFaceCulling = false;
		l_oCylinder.rotateX = 45;
		l_oCylinder.z = -150;
		l_oCylinder.appearance = l_oTextureAppearance;
		
		var l_oTorus:Torus = new Torus("myTorus", 70, 40, 6, 6 );
		//l_oCylinder.enableBackFaceCulling = false;
		l_oTorus.x = -150;
		l_oTorus.rotateX = 90;
		l_oTorus.appearance = l_oTextureAppearance;	

		var l_oSphere:Sphere = new Sphere("mySphere", 60, 6, 4 );
		//l_oCylinder.enableBackFaceCulling = false;
		l_oSphere.z = 150;
		l_oSphere.appearance = l_oTextureAppearance;	
		
		var l_oCone:Cone = new Cone("myCone", 60, 40, 8, 1 );
		//l_oCylinder.enableBackFaceCulling = false;
		l_oCone.y = -50;
		l_oCone.x = -30;
		l_oCone.appearance = l_oTextureAppearance;	
		
				
		// --
		var line:Line3D = new Line3D( "myLine", new Vector( 50, 50), new Vector( 100, 50 ), new Vector( 100, 100 ), new Vector( 75, 50 ), new Vector( 50, 100 ), new Vector( 50, 50 ) );
		line.appearance = l_oAppearance;
		// -- Tree creation
		tgTranslation.addChild( box );
		tgRotation.addChild( hedra );
		tgRotation.addChild( line );
		tgRotation.addChild( l_oCylinder );
		tgRotation.addChild( l_oTorus );
		tgRotation.addChild( l_oSphere );
		tgRotation.addChild( l_oCone );
		tgTranslation.addChild( tgRotation );
		g.addChild( tgTranslation );
		// --
		return g;
	}
	

	public function onEnterFrame() : Void 
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