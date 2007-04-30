package sandy.materials 
{
	import sandy.core.data.Polygon;
	import sandy.materials.Material;
	import flash.display.Sprite;
	import flash.display.Shape;

	/**
	 * @author thomaspfeiffer
	 */
	public class ColorMaterial extends Material 
	{
		private var m_nColor:Number;
		private var m_nAlpha:Number;
		// --
		public function ColorMaterial( p_nColor:Number = 0, p_nAlpha:Number = 1.0, p_oLineAttr:LineAttributes = null )
		{
			super();
			m_nColor = p_nColor;
			m_nAlpha = p_nAlpha/100;
			// --
			lineAttributes = p_oLineAttr;
		}
		
		public override function renderPolygon( p_oPolygon:Polygon ):void 
		{
			var sprite:Shape = p_oPolygon.container;
			var l_points:Array = p_oPolygon.cvertices;
			// --
			sprite.graphics.beginFill( m_nColor, m_nAlpha);
			// --
			if( lineAttributes )
				sprite.graphics.lineStyle( lineAttributes.thickness, lineAttributes.color, lineAttributes.alpha );
			// --
			sprite.graphics.moveTo( l_points[0].sx, l_points[0].sy );
			// --
			switch( l_points.length )
			{
				case 1 :
					sprite.graphics.lineTo( l_points[0].sx+1, l_points[0].sy+1 );
					break;
				case 2 :
					sprite.graphics.lineTo( l_points[1].sx, l_points[1].sy );
					break;
				case 3 :
					sprite.graphics.lineTo( l_points[1].sx, l_points[1].sy );
					sprite.graphics.lineTo( l_points[2].sx, l_points[2].sy );
					break;
				case 4 :
					sprite.graphics.lineTo( l_points[1].sx, l_points[1].sy );
					sprite.graphics.lineTo( l_points[2].sx, l_points[2].sy );
					sprite.graphics.lineTo( l_points[3].sx, l_points[3].sy );
					break;
				default :
					var l:Number = l_points.length;
					while( --l > 0 )
					{
						sprite.graphics.lineTo( l_points[(l)].sx, l_points[(l)].sy);
					}
					break;
			}
			// -- we draw the last edge
			if( lineAttributes )
			{
				sprite.graphics.lineTo( l_points[0].sx, l_points[0].sy );
			}
			// --
			sprite.graphics.endFill();
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