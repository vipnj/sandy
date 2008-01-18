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
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import sandy.bounds.BSphere;
	import sandy.core.Scene3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vertex;
	import sandy.events.BubbleEvent;
	import sandy.view.CullingState;
	import sandy.view.Frustum;
	
	/**
	 * The Sprite2D class is use to create a 2D sprite.
	 *
	 * <p>A Sprite2D object is used to display a static or dynamic texture in the Sandy world.<br/>
	 * The sprite always shows the same side to the camera. This is useful when you want to show more
	 * or less complex images, without heavy calculations of perspective distortion.</p>
	 * <p>The Sprite2D has a fixed bounding sphere radius, set by default to 30.<br />
	 * In case your sprite is bigger, you can adjust it to avoid any frustum culling issue</p>
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
		 * Set this to true if you want this sprite to rotate with camera.
		 */
		public var fixedAngle:Boolean = false;

		/**
		 * When enabled, the sprite will be displayed at its graphical center.
		 * Otherwise its top left corner will be set at the computed screen position
		 */
		public var autoCenter:Boolean = true;
		
		/**
		 * Creates a Sprite2D.
		 *
		 * @param p_sName	A string identifier for this object
		 * @param p_oContent	The container containing all the pre-rendered picture
		 * @param p_nScale 	A number used to change the scale of the displayed object.
		 * 			In case that the object projected dimension
		 *			isn't adapted to your needs. 
		 *			Default value is 1.0 which means unchanged. 
		 * 			A value of 2.0 will make the object will double the size
		 */	
		public function Sprite2D( p_sName:String = "", p_oContent:DisplayObject = null, p_nScale:Number=1) 
		{
			super(p_sName);
			m_oContainer = new Sprite();
			// --
			_v = new Vertex();
			boundingSphere 	= new BSphere();
	        boundingBox		= null;
	        // --
			_nScale = p_nScale;
			// --
			if( p_oContent ) content = p_oContent;
			
			setBoundingSphereRadius( 30 );
		}

		/**
		 * The DisplayObject that will used as content of this Sprite2D. 
		 * If this DisplayObject has already a screen position, it will be reseted to 0,0.
		 * If the DisplayObject has allready a parent, it will be unrelated from it automatically. (its transform matrix property is resetted to identity too).
		 * @param p_container The DisplayObject to attach to the Sprite2D#container. 
		 */
		public function set content( p_container:DisplayObject ):void
		{
			if( p_container.transform ) p_container.transform.matrix.identity();
			if( m_oContent ) m_oContent.parent.removeChild( m_oContent );
			m_oContent = p_container;
			m_oContainer.addChildAt( p_container, 0 );
			p_container.x = 0;
			p_container.y = 0;
			m_nW2 = m_oContainer.width / 2;
			m_nH2 = m_oContainer.height / 2;
		}
		
		/**
		 * Get the content DisplayObject reference
		 * @return The DisplayObject Sprite2D content reference
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
			boundingSphere.radius = p_nRadius; 
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
			if( viewMatrix )
			{
				/////////////////////////
		        //// BOUNDING SPHERE ////
		        /////////////////////////
		        boundingSphere.transform( viewMatrix );
		        culled = p_oFrustum.sphereInFrustum( boundingSphere );
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
	    	_v.wx = _v.x * viewMatrix.n11 + _v.y * viewMatrix.n12 + _v.z * viewMatrix.n13 + viewMatrix.n14;
			_v.wy = _v.x * viewMatrix.n21 + _v.y * viewMatrix.n22 + _v.z * viewMatrix.n23 + viewMatrix.n24;
			_v.wz = _v.x * viewMatrix.n31 + _v.y * viewMatrix.n32 + _v.z * viewMatrix.n33 + viewMatrix.n34;
			m_nDepth = _v.wz;
			m_nPerspScale = _nScale * 100/m_nDepth;
			m_nAngle = Math.atan2( viewMatrix.n22, viewMatrix.n12 );
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
		 * Provide the classical remove behaviour, plus remove the container to the display list.
		 */
		public override function remove():void
		{
			if( m_oContainer.parent ) m_oContainer.parent.removeChild( m_oContainer );
			super.remove();
		}
		
		/**
		 * Displays this sprite.
		 *
		 * <p>display the object onto the scene.
		 * If the object has autocenter enabled, sprite center is set at screen position.
		 * Otherwise the sprite top left corner will be at that position.</p>
		 *
		 * @param p_oScene The current scene
		 * @param p_oContainer	The container to draw on
		 */
		public function display( p_oScene:Scene3D, p_oContainer:Sprite = null  ):void
		{
			m_oContainer.scaleX = m_oContainer.scaleY = m_nPerspScale;
			m_oContainer.x = _v.sx - (autoCenter ? m_oContainer.width/2 : 0);
			m_oContainer.y = _v.sy - (autoCenter ? m_oContainer.height/2 : 0);
			// --
			if (fixedAngle) m_oContainer.rotation = 90 - m_nAngle * 180 / Math.PI;
		}
		
		public function get enableEvents():Boolean
		{
			return m_bEv;
		}
		
		public function set enableEvents( b:Boolean ):void
		{
			if( b &&!m_bEv )
			{
				m_oContainer.addEventListener(MouseEvent.CLICK, _onInteraction);
	    		m_oContainer.addEventListener(MouseEvent.MOUSE_UP, _onInteraction);
	    		m_oContainer.addEventListener(MouseEvent.MOUSE_DOWN, _onInteraction);
	    		m_oContainer.addEventListener(MouseEvent.ROLL_OVER, _onInteraction);
	    		m_oContainer.addEventListener(MouseEvent.ROLL_OUT, _onInteraction);
	    		
				m_oContainer.addEventListener(MouseEvent.DOUBLE_CLICK, _onInteraction);
				m_oContainer.addEventListener(MouseEvent.MOUSE_MOVE, _onInteraction);
				m_oContainer.addEventListener(MouseEvent.MOUSE_OVER, _onInteraction);
				m_oContainer.addEventListener(MouseEvent.MOUSE_OUT, _onInteraction);
				m_oContainer.addEventListener(MouseEvent.MOUSE_WHEEL, _onInteraction);
			}
			else if( !b && m_bEv )
			{
				m_oContainer.removeEventListener(MouseEvent.CLICK, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.MOUSE_UP, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.MOUSE_DOWN, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.ROLL_OVER, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.ROLL_OUT, _onInteraction);
				
				m_oContainer.removeEventListener(MouseEvent.DOUBLE_CLICK, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.MOUSE_MOVE, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.MOUSE_OVER, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.MOUSE_OUT, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.MOUSE_WHEEL, _onInteraction);
			}
		}
		
		protected function _onInteraction( p_oEvt:Event ):void
		{
			m_oEB.broadcastEvent( new BubbleEvent( p_oEvt.type, this, p_oEvt ) );
		}
		
		private var m_bEv:Boolean = false; // The event system state (enable or not)
		
		private var m_nPerspScale:Number=0;
		private var m_nAngle:Number = 0;
		private var m_nW2:Number=0;
		private var m_nH2:Number=0;
		protected var _v:Vertex;
		private var m_nDepth:Number;
		private var _nScale:Number;
		private var m_oContainer:Sprite;
		private var m_oContent:DisplayObject;
	}
}