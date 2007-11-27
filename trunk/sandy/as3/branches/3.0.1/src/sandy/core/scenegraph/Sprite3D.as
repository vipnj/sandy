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
	import flash.display.MovieClip;
	import flash.display.Sprite;

	import sandy.bounds.BSphere;
	import sandy.core.Scene3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.math.VectorMath;
	import sandy.util.NumberUtil;
	import sandy.view.CullingState;
	import sandy.view.Frustum;

	/**
	 * The Sprite3D class is use to create a 3D sprite.
	 *
	 * <p>A Sprite3D can be seen as a special Sprite2D.<br/>
	 * It has an appearance that is a movie clip containing 360 frames (as maximum!) with texture.</p>
	 *
	 * <p>Depending on the camera position, a different frame of the clip is shown, givin a 3D effect.<p/>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		1.0
	 * @date 		20.05.2006
	 **/
	public class Sprite3D extends ATransformable implements IDisplayable
	{
		// FIXME Create a Sprite as the spriteD container,
		// and offer a method to attach a visual content as a child of the sprite
		public var offset:uint = 0;

		/**
		 * When enabled, the sprite will be displayed at its graphical center.
		 * Otherwise its top left corner will be set at the computed screen position
		 */
		public var autoCenter:Boolean = true;

		 /**
	 	 * Creates a Sprite3D
		 *
		 * @param p_sName 	A string identifier for this object
		 * @param p_oContent	The Movieclip containing the pre-rendered textures
		 * @param p_nScale 	A number used to change the scale of the displayed object.
		 * 			In case that the object projected dimension
		 *			isn't adapted to your needs.
		 *			Default value is 1.0 which means unchanged.
		 * 			A value of 2.0 will make the object will double the size
		 *
		 * @param p_nOffset 	A number between [0-360] to give a frame offset into the clip.
		 */
		public function Sprite3D( p_sName:String = "", p_oContent:MovieClip = null, p_nScale:Number=1, p_nOffset:Number=0 )
		{
			super(p_sName);
			m_oContainer = new Sprite();
			// --
			_v = new Vertex();
			boundingSphere 	= new BSphere();
	        boundingBox 	= null;
	        // --
			_nScale = p_nScale;
			// --
			if( p_oContent )content = p_oContent;
			// --
			_dir = new Vertex( 0, 0, -1 );
			_vView = new Vector( 0, 0, 1 );
			// -- set the offset
			offset = p_nOffset;

			setBoundingSphereRadius( 30 );
		}

		/**
		 * The MovieClip that will used as content of this Sprite2D.
		 * If this MovieClip has already a scree position, it will be reseted to 0,0.
		 *
		 * @param p_container The MovieClip to attach to the Sprite3D#container.
		 */
		public function set content( p_container:MovieClip ):void
		{
			p_container.x = 0;
			p_container.y = 0;
			if( m_oContent ) m_oContent.parent.removeChild( m_oContent );
			m_oContent = p_container;
			m_oContainer.addChildAt( m_oContent, 0 );
			m_nW2 = m_oContainer.width / 2;
			m_nH2 = m_oContainer.height / 2;
			// --
			m_nAutoOffset = m_oContent.totalFrames / 360;
		}

		/**
		 * @private
		 */
		public function get content():MovieClip
		{
			return m_oContent;
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
		{ return _nScale; }

		/**
		 * @private
		 */
		public function set scale( n:Number ):void
		{
			if( n )	_nScale = n;
		}

		/**
		 * The depth to draw this sprite at.
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
			super.cull(p_oScene, p_oFrustum, p_oViewMatrix, p_bChanged );
			//
			if( viewMatrix )
			{
				/////////////////////////
		        //// BOUNDING SPHERE ////
		        /////////////////////////
		        boundingSphere.transform( viewMatrix );
		        culled = p_oFrustum.sphereInFrustum( boundingSphere );
			}
			// --
			if( culled == CullingState.OUTSIDE )  container.visible = false;
			else container.visible = true;
		}

		/**
		 * Renders this 3D sprite
		 *
		 * @param p_oScene The current scene
		 * @param p_oCamera	The current camera
		 */
	    public override function render( p_oScene:Scene3D, p_oCamera:Camera3D ):void
		{
	       	const l_oMatrix:Matrix4 = viewMatrix,
					m11:Number = l_oMatrix.n11, m21:Number = l_oMatrix.n21, m31:Number = l_oMatrix.n31,
					m12:Number = l_oMatrix.n12, m22:Number = l_oMatrix.n22, m32:Number = l_oMatrix.n32,
					m13:Number = l_oMatrix.n13, m23:Number = l_oMatrix.n23, m33:Number = l_oMatrix.n33,
					m14:Number = l_oMatrix.n14, m24:Number = l_oMatrix.n24, m34:Number = l_oMatrix.n34;

	        _dir.wx = _dir.x * m11 + _dir.y * m12 + _dir.z * m13 + m14;
			_dir.wy = _dir.x * m21 + _dir.y * m22 + _dir.z * m23 + m24;
			_dir.wz = _dir.x * m31 + _dir.y * m32 + _dir.z * m33 + m34;

			_v.wx = _v.x * m11 + _v.y * m12 + _v.z * m13 + m14;
			_v.wy = _v.x * m21 + _v.y * m22 + _v.z * m23 + m24;
			_v.wz = _v.x * m31 + _v.y * m32 + _v.z * m33 + m34;

			m_nDepth = _v.wz;
			m_nPerspScale = _nScale * 100/m_nDepth;
			// --
			p_oCamera.projectVertex( _v );
			p_oCamera.addToDisplayList( this );
			// -- We push the vertex to project onto the viewport.
	        m_oNormale.x = _v.wx - _dir.wx;
	        m_oNormale.y = _v.wy - _dir.wy;
	        m_oNormale.z = _v.wz - _dir.wz;
			m_nAngle = VectorMath.getAngle( _vView, m_oNormale );
			if( m_oNormale.x < 0 ) m_nAngle = 2*Math.PI - m_nAngle;

			// FIXME problem around 180 frame. A big jump occurs. Problem of precision ?
			m_oContent.gotoAndStop( __frameFromAngle( m_nAngle ) );
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
		}

		// Returns the frame to show at the current camera angle
		private function __frameFromAngle(a:Number):uint
		{
			a = NumberUtil.toDegree( a );
			a = (( a + offset )+360) % 360;
			// -- we have a frame for a 360 content, let's make it fit the current one
			a = ( a * m_nAutoOffset ) << 0;
			return uint(a);
		}

		// -- frames offset
		private var _vView:Vector;
		private var _dir:Vertex;
		private var m_oNormale:Vector;
		private var m_nAutoOffset:Number;
		private var m_nPerspScale:Number=0;
		private var m_nAngle:Number;
		private var m_nW2:Number=0;
		private var m_nH2:Number=0;
		protected var _v:Vertex;
		private var m_nDepth:Number;
		private var _nScale:Number;
		private var m_oContainer:Sprite;
		private var m_oContent:MovieClip;
	}
}