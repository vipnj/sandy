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

import sandy.core.data.Matrix4;
import sandy.core.data.Vertex;
import sandy.core.scenegraph.ATransformable;
import sandy.core.scenegraph.IDisplayable;
import sandy.core.scenegraph.ITransformable;
import sandy.math.Matrix4Math;
import sandy.math.VectorMath;
import sandy.util.NumberUtil;
import sandy.view.Frustum;
import sandy.view.ViewPort;

/**
* Camera3D
* @author		Thomas Pfeiffer - kiroukou
* @version		2.0
* @date 		12.07.2006
**/
class sandy.core.scenegraph.Camera3D extends ATransformable implements ITransformable
{
	/**
	 * The frustum of the camera. See {@see Frustum} class.
	 */
	public var frustrum:Frustum;
	/**
	 * Create a new Camera3D.
	 * The default camera projection is the perspective one with default parameters values.
	 * @param pWidth Number The width of the world
 	 * @param pHeight Number The height of the world
	 * @param pFear Number Near z-plane. Default is 10.
	 * @param pFear Number Far z-plane. Default is 3000. 
	 */
	public function Camera3D( p_nWidth:Number, p_nHeight:Number, p_nFov:Number, p_nNear:Number, p_nFar:Number  )
	{
		super( null );
		_viewport = new ViewPort( p_nWidth, p_nHeight );
		_viewport.update();
		m_nOffx = _viewport.w2; m_nOffy = _viewport.h2;
		// --
		_nFov = (p_nFov)   ? p_nFov : 45;
		_nFar = (p_nFar)   ? p_nFar : 3000;
		_nNear = (p_nNear) ? p_nNear : 10;
		// --
		frustrum = new Frustum();
		// --
		setPerspectiveProjection( _nFov, _viewport.ratio, _nNear, _nFar );
		m_aDisplayList = new Array();
		m_aVerticesList = new Array();
		// It's a non visible node
		visible = false;
	}
	
//////////////////////
///// ACCESSORS //////
//////////////////////		

	
	public function set viewport( pVP:ViewPort ):Void
	{
		_viewport = pVP;
		_perspectiveChanged = true;
		m_nOffx = _viewport.w2; m_nOffy = _viewport.h2;
	}
	
	public function set viewportWidth( p_nWidth:Number ):Void
	{
		_viewport.w = p_nWidth;
		_viewport.update();
		_perspectiveChanged = true;
		m_nOffx = _viewport.w2; m_nOffy = _viewport.h2;
	}
	
	public function set viewportHeight( p_nHeight:Number ):Void
	{
		_viewport.h = p_nHeight;
		_viewport.update();
		_perspectiveChanged = true;
		m_nOffx = _viewport.w2; m_nOffy = _viewport.h2;
	}
		
	
	/**
	 * Angle of view in degrees
	 */
	public function set fov( pFov:Number )
	{
		_nFov = pFov;
		_perspectiveChanged = true;
	}
	
	public function get fov():Number
	{
		return _nFov;
	}
	
	/**
	 * Near plane distance for culling/clipping
	 */
	public function set near( pNear:Number )
	{
		_nNear = pNear;
		_perspectiveChanged = true;
	}
	
	public function get near():Number
	{
		return _nNear;
	}
			
	/**
	 * Far plane distance for culling/clipping
	 */
	public function set far( pFar:Number )
	{
		_nFar = pFar;
		_perspectiveChanged = true;
	}
	
	public function get far():Number
	{
		return _nFar;
	}

///////////////////////////////////////
//// GRAPHICAL ELEMENTS MANAGMENT /////
///////////////////////////////////////

	public function pushVerticesToRender( p_aVertices:Array ):Void
	{
		m_aVerticesList = m_aVerticesList.concat( p_aVertices );
	}
	
	public function renderDisplayList( Void ):Void
	{
	    var l_oDisplayElt:IDisplayable = null, i:Number = 0, l:Number = m_aDisplayList.length;
	    // --
	    m_aDisplayList = m_aDisplayList.sortOn( "depth", Array.NUMERIC | Array.ASCENDING );
	    // --
		while( --l > -1 )
		{
		   m_aDisplayList[l].container.clear();
		   m_aDisplayList[l].display();
		   m_aDisplayList[l].container.swapDepths( i++ );
		}
		// --
		m_aDisplayList.splice(0);
	}
		
	public function addToDisplayList( p_oElement:IDisplayable ):Void
	{
		m_aDisplayList.push( p_oElement );
	}
	
	public function project( Void ):Void
	{
		var l_oVertex:Vertex;
		var l_aPoints:Array = m_aVerticesList;
		var l_nLength:Number = m_aVerticesList.length;
		var l_nCste:Number;
		var mp11:Number,mp21:Number,mp31:Number,mp41:Number,mp12:Number,mp22:Number,mp32:Number,mp42:Number,mp13:Number,mp23:Number,mp33:Number,mp43:Number,mp14:Number,mp24:Number,mp34:Number,mp44:Number;
		//
		mp11 = _mp.n11; mp21 = _mp.n21; mp31 = _mp.n31; mp41 = _mp.n41;
		mp12 = _mp.n12; mp22 = _mp.n22; mp32 = _mp.n32; mp42 = _mp.n42;
		mp13 = _mp.n13; mp23 = _mp.n23; mp33 = _mp.n33; mp43 = _mp.n43;
		mp14 = _mp.n14; mp24 = _mp.n24; mp34 = _mp.n34; mp44 = _mp.n44;
		//
		while( --l_nLength > -1 )
		{
			l_oVertex = l_aPoints[l_nLength];
			l_nCste = 	1 / ( l_oVertex.wx * mp41 + l_oVertex.wy * mp42 + l_oVertex.wz * mp43 + mp44 );
			l_oVertex.sx =  l_nCste * ( l_oVertex.wx * mp11 + l_oVertex.wy * mp12 + l_oVertex.wz * mp13 + mp14 ) * m_nOffx + m_nOffx;
			l_oVertex.sy = -l_nCste * ( l_oVertex.wx * mp21 + l_oVertex.wy * mp22 + l_oVertex.wz * mp23 + mp24 ) * m_nOffy + m_nOffy;
		}
		// --
		m_aVerticesList.splice(0);	
	}

	/**
	* Compile the camera transformations by multiplicating the matrix together.
	* Be carefull to call isModified method before to save computations. 
	*/
	public function render( p_oCamera:Camera3D):Void
	{
		return;/* Nothing to do here */
	}
	
	/**
	 * Update the state of the camera transformation.
	 */
	public function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):Void
	{
		if( _perspectiveChanged ) updatePerspective();
		super.update( p_oModelMatrix, p_bChanged );
		// SHOULD BE DONE IN A FASTER WAY
		m_oModelMatrixInv = Matrix4Math.getInverse(_oModelCacheMatrix);
	}

	/**
	 * Returns the model matrix from the camera, so inverted in comparison of the real model view matrix.
	 * This allows to replace the elements in the correct camera frame before projection
	 */
	public function get modelMatrix():Matrix4
	{
		return m_oModelMatrixInv;
	}
			
	/**
	 * No cull is necessary for the Camera object. This method does nothing.
	 */
	public function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):Void
	{
		return;
	}
	
	/**
	* Return the projection matrix. 
	* 
	* @return Matrix4
	*/
	public function getProjectionMatrix():Matrix4
	{
		return _mp;
	}
	
	/**
	 * Returns the inverse of the projection matrix
	 */
	public function getProjectionMatrixInverse():Matrix4
	{
		return _mpInv;
	}

	public function getTransformationMatrixInverse():Matrix4
	{
		return  Matrix4Math.getInverse( transform.matrix );
	}
	
	public function toString():String
	{
		return "sandy.core.scenegraph.Camera3D";
	}
		
	/**
	* Set an orthographic projection. This projection in opposite of the perspective one, don't distort distances and pictures
	* @param	screenWidth The screen width. Default value: the screen width
	* @param	screenHeight The screen height. Default value: the screen height.
	* @param	zNear The distance betweeen the camera position and the near plane. Default is value set via Constructor.
	* @param	zFar The distance betweeen the camera position and the far plane. Default is value set via Constuctor.
	*/
	/*
	public function setOrthoProjection(screenWidth:Number, screenHeight:Number, zNear:Number, zFar:Number):Void
	{
		var h:Number, w:Number, Q:Number;
		// --
		if( undefined == screenWidth ) screenWidth = _is.getSize().width;
		if( undefined == screenHeight ) screenHeight = _is.getSize().height;
		if( undefined == zNear ) zNear = _nNear;
		if( undefined == zFar )  zFar = _nFar;
		// --
		w = 2*zNear/screenWidth;
		h = 2*zNear/screenHeight;
		Q = zFar/(zFar - zNear);

		delete _mp;
		_mp = Matrix4.createZero();
		_mp.n11 = w;
		_mp.n22 = h;
		_mp.n33 = Q;
		_mp.n34 = -Q*zNear;
		_mp.n43 = 1;
	}
	*/
	
	/**
	* Set a projection matrix with perspective. This projection allows a more human visual representation of objects.
	* @param	fovY The angle of view in degress. Default value: 45.
	* @param	aspectRatio The ratio between vertical and horizontal pixels. Default value: the screeen ratio (width/height)
	* @param	zNear The distance betweeen the camera position and the near plane. Default is value set via Constructor.
	* @param	zFar The distance betweeen the camera position and the far plane. Default is value set via Constructor.
	*/
	public function setPerspectiveProjection(fovY:Number, aspectRatio:Number, zNear:Number, zFar:Number):Void
	{
		var cotan:Number, Q:Number;
		if( undefined == zNear ) fovY = _nFov;
		if( undefined == zNear ) zNear = _nNear;
		if( undefined == zFar )  zFar = _nFar;
		// --
		frustrum.computePlanes(aspectRatio, zNear, zFar, fovY );
		// --
		fovY = NumberUtil.toRadian( fovY );
		cotan = 1 / Math.tan(fovY / 2);
		Q = zFar/(zFar - zNear);
		
		_mp = Matrix4.createZero();

		_mp.n11 = cotan / aspectRatio;
		_mp.n22 = cotan;
		_mp.n33 = Q;
		_mp.n34 = -Q*zNear;
		_mp.n43 = 1;

		mp11 = _mp.n11; mp21 = _mp.n21; mp31 = _mp.n31; mp41 = _mp.n41;
		mp12 = _mp.n12; mp22 = _mp.n22; mp32 = _mp.n32; mp42 = _mp.n42;
		mp13 = _mp.n13; mp23 = _mp.n23; mp33 = _mp.n33; mp43 = _mp.n43;
		mp14 = _mp.n14; mp24 = _mp.n24; mp34 = _mp.n34; mp44 = _mp.n44;			
		
		changed = true;	
	}
		
	
	function updatePerspective( Void ):Void
	{
		if( _perspectiveChanged )
		{
			setPerspectiveProjection(_nFov, _viewport.ratio, _nNear, _nFar );
			_perspectiveChanged = false;
		}
	}
		
//////////////////////////
/// PRIVATE PROPERTIES ///
//////////////////////////

	private var _mp : Matrix4; // projection Matrix4
	private var _mpInv : Matrix4; // Inverse of the projection matrix 
	/*
	 * ViewPort matrix
	 */
	private var _mf:Matrix4; // final Matrix4 which is the result of the transformation and projection matrix's multiplication.

	/**
	 * The viewport associated to the camera
	 */
	private var _viewport:ViewPort;
	private var m_aDisplayList:Array;
	private var _perspectiveChanged:Boolean;
	private var _nFov:Number;
	private var _nFar:Number;
	private var _nNear:Number;
	private var m_aVerticesList:Array;
	private var m_oModelMatrixInv:Matrix4;
	private var mp11:Number, mp21:Number,mp31:Number,mp41:Number,
				mp12:Number,mp22:Number,mp32:Number,mp42:Number,
				mp13:Number,mp23:Number,mp33:Number,mp43:Number,
				mp14:Number,mp24:Number,mp34:Number,mp44:Number,				
				m_nOffx:Number, m_nOffy:Number;
}
