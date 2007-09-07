
package sandy.view
{
	import sandy.view.Camera3D;
	import sandy.view.IScreen;
	import sandy.core.face.Face;
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SpreadMethod;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.BlendMode;
	/**
	 * BitmapScreen This class is an alternative to ClipScreen BUT it's more bugguy
	 * and finally slower. I don't recommend to use it.
	 * @author 	Thomas Pfeiffer - kiroukou
	 * @version 1.0
	 * @date 	05.08.2006
	 * @created 26-VII-2006 13:46:04
	 */
	public class BitmapScreen implements IScreen
	{
	    private var _bgColor:uint;//-- color of the background
	    private var _c:Camera3D;// -- Owner Camera3D reference
	    private var _container:Sprite;// -- movieclip containing the onscreen bitmapData visualisation
	    private var _on:BitmapData;// -- Copy of onscreen bitmapData when all the scene is rendered correctly.
	    private var _off:BitmapData;// -- Copy of offscreen bitmapData when all the scene is rendered correctly.
	    private var _child:Bitmap;
	    private var _tmp:Sprite;
	    private var _array:Array;
	    private var _sRect: Rectangle;//-- Screen rectangle, to memorize screen dimension
	    private const _point:Point = new Point(0,0);
	    /**
	     * Create a new BitmapScreen
	     * @param: mc a MovieClip containig the whole rendered scene
	     * @param: tmp a MovieClip used for temporary drawing
	     * @param: w a Number giving the width of the rendered screen
	     * @param: h a Number giving the height of the rendered screen
	     * @param: bgColor [optionnal] the color of the background, white is the default color
	     * 
	     * @param mc Sprite
	     * @param w Number
	     * @param h Number
	     * @param bgColor uint 
	     */
	    public function BitmapScreen(mc:Sprite, w:Number, h:Number, bgColor:uint=0xFFFFFF)
	    {
	    	_container 	= mc;
	    	_bgColor 	= bgColor;
			_sRect 		= new Rectangle(0, 0, w, h );
			_child 		= new Bitmap();
			_on  		= new BitmapData( w, h, true, _bgColor );
			_off  		= new BitmapData( w, h, true, _bgColor );
			_tmp 		= new Sprite();
			_array		= null;
			_container.addChild( _child );
			_child.bitmapData = _on;
	    }

	    /**
	     * Dispose the BitmapScreen.
	     * 
	     * @param Void
	     */
	    public function dispose():void
	    {
			_on.dispose();
			_container.removeChild( _child );
	    }

	    /**
	     * Return the container clip.
	     * @return	The clip container.
	     * 
	     * @param Void
	     */
	    public function getContainer():Sprite
	    {
	    	return _container;
	    }

	    /**
	     * Returns the rectangle representing the screen dimensions
	     * @return	A Rectangle
	     * 
	     * @param Void
	     */
	    public function getSize():Rectangle
	    {
	    	return _sRect;
	    }

		public function free():void
		{
			if(_array )
			{
				var l:uint = _array.length;
				var i:uint;
				// -- for loop is necessary beause here the way to display is the inverse of ClipScreen
				for( i = 0; i < l; i++ )
				{
					( _array[i].rFace as Face ).free();
				}
			}
		}
		
	    /**
	     * Render the array of {@code Face} passed in arguments.
	     * @param a    The array of {@code Face}.
	     */
	    public function render( a:Array ):void
	    {
			var l:uint = a.length;
			var i:uint;
			var face:Face;
			_array = a;
			_off.fillRect( _sRect, _bgColor );
			_tmp.graphics.clear();
			// -- for loop is necessary beause here the way to display is the inverse of ClipScreen
			for( i = 0; i < l; i++ )
			{
				face = a[i].rFace;
				// -- we render in the temporary clip
				face.render( _tmp );
				//_off.draw( _tmp, _tmp.transform.matrix );
				_off.draw( _tmp );
				_tmp.graphics.clear();
			}
			_on.copyPixels( _off, _sRect, _point );//, null, null, BlendMode.ALPHA );
	    }

	    /**
	     * Set the {@code Camera3D} for the screen
	     * @param c    The {@code Camera3D}.
	     */
	    public function setCamera( c:Camera3D ):void
	    {
	    	_c = c;
	    }
	}//end BitmapScreen
}