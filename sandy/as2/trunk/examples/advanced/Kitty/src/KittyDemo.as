import flash.display.BitmapData;

import sandy.core.data.AnimationData;
import sandy.core.group.Group;
import sandy.core.group.TransformGroup;
import sandy.core.Object3D;
import sandy.core.transform.VertexInterpolator;
import sandy.core.World3D;
import sandy.events.InterpolationEvent;
import sandy.events.ParserEvent;
import sandy.events.TransformEvent;
import sandy.skin.TextureSkin;
import sandy.util.AseParser;
import sandy.util.Ease;
import sandy.util.SaParser;
import sandy.view.Camera3D;
import sandy.util.NumberUtil;
import sandy.skin.Skin;
import sandy.skin.MixedSkin;
		
class KittyDemo 
{
	private var _fps:Number;
	private var _t:Number;
	private var _mc : MovieClip;
	private var _ad:AnimationData;
	private var _o:Object3D;
	private var _b:BitmapData;
	private var _cam:Camera3D;
	private var _move:Boolean;
	private var distance:Number;
	private var _tf:TextField;
	private var circlePlace1:Number=0;
	static private var path:String = "";

	private var distanceH : Number;
	
	public function KittyDemo( mc:MovieClip ) 
	{
		_mc = mc;
		_o = new Object3D();
		_ad = new AnimationData();
		_move = false;
		
		_mc.createEmptyMovieClip('background', -10).loadMovie( path+'background.swf');	
		_mc.createTextField( 'fps', 10000, 0, 20, 50, 20 );
		_t  = getTimer();
		_fps = 0;
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __refreshFps );
		
		_tf = _mc.createTextField('loading', 1000, 100, 150, 200, 30 );
		_tf.text = 'Initializing';
		AseParser.addEventListener( AseParser.onProgressEVENT, this, __onAseProgress );
		AseParser.addEventListener( AseParser.onLoadEVENT, this, __onLoad );
		AseParser.addEventListener( AseParser.onInitEVENT, this, __onAseInitialized );
		AseParser.parse( _o, path+'chat.ASE' );
	}
	
	private function __onSaProgress( e:ParserEvent ):Void
	{
		_tf.text = 'Animation parsing :'+int(e.getPercent())+' %';
		_mc.loading_mc.setProgress( e.getPercent(), 100 );
	}
	private function __onAseProgress( e:ParserEvent ):Void
	{
		_tf.text = 'Object parsing : '+int(e.getPercent())+' %';
		_mc.loading_mc.setProgress( e.getPercent(), 100 );
	}
	
	private function __onLoad( e:ParserEvent ):Void
	{
		_tf.text = 'Loading...';
	}
	private function __onAseInitialized( e:ParserEvent ):Void
	{
		SaParser.addEventListener( SaParser.onInitEVENT, this, __onSaInitialized );
		SaParser.addEventListener( SaParser.onLoadEVENT, this, __onLoad );
		SaParser.addEventListener( SaParser.onProgressEVENT, this, __onSaProgress );
		SaParser.parse( _ad, path+'animation.SA' );
	}

	function __refreshFps ():Void
	{
		if( getTimer() > _t + 1000 )
		{
			_mc.fps.text = _fps+' ips';
			_fps = 0;
			_t = getTimer();
		}
		else _fps++;
		
		onRender();
	}
	private function __onSaInitialized( e:ParserEvent ):Void
	{
		var mcl:MovieClipLoader = new MovieClipLoader();
		mcl.addListener( this );
		mcl.loadClip( path+"texture.JPG", _mc.createEmptyMovieClip('tmp', 2 ) );
	}
	
	private function onLoadProgress (target:MovieClip, bytesLoaded:Number, bytesTotal:Number):Void 
	{
		_tf.text = 'Texture loading : '+int(100*bytesLoaded/bytesTotal)+' %';
		_mc.loading_mc.setProgress( bytesLoaded, bytesTotal );
	}

	private function onLoadInit( mc:MovieClip ):Void
	{
		trace('Bitmap ok');
		_tf.removeTextField();
		_b = new BitmapData( mc._width, mc._height );
		_b.draw( mc );
		mc.unloadMovie();
		__start();
	}
	
	public static function main( mc:MovieClip ) : Void 
	{
		if( !mc ) mc = _root;
		var c:KittyDemo = new KittyDemo( mc );
	}
	
	private function __start ( Void ):Void
	{
		var w:World3D = World3D.getInstance();
		//w.addEventListener( World3D.onRenderEVENT, this, onRender );
		__createCams();
		w.setRootGroup( __createScene() );
		w.render();
	}
	
	private function __createCams ( Void ):Void
	{
		var mc:MovieClip;var cam:Camera3D;
		mc = _mc.createEmptyMovieClip( 'screen', 2 );
		World3D.getInstance().setContainer(mc);
		_cam = new Camera3D( 600, 600 );
		
		distanceH = distance = 2000;
		_cam.setPosition(Math.cos(circlePlace1*Math.PI/360)*distanceH, distance , Math.sin(circlePlace1*Math.PI/360)*distanceH);
		_cam.lookAt(0, 280, 0);
		
		World3D.getInstance().setCamera( _cam );
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
		int.addEventListener( TransformEvent.onEndEVENT, this, __yoyo );
		//var skin:Skin = new MixedSkin( 0xA0FF55, 100, 0, 100 );
		//var skin:Skin = new SimpleColorSkin( 0xA0FF55, 100 );
		var skin:TextureSkin = new TextureSkin( _b );
		//skin.setTransparency( 60 );
		//skin.setLightingEnable( true );
		//_o = new Box( 200, 200, 200 );
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
			distanceH = NumberUtil.constrain(distance, 500, 4000);
			test=true;
		}
		if( Key.isDown( Key.UP ) )
		{
			distance -= 30;
			distanceH = NumberUtil.constrain(distance, 500, 4000);
			test=true;
		}
		if(test)
		{		
			var circlePlace = (circlePlace1)%360;
			_cam.setPosition(Math.cos(circlePlace1*Math.PI/360)*distanceH, distance , Math.sin(circlePlace1*Math.PI/360)*distanceH);
			_cam.lookAt(0, 280, 0);
		}

	}
}
