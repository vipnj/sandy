import sandy.primitive.Cylinder;

/**
 * All credits go to Tim Knipt from suite75.net who did the AS2 implementation.
 * Original sources available at : http://www.suite75.net/svn/papervision3d/tim/as2/org/papervision3d/objects/Cone.as
 * @author thomas pfeiffer for the adaptation to Sandy engine
 */
class sandy.primitive.Cone extends Cylinder
{
	/**
	* Create a new Cone object.
	* @param	radius		[optional] - Desired radius.
	* <p/>
	* @param	segmentsW	[optional] - Number of segments horizontally. Defaults to 8.
	* <p/>
	* @param	segmentsH	[optional] - Number of segments vertically. Defaults to 6.
	*/
	function Cone(p_sName : String, radius:Number, height:Number, segmentsW:Number, segmentsH:Number) 
	{
		super(p_sName, radius, height, segmentsW, segmentsH, 0 );
	}
}