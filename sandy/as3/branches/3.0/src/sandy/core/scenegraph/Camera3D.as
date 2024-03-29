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
	
	import sandy.core.Scene3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vertex;
	import sandy.util.NumberUtil;
	import sandy.view.Frustum;
	import sandy.view.ViewPort;
	
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
		public var nbPolygons:uint = 0;
		public var nbVertices:uint = 0;
		
		/**
		 * <p>Inverse of the model matrix
		 * This is apply at the culling phasis
		 * The matrix is inverted in comparison of the real model view matrix.<br/>
		 * This allows replacement of the objects in the correct camera frame before projection</p>
		 */
		public var invModelMatrix:Matrix4 = new Matrix4();
		
		/**
		 * The camera viewport
		 */
		public var viewport:ViewPort = new ViewPort(640,480);
		
		/**
		 * The frustum of the camera.
		 */
		public var frustrum:Frustum = new Frustum();

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
			viewport.width = p_nWidth;
			viewport.height = p_nHeight;
			// --			
			_nFov = p_nFov;
			_nFar = p_nFar;
			_nNear = p_nNear;
			// --
			setPerspectiveProjection( _nFov, viewport.ratio, _nNear, _nFar );
			// It's a non visible node
			visible = false;
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
		 * Process the rendering of the scene.
		 * The camera has all the information needed about the objects to render.
		 * 
		 * The camera stores all the visible shape/polygons into an array, and loop through it calling their display method.
		 * Before the display call, the container graphics is cleared.
		 */
		public function renderDisplayList( p_oScene:Scene3D ):void
		{
			var l_oShape:IDisplayable;
			// --
			for each( l_oShape in m_aDisplayedList )
			{
				l_oShape.clear();
			}
		    // --
		    nbPolygons = m_aDisplayList.length;
		    // --
		    const l_mcContainer:Sprite = p_oScene.container;
		    // we go high quality for drawing part
		   	//l_mcContainer.stage.quality = StageQuality.HIGH;
		    // --
		    m_aDisplayList.sortOn( "depth", Array.NUMERIC | Array.DESCENDING );
		    // --
			for each( l_oShape in m_aDisplayList )
			{
				l_oShape.display( p_oScene );
				l_mcContainer.addChild( l_oShape.container );
			}
			// -- back to low quality
			//l_mcContainer.stage.quality = StageQuality.LOW;
			// --
			m_aDisplayedList = m_aDisplayList.splice(0);
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
		 * <p>Project the vertices list given in parameter.
		 * The vertices are projected to the screen, as a 2D position.
		 * </p>
		 */
		public function projectArray( p_oList:Array ):void
		{
			const l_nX:Number = viewport.offset.x + m_nOffx;
			const l_nY:Number = viewport.offset.y + m_nOffy;
			var l_nCste:Number;
			for each( var l_oVertex:Vertex in p_oList )
			{
				if( ! l_oVertex.projected )
				{
					l_nCste = 	1 / ( l_oVertex.wx * mp41 + l_oVertex.wy * mp42 + l_oVertex.wz * mp43 + mp44 );
					l_oVertex.sx =  l_nCste * ( l_oVertex.wx * mp11 + l_oVertex.wy * mp12 + l_oVertex.wz * mp13 + mp14 ) * m_nOffx + l_nX;
					l_oVertex.sy = -l_nCste * ( l_oVertex.wx * mp21 + l_oVertex.wy * mp22 + l_oVertex.wz * mp23 + mp24 ) * m_nOffy + l_nY;
					// --
					l_oVertex.projected = true;
					nbVertices ++;
				}
			}
		}
				
		/**
		 * <p>Project the vertex passed as parameter.
		 * The vertices are projected to the screen, as a 2D position.
		 * </p>
		 */
		public function projectVertex( p_oVertex:Vertex ):void
		{
			const l_nX:Number = viewport.offset.x + m_nOffx;
			const l_nY:Number = viewport.offset.y + m_nOffy;
			const l_nCste:Number = 	1 / ( p_oVertex.wx * mp41 + p_oVertex.wy * mp42 + p_oVertex.wz * mp43 + mp44 );
			p_oVertex.sx =  l_nCste * ( p_oVertex.wx * mp11 + p_oVertex.wy * mp12 + p_oVertex.wz * mp13 + mp14 ) * m_nOffx + l_nX;
			p_oVertex.sy = -l_nCste * ( p_oVertex.wx * mp21 + p_oVertex.wy * mp22 + p_oVertex.wz * mp23 + mp24 ) * m_nOffy + l_nY;
		}
		
		/**
		 * Nothing is done here - the camera is not rendered
		 */
		public override function render( p_oScene:Scene3D, p_oCamera:Camera3D):void
		{
			return;/* Nothing to do here */
		}
		
		/**
		 * Updates the state of the camera transformation.
		 *
		 * @param p_oScene			The current scene
		 * @param p_oModelMatrix The matrix which represents the parent model matrix. Basically it stores the rotation/translation/scale of all the nodes above the current one.
		 * @param p_bChanged	A boolean value which specify if the state has changed since the previous rendering. If false, we save some matrix multiplication process.
		 */
		public override function update( p_oScene:Scene3D, p_oModelMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			if( viewport.hasChanged )
			{
				_perspectiveChanged = true;
				// -- update the local values
				m_nOffx = viewport.width2; 
				m_nOffy = viewport.height2;
				// -- Apply a scrollRect to the container at the viewport dimension
				if( p_oScene.rectClipping ) 
					p_oScene.container.scrollRect = new Rectangle( 0, 0, viewport.width, viewport.height );
				// -- we warn the the modification has been taken under account
				viewport.hasChanged = false;
			}
			// --
			nbVertices = 0;
			// --
			if( _perspectiveChanged ) updatePerspective();
			super.update( p_oScene, p_oModelMatrix, p_bChanged );
			// SHOULD BE DONE IN A FASTER WAY
			invModelMatrix.copy( modelMatrix );
			invModelMatrix.inverse();
			/*new Matrix4( 	modelMatrix.n11,
					modelMatrix.n21,
					modelMatrix.n31,
					- modelMatrix.n14,
					modelMatrix.n12,
					modelMatrix.n22,
					modelMatrix.n32,
					- modelMatrix.n24,
					modelMatrix.n13,
					modelMatrix.n23,
					modelMatrix.n33,
					- modelMatrix.n34 );*/
		}
		
		/**
		 * Nothing to do - the camera can't be culled
		 */
		public override function cull( p_oScene:Scene3D, p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			return;
		}
		
		/**
		* Returns the projection matrix of this camera. 
		* 
		* @return 	The projection matrix
		*/
		public function get projectionMatrix():Matrix4
		{
			return _mp;
		}
		
		/**
		 * Returns the inverse of the projection matrix of this camera.
		 *
		 * @return 	The inverted projection matrix
		 */
		public function get invProjectionMatrix():Matrix4
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
			
			_mpInv.copy( _mp );
			_mpInv.inverse();
			
			changed = true;	
		}
			
		/**
		 * Updates the perspective projection.
		 */
		public function updatePerspective():void
		{
			if( _perspectiveChanged )
			{
				setPerspectiveProjection( _nFov, viewport.ratio, _nNear, _nFar );
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
		private var _perspectiveChanged:Boolean = true;
		private var _mp:Matrix4 = new Matrix4(); // projection Matrix4
		private var _mpInv:Matrix4 = new Matrix4(); // Inverse of the projection matrix 

		private var m_aDisplayList:Array = new Array();
		private var m_aDisplayedList:Array;
		
		private var _nFov:Number;
		private var _nFar:Number;
		private var _nNear:Number;
		
		private var mp11:Number, mp21:Number,mp31:Number,mp41:Number,
					mp12:Number,mp22:Number,mp32:Number,mp42:Number,
					mp13:Number,mp23:Number,mp33:Number,mp43:Number,
					mp14:Number,mp24:Number,mp34:Number,mp44:Number,				
					m_nOffx:Number, m_nOffy:Number;
	}
}