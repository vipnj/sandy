
/**
* 	Fast trigonometry functions using cache table and precalculated data. 
* 	Based on Michael Kraus implementation.
* 
* 	@author	Mirek Mencel	// miras@polychrome.pl
* 	@date	01.02.2007
*/

class sandy.math.FastMath
{
	private static var _isInitialize:Boolean = FastMath.initialize();
	
	/** Precission. The bigger, the more entries in lookup table so the more accurate results. */
	public static var PRECISION:Number = 0x100000;
	public static var TWO_PI:Number = 2*Math.PI;
	public static var HALF_PI:Number = Math.PI/2;
	
	/** Precalculated values with given precision */
	private static var sinTable:Array = new Array(PRECISION);
	private static var tanTable:Array = new Array(PRECISION);
	
	private static var RAD_SLICE:Number = TWO_PI / PRECISION;
	
	
	private static function initialize(Void):Boolean
	{
		var rad:Number = 0;

		for (var i:Number = 0; i < PRECISION; i++) 
		{
			rad = Number(i * RAD_SLICE);
			sinTable[i] = Number(Math.sin(rad));
			tanTable[i] = Number(Math.tan(rad));
		}
		
		return true;
	}

	private function radToIndex(radians:Number):Number 
	{
		return int( ((radians / TWO_PI) * PRECISION) & (PRECISION - 1) );
	}

	/**
	 * Returns the sine of a given value, by looking up it's approximation in a
	 * precomputed table.
	 * @param radians The value to sine.
	 * @return The approximation of the value's sine.
	 */
	public function sin(radians:Number):Number 
	{
		return sinTable[ radToIndex(radians) ];
	}

	/**
	 * Returns the cosine of a given value, by looking up it's approximation in a
	 * precomputed table.
	 * @param radians The value to cosine.
	 * @return The approximation of the value's cosine.
	 */
	public function cos(radians:Number ):Number 
	{
		return sinTable[radToIndex(HALF_PI-radians)];
	}

	/**
	 * Returns the tangent of a given value, by looking up it's approximation in a
	 * precomputed table.
	 * @param radians The value to tan.
	 * @return The approximation of the value's tangent.
	 */
	public function tan(radians:Number):Number 
	{
		return tanTable[radToIndex(radians)];
	}
}
