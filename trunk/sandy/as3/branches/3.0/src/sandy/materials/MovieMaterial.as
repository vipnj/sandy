
/**
* Sandy AS3 - VideoMaterial
* Based on the AS2 class VideoSkin made by kiroukou and zeusprod
* @author		Xavier Martin - zeflasher
* @author		Thomas PFEIFFER - kiroukou
* @since		1.0
* @version		1.0
* @date 		26.06.2007
*/

package sandy.materials
{
	iimport flash.display.*;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import sandy.core.data.Polygon;
	
	public class MovieMaterial extends BitmapMaterial
	{
		private var m_oTimer:Timer;
		private var m_oMovie : MovieClip;
			
		public function MovieMaterial( p_oMovie:MovieClip, p_nUpdateMS:uint = 40 )
		{
			super( new BitmapData( p_oMovie.width, p_oMovie.height, false, 0xFF000000 ) );
			m_oMovie = p_oMovie;
			m_nType = MaterialType.MOVIE;
			// --
			m_oTimer = new Timer( p_nUpdateMS );
			m_oTimer.addEventListener(TimerEvent.TIMER, _update );
			m_oTimer.start();
		}
		
		public override function renderPolygon ( p_oPolygon:Polygon, p_mcContainer:Sprite ) : void
		{
			super.renderPolygon( p_oPolygon, p_mcContainer );
		}
		
		private function _update( p_eEvent:TimerEvent ):void
		{
			//m_oTexture.dispose();
			// --
			m_oTexture.draw( m_oMovie );
		}
		
	}
}
