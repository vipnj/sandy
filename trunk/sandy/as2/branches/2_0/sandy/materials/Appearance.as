
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
		
	public function get texture():BitmapData
	{
		return (oRef.visible) ? BitmapData(m_oFrontMaterial.texture) : BitmapData(m_oBackMaterial.texture);
	}
	
	public function get material():Material
	{
		return (oRef.visible) ? Material(m_oFrontMaterial) : Material(m_oBackMaterial);
	}
	
	public function get lineAttributes():LineAttributes
	{
		return (oRef.visible) ? LineAttributes(m_oFrontMaterial.lineAttributes) : LineAttributes(m_oBackMaterial.lineAttributes);
	}
	
	public function get lineThickness():Number
	{
		return (oRef.visible) ? Number(m_oFrontMaterial.lineAttributes.thickness) : Number(m_oBackMaterial.lineAttributes.thickness);
	}
	
	public function get lineAlpha():Number
	{
		return (oRef.visible) ? Number(m_oFrontMaterial.lineAttributes.alpha) : Number(m_oBackMaterial.lineAttributes.alpha);
	}
	
	public function get lineColor():Number
	{
		return (oRef.visible) ? Number(m_oFrontMaterial.lineAttributes.color) : Number(m_oBackMaterial.lineAttributes.color);
	}
	
	public function get filters():Array
	{
		return (oRef.visible) ? Array(m_oFrontMaterial.filters) : Array(m_oBackMaterial.filters);
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
	public var bRepeat:Boolean;
	public var bSmooth:Boolean;
	// --
	private var m_oFrontMaterial:Material;
	private var m_oBackMaterial:Material;
	// --
	private var m_oLineAttributes:LineAttributes;
	// --
}