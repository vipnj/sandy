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

import com.bourre.events.IEventDispatcher;
import flash.geom.Matrix;

import sandy.core.data.UVCoord;
import sandy.core.data.Vector;
import sandy.skin.Skin;

/**
* Face
*  
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		12.01.2006
* 
**/
interface sandy.core.face.IPolygon extends IEventDispatcher
{
	public function getUVCoords( Void ):Array;
	
	public function setUVCoords( pUv1:UVCoord, pUv2:UVCoord, pUv3:UVCoord ):Void;
	
	/**
	* create the normal vector of the Face
	* <p>This method must be called when a face is created. Quite often a single normal vector is used for many faces
	* , so in this case, use {@link sandy.core.face.IPolygon#setNotmale(Vertex)}</p>
	* <p>A vertex is returned rather than a {@link mb.sandy.core.data.Vector4} because it migth be useful to have it transform coordinates.</p>
	* 
	* @return	Vertex	the normal vector
	*/
	public function createNormale( Void ):Vector;
	
	/**
	* Enable or not the events onPress, onRollOver and onRollOut with this face.
	* @param b Boolean True to enable the events, false otherwise.
	*/
	public function enableEvents( b:Boolean ):Void;
	
	/**
	* Say if the face is visible by the camera or not
	* <p>This method is called during the object rendering, it is very useful to prevent from displaying invisible faces.</p>
	* <p>If the user wants to display invisible faces, he must use Object.enableBackFaceCulling(false).</p>
	* 
	* @return	Boolean	a boolean set at true if the face is visible, false otherwise.
	*/
	public function isVisible( faceNum:Number ):Boolean;
	
	/**
	* Display the Face of the Object3D into a MovieClip.
	* <p>This method is called when we want to display the face. It calls it skin {@link mb.sandy.skin.Skin} specific rendering method, depending of the type of the face</p>
	* <p>{@code mc} represent the MovieClip where the Face must be displayed. 
	* @param	mc		The MovieClip
	*/
	public function render( mc:MovieClip, pS:Skin, pSb:Skin, faceNum:Number ):Void;
	
	/**
	* Set the normale vector of the face. Useful when the normale for this face is alleady computed
	* <p>This method is called mainly in primitives, when th object is created. It can saves some CPU calculations when somes faces have the same normale vector</p>
	* <p>{@code n} represent the normale vector, but here as a Vertex, because the Vertex class is used in the engine.
	* @param	n		the normal Vector
	*/
	public function setNormale( n:Vector ):Void;

	/**
	* Set skin of this face.
	* <p>This method is called when the object is changing its skin. You can also call directly this method to apply a specific skin to a face, if you have the reference of the face</p>
	* <p>{@code s} represent the skin which is will be applied during the rendering.
	* @param	s		the Skin
	*/
	public function setSkin( s:Skin ):Void;
	
	/**
	* Set skin to the back of this face.
	* <p>This method is called when the object is changing its back skin. You can also call directly this method to apply a specific skin to a face, if you have the reference of the face</p>
	* <p>{@code s} represent the skin which is will be applied during the rendering.
	* @param	s		the Skin
	*/
	public function setBackSkin( s:Skin ):Void;
	
	/**
	* returns skin of this face.
	* <p>This method is called by {@link Object3D.getSkin}</p>
	* @return	The Skin of the Face
	*/
	public function getSkin( Void ):Skin;

	/**
	 * Update the texture matrix in case that one of its vertex has been changed
	 */
	public function updateTextureMatrix( s:Skin ):Void;

	/**
	 * Returns the precomputed matrix for the texture algorithm.
	 */
	public function getTextureMatrix( Void ):Matrix;
	
	/**
	* returns back skin of this face.
	* <p>This method is called by {@link Object3D.getBackSkin}</p>
	* @return	The Skin of the Face
	*/
	public function getBackSkin( Void ):Skin;
	
	/**
	* Retusn the average of depth of this face
	* <p>This method is called when the object is rendering, and it's very useful to do the z-sorting</p>
	* @return	a Number containing the average
	*/
	public function getZAverage( Void ):Number;
	
	/**
	 * Returns the min depth of its vertex.
	 * @param Void	
	 * @return number the minimum depth of it's vertex
	 */
	public function getMinDepth ( Void ):Number;
	
	/**
	 * Returns the max depth of its vertex.
	 * @param Void	
	 * @return number the maximum depth of it's vertex
	 */
	public function getMaxDepth ( Void ):Number;
	
	/**
	* Force the face to refresh. Mainly used when  skin has changed and the object didn't move. In that case we just need to
	* refresh the movieclip, not to compute it again.
	* @param	Void
	*/
	public function refresh( mc:MovieClip, pS:Skin, pSb:Skin  ):Void;
	
	/**
	* This method change the value of the "normal" clipping side.
	* @param	Void
	*/
	public function swapCulling( Void ):Void;
	
	/**
	* Allows you to get the vertex of the face. Very usefull when you want to make some calculation on a face after it has been clicked.
	* @param	Void
	* @return Array The array of vertex.
	*/
	public function getVertices( Void ):Array;
	
	/**
	* Destroy the face instance and remove all the event it was listening.
	*/
	public function destroy( Void ):Void;
}
