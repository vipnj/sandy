package
{

	import caurina.transitions.Tweener;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import sandy.core.World3D;
	import sandy.core.data.*;
	import sandy.core.scenegraph.*;
	import sandy.materials.*;
	import sandy.parser.*;
	import sandy.primitive.Sphere;

	[SWF(width="400", height="400", backgroundColor='#000000', frameRate='60')]

	public class NormalVertexTest extends Sprite
	{
		private var world:World3D;
		private var capsule:Shape3D;
		private var isTweening:Boolean;
		private var tweenBack:Boolean;
		private var currentVertexIndex:int;
		private var vertexBackup:Vertex;
		private var tweeningVertex:Vertex;
		private var stretchAmount:int;
		
		public function NormalVertexTest()
		{
			init();
		}
		
		private function init():void
		{
			// -- set up the 3d world
			world = World3D.getInstance();
			world.container = this;
			world.root = new Group( "rootGroup" );
			world.camera = new Camera3D( 400, 400 );
			world.camera.z = -500;
			world.root.addChild( world.camera );
			// -- amount that a vertex stretches
			stretchAmount = 50;
			initScene();
		}

		
		private function initScene( ):void
		{
			// -- get the collada object from the parser
			capsule = new Sphere("mySphere", 100, 20, 20 );
			// -- disable backface culling to avoid unwanted effects.
			// -- we can afford this because the stuff we do here
			// -- isn't processor-intensive
			capsule.enableBackFaceCulling = false;
			capsule.appearance = new Appearance(
				new WireFrameMaterial( 1, 0xffff00 )
			);
			// -- add the collada object to the world
			world.root.addChild( capsule );
			
			// -- start animating
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			if( !isTweening && !tweenBack )
			{
				isTweening = true;
				Tweener.removeAllTweens();

				// -- pick a random vertex				
				currentVertexIndex = Math.random() * capsule.geometry.aVertex.length;
				tweeningVertex = capsule.geometry.aVertex[ currentVertexIndex ];

				// -- get the vertex normal
				var normal:Vertex = capsule.geometry.aVertexNormals[ currentVertexIndex ];
				// -- backup the vertex so we can go back to its
				// -- original position later on
				vertexBackup = tweeningVertex.clone();

				// -- create the tween
				Tweener.addTween( tweeningVertex, {
					x : tweeningVertex.x + normal.x * stretchAmount,
					y : tweeningVertex.y + normal.y * stretchAmount,
					z : tweeningVertex.z + normal.z * stretchAmount,
					time : 1, 
					transition : "easeOutElastic",
					onComplete : function():void { tweenBack = true; }
				});
			}
			else if( isTweening && tweenBack )
			{
				tweenBack = false;
				Tweener.removeAllTweens();
				
				// -- tween back
				Tweener.addTween( tweeningVertex, {
					x : vertexBackup.x,
					y : vertexBackup.y,
					z : vertexBackup.z,
					time : 1, 
					transition : "easeOutElastic",
					onComplete : function():void { isTweening = false; }
				});
			}			

			// -- render the world
			world.render();
		}
	}
}