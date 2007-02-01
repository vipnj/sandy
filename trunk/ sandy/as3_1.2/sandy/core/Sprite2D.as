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

package sandy.core 
{

	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import sandy.core.buffer.ZBuffer;
	import sandy.core.data.Vertex;
	import sandy.core.face.IPolygon;
	import sandy.core.face.Polygon;
	import sandy.core.Object3D;
	import sandy.skin.MovieSkin;
	import sandy.skin.BasicSkin;
	import sandy.view.Frustum;
	import sandy.util.DisplayUtil;
	
	
	
	/**
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		1.0
	 * @date 		20.05.2006
	 **/
	public class Sprite2D extends Object3D 
	{
		/**
		* Sprite2D constructor.
		* A sprite is a special Object3D because it's in fact a bitmap in a 3D space.
		* The sprite is an element which always look at the camera, you'll always see the same face.
		* @param	void
		*/
		public function Sprite2D( pScale:Number = 1.0) 
		{
			super();
			
			// Special case - is using MovieClip rather than default Sprite
			setContainer( DisplayUtil.replaceObject(getContainer(), new MovieClip()) );
				
			// -- we create a fictive point
			_v = new Vertex( 0, 0, 0 );
			aPoints[0] = _v;
			aClipped = aPoints;
			// --
			_nScale = pScale;
			// --
		}
		
		/**
		* Set a Skin to the Object3D.
		* <p>This method will set the the new Skin to all his faces.</p>
		* 
		* @param	s	The TexstureSkin to apply to the object
		* @return	Boolean True is the skin is applied, false otherwise.
		*/
		override public function setSkin( s:BasicSkin ):Boolean
		{
			if ( !(s is MovieSkin) )
			{
				trace("#Warning [Sprite2D] setSkin Wrong parameter type: MovieSkin expected.");
				return;
			}
			
			_s = s;
			
			if( _s.isInitialized() )
			{
				__updateContent();
			} else {
				_s.addEventListener( SandyEvent.UPDATE, __updateContent);
			}
			
			return true;
		}
		
		private function __updateContent():void
		{
			_s.attach( getContainer() );
		}

		/**
		 * This method isn't enable with the Sprite object. You might get the reason ;)
		 * Returns always false.
		 */
		override public function setBackSkin( s:BasicSkin/*, bOverWrite:Boolean */):Boolean
		{
			/*if ( !(s is MovieSkin) )
			{
				trace("#Warning [Sprite2D] setSkin Wrong parameter type: MovieSkin expected.");
				return;
			}*/
			
			return false;
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
		
		/**
		* Render the Object3D.
		* <p>Check Faces display visibility and store visible Faces into ZBuffer.</p>
		*/ 
		override public function render ():void
		{		
			getContainer().visible = true;
			
			ZBuffer.push( { movie:getContainer(), depth:_v.wz, callback:_fCallback } );
			
			setModified( false );
		}
		
		private function __renderFaces():void
		{
			// --
			var cste:Number	= _nScale * 100 / _v.wz;
			var mc:MovieClip =  MovieClip(getContainer());
			
			// --
			mc.xscale = 100 * cste;
			mc.yscale = 100 * cste;
			
			// --
			mc.x = _v.sx - mc.width  / 2;
			mc.y = _v.sy - mc.height / 2;
			
			// --
		}
		
		override public function addFace( f:Polygon ):void
		{
			;
		}
			
		/**
		* Erase the behaviour of the Sprite2D addPoint method because Sprite2D handles itself its points. You can't add vertex by yourself here.
		* @param	x
		* @param	y
		* @param	z
		*/
		override public function addPoint( x:Number, y:Number, z:Number ):uint
		{
			return;
		}
		
		override public function enableClipping( b:Boolean ):void
		{
			_enableClipping = b;
		}
		
		override public function clip( frustum:Frustum ):Boolean
		{
			var result:Boolean = false;
			
			if( _enableClipping )
			{
				if( frustum.pointInFrustum( _v.getWorldVector() ) == Frustum.OUTSIDE )
				{
					result =  true;
				} else {
					result =  false;
				}
			} else {
				result =  false;
			}
			
			if( result ) getContainer().visible = false;
			
			return result;
		}
		
		protected var _v:Vertex;
		private var _nScale:Number;
		private var _s:MovieSkin;
	}
}