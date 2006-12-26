
package sandy.core.data
{
	/**
	 * UVCoord
	 * <p>The UVCoord class is a data structure class. It represents the position of a
	 * vertex in the Bitmap. In other words it is the texture coordinates, used in the
	 * TextureSkin class for example</p>
	 * @author Thomas Pfeiffer - kiroukou
	 * @version 1.0
	 * @date 	07.08.2006
	 * @created 26-VII-2006 13:46:10
	 */
	public final class UVCoord
	{
	    public var u:Number;
	    public var v:Number;

	    /**
	     * Get a String representation of the {@code UVCoord}.
	     * @return	A String representing the {@code UVCoord}.
	     * 
	     * @param Void
	     */
	    public function toString():String
	    {
	    	return 'sandy.core.data.UVCoord';
	    }

	    /**
	     * Create a new {@code UVCoord}.
	     * 
	     * @param nU    Number the x texture position  in the bitmap
	     * @param nV    Number the y texture position in the bitmap.
	     */
	    public function UVCoord(nU:Number, nV:Number)
	    {
	    	u = nU;
	    	v = nV;
	    }

	}//end UVCoord

}