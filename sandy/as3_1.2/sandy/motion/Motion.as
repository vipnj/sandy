package sandy.motion 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Motion   extends  Sprite   
	{
		public  var object:*;
		public var prop:String;
		public var begin:Number;
		public var duration:int;
		public var useSeconds:Boolean;
		public var startTime:int;
		public var time:int;
		public var prevTime:int;
		public var prevPos:Number;
		public var pos:Number;
		public var looping:Boolean;
		//event
		public  static var  CHANGED:String    ="changed";
		public  static var  STARTED:String    ="started";
		public  static var  STOP   :String    ="stop";
		public  static var  RESUMED:String    ="resumed";
		public  static var  LOOPED :String    ="looped";
		public  static var  FINISHED :String  ="finished";

		public function Motion(obj:*,prop:String,begin:Number,duration:int,useSeconds:Boolean=false)
		{
				this.object=obj;
				this.prop=prop;
				this.begin=begin;
				this.duration=duration;
				this.useSeconds=useSeconds;
				startTime=time=0;
			      prevPos=pos=begin;
			      start();
			}
			
		public function start():void
		{
			//trace("Motion Started !")
			rewind();
			addEventListener("enterFrame",nextFrames);
			dispatchEvent(new Event(Motion.STARTED));

			}
			
            public function stop():void
            {
			removeEventListener("enterFrame",nextFrames);
			dispatchEvent(new Event(Motion.STOP));
			}
		public function rewind(...arguments):void
		{
			if(arguments.length==0)
			{
				time=0;
			}
			else 
			{
				time=arguments[0];
			}
			fixTime();
		}
		
		public function resume():void 
		{
			fixTime();
			dispatchEvent(new Event(Motion.RESUMED));
		}
		
		public function fforward():void
		{
			setTime(duration);
			fixTime();
		}
        
        public function nextFrames(event:Event):void
        {
			if(useSeconds)
			{
				setTime((getTimer()-startTime)/1000) ;
				} else {
				setTime(time+1);
				}
				//trace("time ="+time );
			}
			
       public function prevFrame():void
       {
			if(! useSeconds) setTime(time-1) ;
			}
 		
 	public function setTime(t:int):void
 	{
			prevTime=time;
			if(t>duration){
				if(looping){
					rewind(t-duration);
					dispatchEvent(new Event(Motion.LOOPED));
				}else {
					stop();
					dispatchEvent(new Event(Motion.FINISHED));
			}
			} else if(t<0){
				rewind();
			}else {
				time=t ;
				}
				update();
		}
		public function fixTime():void{
			if(useSeconds){
				startTime=getTimer()-1000*time ;
				}
			}
		public function update():void{
			setPosition(getPosition(time));
			}
		/**
                     set an get methods
		**/
		public function setObj(obj:*):void{
			object=obj;
			}
		public function getObj():*{
			return object;
			}
		public function setProp(prop:String):void{
			this.prop=prop;
			}
		public function getProp():String{
			return this.prop;
			}
		public function getTime():int{
			return this.time;
			}
		public function setBegin(begin:Number):void{
			this.begin=begin;
			}
		public function getBegin():Number{
			return begin;
			}
		public function setDuration(duration:Number):void{
			this.duration=duration;
			}
		public function getDuration():Number{
			return duration ;
			}
		public function setUseSeconds(useSeconds:Boolean):void{
			this.useSeconds=useSeconds;
			}
		public function getUseSeconds():Boolean{
			return this.useSeconds;
			}
		public function setPosition(position:int):void{
			prevPos=pos ;
			object[prop]=pos=position ;
			dispatchEvent(new Event(Motion.CHANGED));
			}
		public function getPosition(...arguments):Number {

				return 0 ;
			}
		public function getPrevPosition():Number {
			return this.prevPos ;
			}
		public function setLooping(loop:Boolean):void {
			looping=loop ;
			}
		public function getLooping():Boolean {
			return looping ;
			}
            /**
                     set an get methods
		**/
	}
}