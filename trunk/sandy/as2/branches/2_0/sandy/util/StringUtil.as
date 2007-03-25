/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author or authors.
Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.mozilla.org/MPL/MPL-1.1.html
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# ***** END LICENSE BLOCK *****
*/

class sandy.util.StringUtil
{
	/**
	* Basic replace string method. It replace in the string pstr the pattern pold by the new pattern pnew.
	* @param	pstr The string to modify
	* @param	pold The old pattern to replace
	* @param	pnew The new pattern you want to replace with
	* @return	The modified string.
	*/
	public static function replace( pstr:String, pold:String, pnew:String ):String
	{
		// we do the replacement if the element is present at least once.
		if( pstr.lastIndexOf( pold ) )
		{
			return pstr.split( pold ).join( pnew );
		}
		else
			return pstr;
	}
	
	/**
	* Returns an array containing all the strings that are between the pattern deb and end.
	* The patterns aren't in the result strings.
	* @param	pstr	String	the string we are going to look for patterns into.
	* @param	pdeb	String	the start pattern
	* @param	pfin	String	the end pattern
	* @return	An array of Strings if we have found some parts of string matching the pattern, or an empty array if not.
	*/
	public static function getTextBetween( pstr:String, pdeb:String, pfin:String ):Array/*String*/
	{
		var r:Array 	= [];
		var idd:Number 	= 0;
		var idf:Number 	= pdeb.length;
		// --
		while( ( idd = pstr.indexOf( pdeb, idd ) ) > 0 && ( idf = pstr.indexOf( pfin, idd+pdeb.length ) ) > 0 )
		{
			r.push( pstr.slice( idd+pdeb.length, idf ) );
			idd = idf+pfin.length;
			idf = idd+pdeb.length;
		}
		return r;
	}

//--------------------------The following added by [Peanut]-------------------------//
	/**
	*public static findBlockIndex():Array
	*<p>Search all block's start and end index.</p>
	*@param		str:String				The source string
	*@param		str_s:String			Block start with
	*@param		str_e:String			Block end with
	*@return	Array	store all the start and end index;
	*	<p>array struct:</p>
	*	<p>array[0] = [Block_Start_String_Length, Block_End_String_Length]</p>
	*	<p>array[1] = [Start_Index_1, End_Index_1]</p>
	*	<p>array[x] = [Start_Index_x, End_Index_x]</p>
	*/
	public static function findBlockIndex (str:String, str_s:String, str_e:String):Array  {
		var pps = new Array(), ppe = new Array();
		var pairs = new Array();
		pairs.push(new Array(str_s.length, str_e.length));
		//--start serach
		var searchStart1 = -1;
		var searchStart2 = -1;
		while (str.indexOf(str_s, searchStart1+1)>-1 && str.indexOf(str_e, searchStart2+1)>-1){
			searchStart1 = str.indexOf(str_s, searchStart1+1);
			pps.push(searchStart1);
			searchStart2 = str.indexOf(str_e, searchStart2+1);
			ppe.push(searchStart2);
		}
		for (var i=0; i<ppe.length-1; i++) {
			for (var j=i+1; j<pps.length; j++) {
				var a = ppe[i]-pps[j];
				if (a<0) {
					pairs.push(new Array(pps[j-1]+str_s.length, ppe[i]));
					pps.splice(j-1, 1);
					ppe.splice(i, 1);
					i--;
					break;
				}
				delete a;
			}
		}
		for (var i=0; i<pps.length; i++) {
			pairs.push(new Array(pps[i]+str_s.length, ppe[pps.length-1-i]));
		}
		pairs.sort(function (a, b) {
			if (a[0]<b[0]) {
				return -1;
			} else {
				return 1;
			}
		});
		//
		return pairs;
	}
	
	/**
	*public static function getPairs ():Array
	*<p>Get block from source string by index</p>
	*@param		str:String					Source string
	*@param		pairs:Array					Index source, created by findBlockIndex
	*@param		withSymbol:Boolean			Return with start and end symbols
	*@return	Array		All blocks between the start and end symbols
	*/
	public static function getBlocks (str:String, pairs:Array, withSymbol:Boolean):Array  {
		var pairStrs = new Array();
		if (withSymbol) {
			for (var i=1; i<pairs.length; i++) {
				var t:String = str.substring(pairs[i][0]-pairs[0][0], pairs[i][1]+pairs[0][1]);
				pairStrs.push(t);
			}
		} else {
			for (var i=1; i<pairs.length; i++) {
				var t:String = str.substring(pairs[i][0], pairs[i][1]);
				pairStrs.push(t);
			}
		}
		return pairStrs;
	}
	
	/**public static function getBlockByIndex():String
	 * <p>Return a special block by index</p>
	 * @param		str:String			Source String
	 * @param		pairs:Array			Index array, created by findBlockIndex
	 * @param		strIndex:Number		String index, if we found a block start with this index then return
	 * @param		noSymbol:Boolean	Return without start and end symbols
	 * @return		String
	 */
	public static function getBlockByIndex(str:String, pairs:Array, strIndex:Number, noSymbol:Boolean):String{
		var _str:String = "";
		for (var i=1; i<pairs.length; i++) {
			if(strIndex == pairs[i][0]-pairs[0][0])
				if(noSymbol)
					_str = str.substring(pairs[i][0], pairs[i][1]);
				else
					_str = str.substring(pairs[i][0]-pairs[0][0], pairs[i][1]+pairs[0][1]);
		}
		
		return _str;
	}
	
	/**
	 * Return block range array
	 * @param		pairs:Array			Block indexes, use findBlockIndex() to create
	 * @param		strIndex:Number		String's index in source string
	 * @return		Array		Store where the block start and where to end. If not found, return [-1, -1]
	 */
	public static function getBlockRange(pairs:Array, strIndex:Number):Array{
		for (var i=1; i<pairs.length; i++) {
			if(strIndex == pairs[i][0]-pairs[0][0])
				return [pairs[i][0]-pairs[0][0], pairs[i][1]+pairs[0][1]];
		}
		return [-1, -1];
	}
	
	/**
	 * Clear '\r' '\n' and replace multi spaces with a single space.
	 * @param	expand:Array	Others string you want to clear
	 */
	public static function clear(str:String, expand:Array):String{
		str = str.split("\r").join(" ");
		str = str.split("\n").join(" ");
		if(expand){
			for(var i=0; i<expand.length; i++){
				str = str.split(expand[i]).join(" ");
			}
		}
		str = StringUtil.clearRepeat(str, " ", " ");
		return str;
	}
	
	/**
	 * Clear repeated strings
	 * @param		repeat:Array	The repeat chars which will be cleared.
	 * <p>ex: If you want to clear "ababab", just input "ab" is enough.</p>
	 * @param		replace:String	Replace chars, default is a space.
	 */
	public static function clearRepeat(str:String, repeat:String, replace:String):String{
		if(replace == undefined) replace = " ";
		var r:String = repeat+repeat;
		
		while (str.indexOf(r) > -1)
			str = str.split(r).join(repeat);
			
		return str.split(repeat).join(replace);
	}
	
	/**
	 * Return string's start index when it's appear one more times	
	 * @param		s:String		Source string
	 * @param		f:String		String you want find
	 * @param		times:Number	How many times string appeared
	 * @param		start:Number	Where we start search
	 * @return		id:Number		String id which you want	
	 */
	public static function indexTimes(s:String, f:String, times:Number, start:Number):Number{
		var id:Number = start?start:0;
		for(var i=0; i<times; i++){
			id = s.indexOf(f, id)+1;
		}
		return id-1;
	}
//--------------------------------------END-------------------------------------//
}
