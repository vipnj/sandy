package sandy.parser
{
	import flash.events.Event;
	
	import sandy.core.scenegraph.Group;

	public final class ParserEvent extends Event
	{
		/**
	     * The load has failed
	     */
	    static public const onFailEVENT:String = 'onFailEVENT';
	    /**
	     * The OBject3D object is initialized
	     */
	    static public const onInitEVENT:String = 'onInitEVENT';
	    /**
	     * The load has started
	     */
	    static public const onLoadEVENT:String = 'onLoadEVENT';
		/**
		 *  The load is in progress
		 */
		public static const onProgressEVENT:String = 'onProgressEVENT';
		
		
		public var percent:Number;
		public var group:Group;

		public function ParserEvent( p_sType:String )
		{
			super( p_sType );
		}
	}
}