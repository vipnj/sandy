
package sandy.core.scenegraph;

import sandy.core.data.Matrix4;
import sandy.view.CullingState;
import sandy.view.Frustum;

import sandy.HaxeTypes;

/**
* The TransformGroup class is used to create transform group.
*
* <p>It represents a node in the object tree of the world.<br/>
* Transformations performed on this group are applied to all its children.</p>
* <p>The class is final, i.e. it can not be subclassed.
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		26.07.2007
*/
class TransformGroup extends ATransformable
{

	/**
	 * Creates a transform group.
	 *
	 * @param  p_sName	A string identifier for this object
	 */
	public function new( ?p_sName:String = "")
	{
		super( p_sName );
	}


	/**
	* Tests this node against the camera frustum to get its visibility.
	*
	* <p>If this node and its children are not within the frustum,
	* the node is set to cull and it would not be displayed.<p/>
	* <p>The method also updates the bounding volumes to make the more accurate culling system possible.<br/>
	* First the bounding sphere is updated, and if intersecting,
	* the bounding box is updated to perform the more precise culling.</p>
	* <p><b>[MANDATORY] The update method must be called first!</b></p>
	*
	* @param p_oScene The current scene
	* @param p_oFrustum	The frustum of the current camera
	* @param p_oViewMatrix	The view martix of the curren camera
	* @param p_bChanged
	*/
	public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Bool ):Void
	{
		// TODO
		// Parse the children, take their bounding volume and merge it with the current node recurssively.
		// After that call the super cull method to get the correct cull value.
		if( visible == false )
		{
			culled = CullingState.OUTSIDE;
		}
		else
		{
		    var lChanged:Bool = p_bChanged || changed;
		    for ( l_oNode in children )
		        l_oNode.cull( p_oFrustum, p_oViewMatrix, lChanged );
		}
	}

	public function clone( p_sName:String ):TransformGroup
	{
		var l_oGroup:TransformGroup = new TransformGroup( p_sName );

		for ( l_oNode in children )
		{
			if( Std.is(l_oNode,Shape3D) || Std.is(l_oNode,Group) || Std.is(l_oNode,TransformGroup) )
		    {
				l_oGroup.addChild( untyped l_oNode.clone( p_sName+"_"+l_oNode.name ) );
		    }
		}

		return l_oGroup;
	}

	/**
	 * Returns a string representation of the TransformGroup.
	 *
	 * @return	The fully qualified name.
	 */
	public override function toString():String
	{
		return "sandy.core.scenegraph.TransformGroup :["+name+"]";
	}
}

