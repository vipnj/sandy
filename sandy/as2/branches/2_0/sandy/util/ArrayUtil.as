/**
 * @ClassName:			sandy.util.ArrayUtil
 * @Version:			V 1.0
 * @Author:				Peanut
 * @Description:			
 *		sandy.util
 * @Date:				2007-2-1
 * @Usage:
 */
 
class sandy.util.ArrayUtil {
	
	/**Is a String in an Array
	 * @param A_equal_a:Boolean	->	Sensitive the case	
	 * @return	String index in array, -1 is not exist；
	 */
	public static function strInArray(str:String, ary:Array, A_equal_a:Boolean):Number{
		if(A_equal_a){
			for(var i=0;i<ary.length;i++){
				if(str==ary[i]){
					return i;
				}
			}
		}else{
			for(var i=0;i<ary.length;i++){
				if(str.toLowerCase()==ary[i].toLowerCase()){
					return i;
				}
			}
		}
		return -1;
	}

	/**
	 * Clear the empty ,undefined element basicly. You can define user conditions
	 * @param fun:Function -> Condition, return true delete element, false otherwise.
	 * 	<p>function (value, id)</p>
	 * @param format:Function -> Format element. Return a formated value.
	 * 	<p>function (value, id)</p>
	 */
	public static function clear(a:Array, fun:Function, format:Function):Array{
		for(var k = 0; k<a.length; k++){
			if(a[k] == "" || a[k] == undefined){
				a.splice(k,1);
				k--;
			}else if(fun && fun(a[k], k)){
				a.splice(k,1);
				k--;
			}else if(format){
				a[k] = format(a[k], k);
			}
		}
		return a;
	}
}