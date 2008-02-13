/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author Thomas PFEIFFER
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

package sandy.events
{
	import flash.events.Event;
	import sandy.core.scenegraph.Shape3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.UVCoord;
	import sandy.core.data.Vector;

	public class Shape3DEvent extends BubbleEvent
	{
		/**
		 * Reference to the object which has bene clicked
		 */
		public var shape:Shape3D;
		/**
		 * Polygon which has been clicked
		 */
		public var polygon:Polygon;
		/**
		 * Real UV coordinate of the point under the mouse click position
		 */
		public var uv:UVCoord;
		/**
		 * Real 3D position of the point under mouse click position
		 */
		public var point:Vector;
		
		
		/**
		 * Constructs a new {@code Shape3DEvent} instance.
		 * 
		 * <p>{@link #bubbles} and {@link #propagation} properties are set
		 * to {@code true}.
		 * 
		 * <p>Example
		 * <code>
		 *   var e : Shape3DEvent = new Shape3DEvent(MyClass.onSomething, theShapeReference, thePolygonReference, theUVCoord, theReal3DIntersectionPoint );
		 * </code>
		 * 
		 * @param e an {@link EventType} instance (event name).
		 * @param p_oShape The {@code Shape3D} object reference
		 * @param p_oPolygon The {@code Polygon} object reference
		 * @param p_oUV The {@code UVCoord} object which corresponds to the UVCoord under mouse position
		 * @param p_oPoint3d The {@code Vector} object which is the real 3D position under the mouse position
		 */
		public function Shape3DEvent(e:String, p_oShape:Shape3D, p_oPolygon:Polygon, p_oUV:UVCoord, p_oPoint3d:Vector )
		{
			super(e, p_oShape);
			shape = p_oShape;
			polygon = p_oPolygon;
			uv = p_oUV;
			point = p_oPoint3d;
		}
		
	}
}