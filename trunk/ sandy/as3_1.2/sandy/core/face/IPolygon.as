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
package sandy.core.face 
{		
	import sandy.core.data.Vector;
	import sandy.skin.Skin;
	import flash.geom.Matrix;
	import sandy.core.data.UVCoord;

	import flash.display.Sprite;
	/**
	* Polygon
	*  
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		12.01.2006
	* 
	**/
	public interface IPolygon
	{
		function getUVCoords():Array;
		
		function setUVCoords( pUv1:UVCoord, pUv2:UVCoord, pUv3:UVCoord ):void;
		
		/**
		* create the normal vector of the Face
		* <p>This method must be called when a face is created. Quite often a single normal vector is used for many faces
		* , so in this case, use {@link sandy.core.face.IPolygon#setNotmale(Vertex)}</p>
		* <p>A vertex is returned rather than a {@link mb.sandy.core.data.Vector4} because it migth be useful to have it transform coordinates.</p>
		* 
		* @return	Vertex	the normal vector
		*/
		function createNormale():Vector;
		
		/**
		* Enable or not the events onPress, onRollOver and onRollOut with this face.
		* @param b Boolean True to enable the events, false otherwise.
		*/
		function enableEvents( b:Boolean ):void;
		
		/**
		* Say if the face is visible by the camera or not
		* <p>This method is called during the object rendering, it is very useful to prevent from displaying unvisible faces.</p>
		* <p>If the user wants to display unvisible faces, he must use {@link mb.sandy.core.Object3D#drawAllFaces} property.</p>
		* 
		* @return	Boolean	a boolean set at true if the face is visible, false otherwise.
		*/
		function isVisible():Boolean;
		
		/**
		* Display the Face of the Object3D into a MovieClip.
		* <p>This method is called when we want to display the face. It calls it skin {@link mb.sandy.skin.Skin} specific rendering method, depending of the type of the face</p>
		*/
		function render():void;
		
		/**
		* Set the normale vector of the face. Useful when the normale for this face is alleady computed
		* <p>This method is called mainly in primitives, when th object is created. It can saves some CPU calculations when somes faces have the same normale vector</p>
		* <p>{@code n} represent the normale vector, but here as a Vertex, because the Vertex class is used in the engine.
		* @param	n		the normal Vector
		*/
		function setNormale( n:Vector ):void;

		/**
		* Set skin of this face.
		* <p>This method is called when the object is changing its skin. You can also call directly this method to apply a specific skin to a face, if you have the reference of the face</p>
		* <p>{@code s} represent the skin which is will be applied during the rendering.
		* @param	s		the Skin
		*/
		function setSkin( s:Skin ):void;
		
		/**
		* Set skin to the back of this face.
		* <p>This method is called when the object is changing its back skin. You can also call directly this method to apply a specific skin to a face, if you have the reference of the face</p>
		* <p>{@code s} represent the skin which is will be applied during the rendering.
		* @param	s		the Skin
		*/
		function setBackSkin( s:Skin ):void;
		
		/**
		* returns skin of this face.
		* <p>This method is called by {@link Object3D.getSkin}</p>
		* @return	The Skin of the Face
		*/
		function getSkin():Skin;

		/**
		 * Update the texture matrix in case that one of its vertex has been changed
		 */
		function updateTextureMatrix():void;

		/**
		 * Returns the precomputed matrix for the texture algorithm.
		 */
		function getTextureMatrix():Matrix;
		
		/**
		* returns back skin of this face.
		* <p>This method is called by {@link Object3D.getBackSkin}</p>
		* @return	The Skin of the Face
		*/
		function getBackSkin():Skin;
		
		/**
		* Retusn the average of depth of this face
		* <p>This method is called when the object is rendering, and it's very useful to do the z-sorting</p>
		* @return	a Number containing the average
		*/
		function getZAverage():Number;
		
		/**
		 * Returns the min depth of its vertex.
		 * @param void	
		 * @return number the minimum depth of it's vertex
		 */
		function getMinDepth ():Number;
		
		/**
		 * Returns the max depth of its vertex.
		 * @param void	
		 * @return number the maximum depth of it's vertex
		 */
		function getMaxDepth ():Number;
		
		/**
		* Force the face to refresh. Mainly used when  skin has changed and the object didn't move. In that case we just need to
		* refresh the movieclip, not to compute it again.
		* @param	void
		*/
		function refresh():void;
		
		/**
		* This method change the value of the "normal" clipping side.
		* @param	void
		*/
		function swapCulling():void;
		
		/**
		* Allows you to get the vertex of the face. Very usefull when you want to make some calculation on a face after it has been clicked.
		* @param	void
		* @return Array The array of vertex.
		*/
		function getVertices():Array;
		
		function getClippedVertices():Array;
		
		/**
		* Destroy the face instance and remove all the event it was listening.
		*/
		function destroy():void;
	}
}