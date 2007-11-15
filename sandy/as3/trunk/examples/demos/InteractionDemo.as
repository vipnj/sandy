package demos
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import sandy.core.World3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.UVCoord;
	import sandy.core.data.Vector;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.Shape3D;
	import sandy.core.scenegraph.TransformGroup;
	import sandy.events.BubbleEvent;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.Material;
	import sandy.materials.attributes.GouraudAttributes;
	import sandy.materials.attributes.LineAttributes;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.primitive.Line3D;
	import sandy.primitive.Sphere;


	public class InteractionDemo extends Sprite
	{
		private var m_oScene:World3D;
		private var m_oPlane:Shape3D;
		private var keyPressed:Array = new Array();
		private var m_oLine3D:Line3D;
		
		private var texture:BitmapData;
		private var info:TextField = new TextField();
		private var lTg:TransformGroup = new TransformGroup("rotation");
		
		public function InteractionDemo()
		{
			super();
		}
		
		public function init():void
		{
			createTexture();
			// --
			var lCamera:Camera3D = new Camera3D( 640, 480 );
			m_oScene = World3D.getInstance();
			m_oScene.container = this;
			m_oScene.camera = lCamera ;
			lCamera.z = -400;
			lCamera.y = 90;
			lCamera.lookAt( 0, 0, 0 );
			m_oScene.root = _createScene3D();
			m_oScene.root.addChild( lCamera );
			
			info.multiline = true;
			info.width = 300;
			this.addChild( info );
			
			// --
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
	
		public function __onKeyDown(e:KeyboardEvent):void
		{
            keyPressed[e.keyCode]=true;
        }

        public function __onKeyUp(e:KeyboardEvent):void
        {
           keyPressed[e.keyCode]=false;
        }
  
  
  		private function createTexture():void
  		{
  			texture = new BitmapData( 200, 200, false, 0x0000FF );
  		}
  		
		private function enterFrameHandler( event : Event ) : void
		{
			var cam:Camera3D = m_oScene.camera;
			// --
			if( keyPressed[Keyboard.RIGHT] ) 
			{   
			    cam.rotateY -= 5;
			}
			if( keyPressed[Keyboard.LEFT] )     
			{
			    cam.rotateY += 5;
			}		
			if( keyPressed[Keyboard.UP] )
			{ 
			    cam.moveHorizontally( 10 );
			}
			if( keyPressed[Keyboard.DOWN] )
			{ 
			    cam.moveHorizontally( -10 );
			}
			//lTg.rotateY ++;
			m_oScene.render();

		}
			
		private function _createScene3D():Group
		{
			var lG:Group = new Group("rootGroup");
			// --
			//m_oLine3D = new Line3D("normale", new Vector(), new Vector(0, 50, 0) );
			
			m_oPlane = new Sphere("sphere");//new Plane3D("myPlane", 300, 300, 2, 2, Plane3D.ZX_ALIGNED, PrimitiveMode.TRI );
			m_oPlane.useSingleContainer = false;
			m_oPlane.enableEvents = true;
			m_oPlane.enableForcedDepth = true;
			m_oPlane.forcedDepth = 99999999;
			m_oPlane.addEventListener( MouseEvent.CLICK, onClick );

			var l_oAttr:MaterialAttributes = new MaterialAttributes( new LineAttributes(), new GouraudAttributes() );
			var l_oMat:Material = new BitmapMaterial( texture, l_oAttr );
			l_oMat.lightingEnable = true;
			m_oPlane.appearance = new Appearance( l_oMat );
			m_oPlane.enableNearClipping = true;
			
			lTg.addChild( m_oPlane );
			lG.addChild( lTg );

			return lG;
		}
		

        private function onClick( p_eEvent:BubbleEvent ):void
        {
            var l_oPoly:Polygon = ( p_eEvent.target as Polygon );
            //m_vMouse.ignore(  l_oPoly.container );
            // -- Maintenant on calcule le rayon depuis la camera jusqu'au point d'intersection
            // -- il nous faut le point 2D de click, et en profondeur c'est 0
            var l_nClicX:Number = m_oScene.container.mouseX;
            var l_nClicY:Number = m_oScene.container.mouseY;
            
            var l_oPoint:Point = new Point( l_nClicX, l_nClicY );
          
            
            var l_oIntersectionPoint:Vector = l_oPoly.get3DFrom2D( l_oPoint );                                            
          
            info.text = l_oIntersectionPoint.x+" \n "+l_oIntersectionPoint.y+"  \n "+l_oIntersectionPoint.z;
          
            if( m_oLine3D ) m_oLine3D.remove();
          
            var top:Vector = l_oPoly.normal.getVector().clone();
            top.scale( 50 );
            top.add( l_oIntersectionPoint );
            m_oLine3D = new Line3D("normal", l_oIntersectionPoint, top );
            lTg.addChild( m_oLine3D );
            
            // -- on interpole linéairement pour trouver la position du point dans repere de la texture (normalisé)
            var l_oIntersectionUV:UVCoord = l_oPoly.getUVFrom2D( l_oPoint );
                
            // -- recuperation du material appliqué sur le polygone
            var l_oMaterial:BitmapMaterial = (l_oPoly.visible ? l_oPoly.appearance.frontMaterial : l_oPoly.appearance.backMaterial) as BitmapMaterial;
           
            if( l_oMaterial == null )
            {
                trace("ce material doit etre un moviematerial");
            }
            else
            {
                var l_oRealTexturePosition:UVCoord = new UVCoord( l_oIntersectionUV.u * l_oMaterial.texture.width, l_oIntersectionUV.v * l_oMaterial.texture.height );
               
                // -- et là on joue sur la texture
                var l_oTexture:BitmapData = l_oMaterial.texture;
                //l_oTexture.setPixel( l_oRealTexturePosition.u, l_oRealTexturePosition.v, 0xFF0000 );
                //l_oTexture.fillRect( l_oTexture.rect, Math.random()*0xFFFFFF );
                l_oTexture.fillRect( new Rectangle( l_oRealTexturePosition.u-2, l_oRealTexturePosition.v-2, 4, 4 ), 0xFF0000 );
                l_oMaterial.texture = l_oTexture;           
            }

        }
	
	}
}