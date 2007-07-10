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
	import sandy.core.World3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vertex;
	import sandy.view.CullingState;
	import sandy.view.Frustum;
	
	/**
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		1.0
	 * @date 		20.05.2006
	 **/
	final public class Sprite2D extends ATransformable implements IDisplayable
	{	
		/**
		* Sprite2D constructor.
		* A sprite is a special Object3D because it's in fact a bitmap in a 3D space.
		* The sprite is an element which always look at the camera, you'll always see the same face.
		* @param	void
		*/
		
		// FIXME Create a Sprite as the spriteD container, and offer a method to attach a visual content as a child of the sprite
		public function Sprite2D( p_name:String, p_oContent:DisplayObject, p_opScale:Number=1) 
		{
			super(p_name);
			m_oContainer = new Sprite();
			World3D.getInstance().container.addChild( m_oContainer );
			// --
			_v = new Vertex();
			_oBSphere 	= new BSphere();
	        _oBBox 		= null;
	        setBoundingSphereRadius( 30 );
	        // --
			_nScale = p_opScale;
			// --
			content = p_oContent;
		}


		public function set content( p_container:DisplayObject ):void
		{
			m_oContainer.addChildAt( p_container, 0 );
			m_nW2 = m_oContainer.width / 2;
			m_nH2 = m_oContainer.height / 2;
		}
		
		public function get content():DisplayObject
		{
			return m_oContainer.getChildAt(0);
		}
		
		public function get container():Sprite
		{return m_oContainer;}
		
		public function setBoundingSphereRadius( p_nRadius:Number ):void
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
		public function set scale( n:Number ):void
		{if( n )	_nScale = n; }

		public function get depth():Number
		{return m_nDepth;}
		  
		/**
		 * This method test the current node on the frustum to get its visibility.
		 * If the node and its children aren't in the frustum, the node is set to cull
		 * and it would not be displayed.
		 * This method is also updating the bounding volumes to process the more accurate culling system possible.
		 * First the bounding sphere are updated, and if intersecting, the bounding box are updated to perform a more
		 * precise culling.
		 * [MANDATORY] The update method must be called first!
		 */
		public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			super.cull(p_oFrustum, p_oViewMatrix, p_bChanged );
			// --
			if( culled == CullingState.OUTSIDE ) 	container.visible = false;
			else									container.visible = true;
		}
		
	    public override function render( p_oCamera:Camera3D ):void
		{
	        _v.wx = _v.x * _oViewCacheMatrix.n11 + _v.y * _oViewCacheMatrix.n12 + _v.z * _oViewCacheMatrix.n13 + _oViewCacheMatrix.n14;
			_v.wy = _v.x * _oViewCacheMatrix.n21 + _v.y * _oViewCacheMatrix.n22 + _v.z * _oViewCacheMatrix.n23 + _oViewCacheMatrix.n24;
			_v.wz = _v.x * _oViewCacheMatrix.n31 + _v.y * _oViewCacheMatrix.n32 + _v.z * _oViewCacheMatrix.n33 + _oViewCacheMatrix.n34;
			m_nDepth = _v.wz;
			m_nPerspScale = _nScale * 100/m_nDepth;
			// --
			p_oCamera.addToDisplayList( this );
			// -- We push the vertex to project onto the viewport.
			p_oCamera.addToProjectionList( _v );	
		}
		// --
		public function display( p_oContainer:Sprite = null ):void
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