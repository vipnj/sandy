/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author Thomas PFEIFFER
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

package sandy.primitive
{
	import sandy.core.scenegraph.TransformGroup;

	/**
	 * @author		Thomas Pfeiffer
	 * @version		3.0
	 * @date 		26.09.2007
	 *
	 * @example To create a skybox, apply some appearance and, if needed, remove some of the sides
	 * <listing version="3.0">
	 * 	// -- creation of the skybox
	 *  var l_oSkyBox:SkyBox = new SkyBox( "game_sky", 3000, 6, 6 );
	 *  // -- Access to FRONT, BACK, LEFT and RIGHT planes, and set an appearance
	 *	l_oSkyBox.front.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );
	 *	l_oSkyBox.back.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );
	 *	l_oSkyBox.left.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );
	 *	l_oSkyBox.right.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );
	 *	// -- In case you don't need some of the skybox side, access to them, and remove them.
	 *	l_oSkyBox.top.remove();
	 *	l_oSkyBox.bottom.remove();
	 *	// -- link the skybox to a group to make is displayable
	 *	l_oGroup.addChild( l_oSkyBox );
	 *  </listing>
	 */
	
	public class SkyBox extends TransformGroup
	{
		private var m_aPlanes:Array = new Array(6);
		
		/**
		 * Creates a SkyBox objets
		 *
		 * <p>The skybox is created as a TransformGroup. This is a special behaviour comparing the other primitives which directly extend Shape3D.
		 * A skyBox isn't a graphical object itself, but it is composed of 6 planes (Plane3D objects) that represents the 6 sides of the skybox.</p>
		 * 
		 * <p>The planes are automatically created, and placed for you. You can access them individually thanks to the getter methods.
		 * The planes are created with a default name, which is simply the concatenation of the skybox name and "_left" for the left side, "_top" for the top side etc.
		 * </p>
		 * 
		 * @param p_sName The name of the skybox. It is recommended to give a explicit name.
		 * @param p_nDim The dimension of the skybox
		 * @param p_nQualityH The horizontal quality of the skybox (WARNING:Some faces are rotated, and so, the quality isn't representative. To fix!)
		 * @param p_nQualityV The vertical quality of the skybox (WARNING:Some faces are rotated, and so, the quality isn't representative. To fix!)
		 * @param p_bDisable - default true - A boolean value if enabled make the SkyBox static.
		 *
		 */	
		public function SkyBox(p_sName:String="", p_nDim:Number = 100, p_nQualityH:uint = 1, p_nQualityV:uint=1, p_bDisable:Boolean = true )
		{
			super(p_sName);
			var l_oPlane:Plane3D;
			// -- LEFT
			l_oPlane = new Plane3D( p_sName+"_left", p_nDim, p_nDim, p_nQualityH, p_nQualityV, Plane3D.YZ_ALIGNED );
			l_oPlane.swapCulling();
			l_oPlane.rotateX = -90;
			l_oPlane.x = -p_nDim/2;
			m_aPlanes[0] = l_oPlane;
			// -- RIGHT
			l_oPlane = new Plane3D( p_sName+"_right", p_nDim, p_nDim, p_nQualityH, p_nQualityV, Plane3D.YZ_ALIGNED );
			l_oPlane.rotateX = -90;
			l_oPlane.x = p_nDim/2;
			m_aPlanes[1] = l_oPlane;
			// -- FRONT
			l_oPlane = new Plane3D( p_sName+"_front", p_nDim, p_nDim, p_nQualityH, p_nQualityV, Plane3D.XY_ALIGNED );
			l_oPlane.z = p_nDim/2;
			m_aPlanes[2] = l_oPlane;
			// -- BACK
			l_oPlane = new Plane3D( p_sName+"_back", p_nDim, p_nDim, p_nQualityH, p_nQualityV, Plane3D.XY_ALIGNED );
			l_oPlane.rotateY = 180;
			l_oPlane.z = -p_nDim/2;
			m_aPlanes[3] = l_oPlane;
			// -- TOP
			l_oPlane = new Plane3D( p_sName+"_top", p_nDim, p_nDim, p_nQualityH, p_nQualityV, Plane3D.ZX_ALIGNED );
			l_oPlane.swapCulling();
			l_oPlane.rotateY = -90;
			l_oPlane.y = p_nDim/2;
			m_aPlanes[4] = l_oPlane;
			// -- BOTTOM
			l_oPlane = new Plane3D( p_sName+"_bottom", p_nDim, p_nDim, p_nQualityH, p_nQualityV, Plane3D.ZX_ALIGNED );
			l_oPlane.rotateY = -90;
			l_oPlane.y = -p_nDim/2;
			m_aPlanes[5] = l_oPlane;
			
			
			for each( l_oPlane in m_aPlanes )
			{
				if( p_bDisable ) l_oPlane.disable = true;
				this.addChild( l_oPlane );
			}
		}
		
		public function get left():Plane3D
		{return m_aPlanes[0];}
		
		public function get right():Plane3D
		{return m_aPlanes[1];}
		
		public function get front():Plane3D
		{return m_aPlanes[2];}
		
		public function get back():Plane3D
		{return m_aPlanes[3];}
		
		public function get top():Plane3D
		{return m_aPlanes[4];}
		
		public function get bottom():Plane3D
		{return m_aPlanes[5];}
	}
}