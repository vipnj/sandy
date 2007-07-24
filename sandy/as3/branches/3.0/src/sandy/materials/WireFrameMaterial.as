package sandy.materials
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import sandy.core.data.Polygon;
	
	public final class WireFrameMaterial extends Material
	{
		public function WireFrameMaterial( p_nThickness:uint=1, p_nColor:uint = 0, p_nAlpha:uint = 100 )
		{
			super();
			// --
			m_nType = MaterialType.WIREFRAME;
			// --
			lineAttributes = new LineAttributes( p_nThickness, p_nColor,p_nAlpha ) ;
		}

		public override function renderPolygon( p_oPolygon:Polygon, p_mcContainer:Sprite ):void 
		{
			const l_points:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;
			var l_graphics:Graphics = p_mcContainer.graphics;
			// --
			l_graphics.lineStyle( lineAttributes.thickness, lineAttributes.color, lineAttributes.alpha );
			// --
			l_graphics.moveTo( l_points[0].sx, l_points[0].sy );
			// --
			for each (var l_oVertex:Vertex in l_points )
			{
				l_graphics.lineTo( l_oVertex.sx, l_oVertex.sy );
			}
		}

	}
}