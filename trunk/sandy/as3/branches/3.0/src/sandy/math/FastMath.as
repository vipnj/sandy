package sandy.math
{
	/**
	* 	Fast trigonometry functions using cache table and precalculated data. 
	* 	Based on Michael Kraus implementation.
	* 
	* 	@author	Mirek Mencel	// miras@polychrome.pl
	* 	@date	01.02.2007
	*/
	public const FastMath:_FastMath_ = _FastMath_.initialize();
	
}



class _FastMath_ 
{
	private static var instance:_FastMath_;
	
	/** Precission. The bigger, the more entries in lookup table so the more accurate results. */
	public static const PRECISION:int = 0x100000;
	public static const TWO_PI:Number = 2*Math.PI;
	public static const HALF_PI:Number = Math.PI/2;
	// OPTIMIZATION CONSTANTS
	public static const PRECISION_S:int = PRECISION - 1;
	public static const PRECISION_DIV_2PI:Number = PRECISION / TWO_PI;
	/** Precalculated values with given precision */
	private static var sinTable:Array = new Array(PRECISION);
	private static var tanTable:Array = new Array(PRECISION);
	
	private static var RAD_SLICE:Number = TWO_PI / PRECISION;
	
	
	public static function initialize():_FastMath_
	{
		if (!instance) instance = new _FastMath_();
		
		return instance;
	}
	
	public function _FastMath_()
	{
		var rad:Number = 0;

		for (var i:int = 0; i < PRECISION; i++) 
		{
			rad = Number(i * RAD_SLICE);
			sinTable[i] = Number(Math.sin(rad));
			tanTable[i] = Number(Math.tan(rad));
		}
	}

	private function radToIndex(radians:Number):int 
	{
		return int((radians * PRECISION_DIV_2PI ) & (PRECISION_S));
	}

	/**
	 * Returns the sine of a given value, by looking up it's approximation in a
	 * precomputed table.
	 * @param radians The value to sine.
	 * @return The approximation of the value's sine.
	 */
	public function sin(radians:Number):Number 
	{
		return sinTable[ int( radToIndex(radians) ) ];
	}

	/**
	 * Returns the cosine of a given value, by looking up it's approximation in a
	 * precomputed table.
	 * @param radians The value to cosine.
	 * @return The approximation of the value's cosine.
	 */
	public function cos(radians:Number ):Number 
	{
		return sinTable[ int( radToIndex(HALF_PI-radians) ) ];
	}

	/**
	 * Returns the tangent of a given value, by looking up it's approximation in a
	 * precomputed table.
	 * @param radians The value to tan.
	 * @return The approximation of the value's tangent.
	 */
	public function tan(radians:Number):Number 
	{
		return tanTable[int( radToIndex(radians) )];
	}
}