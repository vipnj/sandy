
import flash.display.BitmapData;

import sandy.core.face.Polygon;
import sandy.materials.ColorMaterial;
import sandy.materials.LineAttributes;
import sandy.materials.Material;
/**
 * @author thomaspfeiffer
 */
class sandy.materials.Appearance 
{
	public function Appearance( p_oFront:Material, p_oBack:Material )
	{
		m_oFrontMaterial = 	(p_oFront) 	? p_oFront	:	new ColorMaterial();
		m_oBackMaterial  = 	(p_oBack) 	? p_oBack	:	p_oFront;
	}
	
	public function get needNormals():Boolean
	{ return m_oBackMaterial.needNormals && m_oFrontMaterial.needNormals; }

	
	public function get material():Material
	{
		return (oRef.visible) ? m_oFrontMaterial : m_oBackMaterial;
	}
	
	public function get lineAttributes():LineAttributes
	{
		return (oRef.visible) ? LineAttributes(m_oFrontMaterial.lineAttributes) : LineAttributes(m_oBackMaterial.lineAttributes);
	}
	
	public function get modified():Boolean
	{ return Boolean(m_oBackMaterial.modified && m_oFrontMaterial.modified); }
	
	public function set frontMaterial( p_oMat:Material )
	{
		m_oFrontMaterial = p_oMat;
		if( m_oBackMaterial == null ) m_oBackMaterial = p_oMat;
	}
	
	public function set backMaterial( p_oMat:Material )
	{
		m_oBackMaterial = p_oMat;
		if( m_oFrontMaterial == null ) m_oFrontMaterial = p_oMat;
	}
	
	public function get frontMaterial():Material
	{
		return m_oFrontMaterial;
	}
	
	public function get backMaterial():Material
	{
		return m_oBackMaterial;
	}
	
	public function toString():String
	{
		return "sandy.materials.Appearance";
	}
	// --
	public var oRef:Polygon;
	// --
	private var m_oFrontMaterial:Material;
	private var m_oBackMaterial:Material;
}