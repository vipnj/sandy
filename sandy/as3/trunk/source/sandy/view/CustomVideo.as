package sandy.view
{
	import mx.containers.Canvas;
    import flash.display.Sprite;
    import flash.events.*;
    import flash.media.Video;
    import flash.media.Sound;
    import flash.net.NetConnection;
    import flash.net.NetStream;

    public class CustomVideo extends EventDispatcher
    {
        private var _videoURL:String;
        private var connection:NetConnection;
        public var stream:NetStream;
        public var video:Video;
        public var mySound:Sound;
        public var _duration:Number;
        // if the video is stoped at the END, then Plat button should start video from beggining not togglePause
        private var _atTheEnd:Boolean = false;
        //if the video is maximized
        private var _maximized:Boolean = false;

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
		
		
        public function CustomVideo() 
        {
            
        }

        private function netStatusHandler(event:NetStatusEvent):void 
        {
        	trace("========> netStatusHandler: " + event.info.code);
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
                    connectStream();
                    stop();
                    // Parsing is finished
					dispatchEvent( new Event(CustomVideo.onInitEVENT ) );
                    break;
                case "NetStream.Buffer.Empty":
                	break;
                case "NetStream.Buffer.Flush":
               		 trace("Flush: " + duration + "," + stream.time + " , " + (duration - stream.time));
                	if ((duration - stream.time) < 0.2)
	                {
	                	//_videoControls.btnPlay.selected = false;
	                	//pause();
	                	//_atTheEnd = true;
	                	duration ++;
	                }
                	
                	break;
                case "NetStream.Buffer.Full":
                
                	break;
                case "NetStream.Play.Start":
	                _atTheEnd = false;
                	break;
                case "NetStream.Play.Stop":
	                trace(duration + "," + stream.time + " , " + (duration - stream.time));
                	_atTheEnd = true;
                	break;
                case "NetStream.Play.Complete":
                	trace("we are complete");
                	break;
                case "NetStream.Play.StreamNotFound":
                    trace("Unable to locate video: " + source);
                    break;
            }
        }

		public function init():void
		{
			connection = new NetConnection();
            connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            connection.connect(null);
		}
        public function play():void 
        {
        	//Alert.show("play " + source);
        	
        	if (source != null)
        	{
        		stop();
        		_atTheEnd = false;
	        	stream.play(source);
	        }
        }
        public function pause():void 
        {
        	stream.togglePause();
        }
        public function stop():void 
        {
        	stream.close();
        }
        public function setVolume(volume:Number):void
        {
        	//stream.receiveAudio();
        	
        	//Alert.show('set volume: ' + volume + " , curr: " + stream.soundTransform.volume);
        	//stream.soundTransform.volume = volume;
//        	mySound.setVolume(volume);
        }
        
        private function connectStream():void {
        	//Alert.show("custon");
            stream = new NetStream(connection);
            stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
            stream.client = new CustomClient(this);
            stream.bufferTime = 5;
            //stream.receiveVideo(false);
            video = new Video();
            video.attachNetStream(stream);
            
           // mySound=new Sound();
			//mySound.attachSound(stream);

            //addChild(video);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event);
        }
        
        private function asyncErrorHandler(event:AsyncErrorEvent):void {
            // ignore AsyncErrorEvent events.
            trace(event);
        }
        
        public function get isAtTheEnd():Boolean
        {
        	return 	_atTheEnd;
        }
        
        public function get source():String
        {
        	return 	_videoURL;
        }
        public function set source(url:String):void
        {
        	_videoURL = url;
        }
        
        public function get duration():Number
        {
        	return 	_duration;
        }
        public function set duration(duration:Number):void
        {
        	_duration = duration;
        }
        
        public function get maximized():Boolean
        {
        	return 	_maximized;
        }
        public function set maximized(maximized:Boolean):void
        {
        	_maximized = maximized;
        }

    }
 }
 
class CustomClient 
{
	import sandy.view.CustomVideo;
	
	private var _video:CustomVideo;
	
	public function CustomClient(video:CustomVideo)
	{
		_video = video;	
	}
    public function onMetaData(info:Object,... args):void {
        //trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
        _video.duration = info.duration;
    }
    public function onCuePoint(info:Object):void {
        trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
    }
    
    public function onTransition(info:Object,... args):void {
        trace("onTransition: time=" + info.time + " name=" + info.name + " type=" + info.type);
    }
}