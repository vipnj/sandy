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
			var l_points:Array = p_oPolygon.vertices;
			var l_graphics:Graphics = p_mcContainer.graphics;
			// --
			l_graphics.lineStyle( lineAttributes.thickness, lineAttributes.color, lineAttributes.alpha );
			// --
			l_graphics.moveTo( l_points[0].sx, l_points[0].sy );
			// --
			switch( l_points.length )
			{
				case 1 :
					l_graphics.lineTo( l_points[0].sx+1, l_points[0].sy+1 );
					break;
				case 2 :
					l_graphics.lineTo( l_points[1].sx, l_points[1].sy );
					break;
				case 3 :
					l_graphics.lineTo( l_points[1].sx, l_points[1].sy );
					l_graphics.lineTo( l_points[2].sx, l_points[2].sy );
					break;
				case 4 :
					l_graphics.lineTo( l_points[1].sx, l_points[1].sy );
					l_graphics.lineTo( l_points[2].sx, l_points[2].sy );
					l_graphics.lineTo( l_points[3].sx, l_points[3].sy );
					break;
				default :
					var l:int = l_points.length;
					while( --l > 0 )
					{
						l_graphics.lineTo( l_points[int(l)].sx, l_points[int(l)].sy);
					}
					break;
			}

			l_graphics.lineTo( l_points[0].sx, l_points[0].sy );
		}

	}
}