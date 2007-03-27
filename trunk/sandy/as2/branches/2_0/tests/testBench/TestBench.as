import com.bourre.commands.Delegate;
//mx.utils.Delegate
import flash.display.BitmapData;
//import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.*;
import sandy.core.transform.*;
import sandy.core.World3D;
import sandy.primitive.Box;
import sandy.primitive.Sphere;
import sandy.skin.*;

/**
 * @author thomaspfeiffer
 */
class TestBench 
{	
	private var _mc:MovieClip;
	private var _world:World3D;
	private var box:Box;
	private var sphere:Sphere;
	
	private var m_fpsTf:TextField;
	private var m_nFps:Number;
	private var m_nTime:Number;
	private var obj:ATransformable;
	private var rangle =0;
	
	public static function main( mc:MovieClip ):Void
	{
		var t:TestBench = new TestBench(mc);
	}
	// Creat the environment
	public function TestBench( p_oMc:MovieClip ){
		_mc = p_oMc;
		// All to get timing info
		m_fpsTf = _mc.createTextField("fps", -1, 0, 20, 40, 15 );
		m_fpsTf.border = true;
		//
		m_nTime = getTimer();
		m_nFps = 0;
		
		// Here we get started.
		_world = World3D.getInstance();
		// Set the canvas to draw on
		_world.container = p_oMc;
		_init();
	}
	// Initiate the world
	private function _init( Void ):Void
	{
		// Let's create the object tree ( root node )
		_world.root = _createScene();
		// We need a camera in the world
		_world.camera = new Camera3D(500, 300);
		_world.root.addChild( _world.camera );		
		_world.camera.near = 100;
		_world.camera.z = -500;
		_world.camera.y = 90;
		// --
		obj = _world.camera; // object to move
		setUpControls();
		_mc.onEnterFrame = Delegate.create( this, _onRender );
	}
	// Set up cotrols
	function setUpControls(){
		var keyListener:Object = new Object();
		Key.addListener(keyListener);
		keyListener.onKeyDown = Delegate.create(this, toggle);
		_root.reportBtn.onPress = Delegate.create(this, report);
	}
	// Toggle between controlling the camera and the cube
	function toggle(){
		if ( Key.getCode() == Key.SPACE ){ obj == _world.camera? obj = box: obj = _world.camera; }
	};
	
	// Create the objec tree
	private function _createScene( Void ):Group
	{
		var g:Group = new Group();
		var skin:MixedSkin = new MixedSkin( 0xF2B7EE, 800, 0, 100, 1 );
		var skin2:MixedSkin = new MixedSkin( 0xFEFDA3, 60, 0, 100, 1 );
		var skin3:TextureSkin = new TextureSkin(BitmapData.loadBitmap("monalisafit"));
		box = new Box( "myBox", 100, 100, 100, "quad", 3 );
		var axisX:Box = new Box("",400,1,1);
		var axisY:Box = new Box("",1,400,1);
		var axisZ:Box = new Box("",1,1,400);
		//g.addChild(axisX);
		//g.addChild(axisY);
		//g.addChild(axisZ);
		box.skin = skin2;
		/*var faces = box.geometry.faces;
		for ( var i = 0; i < 2*2*2; i++ ){
			faces[i].setSkin(skin3);
		}*/
		//box.enableClipping = true;
		box.z = 200;
		box.tilt = 45;
		//box.rotateX = 45;
		//box.rotateZ = 45;
		g.addChild( box );

		sphere = new Sphere("", 100, 2, "quad" );
		sphere.skin = skin2;		
		sphere.z = 300;
		sphere.x = 100;
		g.addChild( sphere );
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
		
		//box.roll += 0.5;
		//box.rotateX += 1;
		//box.scaleX += 0.01;
		//_world.camera.z += 2;
		//_world.camera.x -= 1;
		//_world.camera.y += 2;
		//_world.camera.rotateAxis(0,10,0, 0.2);
		//_world.camera.rotateY += 1;
		/*var rotAxis:Vector = new Vector(0,10,0);
		VectorMath.normalize(rotAxis);
		var t:Transform3D = _world.camera.transform;
		t.rotAxisWithReference( rotAxis, new Vector(0,0,0), rangle++ );
		_world.camera.transform = t;*/
		//_world.camera.rotateAxis( 1,0,1,0.2);
		//_world.camera.lookAt( 0, 0, 500 );
		if (Key.isDown (Key.HOME)) {_world.camera.moveForward(5);}
		if (Key.isDown (Key.END))  {_world.camera.moveForward(-5);}
		if ( Key.isDown(Key.SPACE)){ obj == _world.camera? obj = box: obj = _world.camera; }
		if ( Key.isDown(Key.LEFT)) { obj.roll-=0.5 ;}
		if ( Key.isDown(Key.RIGHT)){ obj.roll+=0.5 ;}
		if ( Key.isDown(Key.UP))   { obj.tilt-=0.5 ;}
		if ( Key.isDown(Key.DOWN)) { obj.tilt+=0.5 ;}
		_world.render();
	}
	// Reportiing pertinant angles
	function report(){
		trace("Camera:");
		trace("At: (" + _world.camera.x +", " + _world.camera.y + ", " + _world.camera.z + ")");
		trace ( "roll:" + _world.camera.roll );
		trace ( "tilt:" + _world.camera.tilt );
		trace("Cube:");
		trace("At: (" + box.x +", " + box.y + ", " + box.z + ")");		
		trace( "roll:" + box.roll);
		trace( "tilt:" + box.tilt);		
	}
}