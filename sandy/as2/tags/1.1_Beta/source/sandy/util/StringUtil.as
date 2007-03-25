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
}
