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
	import flash.display.Graphics;
	import flash.utils.Dictionary;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vector;
	import sandy.events.SandyEvent;
	import sandy.materials.Material;

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
		 * @default 1.0
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
		protected function calculate (p_oNormal:Vector, p_bIgnoreSpecular:Boolean = false):Number
		{
			var l_k:Number = ambient + diffuse * Math.max (0, -m_oL.dot (p_oNormal));
			if (!p_bIgnoreSpecular && (specular > 0))
				l_k += specular * Math.pow (Math.max (0, -m_oH.dot (p_oNormal)), gloss);
			return l_k * m_nI;
		}
		
		/**
		 * Override this to perform per-frame tasks.
		 * Always call it first in sub classes.
		 */
		protected function onRenderDisplayList ( p_oArg:* ):void
		{
			var l_oScene:Scene3D;
			l_oScene = ((p_oArg as Scene3D != null) ? p_oArg: (p_oArg as SandyEvent).target) as Scene3D;

			// fetch light power
			m_nI = l_oScene.light.getNormalizedPower ();

			// fetch light direction vector
			m_oL = l_oScene.light.getDirectionVector ();

			// fetch camera vector
			m_oV = l_oScene.camera.getPosition ("absolute"); m_oV.scale (-1); m_oV.normalize ();
			
			// compute Blinn halfway vector
			m_oH.copy( m_oL ); m_oH.add (m_oV); m_oH.normalize ();
		}

		/**
		 * Override this to render the light.
		 * Always call it first in sub classes.
		 */
		public function draw(p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D):void
		{
			if (p_oMaterial.lightingEnable)
			{
				if (_scenes [p_oScene]) 
					; 
				else
				{
					p_oScene.addEventListener (SandyEvent.SCENE_RENDER_DISPLAYLIST, onRenderDisplayList);
					onRenderDisplayList (p_oScene); _scenes [p_oScene] = true;
				}
			}
		}
		
		// --
		private var _ambient:Number = 0.3;
		private var _diffuse:Number = 1.0;
		private var _specular:Number = 0.0;
		private var _gloss:Number = 1.0;
		
		private var _scenes:Dictionary = new Dictionary (true);
	}
}