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

import sandy.core.buffer.ZBuffer;
import sandy.core.data.Vertex;
import sandy.core.face.IPolygon;
import sandy.core.Object3D;
import sandy.skin.MovieSkin;
import sandy.view.Frustum;

/**
 * @author		Thomas Pfeiffer - kiroukou
 * @version		1.0
 * @date 		20.05.2006
 **/
class sandy.core.Sprite2D extends Object3D 
{
	/**
	* Sprite2D constructor.
	* A sprite is a special Object3D because it's in fact a bitmap in a 3D space.
	* The sprite is an element which always look at the camera, you'll always see the same face.
	* @param	Void
	*/
	public function Sprite2D( pScale:Number ) 
	{
		super();
		// -- we create a fictive point
		_v = new Vertex( 0, 0, 0 );
		aPoints[0] = _v;
		aClipped = aPoints;
		// --
		_nScale = (undefined == pScale) ? 1.0 : pScale;
		// --
	}
	
	/**
	* Set a Skin to the Object3D.
	* <p>This method will set the the new Skin to all his faces.</p>
	* 
	* @param	s	The skin to apply to the object. Must be a MovieSkin, not a TextureSkin.
	* @return	Boolean True is the skin is applied, false otherwise.
	*/
	public function setSkin( s:MovieSkin ):Boolean
	{
		_s = s;
		if( _s.isInitialized() )
			__updateContent();
		else
			_s.addEventListener( MovieSkin.onUpdateEVENT, this, __updateContent);
		return true;
	}
	
	private function __updateContent( Void ):Void
	{
		_s.attach( container );
	}

	/**
	 * This method isn't enable with the Sprite object. You might get the reason ;)
	 * Returns always false.
	 */
	public function setBackSkin( s:MovieSkin, bOverWrite:Boolean ):Boolean
	{
		return false;
	}

	/**
	* getScale
	* <p>Allows you to get the scale of the Sprite3D and later change it with setSCale.
	* It is a number usefull to change the dimension of the sprite rapidly.
	* </p>
	* @param	Void
	* @return Number the scale value.
	*/
	public function getScale( Void ):Number
	{
		return _nScale;
	}

	/**
	* Allows you to change the oject's scale.
	* @param	n Number 	The scale. This value must be a Number. A value of 1 let the scale as the perspective one.
	* 						A value of 2.0 will make the object twice bigger. 0 is a forbidden value
	*/
	public function setScale( n:Number ):Void
	{
		if( n )
		{
			_nScale = n;
		}
	}
	
	/**
	* Render the Sprite2D.
	* <p>Check Faces display visibility and store visible Faces into ZBuffer.</p>
	*/ 
	public function render ( Void ):Void
	{		
		container._visible = true;
		var cste:Number	= _nScale * 100 / _v.wz;
		// --
		container._xscale = 100 * cste;
		container._yscale = 100 * cste;
		// --
		container._x = _v.sx - container._width  / 2;
		container._y = _v.sy - container._height / 2;
		// --
		setModified( false );
	}
	
	/**
	* Hide the Sprite2D.
	* <p>Hide the sprite by setting its alpha to something low.</p>
	*/ 
	public function hide ( Void ):Void
	{		
		//trace ("Hiding sprite2D " + name);
		//container._visible = true;
		// Store the previous alpha
		if (container._alpha > 0) {
			_containerAlpha = container._alpha;
		} else {
			_containerAlpha = 100;
		} 
		setAlpha (0);
		setModified( true );
	}
	
	public function setTransparency (a:Number): Void {
		setAlpha(a);
	}
	
	public function setAlpha (a:Number):Void {
		container._alpha = a;
	}
	
	/**
	* Show the Sprite2D.
	* <p>Show the sprite by setting its alpha to 100.</p>
	*/ 
	public function show ( Void ):Void
	{		
		//trace ("Showing sprite2D " + name);
		container._visible = true;
		if (_containerAlpha > 0) {
			setAlpha (_containerAlpha);
		} else {
			setAlpha (100);
		}
		setModified( true );
	}
	
	
	public function addFace( f:IPolygon ):Void
	{
		;
	}
		
	/**
	* Erase the behaviour of the Sprite2D addPoint method because Sprite2D handles itself its points. You can't add vertex by yourself here.
	* @param	x
	* @param	y
	* @param	z
	*/
	public function addPoint( x:Number, y:Number, z:Number ):Void
	{
		;
	}
	
	public function enableClipping( b:Boolean ):Void
	{
		_enableClipping = b;
	}
	
	public function clip( frustum:Frustum ):Boolean
	{
		var result:Boolean = false;
		
		if( _enableClipping )
		{
			if( frustum.pointInFrustum( _v.getWorldVector() ) == Frustum.OUTSIDE )
				result =  true;
			else
				result =  false;
		}
		else
		{
			result =  false;
		}
		
		if( result ) container._visible = false;
		return result;
	}
	
	private var _v:Vertex;
	private var _nScale:Number;
	private var _s:MovieSkin;
	private var _containerAlpha:Number;  // previous alpha setting for restoring later
}
