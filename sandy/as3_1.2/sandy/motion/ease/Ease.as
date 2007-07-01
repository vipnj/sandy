package sandy.motion.ease {
	public class Ease {
		public static function easeInQuad(t:Number,b:Number,c:Number,d:int):Number{
			return c*(t/=d)*t+b ;
			}
		public static function easeOutQuad(t:Number,b:Number,c:Number,d:int):Number{
			return -c*(t/=d)*(t-2)+b ;
			}
		public static function easeInOutQuad(t:Number,b:Number,c:Number,d:int):Number{
			if((t/=d/2)<1) return c/2*t*t+b ;
			return -c/2*((--t)*(t-2)-1)+b ;
			}
		public static function easeInCubic(t:Number,b:Number,c:Number,d:int):Number{
                  return c*Math.pow(t/d,3)+b ;
			}
		public static function easeOutCubic(t:Number,b:Number,c:Number,d:int):Number{
                  return c*(Math.pow(t/d-1,3)+1)+b ;
			}
		public static function easeInOutCubic(t:Number,b:Number,c:Number,d:int):Number{
                  if((t/=d/2)<1) return c/2*Math.pow(t,3)+b ;
			 return c/2*(Math.pow(t-2,3)+2)+b ;
			}
		public static function easeInQuart(t:Number,b:Number,c:Number,d:int):Number{
                  return c*Math.pow(t/d,4)+b ;
			}
		public static function easeOutQuart(t:Number,b:Number,c:Number,d:int):Number{
                  return -c*(Math.pow(t/d-1,4)-1)+b ;
			}
		public static function easeInOutQuart(t:Number,b:Number,c:Number,d:int):Number{
                  if((t/=d/2)<1) return c/2*Math.pow(t,4)+b ;
			 return -c/2*(Math.pow(t-2,4)-2)+b ;
			}
		public static function easeInSine(t:Number,b:Number,c:Number,d:int):Number{
                  return c*(1-Math.cos(t/d*(Math.PI/2)))+b ;
			}
		public static function easeOutSine(t:Number,b:Number,c:Number,d:int):Number{
                  return c*Math.sin(t/d*(Math.PI/2))+b ;
			}
		public static function easeInOutSine(t:Number,b:Number,c:Number,d:int):Number{
                  return c/2*(1-Math.cos(t/d*Math.PI))+b ;
			}
		public static function easeInExpo(t:Number,b:Number,c:Number,d:int):Number{
			return c*Math.pow(2,10*(t/d-1))+b ;
			}
		public static function easeOutExpo(t:Number,b:Number,c:Number,d:int):Number{
			return c*(-Math.pow(2,-10*t/d-1))+b ;
			}
		public static function easeInOutExpo(t:Number,b:Number,c:Number,d:int):Number{
			if((t/=d/2)<1) return c/2*Math.pow(2,10*(t/d-1))+b ;
			return c/2*(-Math.pow(2,-10*(--t))+2)+b ;
			}
		public static function easeInCirc(t:Number,b:Number,c:Number,d:int):Number{
			return c*(1-Math.sqrt(1-(t/=d)*t))+b;
			}
		public static function easeOutCirc(t:Number,b:Number,c:Number,d:int):Number{
			return c*Math.sqrt(1-(t=t/d-1)*t)+b;
			}
		public static function easeInOutCirc(t:Number,b:Number,c:Number,d:int):Number{
			if((t/=d/2)<1) return c/2*(1-Math.sqrt(1-t*t))+b;
			return c/2*(Math.sqrt(1-(t-=2)*t)+1)+b;
			}
		//amp:振幅，timeShift：时移 period：周期 offset：偏移量
		public static function wave(t:Number,amp:Number,period:Number,timeShift:Number,offset:Number):Number{
			return amp*Math.sin((t-timeShift)*(2*Math.PI)/period)+offset ;
			}
		public static function linearTween(t:Number,b:Number,c:Number,d:int):Number{
			return c*t/d+b;
			}
		}
}