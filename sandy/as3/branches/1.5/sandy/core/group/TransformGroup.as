///////////////////////////////////////////////////////////
//  TransformGroup.as
//  Macromedia ActionScript Implementation of the Class TransformGroup
//  Generated by Enterprise Architect
//  Created on:      26-VII-2006 13:46:10
//  Original author: Thomas Pfeiffer - kiroukou
///////////////////////////////////////////////////////////
package sandy.core.group
{
	import sandy.core.group.Node;
	import sandy.core.group.INode;
	import sandy.core.buffer.MatrixBuffer;
	import sandy.core.transform.ITransform3D;
	import sandy.core.data.Matrix4;
	/**
	 * @author 	Thomas Pfeiffer - kiroukou
	 * @version 1.0
	 * @date 	05.08.2006
	 * @created 26-VII-2006 13:46:10
	 */
	public class TransformGroup extends Node implements INode
	{
		/**
		 * Get the current TransformGroup transformation. This allows to manipulate the node transformation.
		 * @return	The transformation 
		 */
		public function getTransform():ITransform3D
		{
			return _t;
		}
		
	    /**
	     * Allows you to know if this node has been modified (true value) or not (false
	     * value). Mainly usefull for the cache system. After this method call the
	     * property hasn't changed it's value. It remains the current returned value.
	     * @return	Boolean Value specifying the statut of the node. A true value means the
	     * node has been modified, it it should be rendered again
	     * 
	     * @param Void
	     */
	    public override function isModified():Boolean
	    {
	    	if( _t != null )
	    		return _modified || _t.isModified();
	    	else
	    		return _modified;
	    }

	    /**
	     * Render the actual node. Object3D's node are rendered, TransformGroup concat
	     * (multiply) their matrix to update the 3D transformations view.
	     * 
	     * @param Void
	     */
	    public function render():void
	    {
	    	if( _t != null )
			{
				var m:Matrix4 = _t.getMatrix();
				if( m != null )
				{
					MatrixBuffer.push( m );
				}
			}
	    }

		/**
		 * Dispose the actual node. Object3D's node are rendered, TransformGroup concat (multiply) their matrix to
		 * update the 3D transformations view.
		 */
		public function dispose():void
		{
			if( _t != null)
			{
				var m:Matrix4 = _t.getMatrix();
				if( m != null )
					MatrixBuffer.pop();
			}
		}
	
	    /**
	     * Add a transformation to the current TransformGroup. This allows to apply a
	     * transformation to all the childs of the Node.
	     * @param t    The transformation to add
	     */
	    public function setTransform( t:ITransform3D ):void
	    {
	    	_t = t;
			setModified( true );
	    }
	    
	    /**
	    * Set the modification to the node and is associated transformation
	    */
		public override function setModified( b:Boolean ):void
		{
			super.setModified( b );
			if( _t != null ) _t.setModified( b );
		}
		
	    /**
	     * Get a String represntation of the {@code TransformGroup}.
	     * @return	A String representing the {@code TransformGroup}.
	     * @param Void
	     */
	    public override function toString():String
	    {
	    	return "sandy.core.group.TransformGroup";
	    }

	    /**
	     * Create a new TransformGroup. This class is one of the most important because it
	     * represents a node in the tree scene representation in Sandy. It has a matrix
	     * which is in fact its Transform3D property matrix.
	     * @param [OPTIONNAL] transform Transform3D The transformation to apply to this
	     * transformGroup
	     * @param transform
	     */
	    public function TransformGroup( transform:ITransform3D=null )
	    {
	    	super();
			_t = transform;
	    }

	    private var _t:ITransform3D; // The transformation of this TransformGroup
	}//end TransformGroup
}