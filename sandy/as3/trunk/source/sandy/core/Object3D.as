package sandy.core
{
	import sandy.core.data.BBox;
	import sandy.core.data.UVCoord;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.events.ObjectEvent;
	import sandy.events.SkinEvent;
	import sandy.core.face.Face;
	import sandy.core.group.Leaf;
	import sandy.core.buffer.DepthBuffer;
	import sandy.skin.SimpleLineSkin;
	import sandy.skin.Skin;
	import sandy.core.data.DepthBufferData;
	/**
	 * <p>Represent an Object3D in a World3D</p>
	 * @author	Thomas Pfeiffer - kiroukou
	 * @version 1.0
	 * @date 	05.08.2006
	 * @created 26-VII-2006 13:46:07
	 */
	public class Object3D extends Leaf
	{
	    /**
	     * This is a constante, the default skin used by an Object3D
	     */
	    static public const DEFAULT_SKIN:Skin = new SimpleLineSkin();
		
		/**
	     * Name of 3D object;
	     */
	    public var name:String;
	    
		/**
	     * Array of Normal ( For better display possibilities );
	     */
	    public var aNormals:Array;
	    /**
	     * Array of Vertex ( Points use in this Object3D )
	     */
	    public var aPoints:Array;
	   	/**
	     * Array of the faces of the Object3D.
	     */
	    public var aFaces:Array;
	    /**
	     * If set to {@code true}, all Face3D of the Object3D will be draw. A false value
	     * is equivalent to enable the backface culling algorithm. Default {@code false}
	     */
	    public var enableBackFaceCulling:Boolean;
	    /**
	     * Create a new Object3D.
	     * <p>By default, a new Object3D has a {@link mb.sandy.skin#SimpleLineSkin} and
	     * all the public arrays are created (as empty). The properties {@link
	     * #drawAllFaces} and {@link #useNormals} are set to {@code false}. The {@code
	     * Matrix4} ({@code m}) is an Identity matrix. See {@link mb.sandy.core.data.
	     * Matrix4#createIdentity} for more details.</p>
	     * <p>You can use primitives, or xml to make a specific Object3D</p>
	     * 
	     * @param Void
	     */
	    public function Object3D(oName:String = 'object3D')
	    {
	    	super();
	    	name		= oName;
			aPoints		= new Array ();
			aFaces		= new Array ();
			aNormals	= new Array	();
			_aUv 		= new Array ();
			enableBackFaceCulling = true;
			_bEv = false;
			_needRedraw = false;
			// we also set skin to Default constant
			_s = _sb = Object3D.DEFAULT_SKIN;
			setSkin( Object3D.DEFAULT_SKIN );
			setBackSkin( Object3D.DEFAULT_SKIN );
	    }
	    
	    /**
	     * Add a Point with the specified coordinates.
	     * @return	The index of the new {@link Vertex} in the {@code aPoints} array
	     * 
	     * @param px    The x coordinate
	     * @param py    The y coordinate
	     * @param pz    The z coordinate
	     */
	    public function addPoint(px:Number, py:Number, pz:Number):uint
	    {
	    	setModified( true );
			return aPoints.push ( new Vertex ( px, py, pz ) );
	    }

	    /**
	     * Add an UVCoordinate to the Object3D.
	     * @return	The new UVCoordinate instance
	     * 
	     * @param x    The x coordinate
	     * @param y    The y coordinate
	     */
	    public function addUVCoordinate(x:Number, y:Number):UVCoord
	    {
	    	setModified( true );
			var o:UVCoord = new UVCoord( x, y );
			_aUv.push( o );
			return o;
	    }

		/**
		 * Add a face to the object
		 * @param f Face the face to add to the object faces array
		 */
		public function addFace( f:Face ):void
		{
			// set Default Skin
			f.setSkin( _s );
			f.setBackSkin( _sb );		
			//store the face
			aFaces.push( f );
			// the object listen the face events
			f.addEventListener( ObjectEvent.onPressEVENT, __onPressed );
			f.addEventListener( ObjectEvent.onRollOverEVENT, __onRollOver );
			f.addEventListener( ObjectEvent.onRollOutEVENT, __onRollOut );
			//
			setModified( true );
		}

	    /**
	     * Allows to enable the event system with onPress, onRollOver and onRollOut events.
	     * Once this feature is enable this feature, the animation is more CPU intensive.
	     * The default value is false. This method set the argument value to all the faces
	     * of the objet. As the Face object has also a enableEvents( Boolean ) method, you
	     * have the possibility to enable only the faces that are interessting for you.
	     * 
	     * @param b    Boolean true to enable event system, false otherwise
	     */
	    public function enableEvents(b:Boolean):void
	    {
			_bEv = b;
			var s:String;
			for( s in aFaces )
			{
				( aFaces[s] as Face ).enableEvents( b );
			}
	    }

		/**
		* Returns the skin used for the back faces of this object. Returns the skin instance.
		* If you gave no value for this skin, the "normal" skin will be returned as it is the default back skin.
		* @param	Void
		* @return	Skin The skin object.
		*/
		public function getBackSkin():Skin
		{
			return _sb;
		}

		/**
		* Returns  bounds of the object. [ minimum  value; maximum  value]
		* @param	Void
		* @return Return the array containing the minimum  value and maximum  value of the object in the world coordinate.
		*/
		public function getBounds():BBox
		{
			return BBox.create( this );
		}
		
		/**
		* Returns the position of the Object3D as a 3D vector.
		* @return	Vector the 3D position of the object
		*/
		public function getPosition():Vector
		{
			var v:Vertex = aPoints[0];
			return new Vector( v.wx - v.x, v.wy - v.y, v.wz - v.z );
		}
		
		/**
		* Returns the skin instance used by this object.
		* Be carefull, if your object faces have some skins some specific skins, this method is not able to give you this information.
		* @param	Void
		* @return 	Skin the skin object
		*/
		public function getSkin():Skin
		{
			return _s;
		}
		
		/**
		* This method allows you to know if the object needs to be redrawn or not. It happens when it skins is updated!
		* @param	Void
		* @return	Boolean True if you should call the render method to update the object.
		*/
		public function needRefresh():Boolean
		{
			return _needRedraw;
		}

	    /**
	     * Render the Object3D.
	     * <p>Check Faces display visibility and store visible Faces into DepthBuffer.</p>
	     * 
	     * @param Void
	     */
	    public override function render():void
	    {
			// -- local copy because it's faster
			var aF:Array = aFaces;
			var s:String;
			var f:Face;
			for( s in aF )
			{
				f = aF [s];
				// CLIPPING Now is the object behind the camera?
				if ( f.getMinDepth() > 100 )
				{
					// if face is visible or enableBackFaceCulling is set to false
					if ( f.isVisible () || !enableBackFaceCulling ) 
					{
						DepthBuffer.push( new DepthBufferData( f, f.getZAverage() ) );
					}
				}				
			}
			// -- 
			_needRedraw = false;
	    }
	    
	    /**
	    * Refresh all the faces of this object.
	    * Used when the skin is updated and the object doesn't move.
	    */
		public function refresh():void
		{
			var s:String;
			var aF:Array = aFaces;
			for( s in aF )
			{
				aF [s].refresh();
			}
			// -- 
			_needRedraw = false;
		}
		
	    /**
	     * Set a Skin to the back of all the faces of the object
	     * <p>This method will set the the new Skin to all his faces.</p>
	     * @return	Boolean True is the skin is applied, false otherwise.
	     * 
	     * @param s    The new Skin
	     * @param bOverWrite    Boolean, overwrite or not all specific Faces's Skin
	     */
	    public function setBackSkin( s:Skin, bOverWrite:Boolean = false ):Boolean
	    {
	    	_s.removeEventListener( SkinEvent.onUpdateEVENT, __onSkinUpdated );
			// set the skin to all the faces
			var aF:Array = aFaces;
			var lf:int = aF.length;
			while ( --lf > -1 ) 
			{
				var face:Face = aF[ lf ];
				if ( bOverWrite || face.getBackSkin() == _sb )
				{
					face.setBackSkin( s );
				} 
			}
			_sb = s;
			// Now we register to the update event
			_s.addEventListener( SkinEvent.onUpdateEVENT, __onSkinUpdated );
			return true;
	    }

	    /**
	     * Set a Skin to the Object3D.
	     * <p>This method will set the the new Skin to all his faces.</p>
	     * @return	Boolean True is the skin is applied, false otherwise.
	     * 
	     * @param s    The new Skin
	     * @param bOverWrite    Boolean, overwrite or not all specific Faces's Skin
	     */
	    public function setSkin( s:Skin, bOverWrite:Boolean = false ):Boolean
	    {
	    	_s.removeEventListener( SkinEvent.onUpdateEVENT, __onSkinUpdated );
			// set the skin to all the faces
			var aF:Array = aFaces;
			var lf:int = aF.length;
			while ( --lf > -1 ) 
			{
				var face:Face = aF[ lf ];
				if ( bOverWrite || face.getSkin() == _s )
				{
	 				face.setSkin( s );
				} 
			}
			_s = s;
			// Now we register to the update event
			_s.addEventListener( SkinEvent.onUpdateEVENT, __onSkinUpdated );
			return true;
	    }

	    /**
	     * This method allows you to change the backface culling side. For example when
	     * you want ot display a cube, you are actually outside the cube, and you see its
	     * external faces. But in the case you are inside the cube, by default Sandy's
	     * engine make the faces invisible (because you should not be in there). Now if
	     * you need to be only inside the cube, you can call the method, and after that
	     * the bue faces will be visible only from the interior of the cube. The last
	     * possibility could be to make the faces visile from inside and oustside the cube.
	     * THis is really easy to do, you just have to change the enableBackFaceCulling
	     * value and set it to false.
	     * 
	     * @param Void
	     */
	    public function swapCulling():void
	    {
	    	var s:String;
			for( s in aFaces )
			{
				( aFaces[s] as Face ).swapCulling();
			}
	    }

	    /**
	     * Represents the Object3D into a String.
	     * @return	A String representing the Object3D
	     * 
	     * @param Void
	     */
	    public override function toString():String
	    {
	    	return 'sandy.core.Object3D';
	    }

	    protected var _aUv:Array;// Array of UVCoords, represents textures position, for this Object3D
	    protected var _bEv:Boolean;// The event system state (enable or not)
	    protected var _s: Skin;// The Skin of this Object3D
	    protected var _sb: Skin;// The back Skin of this Object3D	
		protected var _needRedraw:Boolean;//Say if the object needs to be drawn again or not. Happens when the skin is updated!
	    protected const _ePress:ObjectEvent = new ObjectEvent( ObjectEvent.onPressEVENT 	);
	    protected const _eRollOut:ObjectEvent = new ObjectEvent( ObjectEvent.onRollOutEVENT 	);
	    protected const _eROllOver:ObjectEvent = new ObjectEvent( ObjectEvent.onRollOverEVENT 	);
		/**
		* called when the skin of an object change.
		* We want this object to notify that it has changed to redrawn, so we change its modified property.
		* @param	e
		*/ 
		protected function __onSkinUpdated( e:SkinEvent ):void
		{
			_needRedraw = true;
		} 
	    protected function __onPressed( e:ObjectEvent ):void
	    {
	    	dispatchEvent( _ePress );
	    }
	    protected function __onRollOut( e:ObjectEvent ):void
	    {
	    	dispatchEvent( _eRollOut );
	    }
	    protected function __onRollOver( e:ObjectEvent ):void
	    {
	    	dispatchEvent( _eROllOver );
	    }   
	    
	}//end Object3D
}