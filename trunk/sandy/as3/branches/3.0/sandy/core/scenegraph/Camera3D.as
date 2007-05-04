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

package sandy.core.scenegraph 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import sandy.core.World3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vertex;
	import sandy.core.data.Polygon;
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
	public class Camera3D extends ATransformable implements ITransformable
	{
		/**
		 * The frustum of the camera. See {@see Frustum} class.
		 */
		public var frustrum:Frustum;
		/**
		 * Create a new Camera3D.
		 * The default camera projection is the perspective one with default parameters values.
		 * @param nFoc The focal of the Camera3D
		 * @param s the screen associated to the camera
		 */
		public function Camera3D( p_nWidth:Number, p_nHeight:Number, p_nFov:Number = 45, p_nNear:Number = 50, p_nFar:Number = 10000 )
		{
			super( null );
			_viewport = new ViewPort( p_nWidth, p_nHeight );
			_nFov = p_nFov;
			_nFar = p_nFar;
			_nNear = p_nNear;
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
	
		public function set viewport( pVP:ViewPort ):void
		{
			_viewport = pVP;
			_perspectiveChanged = true;
		}
		
		public function get viewport():ViewPort
		{
			return _viewport;
		}
		
		/**
		 * Angle of view in degrees
		 */
		public function set fov( pFov:Number ):void
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
		public function set near( pNear:Number ):void
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
		public function set far( pFar:Number ):void
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
		
		public function renderDisplayList():void
		{
		    var l_oShape:Shape3D, l_nId:int=0, l_mcContainer:Sprite = World3D.getInstance().container;
		    // --
		    m_aDisplayList.sortOn( "depth", Array.NUMERIC | Array.DESCENDING );
		    // --
			for each( l_oShape in m_aDisplayList )
			{
				l_mcContainer.setChildIndex( l_oShape.container, l_nId++ );
				l_oShape.display();
			}
			// --
			m_aDisplayList = [];
		}
			
		public function addToDisplayList( p_oShape:Shape3D ):void
		{
			m_aDisplayList.push( p_oShape );
		}
		
		
		public function pushVerticesToProject( p_aVertices:Array ):void
		{
			m_aVerticesList = m_aVerticesList.concat( p_aVertices );
		}
		
		public function project():void
		{
			var mp11:Number = _mp.n11,mp21:Number = _mp.n21,mp31:Number = _mp.n31,mp41:Number = _mp.n41,
				mp12:Number = _mp.n12,mp22:Number = _mp.n22,mp32:Number = _mp.n32,mp42:Number = _mp.n42,
				mp13:Number = _mp.n13,mp23:Number = _mp.n23,mp33:Number = _mp.n33,mp43:Number = _mp.n43,
				mp14:Number = _mp.n14,mp24:Number = _mp.n24,mp34:Number = _mp.n34,mp44:Number = _mp.n44,
				l_nOffx:Number = viewport.w2, l_nOffy:Number = viewport.h2, l_nCste:Number, l_oVertex:Vertex;
			// --
			for each( l_oVertex in m_aVerticesList )
			{
				l_nCste = 	1 / ( l_oVertex.wx * mp41 + l_oVertex.wy * mp42 + l_oVertex.wz * mp43 + mp44 );
				l_oVertex.sx =  l_nCste * ( l_oVertex.wx * mp11 + l_oVertex.wy * mp12 + l_oVertex.wz * mp13 + mp14 ) * l_nOffx + l_nOffx;
				l_oVertex.sy = -l_nCste * ( l_oVertex.wx * mp21 + l_oVertex.wy * mp22 + l_oVertex.wz * mp23 + mp24 ) * l_nOffy + l_nOffy;
			}	
			m_aVerticesList = [];
		}
			
		/**
		* Compile the camera transformations by multiplicating the matrix together.
		* Be carefull to call isModified method before to save computations. 
		*/
		public override function render( p_oCamera:Camera3D):void
		{
			return;/* Nothing to do here */
		}
		
		/**
		 * Update the state of the camera transformation.
		 */
		public override function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			updatePerspective();
			updateTransform();
			super.update( p_oModelMatrix, p_bChanged );
		}
		
		/**
		 * No cull is necessary for the Camera object. This method does nothing.
		 */
		public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void
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
		
		public override function toString():String
		{
			return "sandy.core.scenegraph.Camera3D";
		}
			
		/**
		* Set an orthographic projection. This projection in opposite of the perspective one, don't distort distances and pictures
		* @param	screenWidth The screen width. Default value: the screen width
		* @param	screenHeight The screen height. Default value: the screen height.
		* @param	zNear The distance betweeen the camera position and the near plane. Default value: 10.
		* @param	zFar The distance betweeen the camera position and the far plane. Default value: 10,000.
		*/
		/*
		public function setOrthoProjection(screenWidth:Number, screenHeight:Number, zNear:Number, zFar:Number):void
		{
			var h:Number, w:Number, Q:Number;
			// --
			if( undefined == screenWidth ) screenWidth = _is.getSize().width;
			if( undefined == screenHeight ) screenHeight = _is.getSize().height;
			if( undefined == zNear ) zNear = 10;
			if( undefined == zFar ) zFar = 10000;
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
		* @param	zNear The distance betweeen the camera position and the near plane. Default value: 10.
		* @param	zFar The distance betweeen the camera position and the far plane. Default value: 10,000.
		*/
		public function setPerspectiveProjection(fovY:Number, aspectRatio:Number, zNear:Number, zFar:Number):void
		{
			var cotan:Number, Q:Number;
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
	
			changed = true;	
		}
			
			
		/**
		 * Update the camera transformation
		 */
		public function updateTransform ():void
		{
			if( changed )
			{
				var mt:Matrix4 = m_tmpMt;
				mt.n11 = _vSide.x; 
				mt.n12 = _vSide.y; 
				mt.n13 = _vSide.z; 
				mt.n14 = - VectorMath.dot( _vSide, _p );
				
				mt.n21 = _vUp.x; 
				mt.n22 = _vUp.y; 
				mt.n23 = _vUp.z; 
				mt.n24 = - VectorMath.dot( _vUp, _p );
				
				mt.n31 = _vOut.x; 
				mt.n32 = _vOut.y; 
				mt.n33 = _vOut.z; 
				mt.n34 = - VectorMath.dot( _vOut, _p );
				
				transform.matrix = mt;
			}
		}
		
		public function updatePerspective():void
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
	}
}