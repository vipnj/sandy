/**
 * @author thomaspfeiffer
 */
class sandy.view.CullingState 
{
	public static function get INTERSECT():CullingState { return _INTERSECT_ ; };
	private static var _INTERSECT_:CullingState = new CullingState("intersect");
	
	public static function get INSIDE():CullingState { return _INSIDE_ ; };
	private static var _INSIDE_:CullingState = new CullingState("inside");
	
	public static function get OUTSIDE():CullingState { return _OUTSIDE_ ; };
	private static var _OUTSIDE_:CullingState = new CullingState("outside");
	
	public function toString():String
	{
		return "[sandy.view.CullingState] :: state : "+m_sState;
	}
	
	private function CullingState( p_sState:String )
	{
		m_sState = p_sState;
	}
	
	private var m_sState:String;
	
}