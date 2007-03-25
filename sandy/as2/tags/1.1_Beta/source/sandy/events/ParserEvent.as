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
import com.bourre.events.BasicEvent;
import com.bourre.events.EventType;

/**
 * Class of the Parser events.
 * @author Thomas
 */
class sandy.events.ParserEvent extends BasicEvent 
{
	private var _s:String;
	private var _p:Number;
	public function ParserEvent( e:EventType, oT, np:Number, ps:String ) 
	{
		super( e, oT );
		_s = ps;
		_p = np;
	}
	
	public function setPercent( n:Number ):Void
	{
		_p = n;
	}
	
	/**
	* Returns the percentage of the parsing.
	* @param	Void
	* @return The percentage value, between [0,100]
	*/
	public function getPercent( Void ):Number
	{
		return _p;
	}
	
	/**
	* Returns the string representation of the parser code generation.
	* This allows you to save the code into a primitive class, and avoid the generation everytime.
	* This string si non null only if you called the export method of your Parser!
	*/
	public function getString( Void ):String
	{
		return _s;
	}
}