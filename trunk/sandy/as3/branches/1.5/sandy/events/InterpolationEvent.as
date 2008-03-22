///////////////////////////////////////////////////////////
//  InterpolationEvent.as
//  Macromedia ActionScript Implementation of the Class InterpolationEvent
//  Generated by Enterprise Architect
//  Created on:      26-VII-2006 13:46:05
//  Original author: Thomas Pfeiffer - kiroukou
///////////////////////////////////////////////////////////
package sandy.events
{
	import sandy.events.TransformEvent;
	/**
	 * @author Thomas Pfeiffer - kiroukou
	 * @version 1.0
	 * @date 	05.08.2006
	 * @created 26-VII-2006 13:46:05
	 */
	public class InterpolationEvent extends TransformEvent
	{
	    private var _nPercent: Number; 
	    /**
	     * The Interpolation start Event. Broadcasted when the Interpolation is started
	     */
	    static public const onPauseEVENT:String = "onPause";
	    /**
	     * The Interpolation interpolation Event. It's the event broadcasted every time
	     * the interpolation is updated
	     */
	    static public const onProgressEVENT:String = "onProgress";
	    /**
	     * The Interpolation resume Event. Broadcasted when the Interpolation is resumed
	     */
	    static public const onResumeEVENT:String = "onResume";
	    /**
	     * Returns the percentage of the Interpolation.
	     * @return Number The percentage of the Interpolation, a number between [0;1].
	     * 
	     * @param Void
	     */
	    public function getPercent():Number
	    {
	    	return _nPercent;
	    }
	    
	    /**
	     * Set the percentage of the interpolation
	     * @param n Number the percentage of interpolation
	     */
	    public function setPercent( n:Number ):void
	    {
	    	_nPercent = n;
	    }

	    /**
	     * Constructor
	     * @param e String Event type.
	     * @param type uint TransformType constant
	     * @param percent Number The percentage
	     */
	    public function InterpolationEvent(e:String, type:uint, percent:Number)
	    {
	    	super( e, type );
	    	_nPercent = percent;
	    }
	}//end InterpolationEvent
}