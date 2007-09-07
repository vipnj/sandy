package sandy.util
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	import flash.utils.unescapeMultiByte;
	
	import sandy.core.data.bvh.MotionData;
	import sandy.core.data.Vector;
	import sandy.events.ParserEvent;
	import sandy.primitive.Biped;
	import sandy.primitive.Bone3D;
	
	public class ParserBVH extends EventDispatcher
	{
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
		
		private static const _eProgress:ParserEvent = new ParserEvent( ParserBVH.onProgressEVENT, 0, "" );
		
		
		/////////////////////
		///  PROPERTIES   ///
		/////////////////////		
		public const loader:URLLoader = new URLLoader();
		private var _motion:MotionData;
		private var _biped:Biped;
		
	    /**
	     * Initialize the object passed in parameter (which should be new) with the datas
	     * stored in the 3DS file given in second parameter
	     * 
	     * @param scene  Array 	All 3D objects will be added here
	     * @param url    String	The url of the .3DS file used to initialized the Object3D
	     */
	    public function parse( biped:Biped, motion:MotionData, url:String):void
		{
			// Construction d'un objet URLRequest qui encapsule le chemin d'accÃ¨s
			var urlRequest:URLRequest = new URLRequest(url);
			// Ecoute de l'evennement COMPLETE
			
			loader.addEventListener( Event.COMPLETE, _parse );
			loader.addEventListener( IOErrorEvent.IO_ERROR , _io_error );
			
			//Scene initializing
			_biped = biped;
			_motion = motion;
			
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.load(urlRequest);
		}
		
		
		private function _parse(event:Event):void 
		{
			var file:URLLoader = URLLoader(event.target);
			var data:String = unescapeMultiByte( (file.data as String ) );
			
			var boneID:uint = 0;
			var currentBone:Bone3D;
			var parentBone:Bone3D;
			
			//var firstReg:RegExp = /HIERARCHY([\w\s{}:.-]*)MOTION([\w\s{}:.-]*)/ig;
			var firstReg:RegExp = /HIERARCHY([\w\s{}:.-]*)MOTION\s*Frames:\s*(\d*)\s*Frame\s*Time:\s*([\d.]*)\s*([\w\s{}:.-]*)/ig;
	//		var firstReg:RegExp = /HIERARCHY([\w\s{}:.-]*)MOTION\s*Frames:\s*(\d*)\s*Frame\s*Time:\s*([\d.]*)\s*([\w\s{}:.-]*)/ig;
			
		//	var bonesReg:RegExp = /(ROOT|JOINT)\s+(\w*)\s+{\s*OFFSET\s+([-.\d]*)\s+([-.\d]*)\s+([-.\d]*)\s+CHANNELS\s+(\d*)\s+(([ZXY]rotation)\s+([ZXY]rotation)\s+([ZXY]rotation)\s+|([ZXY]position)\s+([ZXY]position)\s+([ZXY]position)\s+)*|(End Site)\s*{\s*OFFSET\s+([-.\d]*)\s+([-.\d]*)\s+([-.\d]*)/ig;
			var bonesReg:RegExp = /(ROOT|JOINT)\s+(\w*)\s+{\s*OFFSET\s+([-.\d]*)\s+([-.\d]*)\s+([-.\d]*)\s+CHANNELS\s+(\d*)\s+(([ZXY]position)\s+([ZXY]position)\s+([ZXY]position))*\s*(([ZXY]rotation)\s+([ZXY]rotation)\s+([ZXY]rotation))*\s*|(End Site)\s*{\s*OFFSET\s+([-.\d]*)\s+([-.\d]*)\s+([-.\d]*)/ig;
			var frameReg:RegExp = /(([-\d.]*)[ \t]*)*\r\n/ig;
//			var frameReg:RegExp = /(([-\d.]*)[ \t]*)*\r\n/ig;		
			

	
			
			var result:Array = firstReg.exec(data);
			
			var hierarchy:String = result[1];
			var frames:String = result[4];
			var framesCount:uint = result[2];
			var framesRate:Number = result[3];
			
			var result1:Array = bonesReg.exec(hierarchy);
			var result2:Array = frameReg.exec(frames);
			
			
			/*var bone:String = result1[2];
			var channelsStr:String = result1[5];
			var channelsNr:uint = result1[6];
			
			currentBone = new Bone3D(bone, channelsNr, boneID);
			currentBone.offset = new Vector(result1[3],result1[4], result1[5]);
			parentBone = currentBone;
			_motion.root = parentBone;
			boneID ++;
			*/

		    //result1 = bonesReg.exec(hierarchy);	
		    _motion.channels = [];		
			while (result1 != null) 
			{
				if (result1[15] != "End Site")
				{
					//bone = result1[2];
					//channelsStr = result1[6];
					//channelsNr = result1[7];
					
					var bone:String = result1[2];
					//var channelsStr:String = result1[6];
					var channelsNr:uint = result1[6];
					
					
			
					currentBone = new Bone3D(bone, channelsNr, boneID);
					currentBone.offset = new Vector(result1[3],result1[4], result1[5]);
					
					//must not be parallel					
					for (var t:int = 0;t < 3; t++)
						if (result1[t+8])	_motion.addChannel(bone+result1[t+8]);
					for (t = 0;t < 3; t++)
						if (result1[t+12])	_motion.addChannel(bone+result1[t+12]);
					
					if (parentBone != null)
					{
						parentBone.addJoint(currentBone);
					}
					else
					{
						// this is the 1st bone (doens have parent)
						_motion.root = currentBone;
					}
					parentBone = currentBone;
				}
				else
				{
					// end point in bone chain
					currentBone = new Bone3D("endTo"+parentBone.name, 0, boneID);

					// must check if height is y or z
					currentBone.offset = new Vector(result1[15],result1[16], result1[17]);
					parentBone.addJoint(currentBone);
					parentBone = _motion.root;
				}
				
				
				boneID ++;
				
			    result1 = bonesReg.exec(hierarchy);
			}
			trace(" len: " + _motion.channels.length + "_motion.channels: " + _motion.channels);
			
			var frameDataReg:RegExp = /([-.\d]*)\s+/ig;
			
			while (result2 != null) 
			{
				var animframeData:Array = frameDataReg.exec(result2[0]);
				var frameData:Array = new Array();
				while (animframeData != null) 
				{
					frameData.push(animframeData[1]);
					animframeData = frameDataReg.exec(result2[0]);
				}
				
				_motion.addFrame(frameData);
				
			    result2 = frameReg.exec(frames);	
			}
			
//			var jointsReg:RegExp = /JOINT\s*(\w*)\s*(\s*OFFSET\s*([-.\d]*)\s*([-.\d]*)\s*([-.\d]*)\s*CHANNELS/ig;
//			var channelsReg:RegExp = /CHANNELS\s*(\d*)\s*(([ZXY]rotation|[ZXY]position)\s*)*/ig;
			
//			OFFSET\s*(([-.\d]*)\s*)*(CHANNELS\s*(\d*)\s*(([ZXY]rotation|[ZXY]position)\s*)*)*
//			OFFSET\s*(([-.\d]*)\s*)*(CHANNELS\s*(\d*)\s*(([ZXY]rotation|[ZXY]position)\s*)*)*(JOINT\s*(\w*)|End Site)*
//ROOT\s*(\w*)\s*{\s*

//JOINT\s*(\w*)\s*{\s*OFFSET\s*(([-.\d]*)\s*)*(CHANNELS\s*(\d*)\s*(([ZXY]rotation|[ZXY]position)\s*)*)*|End Site\s*{\s*OFFSET\s*(([-.\d]*)\s*)*

			_biped.addAnimation(_motion);
			dispatchEvent( new ParserEvent(ParserBVH.onInitEVENT ) );
		}
	
		/**
		* Function is call in case of IO error
		* @param	e IOErrorEvent 	IO_ERROR
		*/
		private function _io_error( e:IOErrorEvent ):void
		{
			dispatchEvent( new ParserEvent( ParserBVH.onFailEVENT ) );
		}
	
	}
}