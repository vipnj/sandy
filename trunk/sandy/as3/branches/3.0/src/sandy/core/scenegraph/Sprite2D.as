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
	
	import sandy.bounds.BSphere;
	import sandy.core.Scene3D;
	import sandy.core.World3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vertex;
	import sandy.view.CullingState;
	import sandy.view.Frustum;
	
	/**
	 * The Sprite2D class is use to create a 2D sprite.
	 *
	 * <p>A Sprite2D object is used to display a static or dynamic texture in the Sandy world.<br/>
	 * The sprite always shows the same side to the camera. This is useful when you want to show more
	 * or less complex images, without heavy calculations of perspective distortion.</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class Sprite2D extends ATransformable implements IDisplayable
	{	
		// FIXME Create a Sprite as the spriteD container, 
		//and offer a method to attach a visual content as a child of the sprite
		
		/**
		 * Creates a Sprite2D.
		 *
		 * @param p_sName	A string identifier for this object
		 * @param p_oContent	The texture to display
		 * @param p_nScale 	A number used to change the scale of the displayed object.
		 * 			In case that the object projected dimension
		 *			isn't adapted to your needs. 
		 *			Default value is 1.0 which means unchanged. 
		 * 			A value of 2.0 will make the object will double the size
		 */	
		public function Sprite2D( p_sName:String, p_oContent:DisplayObject, p_nScale:Number=1) 
		{
			super(p_sName);
			m_oContainer = new Sprite();
			World3D.getInstance().container.addChild( m_oContainer );
			// --
			_v = new Vertex();
			_oBSphere 	= new BSphere();
	        	_oBBox 		= null;
	        	setBoundingSphereRadius( 30 );
	        	// --
			_nScale = p_nScale;
			// --
			content = p_oContent;
		}

		/**
		 * The texture of this sprite.
		 */
		public function set content( p_container:DisplayObject ):void
		{
			m_oContainer.addChildAt( p_container, 0 );
			m_nW2 = m_oContainer.width / 2;
			m_nH2 = m_oContainer.height / 2;
		}
		
		/**
		 * @private
		 */
		public function get content():DisplayObject
		{
			return m_oContainer.getChildAt(0);
		}
		
		/**
		 * The container of this sprite ( canvas )
		 */
		public function get container():Sprite
		{
			return m_oContainer;
		}
		
		/**
		 * Sets the radius of bounding sphere for this sprite.
		 *
		 * @param p_nRadius	The radius
		 */
		public function setBoundingSphereRadius( p_nRadius:Number ):void
		{ 
			_oBSphere.radius = p_nRadius; 
		}
	
		/**
		 * The scale of this sprite.
		 *
		 * <p>Using scale, you can change the dimension of the sprite rapidly.</p>
		 */
		public function get scale():Number
		{ 
			return _nScale; 
		}
	
		/**
		 * @private
		 */
		public function set scale( n:Number ):void
		{
			if( n )	_nScale = n; 
		}
		
		/**
		 * The depth to draw this sprite at.
		 * <p>[<b>ToDo</b>: Explain ]</p>
		 */
		public function get depth():Number
		{
			return m_nDepth;
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
		public override function cull( p_oScene:Scene3D, p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			super.cull( p_oScene, p_oFrustum, p_oViewMatrix, p_bChanged );
			// --
			if( _oViewCacheMatrix )
			{
				/////////////////////////
		        //// BOUNDING SPHERE ////
		        /////////////////////////
		        _oBSphere.transform( _oViewCacheMatrix );
		        culled = p_oFrustum.sphereInFrustum( _oBSphere );
				// --
				if( culled == Frustum.INTERSECT && _oBBox )
				{
		            ////////////////////////
		            ////  BOUNDING BOX  ////
		            ////////////////////////
		            _oBBox.transform( _oViewCacheMatrix );
		            culled = p_oFrustum.boxInFrustum( _oBBox );
				}
			}
			// --
			if( culled == CullingState.OUTSIDE ) 	container.visible = false;
			else									container.visible = true;
		}
		
		/**
		 * Renders this 2D sprite
		 *
		 * @param p_oScene The current scene
		 * @param p_oCamera	The current camera
		 */
	    public override function render( p_oScene:Scene3D, p_oCamera:Camera3D ):void
		{
	    	_v.wx = _v.x * _oViewCacheMatrix.n11 + _v.y * _oViewCacheMatrix.n12 + _v.z * _oViewCacheMatrix.n13 + _oViewCacheMatrix.n14;
			_v.wy = _v.x * _oViewCacheMatrix.n21 + _v.y * _oViewCacheMatrix.n22 + _v.z * _oViewCacheMatrix.n23 + _oViewCacheMatrix.n24;
			_v.wz = _v.x * _oViewCacheMatrix.n31 + _v.y * _oViewCacheMatrix.n32 + _v.z * _oViewCacheMatrix.n33 + _oViewCacheMatrix.n34;
			m_nDepth = _v.wz;
			m_nPerspScale = _nScale * 100/m_nDepth;
			// --
			p_oCamera.addToDisplayList( this );
			// -- We push the vertex to project onto the viewport.
			p_oCamera.projectVertex( _v );	
		}

		/**
		 * Clears the graphics object of this object's container.
		 *
		 * <p>The the graphics that were drawn on the Graphics object is erased, 
		 * and the fill and line style settings are reset.</p>
		 */	
		public function clear():void
		{
			;//m_oContainer.graphics.clear();
		}
		
		/**
		 * Displays this sprite xxx.
		 *
		 * <p>[<b>ToDo</b>: We have a FIXME label here, so it may not work as expected ]</p>
		 *
		 * @param p_oScene The current scene
		 * @param p_oContainer	The container to draw on
		 */
		public function display( p_oScene:Scene3D, p_oContainer:Sprite = null ):void
		{
			//FIXME I don't like the way the perspective is applied here...
			m_oContainer.scaleX = m_oContainer.scaleY = m_nPerspScale;
			m_oContainer.x = _v.sx - m_nW2;
			m_oContainer.y = _v.sy - m_nH2;
		}
		
		private var m_nPerspScale:Number=0;
		private var m_nW2:Number=0;
		private var m_nH2:Number=0;
		protected var _v:Vertex;
		private var m_nDepth:Number;
		private var _nScale:Number;
		private var m_oContainer:Sprite;
	}
}