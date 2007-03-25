import com.bourre.events.BasicEvent;
import com.bourre.events.EventType;

/**
 * @author thomaspfeiffer
 */
class sandy.events.MouseEvent extends BasicEvent 
{
	
	public static var CLICK:EventType = new EventType( "MouseClickEVENT" );
	public static var MOUSE_UP:EventType = new EventType( "MouseUpEVENT" );
	public static var MOUSE_DOWN:EventType = new EventType( "MouseDownEVENT" );
	public static var ROLL_OVER:EventType = new EventType( "MouseRollOverEVENT" );
	public static var ROLL_OUT:EventType = new EventType( "MouseRollOutEVENT" );
	
	public function MouseEvent(e : EventType, oT) 
	{
		super(e, oT);
	}

}