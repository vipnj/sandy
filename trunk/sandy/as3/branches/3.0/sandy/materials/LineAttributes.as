/**
 * @author thomaspfeiffer
 */
package sandy.materials 
{
	public class LineAttributes 
	{
		private var m_nThickness:Number;
		private var m_nColor:Number;
		private var m_nAlpha:Number;
		// --
		public var modified:Boolean;
		
		public function LineAttributes( p_nThickness:uint = 1, p_nColor:uint = 0, p_nAlpha:Number = 100 )
		{
			m_nThickness = p_nThickness;
			m_nAlpha = p_nAlpha/100;
			m_nColor = p_nColor;
			// --
			modified = true;
		}
		
		public function get alpha():Number
		{return m_nAlpha;}
		
		public function get color():Number
		{return m_nColor;}
		
		public function get thickness():Number
		{return m_nThickness;}
		
		
		public function set alpha(p_nValue:Number):void
		{m_nAlpha = p_nValue; modified = true;}
		
		public function set color(p_nValue:Number):void
		{m_nColor = p_nValue; modified = true;}
		
		public function set thickness(p_nValue:Number):void
		{m_nThickness = p_nValue; modified = true;}
	}
}