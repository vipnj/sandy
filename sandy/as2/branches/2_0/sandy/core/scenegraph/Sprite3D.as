		
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
	
import com.bourre.log.Logger;

import sandy.bounds.BSphere;
import sandy.core.data.Matrix4;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.scenegraph.ATransformable;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.IDisplayable;
import sandy.math.VectorMath;
import sandy.util.NumberUtil;
import sandy.view.CullingState;
import sandy.view.Frustum;

/**
 * @author		Thomas Pfeiffer - kiroukou
 * @version		1.0
 * @date 		20.05.2006
 **/
class sandy.core.scenegraph.Sprite3D extends ATransformable implements IDisplayable
{	
	// [ReAd-ONLY]
	public var depth:Number;
	/**
	* A Sprite3D is in fact a special Sprite2D. A Sprite3D is batween a real Object3D and a Sprite2D.
	* It has a skin which is a movie clip containing 360 frames (at least!). 
	* Depending on the camera position, the _currentframe of the Clip3D will change, to give a 3D effect.
	* @param	pOffset Number 	A number between [0-360] to give an offset in the 3D representation.
	* @param 	pScale Number 	A number used to change the scale of the displayed object. In case that the object projected dimension
	* 							isn't adapted to your needs. Default value is 1.0 which means unchanged. A value of 2.0 will make the object
	* 							twice bigger and so on.
	*/
	// FIXME Create a Sprite as the spriteD container, and offer a method to attach a visual content as a child of the sprite
	public function Sprite3D( p_name:String, p_oContent:MovieClip, p_opScale:Number, pOffset:Number) 
	{
		super(p_name);
		m_oContainer = p_oContent;
		//World3D.getInstance().container.addChild( m_oContainer );
		// --
		_v = new Vertex();
		_oBSphere 	= new BSphere();
        _oBBox 		= null;
        setBoundingSphereRadius( 30 );
        // --
		_nScale = p_opScale || 1;
		// --
		content = p_oContent;
		// --
		_dir = new Vertex( 0, 0, -1 );
		_vView = new Vector( 0, 0, 1 );
		// -- set the offset
		_nOffset = (pOffset == undefined )? 0 : pOffset;
	}


	public function set content( p_container:MovieClip )
	{
		m_oContainer = m_oContainer;
		m_oContainer.stop();
		m_nW2 = m_oContainer._width / 2;
		m_nH2 = m_oContainer._height / 2;
	}
	
	public function get content():MovieClip
	{
		return m_oContainer;
	}
	
	public function get container():MovieClip
	{return m_oContainer;}
	
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
	public function set scale( n:Number ):Void
	{if( n )	_nScale = n; }
	  
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
		if( culled == CullingState.OUTSIDE ) 	container._visible = false;
		else									container._visible = true;
	}
	
    public function render( p_oCamera:Camera3D ):Void
	{
       var 	l_oMatrix:Matrix4 = _oViewCacheMatrix;
       var	m11:Number = l_oMatrix.n11, m21:Number = l_oMatrix.n21, m31:Number = l_oMatrix.n31,
			m12:Number = l_oMatrix.n12, m22:Number = l_oMatrix.n22, m32:Number = l_oMatrix.n32,
			m13:Number = l_oMatrix.n13, m23:Number = l_oMatrix.n23, m33:Number = l_oMatrix.n33,
			m14:Number = l_oMatrix.n14, m24:Number = l_oMatrix.n24, m34:Number = l_oMatrix.n34;
				
        _dir.wx = _dir.x * m11 + _dir.y * m12 + _dir.z * m13 + m14;
		_dir.wy = _dir.x * m21 + _dir.y * m22 + _dir.z * m23 + m24;
		_dir.wz = _dir.x * m31 + _dir.y * m32 + _dir.z * m33 + m34;
		
		_v.wx = _v.x * m11 + _v.y * m12 + _v.z * m13 + m14;
		_v.wy = _v.x * m21 + _v.y * m22 + _v.z * m23 + m24;
		_v.wz = _v.x * m31 + _v.y * m32 + _v.z * m33 + m34;
		
		depth = _v.wz;
		// 100 because scale is beteen 0 and 100 in AS2
		m_nPerspScale = _nScale * 10000/depth;
		// --
		p_oCamera.addToDisplayList( this );
		// -- We push the vertex to project onto the viewport.
		p_oCamera.pushVerticesToRender( [_v] );	
		// --
        var vNormale:Vector = new Vector( _v.wx - _dir.wx, _v.wy - _dir.wy, _v.wz - _dir.wz );
		var angle:Number = VectorMath.getAngle( _vView, vNormale );
		if( vNormale.x == 0 ) angle = Math.PI;
		else if( vNormale.x < 0 ) angle = 2*Math.PI - angle;
		// FIXME problem around 180 frame. A big jump occurs. Problem of precision ?
		m_oContainer.gotoAndStop( __frameFromAngle( angle ) );
	}
	
	// --
	public function display( p_oContainer:MovieClip ):Void
	{
		//FIXME I don't like the way the perspective is applied here...
		m_oContainer._xscale = m_oContainer._yscale = m_nPerspScale;
		m_oContainer._x = _v.sx - m_nW2;
		m_oContainer._y = _v.sy - m_nH2;
	}
	
	
	private function __frameFromAngle(a:Number):Number
	{
		a = NumberUtil.toDegree( a );
		a = (( a + _nOffset )+360) % 360;
		return a;
	}
			

	/**
	* getOffset
	* Ollows you to get the offset of the Clip3D and later change it with setOffset if you need.
	* @param	void
	* @return
	*/
	public function getOffset():Number
	{
		return _nOffset;
	}
	
	/**
	* Allows you to change the oject offset.
	* @param	n Number The offset. This value must be between 0 and 360.
	*/
	public function setOffset( n:Number ):Void
	{
		_nOffset = n;
	}
	
	// -- frames offset
	private var _nOffset:Number;
	private var _vView:Vector;
	private var _dir:Vertex;
			
	private var m_nPerspScale:Number;
	private var m_nW2:Number;
	private var m_nH2:Number;
	private var _v:Vertex;
	private var _nScale:Number;
	private var m_oContainer:MovieClip;
}
