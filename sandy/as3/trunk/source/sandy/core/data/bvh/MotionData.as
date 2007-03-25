package sandy.core.data.bvh
{
	import sandy.core.data.Vector;
	import sandy.core.transform.Transform3D;
	import sandy.primitive.Bone3D;
	import flash.utils.Dictionary;
	
	public class MotionData
	{
		public var actionName :String;
		public var channels:Array;
		public var channels_id:uint = 0;
		public var frames:Array;
		public var blocksSet:Array;
		public var loop:Boolean = true;
		public var length:int = 0;
		private var _root:Bone3D;
		
		//public function MotionData(motionName:String, blockQueue:Array, scale:Number, rotationXYZ:Array, offsetXYZ:Array, frameCount:int )
		public function MotionData(motionName:String)
		{
			actionName = motionName;
			frames = new Array();
			
			//calc(blockQueue, scale, rotationXYZ, offsetXYZ, frameCount);
		}
		
		public function calc(blockQueue:Array, scale:Number, rotationXYZ:Array, offsetXYZ:Array, frameCount:int):void 
		{
			length = frameCount;
			blocksSet = new Array();
			
			var len:int = blockQueue.length;
			for (var i:int=0; i < len; i++) 
			{
				blocksSet[i] = new BlockSet();
				var d:BVHBlockData = BVHBlockData(blockQueue[i]);
				blocksSet[i].bone = d;
				blocksSet[i].identifier = d.identifier;
				blocksSet[i].tg = d.transformGroup;
				if ( (d.channels != null) && (d.channels.length > 0) )
				{
					calc2(d, blocksSet[i], scale, rotationXYZ, offsetXYZ, frameCount, i==0);
				}
			}
		}
		
		 public function calc2(d:BVHBlockData, blockSet:BlockSet, scale:Number, rotationXYZ:Array, offsetXYZ:Array, frameCount:int ,isRoot:Boolean):void
		 {
			//if (frameCount != d.channels[0].data.length) 
			
			if (frameCount != d.channels[0].length) 
			{
				trace("BVHBehavior.calc2().");
				trace("????.");
			}
			var xLoc:Array = new Array();
			var yLoc:Array = new Array();
			var zLoc:Array = new Array();
			var xRot:Array = new Array();
			var yRot:Array = new Array();
			var zRot:Array = new Array();
			var xSize:Array = new Array();
			var ySize:Array = new Array();
			var zSize:Array = new Array();
			
			var instanceMapping:Dictionary = new Dictionary();
			instanceMapping["Xposition"] = xLoc;
			instanceMapping["Yposition"] = yLoc;
			instanceMapping["Zposition"] = zLoc;
			instanceMapping["Xrotation"] = xRot;
			instanceMapping["Yrotation"] = yRot;
			instanceMapping["Zrotation"] = zRot;
			instanceMapping["Xscale"] = xSize;
			instanceMapping["Yscale"] = ySize;
			instanceMapping["Zscale"] = zSize;
			
			var len:int = d.channels.length;
			for (var i:int=0; i < len; i++) 
			{
				var s:String = d.channels[i].channelName;

				for (var j:Number=0; j < frameCount; j++) 
				{
					var channel:ChannelData = (d.getChannel(s));
					//var ll:int = channel.data.length;
					var ll:int = channel.length;
					//xLoc[j] = channel.data[j];
					instanceMapping[s][j] = channel[j];
					instanceMapping[s][j] = instanceMapping[s][j]*scale;
				}
			}
					
			/*
			for (var i:int=0; i < len; i++) 
			{
				var s:String = d.channels[i].getChannelName();
				if (s ==("Xposition")) 
				{
					//xLoc = new double[frameCount];
					for (var j:int=0; j < frameCount; j++) 
					{
						xLoc[j] = d.channels[i][j];
						xLoc[j] = xLoc[j]*scale;
					}
				} 
				else 
				{
					if (s ==("Yposition")) 
					{
						//yLoc = new double[frameCount];
						for (j=0; j < frameCount; j++) 
						{
							yLoc[j] = d.channels[i][j];
							yLoc[j] = yLoc[j]*scale;
						}
					} 
					else
					{
						if (s ==("Zposition")) 
						{
							//zLoc = new double[frameCount];
							for (j=0;j<frameCount;j++) 
							{
								zLoc[j] = d.channels[i][j];
								zLoc[j] = zLoc[j]*scale;
							}
						} 
						else
						{
							if (s ==("Xrotation")) 
							{
								//xRot = new double[frameCount];
								for (j=0;j<frameCount;j++) 
								{
									xRot[j] = d.channels[i][j];
									xRot[j] = xRot[j]/360.0*2.0*Math.PI;
								}
							} 
							else 
							{
								if (s ==("Yrotation")) 
								{
									//yRot = new double[frameCount];
									for (j=0;j<frameCount;j++) 
									{
										yRot[j] = d.channels[i][j];
										yRot[j] = yRot[j]/360.0*2.0*Math.PI;
									}
								} 
								else
								{ 
									if (s ==("Zrotation")) 
									{
										//zRot = new double[frameCount];
										for (j=0;j<frameCount;j++) 
										{
											zRot[j] = d.channels[i][j];
											zRot[j] = zRot[j]/360.0*2.0*Math.PI;
										}
									} 
									else
									{
										if (s ==("Xscale")) 
										{
											//xSize = new double[frameCount];
											for (j=0;j<frameCount;j++) 
											{
												xSize[j] = d.channels[i][j];
												xSize[j] = xSize[j]*scale;
											}
										} 
										else 
										{
											if (s ==("Yscale")) 
											{
												//ySize = new double[frameCount];
												for (j=0;j<frameCount;j++) 
												{
													ySize[j] = d.channels[i][j];
													ySize[j] = ySize[j]*scale;
												}
											} 
											else 
											{
												if (s ==("Zscale")) 
												{
													//zSize = new double[frameCount];
													for (j=0;j<frameCount;j++) 
													{
														zSize[j] = d.channels[i][j];
														zSize[j] = zSize[j]*scale;
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
			*/
			
			if (isRoot) 
			{
				/*
				if (xLoc==null)
				xLoc = new double[frameCount];
				if (yLoc==null)
				yLoc = new double[frameCount];
				if (zLoc==null)
				zLoc = new double[frameCount];
				*/
			
				if (offsetXYZ[0] != 0) 
				{
					for (j=0;j<frameCount;j++)
					{
						xLoc[j] = xLoc[j]+offsetXYZ[0];
					}
				}
				if (offsetXYZ[1] != 0) 
				{
					for (j=0;j<frameCount;j++)
					{
						yLoc[j] = yLoc[j]+offsetXYZ[1];
					}
				}
				if (offsetXYZ[2] != 0) 
				{
					for (j=0;j<frameCount;j++)
					{
						zLoc[j] = zLoc[j]+offsetXYZ[2];
					}
				}
				/*
				if (xRot==null)
				xRot = new double[frameCount];
				if (yRot==null)
				yRot = new double[frameCount];
				if (yRot==null)
				yRot = new double[frameCount];
				*/
				
				if (rotationXYZ[0] != 0) 
				{
					for (j=0;j<frameCount;j++)
					{
						xRot[j] = xRot[j]+rotationXYZ[0]/180.0*Math.PI;
					}
				}
				if (rotationXYZ[1] != 0) 
				{
					for (j=0;j<frameCount;j++)
					{
						yRot[j] = yRot[j]+rotationXYZ[1]/180.0*Math.PI;
					}
				}
				if (rotationXYZ[2] != 0) 
				{
					for (j=0;j<frameCount;j++)
					{
						zRot[j] = zRot[j]+rotationXYZ[2]/180.0*Math.PI;
					}
				}
			}
			//blockSet.t = new Transform3D[frameCount];
			blockSet.t = new Array(frameCount);
			for (i=0; i < frameCount; i++) 
			{
				var t0:Transform3D = new Transform3D();
				t0.translateVector(new Vector(d.offsetX * scale, d.offsetY * scale, d.offsetZ * scale));
				
				var t:Transform3D = new Transform3D();
				if ((xRot.length > 0 ) && (yRot.length > 0) && (zRot.length > 0)) 
				{
					t.rotZ(zRot[i]);
					var tt:Transform3D = new Transform3D();
					tt.rotX(xRot[i]);
//					t.mul(tt);
					t.combineTransform(tt);
					tt.rotY(yRot[i]);
//					t.mul(tt);
					t.combineTransform(tt);
				}
				if ((xLoc.length > 0)&&(yLoc.length > 0)&&(zLoc.length > 0)) 
				{
					t.translateVector(new Vector(xLoc[i], yLoc[i], zLoc[i]));
				}
				if ((xSize.length > 0)&&(ySize.length > 0)&&(zSize.length > 0)) 
				{
					t.scaleVector(new Vector(xSize[i],ySize[i],zSize[i]));
				}
//				t0.mul(t);
				t0.combineTransform(t);
				blockSet.t[i] = t0;
			}
		} 

		public function addChannel(channel:String):void
		{
			//if there is not channel (RegExp doesnt find it)
			//if (channel != null)
			//{
				channels[channel] = channels_id;
				channels_id++;
				//trace("addChannel ["+channel+"] => " + channels);
			//}
		}
		public function addJoint(joint:Bone3D, parentBone:Bone3D):void
		{
			parentBone.addJoint(joint);
		}
		
		// frames part
		public function addFrame(frame:Array):void
		{
			trace("motion addFrame: " + frame.length);
			frames.push(frame);
		}
		
		// SETTERS
		
		public function set root(bone:Bone3D):void
		{
			_root = bone;
		}
		
		// GETTERS
		
		public function get root():Bone3D
		{
			return _root;
		}
		
		/*
		public function get length():uint
		{
			return frames.length;
		}
		*/
	}
}