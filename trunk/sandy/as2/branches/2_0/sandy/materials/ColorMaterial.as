import sandy.core.face.Polygon;
import sandy.materials.Material;
/**
 * @author thomaspfeiffer
 */
class sandy.materials.ColorMaterial extends Material 
{
	private var m_nColor:Number;
	private var m_nAlpha:Number;
	// --
	public function ColorMaterial( p_nColor:Number, p_nAlpha:Number )
	{
		super();
		m_nColor = p_nColor;
		m_nAlpha = p_nAlpha;
	}
	
	function renderPolygon( p_oPolygon:Polygon ):Void 
	{
		var mc:MovieClip = p_oPolygon.container;
		var l_points:Array = p_oPolygon.cvertices;
		// --
		mc.beginFill( m_nColor, m_nAlpha );
		// --
		if( lineAttributes )
			mc.lineStyle( lineAttributes.thickness, lineAttributes.color, lineAttributes.alpha );
		// --
		mc.moveTo( l_points[0].sx, l_points[0].sy );
		// --
		switch( l_points.length )
		{
			case 2 :
				mc.lineTo( l_points[1].sx, l_points[1].sy );
				break;
			case 3 :
				mc.lineTo( l_points[1].sx, l_points[1].sy );
				mc.lineTo( l_points[2].sx, l_points[2].sy );
				break;
			case 4 :
				mc.lineTo( l_points[1].sx, l_points[1].sy );
				mc.lineTo( l_points[2].sx, l_points[2].sy );
				mc.lineTo( l_points[3].sx, l_points[3].sy );
				break;
			default :
				var l:Number = l_points.length;
				while( --l > 0 )
				{
					mc.lineTo( l_points[(l)].sx, l_points[(l)].sy);
				}
				break;
		}
		// -- we draw the last edge
		if( lineAttributes )
		{
			mc.lineTo( l_points[0].sx, l_points[0].sy );
		}
		// --
		mc.endFill();
	}
	public function get alpha():Number
	{return m_nAlpha;}
	
	public function get color():Number
	{return m_nColor;}

	
	public function set alpha(p_nValue:Number)
	{m_nAlpha = p_nValue; m_bModified = true;}
	
	public function set color(p_nValue:Number)
	{m_nColor = p_nValue; m_bModified = true;}

}