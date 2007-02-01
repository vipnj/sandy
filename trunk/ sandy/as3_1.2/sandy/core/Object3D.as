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

	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.*;
	
	import sandy.core.buffer.ZBuffer;
	import sandy.core.data.BBox;
	import sandy.core.data.BSphere;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.face.IPolygon;
	import sandy.core.face.Polygon;
	import sandy.core.group.Leaf;
	import sandy.core.World3D;
	import sandy.core.transform.ITransform3D;
	import sandy.core.data.Matrix4;
	import sandy.skin.SimpleLineSkin;
	import sandy.skin.BasicSkin ;
	import sandy.view.Frustum;
	import sandy.events.SandyEvent;

	
	/**
	* <p>Represent an Object3D in a World3D</p>
	* 
	* @author	Thomas Pfeiffer - kiroukou
	* @author	Tabin Cédric - thecaptain
	* @author	Nicolas Coevoet - [ NikO ]
	* @version	1.0
	* @date 	23.06.2006
	*/
	public class Object3D extends Leaf
	{
		
	// _______
	// STATICS_______________________________________________________
	
		/**
		* This is a constante, the default skin used by an Object3D
		*/
		private static var _DEFAUT_SKIN:BasicSkin = new SimpleLineSkin(); 
		
		/**
		* Default Skin of the Object3D.
		*/
		public static function get DEFAULT_SKIN():BasicSkin  { return _DEFAUT_SKIN; }
		
		
	
		
	// _____________
	// [PUBLIC] DATA_________________________________________________		
	
		/** Array of Vertex ( Points used in this Object3D )*/
		public var aPoints:Array;
		
		/** Array of the faces of the Object3D */ 
		public var aFaces:Array;
		
		/** Array of normals vertex. UNUSED in the current version of the engine. */
		public var aNormals:Array;
		
		public var aClipped:Array;
	
		
		
	// ______________
	// [PRIVATE] DATA________________________________________________		
	
		private var _s:BasicSkin ; // The Skin of this Object3D
		private var _sb:BasicSkin ; // The back Skin of this Object3D
		private var _needRedraw:Boolean; //Say if the object needs to be drawn again or not. Happens when the skin is updated!
		private var _bEv:Boolean; // The event system state (enable or not)
		private var _backFaceCulling:Boolean;
		protected var _enableClipping:Boolean;
		private var _visible : Boolean;
		private var _enableForcedDepth:Boolean;
		private var _forcedDepth:Number;
		protected var _fCallback:Function;
		private var _mc:DisplayObject;
		private var _aSorted:Array;
		private var _oBBox:BBox;
		private var _oBSphere:BSphere;
		private var _t:ITransform3D;
		
		
		
		
	// ___________
	// CONSTRUCTOR___________________________________________________
	
		/**
		* Create a new Object3D.
		* 
		* <p>By default, a new Object3D has a {@link mb.sandy.skin#SimpleLineSkin} and
		* all the public arrays are created (as empty). The properties {@link #drawAllFaces}
		* and {@link #useNormals} are set to {@code false}. The {@code Matrix4} ({@code m})
		* is an Identity matrix. See {@link mb.sandy.core.data.Matrix4#createIdentity} for
		* more details.</p>
		* <p>You can use primitives, or xml to make a specific Object3D</p>
		*/
		public function Object3D ()
		{
			super();
			
			aPoints		= new Array ();
			aFaces		= new Array ();
			_aSorted	= new Array ();
			aNormals 	= new Array ();
			
			_backFaceCulling = true;
			_bEv = false;
			_needRedraw = false;
			_visible = true;
			_enableForcedDepth = false;
			_enableClipping = false;
			
			_forcedDepth = 0;
			_oBBox = null;
			_oBSphere = null;
			
			// --
			_fCallback = __renderFaces
			
			// -- We also set skin to Default constant
			setSkin( DEFAULT_SKIN );
			setBackSkin( DEFAULT_SKIN );
			
			// --
			_mc = createObjectContainer();
			
			World3D.getInstance().addEventListener( SandyEvent.CONTAINER_CREATED, __onWorldContainer );
		}
		
		
		
		
		
	// __________________
	// [PUBLIC] FUNCTIONS____________________________________________
		
		public function enableClipping( b:Boolean ):void
		{
			_enableClipping = b;
			
			if( _enableClipping ) 
			{
				_oBSphere = new BSphere( this );
				_oBBox = new BBox( this );
			}
		}
		
		/**
		 * Enable (true) or disable (false) the object forced depth.
		 * Enable this feature makes the object drawn at a specific depth.
		 * When correctly used, this feature allows you to avoid some Z-sorting problems.
		 */
		public function	enableForcedDepth( b:Boolean ):void
		{
			_enableForcedDepth = b;
			setModified( true );
		}
		
		/**
		 * Returns a boolean value specifying if the depth is forced or not
		 */
		public function	isForcedDepthEnable():Boolean
		{
			return _enableForcedDepth;
		}
		
		/**
		 * Set a forced depth for this object.
		 * To make this feature working you must enable the ForcedDepth system too.
		 * The higher the depth is, the sooner the more far the object will be represented.
		 */
		public function setForcedDepth( pDepth:Number ):void
		{
			_forcedDepth = pDepth;
			setModified( true );
		}
		
		/**
		 * Allows you to retrieve the forced depth value.
		 * The default value is 0.
		 */
		public function getForcedDepth():Number
		{
			return _forcedDepth;
		}

		/**
		* Represents the Object3D into a String.
		* @return	A String representing the Object3D
		*/
		override public function toString ():String
		{
			return getQualifiedClassName(this) + " [Faces: " + aFaces.length + ", Points: " + aPoints.length + "]";
		}
		
		/**
		* Returns the skin instance used by this object.
		* Be carefull, if your object faces have some skins some specific skins, this method is not able to give you this information.
		* @param	void
		* @return 	Skin the skin object
		*/
		public function getSkin():BasicSkin 
		{
			return _s;
		}
		
		/**
		* Returns the position of the Object3D as a 3D vector.
		* The returned position in the position in the World frame, not the camera's one.
		* In case you want to get the position to a camera, you'll have to add its position to this vector with VectorMat::add eg.
		* @param	void
		* @return	Vector the 3D position of the object
		*/
		public function getPosition():Vector
		{
			var v:Vertex = aPoints[0];
			return new Vector( v.wx - v.x, v.wy - v.y, v.wz - v.z );
		}
		
		/**
		* Returns the skin used for the back faces of this object. Returns the skin instance.
		* If you gave no value for this skin, the "normal" skin will be returned as it is the default back skin.
		* @param	void
		* @return	Skin The skin object.
		*/
		public function getBackSkin():BasicSkin 
		{
			return _sb;
		}
		
		/**
		* Set a Skin to the Object3D.
		* <p>This method will set the the new Skin to all his faces.
		* Warning : If no backface skin has benn applied, the skin will be applied to the back side of faces too!
		* </p>
		* @param	s	The new Skin to apply to faces
		* @param	bOverWrite	Boolean, overwrite or not all specific Faces's Skin
		* @return	Boolean True to apply the skin to the non default faces skins , false otherwise (default).
		*/
		public function setSkin( pS:BasicSkin ):Boolean
		{
			//
			if (_s)
			{
				_s.removeEventListener( SandyEvent.UPDATE, __onSkinUpdated );
			}
			
			// Now we register to the update event
			_s = pS;
			_s.addEventListener( SandyEvent.UPDATE, __onSkinUpdated );
			
			//
			var l:int = aFaces.length;
			while( --l > -1 )
			{
				aFaces[int(l)].updateTextureMatrix( _s );
			}
			
			//
			_needRedraw = true;
			return true;
		}
		
		/**
		* Set a Skin to the back of all the faces of the object
		* <p>This method will set the the new Skin to all his faces.</p>
		* 
		* @param	s	The new Skin
		* @param	bOverWrite	Boolean, overwrite or not all specific Faces's Skin
		* @return	Boolean True is the skin is applied, false otherwise.
		*/
		public function setBackSkin( pSb:BasicSkin ):Boolean
		{
			//
			if(_sb)
			{
				_sb.removeEventListener( SandyEvent.UPDATE, __onSkinUpdated  );
			}
			
			// Now we register to the update event
			_sb = pSb;
			
			_sb.addEventListener( SandyEvent.UPDATE, __onSkinUpdated );
			
			//
			var l:int = aFaces.length;
			while( --l > -1 )
			{
				aFaces[int(l)].updateTextureMatrix( _sb );
			}
			
			//
			_needRedraw = true;
			return true;
		}
		
		/**
		* Allows to enable the event system with onPress, onRollOver and onRollOut events.
		* Once this feature is enable this feature, the animation is more CPU intensive.
		* The default value is false.
		* This method set the argument value to all the faces of the objet.
		* As the Face object has also a enableEvents( Boolean ) method, you have the possibility to enable only
		* the faces that are interessting for you.
		* @param	b Boolean true to enable event system, false otherwise
		*/
		public function enableEvents( b:Boolean ):void
		{
			// -- 
			if( b )
			{
				if( !_bEv )
				{
					_mc.addEventListener(MouseEvent.CLICK, _onPress);
					_mc.addEventListener(MouseEvent.MOUSE_UP, _onPress); //MIGRATION GUIDE: onRelease & onReleaseOutside
					_mc.addEventListener(MouseEvent.ROLL_OVER, _onRollOver);	
					_mc.addEventListener(MouseEvent.ROLL_OUT, _onRollOut);
				}
			}
			else if( !b && _bEv )
			{
				_mc.addEventListener(MouseEvent.CLICK, _onPress);
				_mc.removeEventListener(MouseEvent.MOUSE_UP, _onPress);
				_mc.removeEventListener(MouseEvent.ROLL_OVER, _onRollOver);
				_mc.removeEventListener(MouseEvent.ROLL_OUT, _onRollOut);
			}
			_bEv = b;
		}

		/**
		 * Hide (false) or make visible( true)  the current object.
		 * The default state is visible (true)
		 */
		public function setVisible( b:Boolean ):void
		{
			_visible = b;
			setModified( true );
		}
		
		/**
		 * Get the visibility of the Object3D.
		 * @return Boolean The visibility boolean, true meaning that the object is visible.
		 */
		public function isVisible():Boolean
		{
			return _visible;
		}
		
		/**
		 * If set to {@code false}, all Face3D of the Object3D will be draw.
		 * A true value is equivalent to enable the backface culling algorithm.
		 * Default {@code true}
		 */
		public function enableBackFaceCulling( b:Boolean ):void
		{
			_backFaceCulling = b;
			_needRedraw = true;	
			setModified( true );
		}
		
		/**
		* This method allows you to change the backface culling side.
		* For example when you want to display a cube, you are actually outside the cube, and you see its external faces.
		* But in the case you are inside the cube, by default Sandy's engine make the faces invisible (because you should not be in there).
		* Now if you need to be only inside the cube, you can call the method, and after that the bue faces will be visible only from the interior of the cube.
		* The last possibility could be to make the faces visile from inside and oustside the cube. This is really easy to do, you just have to change the enableBackFaceCulling value and set it to false.
		*/
		public function swapCulling():void
		{
			var s:String;
			var l:int = aFaces.length;
			for( var i:int = 0;i < l; i++ )
			{
				aFaces[int(i)].swapCulling();
			}
			
			// -- swap the skins too
			/*
			var tmp:Skin;
			tmp = _sb;
			_sb = _s;
			_s = tmp;
			*/
			// --
			
			_needRedraw = true;	
			setModified( true );
		}
			
		/**
		* Add a Point with the specified coordinates.
		* 
		* @param	px		The x coordinate
		* @param	py		The y coordinate
		* @param	pz		The z coordinate
		* @return	The index of the new {@link Vertex} in the {@code aPoints} array
		*/
		public function addPoint (px :Number, py:Number, pz:Number ):uint
		{
			setModified( true );
			return aPoints.push ( new Vertex ( px, py, pz ) );
		}
		
		public function addVertexPoint (p_vertex:Vertex):uint
		{
			setModified( true );
			return aPoints.push ( p_vertex );
		}
		
		
		/**
		* Render the Object3D.
		* <p>Check Faces display visibility and store visible Faces into ZBuffer.</p>
		*/ 
		override public function render ():void
		{
			var l:int = aPoints.length;
			var p:int = l;
			var lDepth:Number = 0;
			while( --l > -1 ) 
			{
				lDepth += (aPoints[int(l)].wz);
			}
			
			ZBuffer.push( { movie:_mc, depth:(lDepth/p), callback:_fCallback, o3d:this } );
		}
		
		private function __renderFaces():void
		{
			var ndepth:Number;
			// -- local copy because it's faster
			var l:int = aFaces.length;
			var f:Polygon;
			
			//
			_mc.graphics.clear();
			
			//
			_aSorted = new Array();
			
			while( --l > -1 )
			{
				f = aFaces[int(l)];
				
				if ( f.isVisible() || !_backFaceCulling) 
				{
					ndepth 	= (_enableForcedDepth) ? _forcedDepth : f.getZAverage();
					if(ndepth) _aSorted.push( { face:f, depth:ndepth } );
				}
				
			}
			
			//
			_aSorted.sortOn( "depth", Array.NUMERIC | Array.ASCENDING );
			
			//trace('_aSorted: ' + _aSorted);
			
			//
			l = _aSorted.length;
			while( --l > -1 )
			{
				_aSorted[int(l)].face.render( _mc, _s, _sb );				
			}
			
			// -- 
			_needRedraw = false;
		}
		
		public function refresh():void
		{
			var a:Array = _aSorted;
			var f:Polygon;
			var l:int = a.length;
			
			//
			_mc.graphics.clear();
			
			//
			while( --l > -1 )
			{
				a[l].refresh( _mc, _s, _sb );
			}
			
			// -- 
			_needRedraw = false;
		}
		
		/**
		* Returns  bounds of the object. [ minimum  value; maximum  value]
		* @param	void
		* @return Return the array containing the minimum  value and maximum  value of the object in the world coordinate.
		*/
		public function getBBox():BBox
		{
			return _oBBox;
		}

		/**
		* Returns  bounding sphere of the object. [ minimum  value; maximum  value]
		* @param	void
		* @return Return the bounding sphere
		*/
		public function getBSphere():BSphere
		{
			return _oBSphere;
		}
		
		/**
		 * Add a face to the objet, set the object skins to faces, and notify that there is a modification
		 */
		public function addFace( f:Polygon ):void
		{
			// -- we update its texture matrix
			f.updateTextureMatrix();
			
			// -- store the face
			aFaces.push( f );
			
			// --
			setModified( true );
		}
		
		/**
		 * Add a face to the objet, set the object skins to faces, and notify that there is a modification
		 */
		public function addFaceList( p_list:Array ):void
		{
			// TODO:	Check if updateTextureMatrix on each face is necessary here
			//			If not than just replace it by arrays concatenation		
			var l:int = p_list.length;
			var f:Polygon;
			for (var i:int = 0; i<l; i++) 
			{
				f = p_list[int(i)];
				
				// -- we update its texture matrix
				f.updateTextureMatrix();
			
				// -- store the face
				aFaces.push( f );
			}
			
			// --
			setModified( true );
		}

		/**
		* This method allows you to know if the object needs to be redrawn or not. It happens only when the OBJECT skin is updated!
		* That means that if you have change the skin of the faces directly with face.setSkin instead of object.setSkin, those faces will not 
		* be updated properly. This missing feature will be fixed in the near future!
		* @param	void
		* @return	Boolean True if you should call the render method to update the object.
		*/
		public function needRefresh():Boolean
		{
			return _needRedraw;
		}
		
		override public function destroy():void
		{
			// --
			var l:int = aFaces.length;
			while( --l > -1 )
			{
				aFaces[int(l)].destroy();
			}
			
			// --
			_s.removeEventListener( SandyEvent.UPDATE, __onSkinUpdated );
			
			super.destroy();
		}
		
		/**
		 * Add a transformation to the current TransformGroup. This allows to apply a transformation to all the childs of the Node.
		 * @param t		The transformation to add
		 */
		public function setTransform( t:ITransform3D ):void
		{
			_t = t;
			setModified( true );
		}
		
		/**
		 * Get the current TransformGroup transformation. This allows to manipulate the node transformation.
		 * @return	The transformation 
		 */
		public function getTransform():ITransform3D
		{
			return _t;
		}
		
		public function getMatrix():Matrix4
		{
			return _t ? _t.getMatrix():null;
		}
		
		public function clip( frustum:Frustum ):Boolean
		{
			/*
			var aF:Array = aFaces;
			var l:Number = aF.length;
			var f:IPolygon;
			while( --l > -1 )
			{
				bClipped = bClipped || aF[l].clip( frustum );
			}
			*/
			
			var result:Boolean = false;
			var res:Number;
					
			aClipped = aPoints;
			
			// Is clipping enable on that object
			if( _enableClipping )
			{
				_oBSphere = null;
				_oBSphere = new BSphere( this );
				
				res = frustum.sphereInFrustum( _oBSphere );
				if( res  == Frustum.OUTSIDE )
				{
					result = true;
				}
				else if( res == Frustum.INTERSECT )
				{
					// The bounding sphere is intersecting a place at least.
					// Let's check the bounding box volume.
					_oBBox = null;
					_oBBox = new BBox( this );
					res = frustum.boxInFrustum( _oBBox );
					if( res == Frustum.OUTSIDE )
					{
						// OUSIDE, the objet is clipped
						result =  true;
					}
					else if (res == Frustum.INTERSECT )
					{
						aClipped = new Array();
						
						// We are intersecting a place one more time. The object shall be at the limit
						// of the frustum volume. Let's try to clip the faces against it.
						var l:Number = aFaces.length;
						while( --l > -1 )
						{
							aClipped = aClipped.concat( aFaces[int(l)].clip( frustum ) );
						}
						// We consider that the object is not clipped and needs to be draw.
						result = false;
					}
					else
					{
						// INSIDE
						result = false;
					}
				}
				else
				{
					// INSIDE 
					return false;
				}
			}
			else
			{
				result =  false;
			}
			
			if( result ) _mc.graphics.clear();
			
			return result;
		}

		public function getContainer():DisplayObject
		{
			return _mc;
		}
		
		public function setContainer(p_mc:DisplayObject):DisplayObject
		{
			if (p_mc) 
			{
				_mc = p_mc;
				
			} else {
				trace("#Error [Object3D] setContainer() Passed parameter is null.");
			}
		}
		
		
		//////////////
		/// PRIVATE
		//////////////
		private function __onWorldContainer( e:Event ):void
		{
			_mc.parent.removeChild(_mc);
			
			_mc = createObjectContainer();
			
			_mc.graphics.clear();
		}
		
		
		/**
		* called when the skin of an object change.
		* We want this object to notify that it has changed to redrawn, so we change its modified property.
		* @param	e
		*/ 
		private function __onSkinUpdated( e:Event ):void
		{
			_needRedraw = true;
		}
		
		private static function createObjectContainer():DisplayObject
		{
			var p_container:DisplayObject = new Sprite();
			World3D.getInstance().getSceneContainer().addChild(p_container);
			
			return p_container;
		}
		
		private function _onPress(e:MouseEvent):void
		{
			dispatchEvent(e);
		}
		
		private function _onRollOver(e:MouseEvent):void
		{
			dispatchEvent(e);
		}
		
		private function _onRollOut(e:MouseEvent):void
		{
			dispatchEvent(e);
		}
	}
}