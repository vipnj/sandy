package sandy.primitive 
{
	
       	/**
	 * The Cone class is used for creating a cone primitive.
	 * 
	 * <p>This class is a special case of the Cylinder class, with an top radius of 0</p>
	 *
	 * <p>All credits go to Tim Knipt from suite75.net who did the AS2 implementation.
	 * Original sources available at : http://www.suite75.net/svn/papervision3d/tim/as2/org/papervision3d/objects/Cone.as</p>
	 *
	 * @author		Thomas Pfeiffer
	 * @author		Tim Knipt
	 * @version		3.0
	 * @date 		26.07.2007
	 *
	 * @example To create a cone with a base radius of 150 and a height of 300,
	 * with default number of segments, here is the statement:
	 *
	 * <listing version="3.0">
	 *     var myCone:Cone = new Cone( "theCone", 150, 300 );
	 *  </listing>
	 */
	public class Cone extends Cylinder implements Primitive3D
	{
		/**
		* Creates a Cone primitive.
		*
		* <p>The cone is created at the origin of the world coordinate system, with its axis
		* along the y axis, and the top pointing upwards - positive y direction</p>
		*
		* <p>Most arguments to the constructor have default values.</p>
		*
		* @param	p_sName		A String identifier of this object
		* @param	p_nRadius	[optional] - Desired radius. Defaults to 100
		* @param	p_nHeight	[optional] - Desired height. Defaults to 100
		* @param	p_nSegmentsW	[optional] - Number of segments horizontally. Defaults to 8.
		* @param	p_nSegmentsH	[optional] - Number of segments vertically. Defaults to 6.
		*/
		public function Cone(p_sName : String = null, p_nRadius:Number=100, p_nHeight:Number=100, p_nSegmentsW:Number=8, p_nSegmentsH:Number=6) 
		{
			super(p_sName, p_nRadius, p_nHeight, p_nSegmentsW, p_nSegmentsH, 0 );
		}
		public override function toString():String
		{
			return "sandy.primitive.Cone";
		}		
	}
}