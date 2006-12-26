package sandy.core.face
{
	import sandy.core.data.Vertex;
	import sandy.core.face.TriFace3D;
	import sandy.core.Sprite2D;
	import sandy.skin.TextureSkin;
	import sandy.skin.Skin;
	import sandy.skin.SkinType;
	import sandy.view.Camera3D;
	import sandy.core.data.Vector;
	import sandy.core.World3D;
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
	/**
	* Sprite2DFace
	* Create the face needed by the Sprite2D object. This face fits perfectly the Sprite2D needs.
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		05.08.2006 
	**/
	public class Sprite2DFace extends TriFace3D
	{
		/**
		* Create a Sprite2DFace. This constructor should be created only by the Sprite or derivated class.
		* @param	oref
		* @param	pt
		*/
		public function Sprite2DFace( oref:Sprite2D, pt:Vertex ) 
		{
			super( oref, pt, null, null );
		}
	
		/**
		* Allows you to get the vertex of the face. Very usefull when you want to make some calculation on a face after it has been clicked.
		* @param	Void
		* @return Array The array of vertex.
		*/
		public override function getVertex():Array
		{
			return [ _va ];
		}
		
		/**
		 * isvisible 
		 * 
		 * <p>Say if the face is visible or not
		 * This methods returns always true in the Sprite2D case.</p>
		 *
		 * @param Void
		 * @return a Boolean, true if visible, false otherwise
		 */	
		public override function isVisible(): Boolean
		{
			return true;
		}
		
		/** 
		 * Render the face into a MovieClip.
		 *
		 * @param	{@code mc}	A {@code MovieClip}.
		 * @param	id			A Number which is the camera identifiant
		 */
		public override function render( mc:Sprite ):void
		{
			_mc = mc;
			if( _bEv) __prepareEvents( mc );
			var t:TextureSkin = ( _s as TextureSkin );
			var b:Bitmap = new Bitmap( t.texture );
			// --
			var sv:Vector 	= (_o as Sprite2D).getScaleVector();
			var s:Number 	= (_o as Sprite2D).getScale();
			// --
			var cam:Camera3D= World3D.getCurrentCamera();
			var cste:Number	= 100 * cam.getFocal() / (cam.getFocal() + _va.wz );
			b.width 	=  t.texture.width  * (s * sv.x * cste);
			b.height 	=  t.texture.height * (s * sv.y * cste);
			// --
			mc.x = _va.sx - b.width  / 2;
			mc.y = _va.sy - b.height / 2;
			// --
			mc.addChild( b );
			mc.filters = t.filters;
		}
		
		/** 
		 * Refresh the face display
		 */
		public override function refresh():void
		{
			_mc.graphics.clear();
			var t:TextureSkin = ( _s as TextureSkin );
			// --
			var sv:Vector 	= Sprite2D(_o).getScaleVector();
			var s:Number 	= Sprite2D(_o).getScale();
			// --
			var cam:Camera3D 	= World3D.getCurrentCamera();
			var cste:Number		= 100 * cam.getFocal() / (cam.getFocal() + _va.wz );
			// --
			_mc.width  = t.texture.width  * (s * sv.x * cste);
			_mc.height = t.texture.height * (s * sv.y * cste);
			_mc.x = _va.sx - _mc.width  / 2;
			_mc.y = _va.sy - _mc.height / 2;
			_mc.filters = t.filters;
		}
		
		/**
		* Set the skin for that SpriteFace. This skin must be a TextureSkin. Others skins can't be applied
		* @param	s TextureSkin The skin
		*/
		public override function setSkin( s:Skin ):void 
		{
			if( s == null ) return;
			else if( s.getType() == SkinType.TEXTURE || s.getType() == SkinType.MOVIE  )
				_s = s;
		}
	
		/**
		* Returns the skin of this SpriteFace which is a TextureSkin.
		* @return TextureSkin the skin of this face
		*/
		public override function getSkin():Skin 
		{
			return _s;
		}
	
		/**
		 * Return the depth average of the face.
		 * <p>Useful for z-sorting.</p>
		 *
		 * @return	A Number as depth average.
		 */
		public override function getZAverage():Number 
		{
			return _va.wz;
		}
	
		/**
		 * Returns the min depth of its vertex.
		 * @param Void	
		 * @return number the minimum depth of it's vertex
		 */
		public override function getMinDepth():Number 
		{
			return _va.wz;
		}
	
		/**
		 * Returns the max depth of its vertex.
		 * @param Void	
		 * @return number the maximum depth of it's vertex
		 */
		public override function getMaxDepth():Number 
		{
			return _va.wz;
		}
	}
}