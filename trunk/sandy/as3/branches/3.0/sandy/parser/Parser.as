package sandy.parser
{
	import sandy.parser.AParser;
	import sandy.parser.ASEParser;
	
	public final class Parser
	{
		public static function parse( p_sFileName:String ):IParser
		{
			var l_sExt:String = (p_sFileName.split('.')).reverse()[0];
			var l_iParser:IParser = null;
			// --
			switch( l_sExt.toUpperCase() )
			{
				case "ASE":
					l_iParser = new ASEParser( p_sFileName );
					break;
				case "OBJ":
					break;
				case "DAE":
					break;
				case "3DS":
					break;
				default:
					break;
			}
			// --
			return l_iParser;
		}
	}
}