/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author or authors.
Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.mozilla.org/MPL/MPL-1.1.html
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# ***** END LICENSE BLOCK *****
*/


	
import sandy.bounds.BSphere;
import sandy.core.data.Matrix4;
import sandy.core.data.Vertex;
import sandy.core.face.Polygon;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.view.CullingState;
import sandy.view.Frustum;

/**
 * @author		Thomas Pfeiffer - kiroukou
 * @version		1.0
 * @date 		20.05.2006
 **/
class sandy.core.scenegraph.Sprite2D extends Shape3D 
{
	/**
	* Sprite2D constructor.
	* A sprite is a special Object3D because it's in fact a bitmap in a 3D space.
	* The sprite is an element which always look at the camera, you'll always see the same face.
	* @param	void
	*/
	public function Sprite2D( p_name:String, pScale:Number) 
	{
		super(p_name);
		// -- we create a fictive point
		geometry = new Geometry3D();
		geometry.setVertex(0, 0, 0, 0);
		_v = geometry.aVertex[0];
		aPolygons.push( new Polygon(this, geometry, [0] ) );
		// --
		_oBSphere 	= new BSphere();
        _oBBox 		= null;
        setBoundingSphereRadius( 10 );
        // --
		_nScale = (pScale == null ) ? 1 : pScale;
	}

	public function setBoundingSphereRadius( p_nRadius:Number ):Void
	{ _oBSphere.radius = p_nRadius; }

	/**
	* getScale
	* <p>Allows you to get the scale of the Sprite3D and later change it with setSCale.
	* It is a number usefull to change the dimension of the sprite rapidly.
	* </p>
	* @param	void
	* @return Number the scale value.
	*/
	public function get scale():Number
	{ return _nScale; }

	/**
	* Allows you to change the oject's scale.
	* @param	n Number 	The scale. This value must be a Number. A value of 1 let the scale as the perspective one.
	* 						A value of 2.0 will make the object twice bigger. 0 is a forbidden value
	*/
	public function set scale( n:Number )
	{if( n )	_nScale = n; }

 	/**
	 * This method goal is to update the node. For node's with transformation, this method shall
	 * update the transformation taking into account the matrix cache system.
	 * FIXME: Transformable nodes shall upate their transform if necessary before calling this method.
	 */
	public function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):Void
	{
		// -- we call the super update mthod
		super.update( p_oModelMatrix, p_bChanged );
	}
	  
	/**
	 * This method test the current node on the frustum to get its visibility.
	 * If the node and its children aren't in the frustum, the node is set to cull
	 * and it would not be displayed.
	 * This method is also updating the bounding volumes to process the more accurate culling system possible.
	 * First the bounding sphere are updated, and if intersecting, the bounding box are updated to perform a more
	 * precise culling.
	 * [MANDATORY] The update method must be called first!
	 */
	public function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):Void
	{
		super.cull(p_oFrustum, p_oViewMatrix, p_bChanged );
		// --
		if( culled == CullingState.OUTSIDE ) 	aPolygons[0].container._visible = false;
		else									aPolygons[0].container._visible = true;
	}
	
    public function render( p_oCamera:Camera3D ):Void
	{
        // Now we consider the camera .Fixme consider the possible cache system for camera.
        var l_oMatrix:Matrix4 = _oViewCacheMatrix;
        // --
        var v:Vertex = _v;
        var i:Number;
        v.wx = v.x * l_oMatrix.n11 + v.y * l_oMatrix.n12 + v.z * l_oMatrix.n13 + l_oMatrix.n14;
		v.wy = v.x * l_oMatrix.n21 + v.y * l_oMatrix.n22 + v.z * l_oMatrix.n23 + l_oMatrix.n24;
		v.wz = v.x * l_oMatrix.n31 + v.y * l_oMatrix.n32 + v.z * l_oMatrix.n33 + l_oMatrix.n34;
        // --
		aPolygons[0].container.swapDepths( 10000000 - int(1000*v.wz) );
		// -- we override the value to realize the scaled effect
		v.wz /= _nScale;
		// --
		p_oCamera.addToDisplayList( aPolygons[0] );
		// --
		p_oCamera.pushVerticesToRender( geometry.aVertex );
	}
	// --
	
	private var _v:Vertex;
	private var _nScale:Number;
}
