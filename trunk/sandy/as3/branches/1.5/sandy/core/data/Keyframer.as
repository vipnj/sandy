package sandy.core.data
{
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vector;
	import sandy.math.VectorMath;
	import sandy.math.QuaternionMath;

	public class Keyframer
	{
		public var id:int;
		
		public var startFrame:int;
		public var endFrame:int;
		/**
	     * Name of animated object
	     */
		public var name:String;
		
		/**
	     * ID for parent object. If object has no parent, -1 is provided
	     */
		public var parent:int;
		
		/**
	     * flags,    do we need them?
	     */
		public var flag1:int;
		public var flag2:int;
		
		/**
	     * Pivot
	     */
		public var pivot:Vector;
		
		
		public var track_data:Object;
		
		/**
		 * Create a new Keyframer.
		 * <p> This class is for storing keyframe animation of 3D object. This info is stored in .3ds file, or you can create your own keyframe animation</p>
		 * 
		 */
		public function Keyframer()
		{
			track_data = new Object();
			track_data.pos_track_keys = 0;
			track_data.pos_track_tag = new Array();
			track_data.rot_track_keys = 0;
			track_data.rot_track_tag = new Array();
			track_data.scl_track_keys = 0;
			track_data.scl_track_tag = new Array();
		}
		
		public function tracePositionFrames(from:int = 0, toFrame:int = -1):void
		{
			var posLen:uint = track_data.pos_track_tag.length;
			for (var i:int=0;i<posLen;i++)
			{
				var position:PositionObject = track_data.pos_track_tag[i];
				trace(this.name + ": " + position);
			}
		}
		public function traceRotationFrames(from:int = 0, toFrame:int = -1):void
		{
			var posLen:uint = track_data.rot_track_tag.length;
			for (var i:int=0;i<posLen;i++)
			{
				var position:RotationObject = track_data.rot_track_tag[i];
				trace(this.name + ": " + position);
			}
		}
		public function traceScaleFrames(from:int = 0, toFrame:int = -1):void
		{
			var posLen:uint = track_data.scl_track_tag.length;
			for (var i:int=0;i<posLen;i++)
			{
				var position:ScaleObject = track_data.scl_track_tag[i];
				trace(this.name + ": " + position);
			}
		}
		
		
		public function getFramePosition(frame:uint):Object
		{
			var notFound:Boolean = true;
			var pos:uint = 0;
			
			var posLen:uint = track_data.pos_track_tag.length;
			
			while(notFound)
			{
				var position:PositionObject = track_data.pos_track_tag[pos];
				if (posLen > (pos+1))
				{
					var positionNext:PositionObject = track_data.pos_track_tag[pos+1];
					
					var frameBefore:uint = position.key;
					var frameAfter:uint = positionNext.key;
					
					if ((frameBefore <= frame) && (frameAfter >= frame))
					{
						notFound = false;
						//trace("found position frame["+frame+"] : " + frameBefore + " , " + frameAfter);
						var diffFrame:int = frameAfter - frameBefore;
						if ( diffFrame < 2 )
						{
							// next frame, is just same frame  (last) or current + 1
							return position;
						}
						else
						{
							// there is difference more than 1 frame
							var retPosition:PositionObject = new PositionObject();
							var diffFrame2:int = frame - frameBefore;
							
							var k:Number = diffFrame2 / diffFrame;
							
							var po1:Vector = position.position;
							var po2:Vector = positionNext.position;
							
							retPosition.position = VectorMath.addVector( VectorMath.scale( VectorMath.sub(po2, po1), k), po1 )
							
							return retPosition;
						}
					}
				}
				else
				{
					positionNext = position;
					notFound = false;
					//trace("end pos object ["+frame+"] =>  " + pos + "/"+posLen);
					return positionNext;
				}
				pos++;
			}
			return position;
		}
		
		//interpolation => must be used Quaternion:SLERP method
		public function getFrameRotation(frame:uint):Object
		{
			var notFound:Boolean = true;
			var pos:uint = 0;
			
			var rotLen:uint = track_data.rot_track_keys;
			
			while(notFound)
			{
				var rotation:RotationObject = track_data.rot_track_tag[pos];
				if (rotLen > (pos+1))
				{
					var rotationNext:RotationObject = track_data.rot_track_tag[pos+1];
					
					var frameBefore:uint = rotation.key;
					var frameAfter:uint = rotationNext.key;
					
					if ((frameBefore <= frame) && (frameAfter >= frame))
					{
						notFound = false;
						//trace("found rotation frame["+frame+"] : " + frameBefore + " , " + frameAfter);
						var diffFrame:int = frameAfter - frameBefore;
						
						if ( diffFrame < 2 )
						{
							// next frame, is just same frame  (last) or current + 1
							return rotation;
						}
						else
						{
							// there is difference more than 1 frame
							var retRotation:RotationObject = new RotationObject();
							var diffFrame2:int = frame - frameBefore;
							
							var k:Number = diffFrame2 / diffFrame;
							/*
							var an1:Number = rotation.angle;
							var an2:Number = rotationNext.angle;
							
							var ax1:Vector = rotation.axis;
							var ax2:Vector = rotationNext.axis;
							
							retRotation.angle = an1 + (an2 - an1) * k;
							retRotation.axis = VectorMath.addVector( VectorMath.scale( VectorMath.sub(ax2, ax1), k), ax1 )
							*/
							
							var an1:Quaternion = rotation.axis;
							var an2:Quaternion = rotationNext.axis;
							
							//retRotation.axis = VectorMath.addVector( VectorMath.scale( VectorMath.sub(an2, an1), k), an1 )
							retRotation.axis = QuaternionMath.Slerp(k, an1, an2);
							
							
							
							return retRotation;
						}
					}
				
				}
				else
				{
					rotationNext = rotation;
					notFound = false;
					//trace("end rot object")
					return rotationNext;
				}
				
				
				pos++;
				
			}
			return rotation;
		}
		
		public function getFrameScale(frame:uint):Object
		{
			var notFound:Boolean = true;
			var pos:uint = 0;
			
			var sclLen:uint = track_data.scl_track_tag.length;
			
			while(notFound)
			{
				var scale:ScaleObject = track_data.scl_track_tag[pos];
				if (sclLen > (pos+1))
				{
					var scaleNext:ScaleObject = track_data.scl_track_tag[pos+1];
					
					var frameBefore:uint = scale.key;
					var frameAfter:uint = scaleNext.key;
					
					if ((frameBefore <= frame) && (frameAfter >= frame))
					{
						notFound = false;
						//trace("found position frame["+frame+"] : " + frameBefore + " , " + frameAfter);
						var diffFrame:int = frameAfter - frameBefore;
						if ( diffFrame < 2 )
						{
							// next frame, is just same frame  (last) or current + 1
							return scale;
						}
						else
						{
							// there is difference more than 1 frame
							var sclPosition:ScaleObject = new ScaleObject();
							var diffFrame2:int = frame - frameBefore;
							
							var k:Number = diffFrame2 / diffFrame;
							
							var scl1:Vector = scale.size;
							var scl2:Vector = scaleNext.size;
							
							sclPosition.size = VectorMath.addVector( VectorMath.scale( VectorMath.sub(scl2, scl1), k), scl1 )
							
							return sclPosition;
						}
					}
				}
				else
				{
					scaleNext = scale;
					notFound = false;
					//trace("end pos object ["+frame+"] =>  " + pos + "/"+sclLen);
					return scaleNext;
				}
				pos++;
			}
			return scale;
		}
		
		public function getPositionObject():PositionObject
		{
			var posObj:PositionObject = new PositionObject();
			track_data.pos_track_tag.push(posObj);
			
			return posObj;
		}
		
		public function getRotationObject():RotationObject
		{
			var rotObj:RotationObject = new RotationObject();
			track_data.rot_track_tag.push(rotObj);
			
			return rotObj;
		}
		
		public function getScaleObject():ScaleObject
		{
			var sclObj:ScaleObject = new ScaleObject();
			track_data.scl_track_tag.push(sclObj);
			
			return sclObj;
		}
		
		/**
	     * Returns the number of frames of the animation
	     * @return Number the number of frames of the animation
	     * 
	     * @param Void    Void
	     */
	    public function getTotalFrames():uint
	    {
	    	return endFrame;
	    }
	    
		/**
	     * Get a String representation of the {@code Keyframer}.
	     * @return	A String representing the {@code Keyframer}.
	     * 
	     * @param Void    Void
	     */
	    public function toString():String
	    {
	    	return "sandy.core.data.Keyframer";
	    }
	}
}

class PositionObject extends Object
{
	import sandy.core.data.Vector;
	
	public var keys:int;
	public var key:uint;
	public var acc:int;
	public var position:Vector;
	
	public function PositionObject()
	{
		

	}
	
	public function toString():String
	{
		return 'Position ['+key+'] = ' + position;
	}

}

class RotationObject extends Object 
{
	import sandy.core.data.Quaternion;
	import sandy.core.data.Vector;
	import sandy.core.data.Matrix4;
	
	public var keys:int;
	public var key:uint;
	public var acc:int;
	//public var axis:Vector;
	public var axis:Quaternion;
	public var matrix:Matrix4;
	//public var angle:Number;
	public var angle:Quaternion;
	
	public function RotationObject()
	{
		

	}
	
	public function toString():String
	{
		//return 'Rotation ['+key+'] = ' + angle + " axis: " + axis;
		return 'Rotation ['+key+'] = ' + angle;
	}

}

class ScaleObject extends Object 
{
	import sandy.core.data.Vector;
	
	public var keys:int;
	public var key:uint;
	public var acc:int;
	public var size:Vector;
	
	public function ScaleObject()
	{
		

	}
	
	public function toString():String
	{
		return 'Scale ['+key+'] = ' + size;
	}

}