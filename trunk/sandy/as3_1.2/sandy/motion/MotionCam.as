package sandy.motion {
	import flash.display.Sprite;
	import flash.events.Event;
	public class MotionCam extends Motion {
		private var film:Array;
		private var isRecording:Boolean;
		private var actorProp:String;
		private var actorObj:*;
		public function MotionCam(obj:*,prop:String,duration:int){
			super(obj,prop,obj[prop],duration,false);
			setActor(obj,prop);
			film = [] ;
			}

		public function startRecord():void{
			isRecording=true ;
			}
		public function stopRecord():void{
			isRecording=false;
			}
		public function cutFilm(...arguments):void{
			var t:int;
			if(arguments.length == 0){
				t=time ;
			}else {
				t=arguments[0];
				}
			film.length=t+1 ;
			setDuration(t);
			}
		public function eraseFilm():void{
			film=[];
			setDuration(0);
			}
		public function getFilmString():String {
			return film.toString();
			}
		public function setFilmString(str:String):Array {
			return film=str.split(",") ;
			}
		public function setActor(ao:*,ap:String):void{
			actorObj=ao;
			actorProp=ap ;
			}
		public function getActorObj():*{
			return actorObj;
			}
		public function setActorObj(obj:*):void{
			 actorObj=obj ;
			}
		public function getActorProp():String{
			return actorProp;
			}
		public function setActorProp(p:String):void{
			 actorProp=p ;
			}
		public function setFilm(film_arr:Array):void {
			film=film_arr ;
			}
		public function getFilm():Array{
			return film ;
			}
		override public function  getPosition(...arguments):Number{
			var t:int ;
			if(arguments.length == 0 ){
				t=time ;
			}else {
				t=arguments[0];
				}
				return film[t] ;
			}
		override public function update():void {
			if(isRecording) film[time]=actorObj[actorProp];
                       setPosition(getPosition(time));
			}
		}
	}