class sandy.util.ColorUtil 
{
	/**
	 * Calculate the colour for a particular lighting strength.
	 * This converts the supplied pre-multiplied RGB colour into HSL
	 * then modifies the L according to the light strength. 
	 * The result is then mapped back into the RGB space.	 */
	public static function calculateLitColour(col:Number, lightStrength:Number):Number
	{
		var r:Number = ( col >> 16 )& 0xFF;
		var g:Number = ( col >> 8 ) & 0xFF;
		var b:Number = ( col ) 		& 0xFF;
		
		// divide by 256
		r *= 0.00390625;
		g *= 0.00390625;
		b *= 0.00390625;
												   
		var min, mid, max, delta;
		var l, s, h, F, n = 0;
		
		var a:Array = [r,g,b];
		a.sort();

		min = a[0];
		mid = a[1];		
		max = a[2];
		
		var range:Number = max - min;
		
		l = (min + max) * 0.5;
		
		if (l == 0) 
		{
			s = 1;
		}
		else
		{
			delta = range * 0.5;
			
			if (l < 0.5) 
			{
				s = delta / l;
			}
			else 
			{
				s = delta / (1 - l);
			}

			if (range != 0) 
			{
				while (true) 
				{
					if (r == max) 
					{
						if (b == min) n = 0; else n = 5;
						break;
					}
						
					if (g == max) 
					{
						if (b == min) n = 1; else n = 2;
						break;
					}
						
					if (r == min) n = 3; else n = 4;
					break;
				}
				
				if ((n % 2) == 0) 
				{
					F = mid - min;
				}
				else 
				{
					F = max - mid;
				}
				
				F = F / range;
				h = 60 * (n + F);
			}
		}
		
		if (lightStrength < 0.5) 
		{
			delta = s * lightStrength;
		}
		else 
		{
			delta = s * (1 - lightStrength);
		}
		
		min = lightStrength - delta;
		max = lightStrength + delta;
		
		n = Math.floor(h / 60);
		F = (h - n*60) * delta / 30;
		n %= 6;
		
		var mu:Number = min + F;
		var md:Number = max - F;
		
		switch (n) 
		{
			case 0: r = max; g= mu;  b= min; break;
			case 1: r = md;  g= max; b= min; break;
			case 2: r = min; g= max; b= mu; break;
			case 3: r = min; g= md;  b= max; break;
			case 4: r = mu;  g= min; b= max; break;
			case 5: r = max; g= min; b= md; break;
		}
						
		return ((r * 256) << 16 | (g * 256) << 8 |  (b * 256));
	}
	
}