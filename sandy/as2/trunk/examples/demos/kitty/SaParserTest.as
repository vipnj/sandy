import flash.display.BitmapData;
import sandy.view.*;
import sandy.core.group.*;
import sandy.skin.*;
import sandy.core.*;
import sandy.core.data.*;
import sandy.util.Ease;
import sandy.core.transform.*;
import sandy.events.*;
import sandy.util.*;

/**
* @mtasc -main SaParserTest -swf SaParserTest.swf -header 600:600:15:FFFFFF -version 8 -wimp 
*/
//-trace org.flashdevelop.utils.FlashConnect.mtrace org/flashdevelop/utils/FlashConnect.as 

class SaParserTest 
{
	private var _mc : MovieClip;
	private var _ad:AnimationData;
	private var _o:Object3D;
	private var _b:BitmapData;
	private var _cam:Camera3D;
	private var _move:Boolean;private var distance:Number;
	private var _t:TextField;private var circlePlace1:Number=220;
	
	public function SaParserTest( mc:MovieClip ) 
	{
		_mc = mc;
		_o = new Object3D();
		_ad = new AnimationData();
		_move = false;
		
		_mc.createEmptyMovieClip('background', 1).loadMovie( 'background.swf');	
		
		_t = _mc.createTextField('loading', 1000, 100, 150, 200, 30 );
		_t.text = 'Initializing';
		AseParser.addEventListener( AseParser.onProgressEVENT, this, __onAseProgress );
		AseParser.addEventListener( AseParser.onLoadEVENT, this, __onLoad );
		AseParser.addEventListener( AseParser.onInitEVENT, this, __onAseInitialized );
		AseParser.parse( _o, 'chat.ASE' );
		
	}
	
	private function __onSaProgress( e:ParserEvent ):Void
	{
		_t.text = 'Animation parsing :'+int(e.getPercent())+' %';
		_mc.loading_mc.setProgress( e.getPercent(), 100 );
	}
	private function __onAseProgress( e:ParserEvent ):Void
	{
		_t.text = 'Object parsing : '+int(e.getPercent())+' %';
		_mc.loading_mc.setProgress( e.getPercent(), 100 );
	}
	
	private function __onLoad( e:ParserEvent ):Void
	{
		_t.text = 'Loading...';
	}
	private function __onAseInitialized( e:ParserEvent ):Void
	{
		SaParser.addEventListener( SaParser.onInitEVENT, this, __onSaInitialized );
		SaParser.addEventListener( SaParser.onLoadEVENT, this, __onLoad );
		SaParser.addEventListener( SaParser.onProgressEVENT, this, __onSaProgress );
		SaParser.parse( _ad, 'animation.SA' );
	}


	private function __onSaInitialized( e:ParserEvent ):Void
	{
		var mcl:MovieClipLoader = new MovieClipLoader();
		mcl.addListener( this );
		mcl.loadClip( "texture.JPG", _mc.createEmptyMovieClip('tmp', 2 ) );
	}
	
	private function onLoadProgress (target:MovieClip, bytesLoaded:Number, bytesTotal:Number):Void 
	{
		_t.text = 'Texture loading : '+int(100*bytesLoaded/bytesTotal)+' %';
		_mc.loading_mc.setProgress( bytesLoaded, bytesTotal );
	}

	private function onLoadInit( mc:MovieClip ):Void
	{
		trace('Bitmap ok');
		_t.removeTextField();
		_b = new BitmapData( mc._width, mc._height );
		_b.draw( mc );
		mc.unloadMovie();
		__start();
	}
	
	public static function main( mc:MovieClip ) : Void 
	{
		if( !mc ) mc = _root;
		var c:SaParserTest = new SaParserTest( mc );
	}
	
	private function __start ( Void ):Void
	{
		var w:World3D = World3D.getInstance();
		w.addEventListener( World3D.onRenderEVENT, this, onRender );
		__createCams();
		w.setRootGroup( __createScene() );
		w.render();
	}
	
	private function __createCams ( Void ):Void
	{
		var mc:MovieClip;var cam:Camera3D;var screen:ClipScreen;
		mc = _mc.createEmptyMovieClip( 'screen', 2 );
		screen = new ClipScreen( mc, 600, 600 );
		_cam = new Camera3D( 700, screen );
		
		distance = 1800;
		_cam.setPosition(Math.cos(circlePlace1*Math.PI/360)*distance, distance-1000, Math.sin(circlePlace1*Math.PI/360)*distance);
		_cam.lookAt(1, 200, 1);
		World3D.getInstance().addCamera( _cam );
	}
	
	private function __createScene ( Void ):Group
	{
		var bg:Group = new Group();
		var tg:TransformGroup = new TransformGroup();
		// -- interpolator
		var myEase:Ease = new Ease();
		myEase.linear();
		//
		var int:VertexInterpolator = new VertexInterpolator( _o, myEase.create(), [_ad] );		
		int.addEventListener( BasicInterpolator.onEndEVENT, this, __yoyo );
		//var skin:Skin = new MixedSkin( 0xA0FF55, 100, 0, 100 );
		//var skin:Skin = new SimpleColorSkin( 0xA0FF55, 100 );
		var skin:Skin = new TextureSkin( _b );
		//skin.setLightingEnable( true );
		_o.setSkin( skin );
		//
		tg.setTransform( int );
		tg.addChild( _o );
		bg.addChild( tg );
		//
		return bg;
	}
	
	
	private function __yoyo( e:InterpolationEvent ):Void
	{
		e.getTarget().redo();
	}
	
	private function onRender( Void ):Void
	{
		var test=false;
		if(Key.isDown(Key.LEFT))
		{
			circlePlace1+=10;
			test=true;
		}
		if(Key.isDown(Key.RIGHT))
		{
			circlePlace1-=10;
			test=true;
		}
		if( Key.isDown( Key.DOWN ) )
		{
			distance += 30;
			test=true;
		}
		if( Key.isDown( Key.UP ) )
		{
			distance -= 30;
			test=true;
		}
		if(test)
		{
		
			var circlePlace = (circlePlace1)%360;
			_cam.setPosition(Math.cos(circlePlace1*Math.PI/360)*distance, distance-1000, Math.sin(circlePlace1*Math.PI/360)*distance);
			_cam.lookAt(1, 200, 1);
		}
	}
/*
	
		var xm:Number = _mc._xmouse - 150;
		var ym:Number = 150 - _mc._ymouse ;
		var dx:Number = (xm) * 90 / 150;
		var dy:Number = (ym) * 90 / 150;
		//_cam.tilt( 0.02 * dx );
		_cam.tilt( 0.01 * dy );
		_cam.rotateY (0.01 * dx );

		// rotation around the global vertical axis
		if (Key.isDown (Key.RIGHT))	{_cam.moveSideways(15);}
		if (Key.isDown (Key.LEFT))	{_cam.moveSideways(-15);}
		// translation on the view vector direction.
		if (Key.isDown (Key.UP))	{_cam.moveForward(15);}
		if (Key.isDown (Key.DOWN))	{_cam.moveForward(-15);}
		// rotation around the local horizontal axis of the camera
		//if (Key.isDown (Key.SHIFT)){_cam.tilt(5);}
		//if (Key.isDown (Key.CONTROL)){_cam.tilt(-5);}
		*/

}
