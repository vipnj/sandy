package demos
{
	import caurina.transitions.Tweener;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.ui.Keyboard;
	import flash.utils.*;
	
	import sandy.bounds.BSphere;
	import sandy.commands.Delegate;
	import sandy.core.World3D;
	import sandy.core.data.Vector;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.Sprite2D;
	import sandy.core.scenegraph.Sprite3D;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.math.IntersectionMath;
	import sandy.primitive.SkyBox;
	
	
	public class SpriteWorld extends Sprite
	{
		public function SpriteWorld()
		{
			super();
		}
		private var keyPressed:Array = new Array();
		private var planeList:Array = new Array();
		private var missileList:Array = new Array();
		private var MissileClass:Class;
		private var AvionClass:Class;
		private var loader:Loader;
		
		[Embed(source="../assets/skybox/topav9.jpg")]
		private var SkyBox_TOP:Class;
		
		[Embed(source="../assets/skybox/topav9.jpg")]
		private var SkyBox_BOTTOM:Class;
		
		[Embed(source="../assets/skybox/leftav9.jpg")]
		private var SkyBox_LEFT:Class;
		
		[Embed(source="../assets/skybox/rightav9.jpg")]
		private var SkyBox_RIGHT:Class;
		
		[Embed(source="../assets/skybox/frontav9.jpg")]
		private var SkyBox_FRONT:Class;
		
		[Embed(source="../assets/skybox/backav9.jpg")]
		private var SkyBox_BACK:Class;
		
		
		
		public function init():void
		{
			var l_oURL:URLRequest = new URLRequest();
			l_oURL.url = "assets/kamikaze_optim.swf";
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
			loader.load( l_oURL );
		}

		private function completeHandler( e:Event ):void 
		{
			// On fait appel au domain d'application du fichier library que l'on vient de charger
			// pour instancier des objets Square ,Circle...
			var domain:ApplicationDomain = loader.contentLoaderInfo.applicationDomain;
			 
			// On se sert de la methode getDefinition pour obtenir comme son nom l'indique
			// une definition de classe
			AvionClass = domain.getDefinition("Avion") as Class;
			MissileClass = domain.getDefinition("Missile") as Class;
			
			_createScene();
		}
			
		public function __onKeyDown(e:KeyboardEvent):void
		{
            if( e.keyCode != Keyboard.SPACE )
            {
            	keyPressed[e.keyCode]=true;
            }
            else
            {
            	var l_oMissileData:BitmapData = new MissileClass(20, 20) as BitmapData;
				var l_oMissile:Bitmap = new Bitmap(l_oMissileData);
			    // --
			    var l_oSprite:Sprite2D = new Sprite2D("missile_"+getTimer(), l_oMissile, 0.4 );
				l_oSprite.setBoundingSphereRadius( 10 );
				World3D.getInstance().root.addChild( l_oSprite );
			    _moveMissile( l_oSprite );
			    // --
			    missileList.push( l_oSprite );
            }
        }

        public function __onKeyUp(e:KeyboardEvent):void
        {
           keyPressed[e.keyCode]=false;
        }	
			
		private function _moveSprite( p_oSprite3D:Sprite3D ):void
		{
			var lDestX:Number = Math.random()*3000-1500;
			var lDestZ:Number = Math.random()*3000-1500;
			// --
			p_oSprite3D.lookAt( lDestX, 0, lDestZ );
			p_oSprite3D.offset = 180; // TODO find why this is needed
			// --
			Tweener.addTween( p_oSprite3D, 
			{
				x : lDestX,
				z : lDestZ,
				time : 5+Math.random()*5, 
				transition : "linear",
				onComplete : Delegate.create( _moveSprite, p_oSprite3D )
			});
		}
		
		private function _removeMissile( p_oSprite:Sprite2D ):void
		{
			Tweener.removeTweens( p_oSprite );
			p_oSprite.remove();
			var l_nId:int =  missileList.indexOf( p_oSprite );
			if( l_nId >= 0 )
			{
				missileList.splice( l_nId, 1 );
			}
		}
		
		private function _removePlane( p_oSprite:Sprite3D ):void
		{
			Tweener.removeTweens( p_oSprite );
			p_oSprite.remove();
			var l_nId:int = planeList.indexOf( p_oSprite );
			if( l_nId >= 0 )
			{
				planeList.splice( l_nId, 1 );
			}
		}
		
		private function _moveMissile( p_oSprite2D:Sprite2D ):void
		{
			var l_oDir:Vector = World3D.getInstance().camera.out.clone();
			var l_nDepart:int = 40;
			var l_nDist:int = 1000;
			var l_oPos:Vector = World3D.getInstance().camera.getPosition("absolute")
			// --
			p_oSprite2D.x = l_oPos.x + l_oDir.x * l_nDepart;
			p_oSprite2D.z = l_oPos.z + l_oDir.z * l_nDepart;
			// --
			l_oDir.scale(l_nDist );
			l_oPos.add( l_oDir );
			// --
			Tweener.addTween( p_oSprite2D, 
			{
				x : l_oPos.x,
				z : l_oPos.z,
				time : 5, 
				transition : "linear",
				onComplete : Delegate.create( _removeMissile, p_oSprite2D )
			});
		}
		
		private function _createScene():void
		{
			var l_oGroup:Group = new Group("root");
			
			for( var id:int = 0; id < 100; id ++ )
			{
				var l_oAvion:MovieClip = new AvionClass();
				var l_oSprite3D:Sprite3D = new Sprite3D("avion_"+id, l_oAvion, 1+Math.random()*2 );
				l_oSprite3D.z = Math.random()*2000-1000;
				l_oSprite3D.x = Math.random()*2000-1000;
				// --
				l_oGroup.addChild( l_oSprite3D );
				_moveSprite( l_oSprite3D );
				// --
				planeList.push( l_oSprite3D );
			}
			
			// -- creation de la skybox
			var l_oSkyBox:SkyBox = new SkyBox( "game_sky", 15000, 6, 6 );
			var lPic:Bitmap;
			
			lPic = new SkyBox_FRONT();
			l_oSkyBox.front.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );

			lPic = new SkyBox_BACK();
			l_oSkyBox.back.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );
			
			lPic = new SkyBox_LEFT();
			l_oSkyBox.left.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );
			
			lPic = new SkyBox_RIGHT();
			l_oSkyBox.right.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );
			
			//lPic = new SkyBox_TOP();
			//l_oSkyBox.top.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );
					
			//lPic = new SkyBox_BOTTOM();
			//l_oSkyBox.bottom.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );
			l_oSkyBox.top.remove();
			l_oSkyBox.bottom.remove();
			
			l_oGroup.addChild( l_oSkyBox );
			
			World3D.getInstance().container = this;
			World3D.getInstance().camera = new Camera3D( 800, 600 );
			l_oGroup.addChild( World3D.getInstance().camera );
			World3D.getInstance().root = l_oGroup;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			addEventListener(Event.ENTER_FRAME, _onEnterFrame );
			
		}
		
		private function processIntersectionTest():void
		{
			var l_bIsIntersection:Boolean = false;
			// --
			for( var l_nJd:int = 0; l_nJd < missileList.length; l_nJd++ )
			{
				var l_oMissile:Sprite2D = missileList[ l_nJd ] as Sprite2D;
				l_bIsIntersection = false;
				// --
				var l_oBS:BSphere = l_oMissile.boundingSphere;
				// --
				var l_nLength:int = planeList.length;
				for( var l_nId:int = 0; l_nId < l_nLength && l_bIsIntersection == false; l_nId++ )
				{
					var l_oPlane:Sprite3D = planeList[ l_nId ] as Sprite3D;
					// --
					if( IntersectionMath.intersectionBSphere( l_oPlane.boundingSphere, l_oBS ) )
					{
						_removePlane( l_oPlane );
						_removeMissile( l_oMissile );
						// --
						l_bIsIntersection = true;
						// --
						break;
					}
				}
			}
			
		}
		
		private function _onEnterFrame( e:Event  ):void
		{
			var cam:Camera3D = World3D.getInstance().camera;
			
			if( keyPressed[Keyboard.RIGHT] ) 
			{   
			    cam.rotateY -= 2;
			}
			if( keyPressed[Keyboard.LEFT] )     
			{
			    cam.rotateY += 2;
			}	
			/*	
			if( keyPressed[Keyboard.UP] )
			{ 
			    cam.moveHorizontally( 5 );
			}
			if( keyPressed[Keyboard.DOWN] )
			{ 
			    cam.moveHorizontally( -5 );
			}
			*/
			processIntersectionTest();
			
			World3D.getInstance().render();
		}

	}
}