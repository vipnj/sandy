package sandy.materials 
{
	import sandy.core.data.Polygon;
	import sandy.materials.Material;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import sandy.core.data.Vertex;
	
	/**
	 * @author thomaspfeiffer
	 */
	public final class ColorMaterial extends Material 
	{
		private var m_nColor:Number;
		private var m_nAlpha:Number;
		// --
		public function ColorMaterial( p_nColor:uint = 0, p_nAlpha:uint = 100, p_oLineAttr:LineAttributes = null )
		{
			super();
			// --
			m_nType = MaterialType.COLOR;
			// --
			m_nColor = p_nColor;
			m_nAlpha = p_nAlpha/100;
			// --
			lineAttributes = p_oLineAttr;
		}
		
		public override function renderPolygon( p_oPolygon:Polygon, p_mcContainer:Sprite ):void 
		{
			const l_points:Array = p_oPolygon.cvertices;
			const l_graphics:Graphics = p_mcContainer.graphics;
			// --
			l_graphics.beginFill( m_nColor, m_nAlpha );
			// --
			if( lineAttributes )
				l_graphics.lineStyle( lineAttributes.thickness, lineAttributes.color, lineAttributes.alpha );
			// --
			l_graphics.moveTo( l_points[0].sx, l_points[0].sy );
			// --
			for each (var l_oVertex:Vertex in l_points )
			{
				l_graphics.lineTo( l_oVertex.sx, l_oVertex.sy );
			}			
			// --
			l_graphics.endFill();
		}

		
		public function get alpha():Number
		{return m_nAlpha;}
		
		public function get color():Number
		{return m_nColor;}
	
		
		public function set alpha(p_nValue:Number):void
		{m_nAlpha = p_nValue; m_bModified = true;}
		
		public function set color(p_nValue:Number):void
		{m_nColor = p_nValue; m_bModified = true;}
	
	}
}