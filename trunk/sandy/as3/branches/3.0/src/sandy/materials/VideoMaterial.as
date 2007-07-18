
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
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.utils.Timer;
	
	import sandy.core.data.Polygon;
	
	public class VideoMaterial extends BitmapMaterial
	{
		private var m_oTimer:Timer;
		private var m_oVideo : Video;
			
		public function VideoMaterial( p_oVideo:Video, p_nUpdateMS:uint = 40 )
		{
			super( new BitmapData( p_oVideo.width, p_oVideo.height, false, 0xFF000000 ) );
			m_oVideo = p_oVideo;
			m_nType = MaterialType.VIDEO;
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
			m_oTexture.draw( m_oVideo );
		}
		
	}
}
