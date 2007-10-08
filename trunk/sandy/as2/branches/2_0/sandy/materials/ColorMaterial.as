import com.bourre.log.Logger;

import sandy.core.face.Polygon;
import sandy.materials.LineAttributes;
import sandy.materials.Material;
import sandy.materials.MaterialType;

/**
 * @author thomaspfeiffer
 */
class sandy.materials.ColorMaterial extends Material 
{
	private var m_nColor:Number;
	private var m_nAlpha:Number;
	// --
	public function ColorMaterial( p_nColor:Number, p_nAlpha:Number, p_oLineAttr:LineAttributes )
	{
		super();
		m_nColor = p_nColor || 0xFF0000;
		m_nAlpha = p_nAlpha || 100;
		lineAttributes = p_oLineAttr;
	}
	
	function renderPolygon( p_oPolygon:Polygon, p_mcContainer:MovieClip ):Void 
	{
		super.renderPolygon( p_oPolygon, p_mcContainer );
		//
		var mc:MovieClip = p_mcContainer;
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
			case 1 :
				mc.lineTo( l_points[0].sx+1, l_points[0].sy+1 );
				break;
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
	
	/**
	 * getType, returns the type of the Material
	 * @param Void
	 * @return	The appropriate MaterialType
	 */
	 public function get type ():MaterialType
	 { return MaterialType.COLOR; } 
	
	
	/**
	* Returns the name of the Material you are using.
	* @param	Void
	* @return String representing your Material.
	*/
	public function getName( Void ):String
	{
		return "COLOR"; 
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