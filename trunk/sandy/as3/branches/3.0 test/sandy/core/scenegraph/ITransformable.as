/**
 * @author thomaspfeiffer
 */
package sandy.core.scenegraph {
	public interface ITransformable 
	{
		/**
		 * This method shall be called to update the transform matrix of the current object/node
		 * before being rendered.
		 */
		function updateTransform():void;
		
	}
}