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
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import sandy.core.World3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vertex;
	import sandy.math.Matrix4Math;
	import sandy.util.NumberUtil;
	import sandy.view.Frustum;
	import sandy.view.ViewPort;
	import flash.geom.Matrix;
	
	/**
	 * The Camera3D class is used to create a camera for the Sandy world.
	 *
	 * <p>As of this version of Sandy, the camera is added to the object tree,
	 * which means it is transformed in the same manner as any other object.</p>
	 * <p>[<b>ToDo</b>: Describe the camera in some detail]</p> 
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class Camera3D extends ATransformable
	{
		/**
		 * The frustum of the camera.
		 */
		public var frustrum:Frustum;

		/**
		 * Creates a camera for projecting visible objects in the world.
		 *
		 * <p>By default the camera shows a perspective projection</p>
		 * 
		 * @param p_nWidth	Width of the camera viewport in pixels
		 * @param p_nHeight	Height of the camera viewport in pixels
		 * @param p_nFov	The vertical angle of view in degrees - Default 45
		 * @param p_nNear	The distance from the camera to the near clipping plane - Default 50
		 * @param p_nFar	The distance from the camera to the far clipping plane - Default 10000
		 */
		public function Camera3D( p_nWidth:Number, p_nHeight:Number, p_nFov:Number = 45, p_nNear:Number = 50, p_nFar:Number = 10000 )
		{
			super( null );
			_viewport = new ViewPort( p_nWidth, p_nHeight );
			_viewport.update();
			_perspectiveChanged = true;
			m_nOffx = _viewport.w2; m_nOffy = _viewport.h2;
			
			_nFov = p_nFov;
			_nFar = p_nFar;
			_nNear = p_nNear;
			// --
			frustrum = new Frustum();
			// --
			setPerspectiveProjection( _nFov, _viewport.ratio, _nNear, _nFar );
			m_aDisplayList = new Array();
			// It's a non visible node
			visible = false;
		}
		
		//////////////////////
		///// ACCESSORS //////
		//////////////////////		
		/**
		 * The viewport of this camera.
		 */
		public function set viewport( p_oVP:ViewPort ):void
		{
			_viewport = p_oVP;
			_perspectiveChanged = true;
			m_nOffx = _viewport.w2; m_nOffy = _viewport.h2;
			World3D.getInstance().container.scrollRect = new Rectangle( _viewport.w, _viewport.h );
		}
		
		/**
		 * The width of this camera's viewport.
		 */
		public function set viewportWidth( p_nWidth:Number ):void
		{
			_viewport.w = p_nWidth;
			_viewport.update();
			_perspectiveChanged = true;
			m_nOffx = _viewport.w2; m_nOffy = _viewport.h2;
			World3D.getInstance().container.scrollRect = new Rectangle( _viewport.w, _viewport.h );
		}
		
		/**
		 * The height of this camera's viewport.
		 */
		public function set viewportHeight( p_nHeight:Number ):void
		{
			_viewport.h = p_nHeight;
			_viewport.update();
			_perspectiveChanged = true;
			m_nOffx = _viewport.w2; m_nOffy = _viewport.h2;
			World3D.getInstance().container.scrollRect = new Rectangle( _viewport.w, _viewport.h );
		}
				
		/**
		 * The angle of view of this camera in degrees.
		 */
		public function set fov( p_nFov:Number ):void
		{
			_nFov = p_nFov;
			_perspectiveChanged = true;
		}

		/**
		 * @private
		 */
		public function get fov():Number
		{return _nFov;}
		
		/**
		 * Near plane distance for culling/clipping.
		 */
		public function set near( pNear:Number ):void
		{_nNear = pNear;_perspectiveChanged = true;}
		
		/**
		 * @private
		 */
		public function get near():Number
		{return _nNear;}
				
		/**
		 * Far plane distance for culling/clipping.
		 */
		public function set far( pFar:Number ):void
		{_nFar = pFar;_perspectiveChanged = true;}
		
		/**
		 * @private
		 */
		public function get far():Number
		{return _nFar;}
	
		///////////////////////////////////////
		//// GRAPHICAL ELEMENTS MANAGMENT /////
		///////////////////////////////////////
		/**
		 * [<b>Todo</b>: Explain this ;-)].
		 */
		public function renderDisplayList():void
		{
		    var l_nId:int=0, l_mcContainer:Sprite = World3D.getInstance().container;
		    // --
		    m_aDisplayList.sortOn( "depth", Array.NUMERIC | Array.DESCENDING );
		    // --
			for each( var l_oShape:IDisplayable in m_aDisplayList )
			{
				l_oShape.clear();
				l_oShape.display();
				l_mcContainer.addChild( l_oShape.container );
			}
			// --
			m_aDisplayList.splice(0);
		}

		/**
		 * Adds a displayable object to the display list.
		 *
		 * @param p_oShape	The object to add
		 */
		public function addToDisplayList( p_oShape:IDisplayable ):void
		{
			m_aDisplayList.push( p_oShape );
		}
	
		/**
		 * Adds an array of objects to the projection list.
		 *
		 * @param p_aList	The array of objects to add
		 */
		public function addToProjectionList( p_aList:Array ):void
		{
			m_oProjList = m_oProjList.concat( p_aList );
		}
		
		/**
		 * [<b>Todo</b>: Explain this ;-)].
		 */
		public function project():void
		{
			var l_nCste:Number;
			for each( var l_oVertex:Vertex in m_oProjList )
			{
				l_nCste = 	1 / ( l_oVertex.wx * mp41 + l_oVertex.wy * mp42 + l_oVertex.wz * mp43 + mp44 );
				l_oVertex.sx =  l_nCste * ( l_oVertex.wx * mp11 + l_oVertex.wy * mp12 + l_oVertex.wz * mp13 + mp14 ) * m_nOffx + m_nOffx;
				l_oVertex.sy = -l_nCste * ( l_oVertex.wx * mp21 + l_oVertex.wy * mp22 + l_oVertex.wz * mp23 + mp24 ) * m_nOffy + m_nOffy;
			}	
			m_oProjList.splice( 0 );
		}

		/**
		 * [<b>Todo</b>: Explain this ;-)].
		 */
		public function projectArray( p_oList:Array ):void
		{
			var l_nCste:Number;
			for each( var l_oVertex:Vertex in p_oList )
			{
				l_nCste = 	1 / ( l_oVertex.wx * mp41 + l_oVertex.wy * mp42 + l_oVertex.wz * mp43 + mp44 );
				l_oVertex.sx =  l_nCste * ( l_oVertex.wx * mp11 + l_oVertex.wy * mp12 + l_oVertex.wz * mp13 + mp14 ) * m_nOffx + m_nOffx;
				l_oVertex.sy = -l_nCste * ( l_oVertex.wx * mp21 + l_oVertex.wy * mp22 + l_oVertex.wz * mp23 + mp24 ) * m_nOffy + m_nOffy;
			}
		}
				
		/**
		 * [<b>Todo</b>: Explain this ;-)].
		 */
		public function projectVertex( p_oVertex:Vertex ):void
		{
			const l_nCste:Number = 	1 / ( p_oVertex.wx * mp41 + p_oVertex.wy * mp42 + p_oVertex.wz * mp43 + mp44 );
			p_oVertex.sx =  l_nCste * ( p_oVertex.wx * mp11 + p_oVertex.wy * mp12 + p_oVertex.wz * mp13 + mp14 ) * m_nOffx + m_nOffx;
			p_oVertex.sy = -l_nCste * ( p_oVertex.wx * mp21 + p_oVertex.wy * mp22 + p_oVertex.wz * mp23 + mp24 ) * m_nOffy + m_nOffy;
		}
		
		/**
		 * Nothing to do - the camera is not rendered.
		 */
		public override function render( p_oCamera:Camera3D):void
		{
			return;/* Nothing to do here */
		}
		
		/**
		 * Updates the state of the camera transformation.
		 *
		 * @param p_oModelMatrix	[<b>Todo</b>: Explain this ;-)]
		 * @param p_bChanged		[<b>Todo</b>: Explain this ;-)]
		 */
		public override function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			if( _perspectiveChanged ) updatePerspective();
			super.update( p_oModelMatrix, p_bChanged );
			// SHOULD BE DONE IN A FASTER WAY
			m_oModelMatrixInv.copy( _oModelCacheMatrix );
			m_oModelMatrixInv.inverse();
			/*new Matrix4( 	_oModelCacheMatrix.n11,
					_oModelCacheMatrix.n21,
					oModelCacheMatrix.n31,
					- _oModelCacheMatrix.n14,
					_oModelCacheMatrix.n12,
					_oModelCacheMatrix.n22,
					_oModelCacheMatrix.n32,
					- _oModelCacheMatrix.n24,
					_oModelCacheMatrix.n13,
					_oModelCacheMatrix.n23,
					_oModelCacheMatrix.n33,
					- _oModelCacheMatrix.n34 );*/
		}
				
		/**
		 * The model matrix of this camera.
		 *
		 * <p>[<b>Todo</b>: Explain this better ]</p>
		 *
		 * <p>The matrix is inverted in comparison of the real model view matrix.<br/>
		 * This allows replacement of the objects in the correct camera frame before projection</p>
		 */
		public function get modelMatrix():Matrix4
		{
			return m_oModelMatrixInv;
		}
		
		/**
		 * Nothing to do - the camera is not rendered.
		 */
		public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			return;
		}
		
		/**
		* Returns the projection matrix of this camera. 
		* 
		* @return 	The projection matrix
		*/
		public function getProjectionMatrix():Matrix4
		{
			return _mp;
		}
		
		/**
		 * Returns the inverse of the projection matrix of this camera.
		 *
		 * @return 	The inverted projection matrix
		 */
		public function getProjectionMatrixInverse():Matrix4
		{
			return _mpInv;
		}
		
		/**
		* Sets a projection matrix with perspective. 
		*
		* <p>This projection allows a natural visual presentation of objects, mimicking 3D perspective.</p>
		*
		* @param p_nFovY 	The angle of view in degrees - Default 45.
		* @param p_nAspectRatio The ratio between vertical and horizontal dimension - Default the viewport ratio (width/height)
		* @param p_nZNear 	The distance betweeen the camera and the near plane - Default 10.
		* @param p_nZFar 	The distance betweeen the camera position and the far plane. Default 10 000.
		*/
		public function setPerspectiveProjection(p_nFovY:Number, p_nAspectRatio:Number, p_nZNear:Number, p_nZFar:Number):void
		{
			var cotan:Number, Q:Number;
			// --
			frustrum.computePlanes(p_nAspectRatio, p_nZNear, p_nZFar, p_nFovY );
			// --
			p_nFovY = NumberUtil.toRadian( p_nFovY );
			cotan = 1 / Math.tan(p_nFovY / 2);
			Q = p_nZFar/(p_nZFar - p_nZNear);
			
			_mp.zero();
	
			_mp.n11 = cotan / p_nAspectRatio;
			_mp.n22 = cotan;
			_mp.n33 = Q;
			_mp.n34 = -Q*p_nZNear;
			_mp.n43 = 1;
			// to optimize later
			mp11 = _mp.n11; mp21 = _mp.n21; mp31 = _mp.n31; mp41 = _mp.n41;
			mp12 = _mp.n12; mp22 = _mp.n22; mp32 = _mp.n32; mp42 = _mp.n42;
			mp13 = _mp.n13; mp23 = _mp.n23; mp33 = _mp.n33; mp43 = _mp.n43;
			mp14 = _mp.n14; mp24 = _mp.n24; mp34 = _mp.n34; mp44 = _mp.n44;			
			
			changed = true;	
		}
			
		/**
		 * Updates the perspective projection.
		 */
		public function updatePerspective():void
		{
			if( _perspectiveChanged )
			{
				setPerspectiveProjection(_nFov, _viewport.ratio, _nNear, _nFar );
				_perspectiveChanged = false;
			}
		}

		public override function toString():String
		{
			return "sandy.core.scenegraph.Camera3D";
		}
			
		//////////////////////////
		/// PRIVATE PROPERTIES ///
		//////////////////////////
		
		private var _mp : Matrix4 = new Matrix4(); // projection Matrix4
		private var _mpInv : Matrix4; // Inverse of the projection matrix 
		private var _mf:Matrix4; // final Matrix4 which is the result of the transformation and projection matrix's multiplication.
	
		private var m_oProjList:Array = new Array();
		
		private var _viewport:ViewPort;
		private var m_aDisplayList:Array;
		private var _perspectiveChanged:Boolean;
		private var _nFov:Number;
		private var _nFar:Number;
		private var _nNear:Number;
		private var m_oModelMatrixInv:Matrix4 = new Matrix4();
		private var mp11:Number, mp21:Number,mp31:Number,mp41:Number,
					mp12:Number,mp22:Number,mp32:Number,mp42:Number,
					mp13:Number,mp23:Number,mp33:Number,mp43:Number,
					mp14:Number,mp24:Number,mp34:Number,mp44:Number,				
					m_nOffx:Number, m_nOffy:Number;
	}
}