/**
 * @author thomaspfeiffer
 */
interface sandy.core.scenegraph.ITransformable 
{
	/**
	 * This method shall be called to update the transform matrix of the current object/node
	 * before being rendered.
	 */
	function updateTransform(Void):Void;
	
}