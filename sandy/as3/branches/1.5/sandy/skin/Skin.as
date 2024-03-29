///////////////////////////////////////////////////////////
//  Skin.as
//  Macromedia ActionScript Implementation of the Interface Skin
//  Generated by Enterprise Architect
//  Created on:      26-VII-2006 13:46:08
//  Original author: Thomas Pfeiffer - kiroukou
///////////////////////////////////////////////////////////
package sandy.skin
{
	import sandy.core.face.Face;
	import sandy.skin.SkinType;
	
	import flash.events.IEventDispatcher;
	import flash.display.Sprite;
	/**
	 * Represent a skin for a Face in an Object3D.
	 * @since		0.1
	 * @author Thomas Pfeiffer - kiroukou
	 * @version 0.2
	 * @date 		12.01.2006
	 * @created 26-VII-2006 13:46:08
	 */
	public interface Skin extends IEventDispatcher
	{
	    /**
	     * Prepare the Face drawing of the Object3D into a Sprite.
	     * <p>This method can be called when the {@link mb.sandy.view.
	     * IScreen#render(Array)} is executed, depending of the type of the Skin that must
	     * be applyed to the Face. /p>
	     * <p>{@code mc} represent the Sprite where the Face must be displayed. The
	     * {@code f} represents the face which is calling the Skin. The skin can call all
	     * the public properties of the face</p>
	     * 
	     * @param f    The face calling the skin method
	     * @param mc    The Sprite
	     */
	    function begin(f:Face, mc:Sprite):void;

	    /**
	     * Finish the Face drawing of the Object3D into a Sprite.
	     * <p>This method can be called when the {@link mb.sandy.view.
	     * IScreen#render(Array)} is executed, depending of the type of the Skin that must
	     * be applyed to the Face. /p>
	     * <p>{@code mc} represent the Sprite where the Face must be displayed. The
	     * {@code f} represents the face which is calling the Skin. The skin can call all
	     * the public properties of the face</p>
	     * 
	     * @param f    The face calling the skin method
	     * @param mc    The Sprite
	     */
	    function end(f:Face, mc:Sprite):void;

	    /**
	     * getType, returns the type of the skin
	     * @return	The appropriate SkinType
	     * 
	     * @param Void
	     */
	    function getType():uint;

	    /**
	     * setLightingEnable. Prepare the skin to use the world light or not. The default
	     * value is false.
	     * @return	Void
	     * 
	     * @param bool    Boolean	true is the skin use the light of the world, false if no.
	     */
	    function setLightingEnable(bool:Boolean):void;

	}//end Skin

}