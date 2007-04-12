import sandy.core.face.Polygon;
import sandy.materials.Appearance;

/**
 * @author thomaspfeiffer
 */
interface sandy.core.renderer.IRenderer 
{
	function init():Void;
	function clear():Void;
	function addToDisplayList( p_oPolygon:Polygon, p_nDepth:Number ):Void;
	function getDisplayListLength(Void):Number;
	function render():Void;
	function renderPolygon( p_oPolygon:Polygon, p_oAppearance:Appearance, p_mcContainer:MovieClip ):Void;
}