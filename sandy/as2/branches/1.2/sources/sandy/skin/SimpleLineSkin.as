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

import sandy.core.face.IPolygon;
import sandy.skin.Skin;
import sandy.skin.BasicSkin;
import sandy.skin.SkinType;

/**
* SimpleLineSkin
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin C�dric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @version		0.2
* @date 		12.01.2006 
**/
class sandy.skin.SimpleLineSkin extends BasicSkin implements Skin
{
	/**
	* Create a new SimpleLineSkin
	* 
	* @param t The size of line
	* @param c The color ot the line
	* @param a The alpha of the line
	* 
	*/ 
	public function SimpleLineSkin( t:Number, c:Number,  a:Number )
	{
		super();
		_thickness 	= (isNaN(t)) ? 2 : t;
		_color 		= (isNaN(c)) ? 0x000000 : c;
		_alpha 		= (isNaN(a)) ? 100 : a;
	}

	/////////////
	// SETTERS //
	/////////////

	public function set alpha( n:Number )
	{
		_alpha = n;
		broadcastEvent( _eOnUpdate );
	}
	public function set color( n:Number )
	{
		_color = n;
		broadcastEvent( _eOnUpdate );
	}
	public function set thickness( n:Number )
	{
		_thickness = n;
		broadcastEvent( _eOnUpdate );
	}	
	/////////////
	// GETTERS //
	/////////////	
	public function get alpha():Number
	{
		return _alpha;
	}
	public function get color():Number
	{
		return _color;
	}	
	public function get thickness():Number
	{
		return _thickness;
	}		
	/**
	 * getType, returns the type of the skin
	 * @param Void
	 * @return	The appropriate SkinType
	 */
	 public function getType ( Void ):SkinType
	 {
	 	return SkinType.SIMPLE_LINE;
	 }
	
   /**
	* Returns the name of the skin you are using.
	* For the SimpleLineSkin class, this value is set to "SIMPLE_LINE"
	* @param	Void
	* @return String representing your skin.
	*/
	public function getName( Void ):String
	{
		return "SIMPLE_LINE";
	}
	
	/**
	* Start the rendering of the Skin
	* @param f	The face which is being rendered
	* @param mc The mc where the face will be build.
	*/ 	
	public function begin( f:IPolygon, mc:MovieClip ):Void
	{
		mc.filters = _filters;
		mc.lineStyle( thickness, color,alpha);
	}
	
	/**
	* Finish the rendering of the Skin
	* @param f	The face which is being rendered
	* @param mc The mc where the face will be build.
	*/ 	
	public function end( f:IPolygon, mc:MovieClip ):Void
	{
		; // nothing here
	}
	
	public function toString( Void ):String
	{
		return 'sandy.skin.SimpleLineSkin' ;
	}
	
	/**
	 * Color of the lines
	 */
	private var _color:Number;
	/**
	 * Thickness of the lines
	 */
	private var _thickness:Number;
	/**
	 * Alpha transparency of the lines
	 */
	private var _alpha:Number;
	
}
