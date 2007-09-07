package sandy.events
{
	import flash.events.Event;
	/**
	 * @author 		Thomas Pfeiffer - kiroukou
	 * @version		1.0
	 * @date 		05.08.2006
	 */
	public class ParserEvent extends Event 
	{
		private var _s:String;
		private var _p:Number;
		public function ParserEvent( e:String, np:Number=0, ps:String=null) 
		{
			super( e );
			_s = ps;
			_p = np;
		}
		
		public function setPercent( n:Number ):void
		{
			_p = n;
		}
		
		/**
		* Returns the percentage of the parsing.
		* @param	Void
		* @return The percentage value, between [0,100]
		*/
		public function getPercent():Number
		{
			return _p;
		}
		
		public function setString( s:String ):void
		{
			_s = s;
		}
		
		/**
		* Returns the string representation of the parser code generation.
		* This allows you to save the code into a primitive class, and avoid the generation everytime.
		* This string si non null only if you called the export method of your Parser!
		*/
		public function getString():String
		{
			return _s;
		}
	}
}