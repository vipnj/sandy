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

# ***** END LICENSE BLOCK ******/

package sandy.materials.attributes
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vector;
	import sandy.events.SandyEvent;
	import sandy.materials.Material;
	import sandy.math.ColorMath;

	/**
	 * ABSTRACT CLASS - super class for all light attributes.
	 *
	 * <p> This class should not be directly instatiated, but sub classed.<br/>
	 * The ALightAttributes class implements Blinn flavor of Phong reflection model.</p>
	 *
	 * @author		makc
	 * @version		3.0.2
	 * @date 		13.12.2007
	 **/
	public class ALightAttributes implements IAttributes
	{
		/**
		 * Ambient reflection factor.
		 * @default 0.3
		 */
		public function get ambient ():Number
		{return _ambient;}

		/**
		 *
		 * @private
		 */
		public function set ambient (p_nAmbient:Number):void
		{
			_ambient = p_nAmbient; onPropertyChange ();
		}

		/**
		 * Diffuse reflection factor.
		 * @default 1.0
		 */
		public function get diffuse ():Number
		{return _diffuse;}

		/**
		 * @private
		 */
		public function set diffuse (p_nDiffuse:Number):void
		{
			_diffuse = p_nDiffuse; onPropertyChange ();
		}

		/**
		 * Specular reflection factor.
		 * @default 0.0
		 */
		public function get specular ():Number
		{return _specular;}

		/**
		 * @private
		 */
		public function set specular (p_nSpecular:Number):void
		{
			_specular = p_nSpecular; onPropertyChange ();
		}

		/**
		 * Specular exponent.
		 * @default 5.0
		 */
		public function get gloss ():Number
		{return _gloss;}

		/**
		 * @private
		 */
		public function set gloss (p_nGloss:Number):void
		{
			_gloss = p_nGloss; onPropertyChange ();
		}

		/**
		 * Override this to respond to property changes.
		 */
		protected function onPropertyChange ():void
		{
			;
		}
		
		/**
		 * Latest light power.
		 */
		protected var m_nI:Number;
		
		/**
		 * Latest light direction vector.
		 */
		protected var m_oL:Vector;

		/**
		 * Latest camera direction vector.
		 */
		protected var m_oV:Vector;

		/**
		 * Latest Blinn halfway vector between camera and light.
		 */
		protected const m_oH:Vector = new Vector();

		/**
		 * Calculates the reflection for given normal.
		 */
		protected function calculate (p_oNormal:Vector, p_bFrontside:Boolean, p_bIgnoreSpecular:Boolean = false):Number
		{
			var l_n:Number = p_bFrontside ? -1 : 1;
			var l_k:Number = ambient + diffuse * Math.max (0, l_n * m_oL.dot (p_oNormal));
			if (!p_bIgnoreSpecular && (specular > 0))
				l_k += specular * Math.pow (Math.max (0, l_n * m_oH.dot (p_oNormal)), gloss);
			return l_k * m_nI;
		}
		
		/**
		 * This method applies light color to polygon containers.
		 * Always call super.draw() when you override it.
		 */
		public function draw(p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D):void
		{
			if (p_oMaterial.lightingEnable)
			{
				// to avoid color darkening, we will normalize color; pitch-black is "normalized" to white
				var c:uint = p_oScene.light.color;
				if ((c < 1) || (c > 0xFFFFFF)) c = 0xFFFFFF;
				const rgb:Object = ColorMath.hex2rgb (c);
				const Y:Number = Math.sqrt (rgb.r * rgb.r + rgb.g * rgb.g + rgb.b * rgb.b) / Math.sqrt (3);
				rgb.r /= Y; rgb.g /= Y; rgb.b /= Y;
				const s:DisplayObject = (p_oPolygon.shape.useSingleContainer) ? p_oPolygon.shape.container : p_oPolygon.container;
				const ct:ColorTransform = s.transform.colorTransform;
				if ((ct.redMultiplier != rgb.r) || (ct.greenMultiplier != rgb.g) || (ct.blueMultiplier != rgb.b))
				{
					ct.redMultiplier = rgb.r; ct.greenMultiplier = rgb.g; ct.blueMultiplier = rgb.b;
					s.transform.colorTransform = ct;
				}
			}
		}
		
		/**
		 * Method called before the display list rendering.
		 * This is the common place for this attribute to precompute things
		 */
		public function begin( p_oScene:Scene3D ):void
		{
			// fetch light power
			m_nI = p_oScene.light.getNormalizedPower ();

			// fetch light direction vector
			m_oL = p_oScene.light.getDirectionVector ();

			// fetch camera vector
			m_oV = p_oScene.camera.getPosition ("absolute"); m_oV.scale (-1); m_oV.normalize ();
			
			// compute Blinn halfway vector
			m_oH.copy( m_oL ); m_oH.add (m_oV); m_oH.normalize ();
		}
		
		/**
		 * Method called right after the display list rendering
		 * This is the place to remove and dispose memory if necessary.
		 */
		public function finish( p_oScene:Scene3D ):void
		{
			;
		}
		
		/**
		 * Allows to proceed to an initialization
		 * to know when the polyon isn't lined to the material, look at #unlink
		 */
		public function init( p_oPolygon:Polygon ):void
		{
			;// to keep reference to the shapes/polygons that use this attribute
		}
	
		/**
		 * Remove all the initialization
		 * opposite of init
		 */
		public function unlink( p_oPolygon:Polygon ):void
		{
			;// to remove reference to the shapes/polygons that use this attribute
		}
		
		/**
		 * Returns the specific flags of this attribute.
		 */
		public function get flags():uint
		{ return m_nFlags; }
		
		protected var m_nFlags:uint = 0;
		
		// --
		private var _ambient:Number = 0.3;
		private var _diffuse:Number = 1.0;
		private var _specular:Number = 0.0;
		private var _gloss:Number = 5.0;
		
		private var _scenes:Dictionary = new Dictionary (true);
	}
}