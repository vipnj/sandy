package demos
{
	import fl.controls.UIScrollBar;
	import fl.controls.*;
    import flash.display.BitmapData;
	import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.ui.Keyboard;
	import sandy.materials.MovieMaterial;
	import sandy.primitive.Plane3D;
	import sandy.primitive.PrimitiveMode;
   
    import sandy.core.World3D;
    import sandy.core.data.Matrix4 ;
    import sandy.core.data.Polygon;
    import sandy.core.data.UVCoord;
    import sandy.core.data.Vector;
    import sandy.core.data.Vertex;
    import sandy.core.scenegraph.Camera3D;
    import sandy.core.scenegraph.Group ;
    import sandy.core.scenegraph.Shape3D;
    import sandy.core.scenegraph.TransformGroup;
    import sandy.events.BubbleEvent;
    import sandy.materials.Appearance;
    import sandy.materials.BitmapMaterial ;
    import sandy.materials.attributes.LineAttributes;
    import sandy.materials.attributes.MaterialAttributes;
    import sandy.math.VectorMath;
    import sandy.primitive.Line3D;
    import sandy.primitive.Sphere ;
    import sandy.util.NumberUtil;


    public class InteractionDemo extends Sprite
    {
        private var m_oScene:World3D;
        private var m_oPlane:Shape3D;
        private var m_oScroll:Shape3D;

        private var keyPressed:Array = new Array();
        private var m_oLine3D:Line3D;
       
        private var texture:MovieClip;
        private var textureScroll:MovieClip;
        private var info:TextField = new TextField();
        private var lTg:TransformGroup = new TransformGroup("rotation");
        private var btn_test : MovieClip;
		
        public function InteractionDemo()
        {
            super();
			init();
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
            lCamera.y = 0;
            lCamera.lookAt( 0, 0, 0 );
            m_oScene.root = _createScene3D();
            m_oScene.root.addChild( lCamera );
           
            info.multiline = true;
            info.width = 300;
            this.addChild( info );
           
            // --
            this.stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
            this.stage.addEventListener (KeyboardEvent.KEY_UP, __onKeyUp);
            addEventListener( Event.ENTER_FRAME, enterFrameHandler );
        }
   
        public function __onKeyDown(e:KeyboardEvent):void
        {
            keyPressed[ e.keyCode]=true;
        }

        public function __onKeyUp(e:KeyboardEvent):void
        {
           keyPressed[e.keyCode]=false;
        }
 
 
		private function createTexture():void
		{
			texture = new Texture();
			textureScroll = new TexturePanel();
			
			/*
			btn_test  = texture.getChildByName('btn_test') as MovieClip;
			btn_test.addEventListener( MouseEvent.MOUSE_OVER, _interaction );
			btn_test.addEventListener( MouseEvent.CLICK, _interaction );
			*/
		}
		
		private function _interaction( e : MouseEvent ): void
		{
			;//btn_test.transform.colorTransform = new ColorTransform( Math.random(), Math.random(), Math.random(), 1, Math.abs( Math.random()*255 ), Math.abs( Math.random()*255 ), Math.abs( Math.random()*255 ) );
		}
         
        private function enterFrameHandler( event : Event ) : void
        {
            var cam:Camera3D = m_oScene.camera;
            // --
            if( keyPressed[Keyboard.RIGHT] )
            {  
                m_oScroll.rotateY -= 5;
            }
            if( keyPressed[Keyboard.LEFT] )    
            {
            	m_oScroll.rotateY += 5;
            }       
			if( keyPressed[Keyboard.DOWN] )
            {  
                cam.z -= 5;
            }
            if( keyPressed[Keyboard.UP] )    
            {
            	cam.z += 5;
           	}
            
            m_oScene.render();

        }
           
        private function _createScene3D():Group
        {
            var lG:Group = new Group("rootGroup");

         	m_oScroll = new Plane3D("myPlane", 311, 235, 4, 4, Plane3D.ZX_ALIGNED, PrimitiveMode.TRI );
			m_oScroll.rotateX = 90;
			m_oScroll.rotateZ = 90;

 			m_oScroll.enableBackFaceCulling = false;
            m_oScroll.enableInteractivity = true;
          
            var l_oAttr:MaterialAttributes = new MaterialAttributes();
            m_oScroll.appearance = new Appearance( /*new MovieMaterial( texture, 60, l_oAttr ) ), */new MovieMaterial( textureScroll, 40, l_oAttr ) );

            lTg.addChild( m_oScroll );
            lG.addChild( lTg );

            return lG;
        }
       
    }
}
