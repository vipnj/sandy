package sandy.parser
{
	import sandy.parser.AParser;
	import sandy.parser.ASEParser;
	import sandy.parser.Parser3DS;
	import sandy.parser.ColladaParser;
	
	public final class Parser
	{
		public static const ASE:String = "ASE";
		public static const MAX_3DS:String = "3DS";
		public static const COLLADA:String = "DAE";
		
		public static function create( p_sFile:*, p_sParserType:String=null, p_nScale:Number=1 ):IParser
		{
			var l_sExt:String,l_iParser:IParser = null;
			// --
			if( p_sFile is String && p_sParserType == null )
			{
				l_sExt = (p_sFile.split('.')).reverse()[0];
			}  
			else 
			{
				l_sExt = p_sParserType;
			}
			// --
			switch( l_sExt.toUpperCase() )
			{
				case "ASE":
					l_iParser = new ASEParser( p_sFile, p_nScale );
					break;
				case "OBJ":
					break;
					
				case "DAE":
					l_iParser = new ColladaParser( p_sFile, p_nScale );
					break;
				case "3DS":
					l_iParser = new Parser3DS( p_sFile, p_nScale );
					break;
					
				default:
					break;
			}
			// --
			return l_iParser;
		}
	}
}
