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
import sandy.materials.Appearance;
import sandy.materials.ColorMaterial;
import sandy.materials.Material;
import sandy.materials.BitmapMaterial;
import sandy.materials.LineAttributes;
/**
 * @author thomaspfeiffer
 */
class TestBench 
{	
	private var _mc:MovieClip;
	private var _world:World3D;
	private var box:Box;
	//private var sphere:Sphere;
	
	private var m_fpsTf:TextField;
	private var m_nFps:Number;
	private var m_nTime:Number;
	private var obj:ATransformable;
	private var rangle =0;
	
	public static function main( mc:MovieClip ):TestBench
	{
		var t:TestBench = new TestBench(mc);
		return t;
	}
	// Creat the environment
	public function TestBench( p_oMc:MovieClip ){
		_mc = p_oMc;
		// All to get timing info
		m_fpsTf = _mc.createTextField("fps", -1, 0, 40, 40, 20 );
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
		_world.camera = new Camera3D(550, 400);
		_world.root.addChild( _world.camera );		
		//_world.camera.near = 100;
		_world.camera.z = -300;
		//_world.camera.y = 200;
		//_world.camera.x = 200;		
		// --
		_mc.onEnterFrame = Delegate.create( this, _onRender );
	}
		
	// Create the objec tree
	private function _createScene( Void ):Group
	{
		var g:Group = new Group();
		//var skin:MixedSkin = new MixedSkin( 0xF2B7EE, 800, 0, 100, 1 );
		//var skin2:MixedSkin = new MixedSkin( 0xFEFDA3, 60, 0, 100, 1 );
		//var skin3:TextureSkin = new TextureSkin(BitmapData.loadBitmap("monalisafit"));
		var l_oTextureAppearance:Appearance = new Appearance( new BitmapMaterial( BitmapData.loadBitmap("monalisafit") ) ); 
		//var l_oMaterial:Material = new ColorMaterial( 0xFF0000, 0 );
		//l_oMaterial.lineAttributes = new LineAttributes(2, 0xFF, 100 );
		//var l_oAppearance:Appearance = new Appearance( l_oMaterial, l_oMaterial );
		box = new Box( "myBox", 100, 100, 100, "tri", 2 );
		//var axisX:Box = new Box("",400,1,1);
		//var axisY:Box = new Box("",1,400,1);
		//var axisZ:Box = new Box("",1,1,400);
		//g.addChild(axisX);
		//g.addChild(axisY);
		//g.addChild(axisZ);
		box.appearance = l_oTextureAppearance;
		/*var faces = box.geometry.faces;
		for ( var i = 0; i < 2*2*2; i++ ){
			faces[i].setSkin(skin3);
		}*/
		box.enableClipping = true;
		//box.z = 200;
		//box.tilt = 45;
		//box.rotateX = 45;
		//box.rotateZ = 45;
		g.addChild( box );

		//sphere = new Sphere("", 100, 2, "quad" );
		//sphere.skin = skin2;		
		//sphere.z = 300;
		//sphere.x = 100;
		//g.addChild( sphere );
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
		var cam = _world.camera;
		if(Key.isDown(Key.HOME))   cam.moveForward(5); 
		if(Key.isDown(Key.END))    cam.moveForward(-5); 
		//if ( Key.isDown(Key.UP))   cam.moveUpwards(1);
		//if ( Key.isDown(Key.DOWN)) cam.moveUpwards(-1);
		//if(Key.isDown(Key.LEFT))   cam.moveSideways(-1); 
		//if(Key.isDown(Key.RIGHT))  cam.moveSideways(1); 		
		if ( Key.isDown(Key.UP))   box.rotateX-=1;
		if ( Key.isDown(Key.DOWN)) box.rotateX+=1;
		if ( Key.isDown(Key.LEFT))  box.rotateY-=1; 
		if ( Key.isDown(Key.RIGHT))  box.rotateY+=1; 		
		//cam.lookAt( 0, 0, 0 );
		_world.render();
	}
	// Reporting pertinent angles
	function report(){
		trace ("Reporting");
		var faces:Array = box.aPolygons;
		for ( var i = 0; i < faces.length; i++) {
			trace(faces[i].id + (faces[i].visible?" visible": ""));
		}
	}
}