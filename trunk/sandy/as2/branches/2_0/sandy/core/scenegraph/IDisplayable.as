/**
 * @author thomaspfeiffer
 */
interface sandy.core.scenegraph.IDisplayable 
{
		//IMPORTANT NOTE :
		//The two virtual properties muse exist in the implementation !
		//As AS2 does not allow them into interface, they are commented, but should exist!
		//function get container():MovieClip;	
		//function get depth():Number;	
		function display( p_mcMovieClip:MovieClip ):Void;
}