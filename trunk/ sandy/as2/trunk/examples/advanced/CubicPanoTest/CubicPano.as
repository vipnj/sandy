import com.bourre.data.libs.GraphicLib;
import com.bourre.data.libs.LibEvent;
import com.bourre.data.libs.LibStack;
import com.bourre.data.libs.AbstractLib;

import sandy.core.group.Group;
import sandy.core.face.*;
import sandy.primitive.Box;
import sandy.skin.*;
import sandy.view.Camera3D;
import sandy.view.ClipScreen;
import sandy.view.IScreen;
import sandy.core.World3D;
import sandy.util.*;


import flash.display.BitmapData;

class CubicPano
{
	// the MovieClip in which CubicPano does its stuff
	private var _scope:MovieClip;

	// the six bitmaps that will constitute the cubic view
	static var CUBE_DIM 		= 300;
	static var ANIM_DIM 		= 400;
	static var CUBE_QUALITY 	= 2;
	private var cube:Box;

	private var oLibStack:LibStack;
	private var _planeNames:Array;
	private var _world:World3D;
	private var aElmts:Array;
	private var _tf:TextField;
	private var _fps:Number;
	private var _ms:Number;

	private var _loadingTF:TextField;

	private var _yaw:Number;
	private var _pitch:Number;
	private var _fov:Number;

	public static function main():Void
	{
		var p:CubicPano = new CubicPano(_root);
	}

	public function CubicPano(scope:MovieClip)
	{
		_scope = scope;
		_world = World3D.getInstance();
		_fps = 0;
		aElmts = [];
		_planeNames = ["straight_ahead", "down","behind",  "up", "left", "right"];
		initLoader();
	}

	private function __createFPS():Void
	{
		_tf = _scope.createTextField ("fps", _scope.getNextHighestDepth(), 5, 10, 40, 20);
		_tf.border = true;
		_tf.borderColor = 0xFFFFFF;
	}

	public function initLoader( Void ):Void
	{
		// On crée une instance de LibStack
		oLibStack = new LibStack();
		// On instancie les différentes librairies que l'on veut charger en stipulant la cible et la profondeur,et en option si le contenu est visible  à la fin du chargement (true par defaut).
		for(var i:Number = 0; i < 6; i++)
		{
			var gl:GraphicLib 	= new GraphicLib(_scope, 10+i, false);
			aElmts.push( gl );
			oLibStack.enqueue( gl, _planeNames[i], _planeNames[i]+'.jpg' );
		}
		// On s'abonne
		oLibStack.addEventListener( LibStack.onLoadInitEVENT, 		this, onLoadInit );
		oLibStack.addEventListener( LibStack.onLoadProgressEVENT, 	this, onLoadProgress );
		oLibStack.addEventListener( LibStack.onTimeOutEVENT, 		this, onTimeOut );
		oLibStack.addEventListener( LibStack.onLoadCompleteEVENT, 	this, onLoadComplete );
		// On lance le chargement
		oLibStack.execute();
	}
	
	function onLoadInit(e:LibEvent) : Void
	{
		trace(e.getName());
		e.getType()
	}
	 
	function onLoadProgress(e:LibEvent) : Void
	{
		trace(e.getName() + ' : ' + e.getPerCent() + '%');
	}
	 
	function onLoadComplete(e:LibEvent)
	{	

		start();
	}
	 
	function onTimeOut(e:LibEvent) : Void
	{	// On peut utiliser setTimeOut pour le modifier le délais de 10 secs par défaut.
		trace("Le chargement de " + e.getName() + " a échouŽ!");
	}

	public function start():Void
	{
		_yaw = _pitch = 0;
		// We have built all the objects; now we can display them 
		_world.setContainer(_scope.createEmptyMovieClip("screen", _scope.getNextHighestDepth()));
		var screen:IScreen = new ClipScreen( ANIM_DIM, ANIM_DIM);
		__createFPS();
		var cam:Camera3D = new Camera3D( screen);
		//cam.setPosition( 0, 0, -500 );
		_world.setCamera(cam);
		_world.setRootGroup( makeScene() );
		_ms = getTimer();
		_world.addEventListener(World3D.onRenderEVENT, this, interactions);
		_world.render();
	}

	private function makeScene():Group
	{
		var g:Group = new Group();	
		cube = new Box( CUBE_DIM, CUBE_DIM, CUBE_DIM, 'tri', CUBE_QUALITY );
		var a:Array = cube.aFaces;
		trace(a.length);
		for( var i:Number = 0,j:Number = 1; i < a.length; i+=(2*CUBE_QUALITY*CUBE_QUALITY), j++ )
		{
			var f:Polygon;
			var skin:Skin;
			var lib:AbstractLib = AbstractLib( aElmts[j-1] );
trace(lib.getContent() );
			var b:BitmapData = BitmapUtil.movieToBitmap( lib.getContent(), true );
			skin = new TextureSkin( b ); 
			// --
			for(var k:Number = 0; k < 2*CUBE_QUALITY*CUBE_QUALITY; k++ )
			{
				f = a[i+k];
				f.setSkin( skin );
			}
		}
		cube.swapCulling();
		g.addChild( cube );
		return g;
	}


	private function interactions():Void
	{
		var newMS:Number = getTimer();
		if (newMS - 1000 > _ms)
		{
			_ms = newMS;
			_tf.text = _fps + " fps";
			_fps = 0;
		}
		else
		{
			_fps++;
		}

		var cam:Camera3D = _world.getCamera();

		if (Key.isDown(Key.RIGHT))
		{
			cam.rotateY(5);		// yaw
			_yaw += 5;
		}
		if (Key.isDown(Key.LEFT))
		{
			cam.rotateY(-5);	// yaw
			_yaw -= 5;
		}
		if (Key.isDown(Key.UP))
		{
			cam.tilt(5);		// pitch (not really but OK since we don't roll)
			_pitch += 5;
		}
		if (Key.isDown(Key.DOWN))
		{
			cam.tilt(-5);		// pitch (not really but OK since we don't roll)
			_pitch -= 5;
		}

		if (_yaw > 180) _yaw -= 360;
		else if (_yaw < -180) _yaw += 360;
	}


}
