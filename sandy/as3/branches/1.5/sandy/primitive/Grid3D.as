package sandy.primitive
{
	import sandy.core.data.bvh.MotionData;
	import sandy.core.group.TransformGroup;
	import sandy.skin.Skin;
	import sandy.skin.SimpleLineSkin;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.math.VectorMath;
	import sandy.math.VertexMath;
	import sandy.core.Object3D;
	
	public class Grid3D extends Object3D
	{
		public var mainAxesColor:uint = 0xAA0000;
		public var subAxesColor:uint = 0xAAAAAA;
		public var mainAxesAlpha:Number = 1;
		public var subAxesAlpha:Number = 1;
		public var position:Vector;
		public var size:Vector;
		public var grid:Vector;
		
		public function Grid3D(tg:TransformGroup, pos:Vector, sz:Vector, grd:Vector)
		{
			position = pos;
			size = sz;
			grid = grd;
			generate(tg);
		}
		

		/**
		* generate
		* 
		* <p>Generate all is needed to construct the Object3D : </p>
		* <ul>
		* 	<li>{@link Vertex}</li>
		* 	<li>{@link UVCoords}</li>
		* 	<li>{@link TriFace3D}</li>
		* </ul>
		* <p>It can construct dynamically the object, taking care of your preferences given in arguments. <br/>
		*    Note in Sandy 0.1 all faces have only three points.
		*    This will change in the future version, 
		*    and give to you the possibility to choose n points per faces</p> 
		*/
		public function generate (tg:TransformGroup):void
		{
			var pos:Vertex = position.toVertex();
			var sz:Vertex = size.toVertex();
			
			var mainAxesSkin:SimpleLineSkin = new SimpleLineSkin( 3, mainAxesColor, mainAxesAlpha );
			var subAxesSkin:SimpleLineSkin = new SimpleLineSkin( 1, subAxesColor, subAxesAlpha );
			//main axes	
			var axisX:Line3D = new Line3D( new Array ( pos, new Vertex (position.x + size.x, position.y, position.z )  ) );
			var axisY:Line3D = new Line3D( new Array ( pos, new Vertex (position.x, position.y + size.y, position.z )  ) );
			var axisZ:Line3D = new Line3D( new Array ( pos, new Vertex (position.x, position.y, position.z + size.z )  ) );
				
			axisX.setSkin(mainAxesSkin);
			axisY.setSkin(mainAxesSkin);
			axisZ.setSkin(mainAxesSkin);
			
			tg.addChild( axisX );
			tg.addChild( axisY );
			tg.addChild( axisZ );
			
			var toVal:Number = position.x + size.x
			var stepVal:Number = grid.x;
			
			for (i = position.x; i <= toVal; i += stepVal)
			{
				var fromV:Vertex = new Vertex (i, position.y, position.z);
				var toV:Vertex = new Vertex (i, position.y, position.z + size.z);
				
				var subAxis:Line3D = new Line3D( new Array ( fromV , toV  ) );
				subAxis.setSkin(subAxesSkin);
				tg.addChild( subAxis );
				
				toV = new Vertex (i, position.y + size.y, position.z);
				
				subAxis = new Line3D( new Array ( fromV , toV  ) );
				subAxis.setSkin(subAxesSkin);
				tg.addChild( subAxis );
				
			}
			
			toVal = position.y + size.y
			stepVal = grid.y;
			
			for (i = position.y; i <= toVal; i += stepVal)
			{
				fromV = new Vertex (position.x, i, position.z);
				toV = new Vertex (position.x, i, position.z + size.z);
				
				subAxis = new Line3D( new Array ( fromV , toV  ) );
				subAxis.setSkin(subAxesSkin);
				tg.addChild( subAxis );
				
				toV = new Vertex (position.x+ size.x, i, position.z);
				
				subAxis = new Line3D( new Array ( fromV , toV  ) );
				subAxis.setSkin(subAxesSkin);
				tg.addChild( subAxis );
			}
			
			toVal = position.z + size.z
			stepVal = grid.z;
			
			for (var i:int = position.z; i <= toVal; i += stepVal)
			{
				fromV = new Vertex (position.x, position.y, i);
				toV = new Vertex (position.x, position.y + size.y, i);
				
				subAxis = new Line3D( new Array ( fromV , toV  ) );
				subAxis.setSkin(subAxesSkin);
				tg.addChild( subAxis );
				
				toV = new Vertex (position.x + size.x, position.y, i);
				
				subAxis = new Line3D( new Array ( fromV , toV  ) );
				subAxis.setSkin(subAxesSkin);
				tg.addChild( subAxis );
			}
		}
		
		
	}
}