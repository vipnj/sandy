
class sandy.view.ViewPort
{
    /**
	* Create a new ViewPort.
	*
	* @param: w a Number giving the width of the rendered screen
	* @param: h a Number giving the height of the rendered screen
	**/
	public function ViewPort ( p_w:Number, p_h:Number )
	{
		w = p_w;
		h = p_h;
		update();
	}
	
	public function update():Void
	{
		w2 = w/2;
		h2 = h/2;
		ratio = w/h;
	}
	
	public var w:Number;
	public var h:Number;
	public var w2:Number;
	public var h2:Number;
	public var ratio:Number;
}
