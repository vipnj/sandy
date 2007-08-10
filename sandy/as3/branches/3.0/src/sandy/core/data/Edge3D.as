package sandy.core.data
{
	
	
	public final class Edge3D
	{
		/**
		 * [READ-ONLY]
		 * First ID of the vertex which compose the EDGE. The ID correspond to the {@Geometry3D} aVertex list
		 */
		public var vertexId1:uint;
		/**
		 * [READ-ONLY]
		 * Second ID of the vertex which compose the EDGE. The ID correspond to the {@Geometry3D} aVertex list
		 */
		public var vertexId2:uint;

		/**
		 * [READ-ONLY]
		 * First vertex which compose the EDGE. The ID correspond to the {@Geometry3D} aVertex list
		 */
		public var vertex1:Vertex;
		
		/**
		 * [READ-ONLY]
		 * Second vertex which compose the EDGE. The ID correspond to the {@Geometry3D} aVertex list
		 */
		public var vertex2:Vertex;
		
		public function Edge3D( p_nVertexId1:uint, p_nVertexId2:uint )
		{
			vertexId1 = p_nVertexId1;
			vertexId2 = p_nVertexId2;
		}
		
	}
}