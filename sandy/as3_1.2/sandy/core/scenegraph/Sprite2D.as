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
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import sandy.core.World3D;
	import sandy.view.Camera3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vertex;
	import sandy.core.face.IPolygon;
	import sandy.core.face.Polygon;
	import sandy.core.scenegraph.Shape3D;
	import sandy.skin.MovieSkin;
	import sandy.skin.Skin;
	import sandy.view.Frustum;
	import sandy.util.DisplayUtil;
	import sandy.events.SandyEvent;	
	
	/**
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		1.0
	 * @date 		20.05.2006
	 **/
	public class Sprite2D extends Shape3D 
	{
	    public var container:MovieClip;
	    
		/**
		* Sprite2D constructor.
		* A sprite is a special Object3D because it's in fact a bitmap in a 3D space.
		* The sprite is an element which always look at the camera, you'll always see the same face.
		* @param	void
		*/
		public function Sprite2D( p_name:String, pScale:Number = 1.0) 
		{
			super(p_name);
			
			// Special case - is using MovieClip rather than default Sprite
			container = new MovieClip();	
			// -- we create a fictive point
			geometry = new Geometry3D( [new Vertex() ] );
			_v = geometry.points[0];
			// --
			_nScale = pScale;
			// --
			// Add this graphical object to the World display list
			World3D.getInstance().getSceneContainer().addChild( container );
		}
		
		/**
		* Set a Skin to the Object3D.
		* <p>This method will set the the new Skin to all his faces.</p>
		* 
		* @param	s	The TexstureSkin to apply to the object
		* @return	Boolean True is the skin is applied, false otherwise.
		*/
		override public function setSkin( s:Skin ):Boolean
		{
			if ( !(s is MovieSkin) )
			{
				//trace("#Warning [Sprite2D] setSkin Wrong parameter type: MovieSkin expected.");
				return false;
			}
			
			_s = MovieSkin(s);
			
			if( _s.isInitialized() )
			{
				__updateContent(null);
			} 
			else 
			{
				_s.addEventListener( SandyEvent.UPDATE, __updateContent);
			}
			
			return true;
		}
		
		private function __updateContent(p_event:Event):void
		{
			_s.attach( container );
			container.cacheAsBitmap = true;
		}

		/**
		* getScale
		* <p>Allows you to get the scale of the Sprite3D and later change it with setSCale.
		* It is a number usefull to change the dimension of the sprite rapidly.
		* </p>
		* @param	void
		* @return Number the scale value.
		*/
		public function getScale():Number
		{
			return _nScale;
		}

		/**
		* Allows you to change the oject's scale.
		* @param	n Number 	The scale. This value must be a Number. A value of 1 let the scale as the perspective one.
		* 						A value of 2.0 will make the object twice bigger. 0 is a forbidden value
		*/
		public function setScale( n:Number ):void
		{
			if( n )
			{
				_nScale = n;
			}
		}
		
	    override public function render(p_oCamera:Camera3D, p_oViewMatrix:Matrix4, p_bCache:Boolean):void
		{
		    // VISIBILITY CHECK
			if( isVisible() == false ) 
			{
			    container.visible = false;
			    return;
			}
			
            var l_oFrustum:Frustum = p_oCamera.frustrum;
			// 
			var l_oModelMatrix:Matrix4 = __updateLocalViewMatrix( p_oCamera, p_oViewMatrix, p_bCache );
            
            // Now we consider the camera .Fixme consider the possible cache system for camera.
			var l_oMatrix:Matrix4 = p_oCamera.getProjectionMatrix() ;
            
            var v:Vertex;
            var i:int;
            for( i=0; v=geometry.points[i]; i++ )
            {
                v.wx = v.x * l_oModelMatrix.n11 + v.y * l_oModelMatrix.n12 + v.z * l_oModelMatrix.n13 + l_oModelMatrix.n14;
			    v.wy = v.x * l_oModelMatrix.n21 + v.y * l_oModelMatrix.n22 + v.z * l_oModelMatrix.n23 + l_oModelMatrix.n24;
			    v.wz = v.x * l_oModelMatrix.n31 + v.y * l_oModelMatrix.n32 + v.z * l_oModelMatrix.n33 + l_oModelMatrix.n34;
            }
            
			if( l_oFrustum.pointInFrustum( _v.getWorldVector() ) == Frustum.OUTSIDE )
			{
			    container.visible = false;
			    return;
			} 
			else 
			{
    			///////////////////////////////////
    			///////  SCREEN PROJECTION ////////
    			///////////////////////////////////
    			var l_nCste:Number;
    			var l_nOffx:Number = p_oCamera.viewport.w2;
    			var l_nOffy:Number = p_oCamera.viewport.h2;
    			// --
    			l_nCste = 	1 / ( _v.wx * l_oMatrix.n41 + _v.wy * l_oMatrix.n42 + _v.wz * l_oMatrix.n43 + l_oMatrix.n44 );
    			_v.sx =  l_nCste * ( _v.wx * l_oMatrix.n11 + _v.wy * l_oMatrix.n12 + _v.wz * l_oMatrix.n13 + l_oMatrix.n14 ) * l_nOffx + l_nOffx;
    			_v.sy = -l_nCste * ( _v.wx * l_oMatrix.n21 + _v.wy * l_oMatrix.n22 + _v.wz * l_oMatrix.n23 + l_oMatrix.n24 ) * l_nOffy + l_nOffy;
    			// --
			    container.scaleX = container.scaleY = (_nScale * 100 / _v.wz);
			    // --
			    container.x = _v.sx - container.width  / 2;
			    container.y = _v.sy - container.height / 2;
			    // We add the graphic object to the display List.
			    p_oCamera.addToDisplayList( container, _v.wz );  
			}
		}

		
		protected var _v:Vertex;
		private var _nScale:Number;
		protected var _s:MovieSkin;
	}
}