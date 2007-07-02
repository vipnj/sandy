package sandy.motion {
	import flash.display.Sprite;

	import sandy.motion.Motion ;
	import flash.events.*;
	public class Tween extends Motion {
		private var func:Function;
		private var finish:Number;
		private var change:Number;
		public function Tween(obj:*,prop:String,func:Function,begin:Number,finish:Number,duration:int,useSeconds:Boolean=false){
			super(obj,prop,begin,duration,useSeconds);
			setFunc(func);
			setFinish(finish);
			change=finish-begin ;
			}
		public function continueTo(finish:Number,duration:Number):void{
			setBegin(getPosition());
			setFinish(finish);
			setDuration(duration);
			start();
			}
		public function yoyo():void{
			continueTo(-getBegin(),getTime());
			}
		override public function getPosition(...arguments):Number{
			var t:int;
			if(arguments.length == 0) {
				t=time ;
			}else {
				t=arguments[0];
				}
			return func(t,begin,change,duration) ;
			}
		public function setFunc(f:Function):void{
			func=f ;
			}
		public function getFunc():Function{
			return func ;
			}
		public function setChange(c:Number):void{
			change=c ;
			}
		public function getChange():Number{
			return change ;
			}
		public function setFinish(c:Number):void{
			change=c-begin;
			}
		public function getFinish():Number{
			return change +begin ;
			}
		}
	}