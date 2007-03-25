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

import com.bourre.events.BasicEvent;

import sandy.core.data.Matrix4;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.scenegraph.Sprite2D;
import sandy.events.SandyEvent;
import sandy.math.VectorMath;
import sandy.skin.MovieSkin;
import sandy.skin.Skin;
import sandy.util.NumberUtil;
import sandy.view.Camera3D;
	
/**
 * @author		Thomas Pfeiffer - kiroukou
 * @date 		28.02.2007
 **/
class sandy.core.scenegraph.Sprite3D extends Sprite2D 
{
	/**
	* A Sprite3D is in fact a special Sprite2D. A Sprite3D is batween a real Object3D and a Sprite2D.
	* It has a skin which is a movie clip containing 360 frames (at least!). 
	* Depending on the camera position, the _currentframe of the Clip3D will change, to give a 3D effect.
	* @param	pOffset Number 	A number between [0-360] to give an offset in the 3D representation.
	* @param 	pScale Number 	A number used to change the scale of the displayed object. In case that the object projected dimension
	* 							isn't adapted to your needs. Default value is 1.0 which means unchanged. A value of 2.0 will make the object
	* 							twice bigger and so on.
	*/
	public function Sprite3D( p_Name:String, pScale:Number pOffset:Number ) 
	{
		super(p_Name, pScale);
		// -- we create a fictive normal vector
		_dir = new Vertex( 0, 0, -1 );
		_vView = new Vector(0, 0, 1);
		// -- set the offset
		_nOffset = pOffset||0;
		//
		geometry.addPoint( _dir );
	}
	
	/**
	* Set a Skin to the Object3D.
	* <p>This method will set the the new Skin to all his faces.</p>
	* 
	* @param	s	The TexstureSkin to apply to the object
	* @return	Boolean True is the skin is applied, false otherwise.
	*/
	public function setSkin( s:Skin ):Boolean
	{
		if ( !(s instanceof MovieSkin) )
		{
			//trace("#Warning [Sprite3D] setSkin Wrong parameter type: MovieSkin expected.");
			return false;
		}
		
		_s = MovieSkin(s);
		
		if( _s.isInitialized() )
			__updateContent(null);
		else
			_s.addEventListener( SandyEvent.UPDATE, __updateContent);
			
		return true;
	}
	
	private function __updateContent(p_event:BasicEvent):Void
	{
		if( MovieClip(_s.getMovie()).totalFrames != 360 )
		{
			trace("Sprite3D:: Error, the skin movie must have 360 frames");
		}
		else
		{
			container =  MovieClip(_s.attach( container ));
			container.cacheAsBitmap = true;
		}
	}

	
	/**
	* Render the Sprite3D.
	* <p>Check Faces display visibility and store visible Faces into ZBuffer.</p>
	*/ 
	public function render(p_oCamera:Camera3D, p_oViewMatrix:Matrix4, p_bCache:Boolean):Void
	{
		if (!_s.isInitialized()) return;
				    // VISIBILITY CHECK
		super.render(p_oCamera, p_oViewMatrix, p_bCache);
		
		if( container.visible )
		{
            var vNormale:Vector = new Vector( _v.wx - _dir.wx, _v.wy - _dir.wy, _v.wz - _dir.wz );
			var angle:Number = VectorMath.getAngle( _vView, vNormale );
			if( vNormale.x < 0 ) angle = 2*Math.PI - angle;
			// FIXME problem around 180 frame. A big jump occurs. Problem of precision ?
			container.gotoAndStop( __frameFromAngle( angle ) );
		}
	}
	
	
	private function __frameFromAngle(a:Number):Number
		{
			a = NumberUtil.toDegree( a );
			a = (( a + _nOffset )+360) % 360;
			return a;
		}
			

		/**
		* getOffset
		* Ollows you to get the offset of the Clip3D and later change it with setOffset if you need.
		* @param	void
		* @return
		*/
		public function getOffset():Number
		{
			return _nOffset;
		}
		
		/**
		* Allows you to change the oject offset.
		* @param	n Number The offset. This value must be between 0 and 360.
		*/
		public function setOffset( n:Number ):Void
		{
			_nOffset = n;
		}
		
		// -- frames offset
		private var _nOffset:Number;
		private var _nScale:Number;
		private var _vView:Vector;
		private var _dir:Vertex;
		
	}