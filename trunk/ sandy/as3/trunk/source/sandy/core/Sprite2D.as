package sandy.core
{
	import sandy.core.buffer.DepthBuffer;
	import sandy.core.face.Sprite2DFace;
	import sandy.core.Object3D;
	import sandy.core.data.Vector;
	import sandy.core.data.DepthBufferData;
	import sandy.events.ObjectEvent;
	import sandy.skin.TextureSkin;
	import sandy.skin.Skin;
	/**
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		1.0
	 * @date 		05.08.2006
	 **/
	public class Sprite2D extends Object3D 
	{
		/**
		* Sprite2D constructor.
		* A sprite is a special Object3D because it's in fact a bitmap in a 3D space.
		* The sprite is an element which always look at the camera, you'll always see the same face.
		* @param	Void
		*/
		public function Sprite2D( pScale:Number = 1 ) 
		{
			super();
			// -- we create a fictive point
			super.addPoint( 0, 0, 0 );
			// -- the scale vector
			super.addPoint( 1, 1, 1 );
			// --
			_nScale = pScale;
			// --
			createFace();
		}
		
		/**
		* Set a Skin to the Object3D.
		* <p>This method will set the the new Skin to all his faces.</p>
		* 
		* @param	s	The TexstureSkin to apply to the object
		* @return	Boolean True is the skin is applied, false otherwise.
		*/
		public override function setSkin( s:Skin, bOverWrite:Boolean = false ):Boolean
		{
			return super.setSkin( s, true );
		}
	
		/**
		 * This method isn't enable with the Sprite object. You might get the reason ;)
		 * Returns always false.
		 */
		public override function setBackSkin( s:Skin, bOverWrite:Boolean = false ):Boolean
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
		public function getScale():Number
		{
			return _nScale;
		}
		
		/**
		* getScaleVector
		* <p>Returns the scale vector that represents the result of all the scales transformations applyied during the pipeline.
		* </p>
		* @param	Void
		* @return Number the scale value.
		*/
		public function getScaleVector():Vector
		{
			return new Vector( aPoints[1].tx - aPoints[0].tx, aPoints[1].ty - aPoints[0].ty, aPoints[1].tz - aPoints[0].tz );
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
		* <p>Check Faces display visibility and store visible Faces into DepthBuffer.</p>
		*/ 
		public override function render():void
		{
			// -- local copy because it's faster
			var f:Sprite2DFace = aFaces[0];
			// -- private property access hack for speed purpose. Please use the equivalent public method in your code!
			var ndepth:Number = f.getVertex()[0].wz;
			// CLIPPING Now is the object behind the camera?
			if ( ndepth > 100 )
			{
				// if face is visible or drawAllFaces is set to true
				if ( !enableBackFaceCulling || f.isVisible () ) 
					DepthBuffer.push( new DepthBufferData( f, ndepth ) );				
			}
			setModified( false );
		}
		
		/**
		* Create a new Frace.
		* <p>When a new Face is created, by default it has the Skin of the Object3D. 
		* The new Face will be automatically stored into the Object3D.</p>	* 
		* @return	The created Face
		*/
		public function createFace():Sprite2DFace
		{
			setModified( true );
			//
			var f:Sprite2DFace = new Sprite2DFace( this, aPoints[0] );
			// set Default Skin
			f.setSkin( (_s as TextureSkin) );
			aFaces[0] = f;
			// the object listen the face events
			f.addEventListener( ObjectEvent.onPressEVENT, 	__onPressed );
			f.addEventListener( ObjectEvent.onRollOverEVENT,__onRollOver);
			f.addEventListener( ObjectEvent.onRollOutEVENT, __onRollOut );
			//and return it
			return f;
		}
		
		/**
		* Erase the behaviour of the Sprite2D addPoint method because Sprite2D handles itself its points. You can't add vertex by yourself here.
		* @param	x
		* @param	y
		* @param	z
		*/
		public override function addPoint( x:Number, y:Number, z:Number ):uint
		{
			return 0;
		}
		
		private var _nScale:Number;
	}
}