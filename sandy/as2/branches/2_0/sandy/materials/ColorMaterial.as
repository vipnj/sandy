import flash.display.BitmapData;

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
		// -- OVERRIDE
		m_bRepeat = true;
		// -- Creation of the texture
		texture = new BitmapData( 1, 1, Boolean(m_nAlpha<100), m_nAlpha << 24 | m_nColor );
	}
	
	public function get alpha():Number
	{return m_nAlpha;}
	
	public function get color():Number
	{return m_nColor;}

	
	public function set alpha(p_nValue:Number)
	{m_nAlpha = p_nValue; m_bModified = true;}
	
	public function set color(p_nValue:Number)
	{m_nColor = p_nValue; m_bModified = true;}

	public function update():Void
	{
		m_oTexture.dispose();
		m_oTexture = new BitmapData( 1, 1, Boolean(m_nAlpha<100), m_nAlpha << 24 | m_nColor );
	}
}