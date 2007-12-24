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

package sandy.materials 
{
	import flash.display.Sprite;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.materials.attributes.MaterialAttributes;
	
	/**
	 * ABSTRACT CLASS - base class for all materials.
	 * 
	 * <p>This class should not be directly instatiated</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class Material
	{
		/**
		 * The attributes of this material.
		 */
		public var attributes:MaterialAttributes;
		
		/**
		 * Specify if the material use the vertex normal information
		 * Default value is set to false.
		 */
		public var useVertexNormal:Boolean = false;
		
		/**
		 * Specify is the material can receive light and apply the lightAttributes if specified.
		 * Can be useful to disable very rapidly the light when unused.
		 * Default value : false
		 */
		public var lightingEnable:Boolean = false;
		
		/**
		 * Creates a matrial.
		 *
		 * <p>This constructor is never called directly - but by sub class constructors</p>
		 * @param p_oAttr	The attributes for this material
		 */
		public function Material( p_oAttr:MaterialAttributes = null )
		{
			_filters 	= [];
			_useLight 	= false;
			_id = _ID_++;
			attributes = (p_oAttr == null) ? new MaterialAttributes() : p_oAttr;
			m_bModified = true;
			m_oType = MaterialType.NONE;
		}
		
		/**
		 * The unique id of this material
		 */
		public function get id():Number
		{	
			return _id;
		}
		
	
		/**
		 * Renders the polygon dress in this material.
		 *
		 * <p>Implemented by sub classes</p>
		 */
		public function renderPolygon( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ):void
		{
			;
		}
			
		/**
		 * Not used in this version of Sandy.
		 *
		 */
		public function init( f:Polygon ):void
		{
			;
		}
	
		public function unlink( p_oPolygon:Polygon ):void
		{
			;
		}
		/**
		 * The material type of this material.
		 * 
		 * <p>For the default material this value is set to NONE</p>
		 */
		public function get type():MaterialType
		{ 
			return m_oType; 
		}
		
		/**
		 * The array of filters for this material.
		 * 
		 * <p>You use this property to add an array of filters you want to apply to this material<br>
		 * To remove the filters, just assign an empty array.</p>
		 */
		public function set filters( a:Array ):void
		{ 
			_filters = a; m_bModified = true;
		}
		
		/**
		 * @private
		 */
		public function get filters():Array
		{ 
			return _filters; 
		}
		
		/**
		 * The modified state of this material.
		 *
		 * <p>true if this material or its line attributes were modified since last rendered, false otherwise.</p> 
		 */
		public function get modified():Boolean
		{
			return (m_bModified);// && ((lineAttributes) ? lineAttributes.modified : true));
		}
				
		/**
		 * The repeat property (?).
		 * 
		 * Property that has to be updated when the material needs to have the normals 
		 * vector in order to compute the correct effect.
		 * For example, with ligthening enabled, this property must be set to true 
		 * in order to render the light effect correctly.
		 * .
		 * <p>[<strong>ToDo</strong>: Explain this better!]</p>
		 * NOTE: The variable is READ ONLY unless you perfectly know what you are doing.
		 */
		public var repeat:Boolean;
		
		//////////////////
		// PROPERTIES
		//////////////////	
		protected var m_bModified:Boolean;
		private var _filters:Array;
		protected var _useLight : Boolean = false;
		private var _id:Number;
		protected var m_oType:MaterialType;
		private static var _ID_:Number = 0;
		private static var create:Boolean;
	}
}