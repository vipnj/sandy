package sandy.skin
{
	import flash.display.BitmapData;
	import sandy.core.World3D;
	import sandy.skin.SkinType;
	import sandy.skin.TextureSkin;
	import sandy.util.BitmapUtil;
	import flash.display.MovieClip;
	
	/**
	* MovieSkin
	* Allow you to texture a 3D Object with a movieClip wich contains animation, picture, or video.
	* @author		Thomas Pfeiffer - kiroukou
	* @since		1.0
	* @version		1.0
	* @date 		22.04.2006 
	**/
	public class MovieSkin extends TextureSkin
	{
		/**
		* Create a new MovieSkin.
		* 
		* @param mc MovieClip a MovieClip 
		* @param b	Boolean	if true we DISABLE the automatic update of the texture property.
		*/
		public function MovieSkin( mc:MovieClip, b:Boolean=false )
		{
			super( new BitmapData( mc._width-2, mc._height-2 , false ) );
			_mc = mc;
			// TODO: Think again on which choice is clever, choosing the World3D framerate to update the texture
			// or to use the texture movieClip framerate as timer to update the bitmap.
			if( false == b ) 
			{
				World3D.addEventListener( World3D.onRenderEVENT, updateTexture );
			}
			else
			{
				_mc.stop();
			}
		}
	
		/**
		 * getType, returns the type of the skin
		 * @param Void
		 * @return	The appropriate SkinType
		 */
		public override function getType ():uint
		{
			return SkinType.MOVIE;
		}
		
		/**
		* Returns the MovieClip used to texture objects with.
		* Usefull for example when you need to apply a function to the movieClip, such as stop(), gotoAndPlay(), etc..
		* @param	Void
		* @return	MovieClip The movieclip which is used to texture objects
		*/
		public function getMovie():MovieClip
		{
			return _mc;
		}
		
		/**
		* Give a string representation of the class
		* @param	Void
		* @return	String the string representing the object.
		*/
		public override function toString():String
		{
			return 'sandy.skin.MovieSkin' ;
		}
	
		/**
		* Update the texture BitmapData with the current content of the actual frame of the movieclip.
		* @param	Void
		*/
		public function updateTexture():void
		{
			_texture.dispose();
			texture = BitmapUtil.movieToBitmap( _mc, true );
		}
		
		// --
		private var _mc:MovieClip;
	}

}