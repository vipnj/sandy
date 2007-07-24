package sandy.materials 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import sandy.core.World3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.light.Light3D;
	import sandy.math.VectorMath;
	import sandy.util.NumberUtil;
	
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
			const l_points:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;
			if( !l_points.length ) return;
			const l_graphics:Graphics = p_mcContainer.graphics;
			var l_nCol:uint = m_nColor;
			if( _useLight )
			{
				var l:Light3D 	= World3D.getInstance().light;
				var vn:Vector 	= p_oPolygon.normal.getVector();
				var vl:Vector 	= l.getDirectionVector()
				var lp:Number	= l.getPower()/100;
				// --
				var r:Number = ( l_nCol >> 16 )& 0xFF;
				var g:Number = ( l_nCol >> 8 ) & 0xFF;
				var b:Number = ( l_nCol ) 	   & 0xFF;
				// --
				var dot:Number =  - ( VectorMath.dot( vl, vn ) );
				r = NumberUtil.constrain( r*(dot+lp), 0, 255 );
				g = NumberUtil.constrain( g*(dot+lp), 0, 255 );
				b = NumberUtil.constrain( b*(dot+lp), 0, 255 );
				// --
				l_nCol =  r << 16 | g << 8 |  b;
			}
			// --
			l_graphics.beginFill( l_nCol, m_nAlpha );
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