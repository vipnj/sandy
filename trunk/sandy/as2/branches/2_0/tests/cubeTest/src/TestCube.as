import com.bourre.commands.Delegate;

import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.TransformGroup;
import sandy.core.World3D;
import sandy.math.Matrix4Math;
import sandy.primitive.Box;
import sandy.primitive.Sphere;
import sandy.skin.MixedSkin;

import tests.cubeTest.src.TestCube;

/**
 * @author thomaspfeiffer
 */
class TestCube 
{
	private var _mc:MovieClip;
	private var _world:World3D;
	private var box:Box;
	private var sphere:Sphere;
	
	private var m_fpsTf:TextField;
	private var m_nFps:Number;
	private var m_nTime:Number;
	
	public static function main( mc:MovieClip ):Void
	{
		var t:TestCube = new TestCube(mc);
		Matrix4Math.USE_FAST_MATH = true;
	}
	
	public function TestCube( p_oMc:MovieClip )
	{
		_mc = p_oMc;
		m_fpsTf = _mc.createTextField("fps", -1, 0, 20, 40, 15 );
		m_fpsTf.border = true;
		//
		m_nTime = getTimer();
		m_nFps = 0;
		//
		_world = World3D.getInstance();
		// FIRST THING TO INITIALIZE
		_world.container = p_oMc;
		_init();
	}
	
	private function _init( Void ):Void
	{
		_world.root = _createScene();
		_world.camera = new Camera3D(500, 500);
		// --
		_world.root.addChild( _world.camera );
		_world.container = _mc;
		_mc.onEnterFrame = Delegate.create( this, _onRender );
	}
	
	private function _createScene( Void ):Group
	{
		var g:Group = new Group();
		var tgTranslation:TransformGroup = new TransformGroup("translation");
		var tgRotation:TransformGroup = new TransformGroup("rotation");
		
		tgTranslation.z = 500;
		//tgRotation.transform = TransformUtil.rotAxisWithReference( new Vector( 0, 1, 0 ), new Vector( 0, 0, 0), 90);
		tgRotation.rotateY = 20;
		
		box = new Box( "myBox", 50, 50, 50, "quad", 3 );
		//box.enableClipping = true;
		box.skin = new MixedSkin( 0xFF00FF, 100 );
		box.rotateX = 45;
		box.rotateZ = 45;
		tgRotation.addChild( box );
		
		sphere = new Sphere( "mySphere", 100, 2, "quad" );
		sphere.skin = new MixedSkin( 0x0000FF, 100 );
		sphere.z = 200;
		sphere.x = 100;
		sphere.rotateAxis(1,1,1, 45);
		
		tgRotation.addChild( sphere );
		//
		tgTranslation.addChild( tgRotation );
		g.addChild( tgTranslation );
		return g;
	}
	
	private function _onRender( Void ):Void
	{
		m_nFps++;
		if( (getTimer() - m_nTime) > 1000 )
		{
			m_fpsTf.text = m_nFps+" fps";
			m_nFps = 0;
			m_nTime = getTimer();
		}
		
		box.roll += 0.5;
		//box.rotateX += 0.5;
		//box.scaleX += 0.01;
		//_world.camera.z += 2;
		//_world.camera.x -= 1;
		//_world.camera.y += 0.1;
		//sphere.pan += 0.2;
		
		//_world.camera.lookAt( 0, 0, 500 );
		_world.render();
	}
}