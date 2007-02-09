/**
 * @author tom
 */
class sandy.view.Viewport 
{
	public var nWidth:Number;
	public var nHeight:Number;
	public var nW2:Number;
	public var nH2:Number;
	public var ratio:Number;
	
	public function Viewport( p_nWidth:Number, p_nHeight:Number )
	{
		nWidth = p_nWidth;
		nHeight = p_nHeight;
		nW2 = nWidth / 2;
		nH2 = nHeight / 2;
		ratio = nWidth / nHeight;
	}
	
}