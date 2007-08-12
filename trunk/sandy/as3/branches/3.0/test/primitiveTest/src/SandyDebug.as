package {
    import flash.display.Sprite;
    import flash.events.Event;
    
    import sandy.core.World3D;
    import sandy.core.scenegraph.Camera3D;
    import sandy.core.scenegraph.Group ;
    import sandy.core.scenegraph.TransformGroup;
    import sandy.materials.Appearance;
    import sandy.materials.WireFrameMaterial;
    import sandy.primitive.Sphere;

    [SWF(width="600", height="600", backgroundColor="#eeeeee", frameRate="60")] 

    public class SandyDebug extends Sprite
    {
        private var world:World3D;
        private var tg:TransformGroup;
        private var sphere:Sphere;
        
        public function SandyDebug() 
        {
            world = World3D.getInstance();
            world.container = this;
            world.root = new Group( "rootGroup" );
            world.camera = new Camera3D( 600, 600 );
            world.camera.x = 670;
            world.camera.y = 410;
            world.camera.z = 820;
            world.camera.lookAt(0,0,0);
            world.root.addChild( world.camera );
            tg = new TransformGroup("tg"); 
            world.root.addChild(tg);
            
            sphere = new Sphere("sphere", 100, 12, 12 );
            sphere.appearance = new Appearance( 
                new WireFrameMaterial( 1, 0x0000ff ) 
            );
           sphere.scaleX = sphere.scaleY = sphere.scaleZ = 2;
            tg.addChild(sphere);

            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        
        private function enterFrameHandler(event:Event):void
        {
            sphere.rotateY++;
            world.render();
        }
    }
}