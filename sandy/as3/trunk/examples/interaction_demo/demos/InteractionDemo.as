package demos
{
	import fl.controls.UIScrollBar;
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
			( textureScroll.getChildByName('scrollbar') as UIScrollBar ).drawNow();
		//	this.addChild( textureScroll );
			btn_test  = texture.getChildByName('btn_test') as MovieClip;
			btn_test.addEventListener( MouseEvent.MOUSE_OVER, _interaction );
			btn_test.addEventListener( MouseEvent.CLICK, _interaction );
		}
		
		private function _interaction( e : MouseEvent ): void
		{
			btn_test.transform.colorTransform = new ColorTransform( Math.random(), Math.random(), Math.random(), 1, Math.abs( Math.random()*255 ), Math.abs( Math.random()*255 ), Math.abs( Math.random()*255 ) );
		}
         
        private function enterFrameHandler( event : Event ) : void
        {
            var cam:Camera3D = m_oScene.camera;
            // --
            if( keyPressed[Keyboard.RIGHT] )
            {  
                m_oPlane.rotateY -= 5;
                m_oScroll.rotateY -= 5;
            }
            if( keyPressed[Keyboard.LEFT] )    
            {
                m_oPlane.rotateY += 5;
                m_oScroll.rotateY += 5;
            }       
            if( keyPressed[Keyboard.UP] )
            {
                cam.moveHorizontally( 10 );
            }
            if( keyPressed[Keyboard.DOWN] )
            {
                cam.moveHorizontally( -10 );
            }
			
			if( keyPressed[Keyboard.NUMPAD_8] )
			{
				cam.moveVertically( 10 );
			}
			if( keyPressed[Keyboard.NUMPAD_2])
			{
				cam.moveVertically( -10 );
			}
			
			//m_oPlane.rotateY += 1;
            //lTg.rotateY ++;
            m_oScene.render();

        }
           
        private function _createScene3D():Group
        {
            var lG:Group = new Group("rootGroup");
            // --
            //m_oLine3D = new Line3D("normale", new Vector(), new Vector(0, 50, 0) );
           
            m_oPlane = new Sphere("sphere", 150);//new Plane3D("myPlane", 300, 300, 2, 2, Plane3D.ZX_ALIGNED, PrimitiveMode.TRI );
			m_oScroll = new Plane3D("myPlane", 311, 235, 4, 4, Plane3D.ZX_ALIGNED, PrimitiveMode.TRI );
		//	m_oScroll.rotateY = 90;
			m_oScroll.rotateX = 90;
			m_oScroll.rotateZ = 90;
            m_oPlane.useSingleContainer = false;
            m_oScroll.useSingleContainer = false;
            
            m_oPlane.enableInteractivity = true;
            m_oScroll.enableInteractivity = true;
           // m_oPlane.enableEvents( true, m_oScene, EnableEventList.TEXTURE, [MouseEvent.MOUSE_OVER, MouseEvent.CLICK]);
           // m_oScroll.enableEvents( true, m_oScene, EnableEventList.TEXTURE, [MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_UP,MouseEvent.ROLL_OVER, MouseEvent.ROLL_OUT, MouseEvent.CLICK]);
          /*  //m_oPlane.addEventListener( MouseEvent.CLICK, onClick );
            //m_oPlane.addEventListener( MouseEvent.DOUBLE_CLICK, onClick );
            m_oPlane.addEventListener( MouseEvent.MOUSE_UP, onClick );
            //m_oPlane.addEventListener( MouseEvent.MOUSE_MOVE, onClick );*/
            m_oPlane.enableForcedDepth = true;
            m_oScroll.enableForcedDepth = true;
            m_oPlane.forcedDepth = 999999999999;
            m_oScroll.forcedDepth = 999999999998;
           
		//	TODO Check here
		//	BUG
		//	ENHANCE
            var l_oAttr:MaterialAttributes = new MaterialAttributes();
            m_oPlane.appearance = new Appearance( new MovieMaterial( texture, 40, l_oAttr ) );
            m_oPlane.enableNearClipping = true;
			m_oScroll.appearance = new Appearance( new MovieMaterial( textureScroll, 40, l_oAttr ) );
            m_oScroll.enableNearClipping = true;
            m_oScroll.enableBackFaceCulling = false;
           
			
			m_oPlane.setPosition( 0, 300, 0 );
            lTg.addChild( m_oPlane );
            lTg.addChild( m_oScroll );
            lG.addChild( lTg );

            return lG;
        }
       

        /*private function onClick( p_eEvent:BubbleEvent ):void
        {
			VirtualMouse.getInstance().interact( m_oScene, p_eEvent );
        }  */
    }
}
