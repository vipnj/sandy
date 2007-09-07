package sandy.primitive
{
	import flash.utils.Dictionary;
	
	import sandy.core.Object3D;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.data.bvh.BlockSet;
	import sandy.core.data.bvh.MotionData;
	import sandy.core.group.TransformGroup;
	import sandy.core.transform.Transform3D;
	import sandy.math.VectorMath;
	import sandy.skin.*;
	
	public class Biped extends Object3D
	{
		public var animation:Dictionary;
		public var animationID:String;
		public var currentAnimation:MotionData;
		public var currentFrame:uint;
		public var bonesObjects3D:Array;
		
		public function Biped()
		{
			animation = new Dictionary();
			bonesObjects3D = new Array();
		}
		
		public function addAnimation(motionData:MotionData):void
		{
			animationID = motionData.actionName;
			animation[animationID] = motionData;
			if (currentAnimation ==  null)
			{
				setAnimation(animationID);
			}
		}
		
		public function setAnimation(id:String):void
		{
			currentAnimation = animation[id];
			currentFrame = 0;
			
		}
		
		public function processStimulus(count:int, tgAll:TransformGroup = null):void
		{
			var motionData:MotionData = currentAnimation;
			var len:int = motionData.blocksSet.length;
			
			for (var i:int = 0; i < len; i++) 
			{
				var blockSet:BlockSet = motionData.blocksSet[i];
				var tg:TransformGroup = blockSet.tg;
				if (blockSet.t != null)
				{
					var t:Transform3D = motionData.blocksSet[i].t[count];
					tg.setTransform(t);
					var line:Line3D = new Line3D( [new Vertex(0,0,0), new Vertex(blockSet.bone.offsetX,blockSet.bone.offsetY,blockSet.bone.offsetZ) ] );
					var color:uint = uint(Math.random()*uint.MAX_VALUE);
					var ls:Skin = new SimpleLineSkin( 5,color, 1 );
					
					
					line.setSkin(ls);
					tg.addChild(line);
					if (tgAll != null)	tgAll.addChild(tg);
					
				}
			} 
		}
		/**
		* generate
		* 
		* <p>Generate all is needed to construct the Object3D : </p>
		* <ul>
		* 	<li>{@link Vertex}</li>
		* 	<li>{@link UVCoords}</li>
		* 	<li>{@link TriFace3D}</li>
		* </ul>
		* <p>It can construct dynamically the object, taking care of your preferences given in arguments. <br/>
		*    Note in Sandy 0.1 all faces have only three points.
		*    This will change in the future version, 
		*    and give to you the possibility to choose n points per faces</p> 
		*/
		public function generate (tg:TransformGroup, skin:Skin):void
		{
			//processStimulus(0, tg);
			
			create(0,tg);
			/*
			var rootBone:Bone3D = currentAnimation.root;

			trace("Biped generate "+ rootBone.offset);
	
			for (var i:String in rootBone.joints)
			{
				var currentBone:Bone3D = rootBone.joints[i];
				var position:Vector = currentBone.offset;			
				
				
				var v:Vertex = new Vertex(rootBone.offset.x, rootBone.offset.y, rootBone.offset.z);
				var bones:Array = new Array(v);
				
				v = new Vertex(position.x, position.y, position.z);
				bones.push(v);
				
				do
				{
					position = VectorMath.addVector(position, currentBone.joints[0].offset);
					//v = new Vertex(currentBone.joints[0].offset.x, currentBone.joints[0].offset.y, currentBone.joints[0].offset.z);
					v = new Vertex(position.x, position.y, position.z);
					bones.push(v);
					currentBone = currentBone.joints[0];
					
				} while(currentBone.joints[0]);
				
				var line:Line3D = new Line3D( bones );
				
				// save them for animation
				bonesObjects3D.push(line);
				
				var color:uint = uint(Math.random()*uint.MAX_VALUE);
				var ls:Skin = new SimpleLineSkin( 1,color, 1 );
				
				line.setSkin(ls);
				tg.addChild( line );
				
			}
			*/
			
		}
		
		public function create ( frame:uint, tg:TransformGroup = null ):void
		{
			//processStimulus(frame, tg);
			
			var boneObjectID:uint = 0;
			var channels:Array = currentAnimation.channels;
			var frameAnimation:Array = currentAnimation.frames[frame];
			var rootBone:Bone3D = currentAnimation.root;
			
			var channel_id:uint = 0;
			var currentBone:Bone3D = rootBone;
			//var vectors_count:uint = currentBone.channels_count/3;

					
			currentBone.transform.translateVector(currentBone.offset);
			var nm:String = currentBone.name;
			if (frameAnimation[channels[nm+"Xposition"]] != null)
			{
				var posVector:Vector = new Vector(frameAnimation[channels[nm+"Xposition"]], frameAnimation[channels[nm+"Yposition"]], frameAnimation[channels[nm+"Zposition"]]);
				currentBone.transform.translateVector(posVector);	
			}
			if (frameAnimation[channels[nm+"Xrotation"]] != null)
			{
//				var rotVector:Vector = new Vector(frameAnimation[channels[nm+"Xrotation"]], frameAnimation[channels[nm+"Yrotation"]], frameAnimation[channels[nm+"Zrotation"]]);
				currentBone.transform.rotY(frameAnimation[channels[nm+"Yrotation"]]);
				currentBone.transform.rotX(frameAnimation[channels[nm+"Xrotation"]]);
				currentBone.transform.rotZ(frameAnimation[channels[nm+"Zrotation"]]);
			}

			currentBone.tg.setTransform(currentBone.transform);
			currentBone.tg.addChild(currentBone.gfx);
			
			tg.addChild(currentBone.tg);
			//var rootOffset:Vector = VectorMath.addVector(rootBone.offset, posVector);
			//var rootRotation:Vector = VectorMath.addVector(rootBone.offset, rotVector);
			


			for (var j:String in rootBone.joints)
			{
				currentBone = rootBone.joints[j];
				currentBone.transform.translateVector(currentBone.offset);
				nm = currentBone.name;
				if (frameAnimation[channels[nm+"Xposition"]] != null)
				{
					posVector = new Vector(frameAnimation[channels[nm+"Xposition"]], frameAnimation[channels[nm+"Yposition"]], frameAnimation[channels[nm+"Zposition"]]);
					currentBone.transform.translateVector(posVector);
				}
				if (frameAnimation[channels[nm+"Xrotation"]] != null)
				{
					//rotVector = new Vector(frameAnimation[channels[nm+"Xrotation"]], frameAnimation[channels[nm+"Yrotation"]], frameAnimation[channels[nm+"Zrotation"]]);
					currentBone.transform.rotY(frameAnimation[channels[nm+"Yrotation"]]);
					currentBone.transform.rotX(frameAnimation[channels[nm+"Xrotation"]]);
					currentBone.transform.rotZ(frameAnimation[channels[nm+"Zrotation"]]);
				}
			
				currentBone.tg.setTransform(currentBone.transform);
				currentBone.tg.addChild(currentBone.gfx);
				
				tg.addChild(currentBone.tg);
				//var rotationXYZ:Array = new Array();
				//var offsetXYZ:Array = new Array();
				/*
				var xLoc:Array = new Array();
				var yLoc:Array = new Array();
				var zLoc:Array = new Array();
				var xRot:Array = new Array();
				var yRot:Array = new Array();
				var zRot:Array = new Array();
				var xSize:Array = new Array();
				var ySize:Array = new Array();
				var zSize:Array = new Array(); 
				*/
				
				//var position:Vector = posVector;
				
				/*
				var position:Vector =  VectorMath.addVector(rootOffset,currentBone.offset);	
				//var position:Vector =  VectorMath.addVector(rootOffset,posVector);	
				var v:Vertex = new Vertex(rootOffset.x, rootOffset.y, rootOffset.z);
				var bones:Array = new Array(v);
				
				v = new Vertex(position.x, position.y, position.z);
				bones.push(v);
				
				do
				{
					nm = currentBone.joints[0].name;
					if (frameAnimation[channels[nm+"Xposition"]] != null)
					{
						posVector = new Vector(frameAnimation[channels[nm+"Xposition"]], frameAnimation[channels[nm+"Yposition"]], frameAnimation[channels[nm+"Zposition"]]);
					}
					if (frameAnimation[channels[nm+"Xrotation"]] != null)
					{
						rotVector = new Vector(frameAnimation[channels[nm+"Xrotation"]], frameAnimation[channels[nm+"Yrotation"]], frameAnimation[channels[nm+"Zrotation"]]);
					}
				
					position = VectorMath.addVector(position, currentBone.joints[0].offset);
					//position = VectorMath.addVector(position, posVector);
					v = new Vertex(position.x, position.y, position.z);
					bones.push(v);
					currentBone = currentBone.joints[0];
					
				} while(currentBone.joints[0]);
				*/
				
				//trace("bones ["+boneObjectID+"] : " + bones)
				//var line:Line3D = bonesObjects3D[boneObjectID];
				// i update aPoints of Line, should I dispatch some event for redrawing?
				//line.update(bones);
				boneObjectID++;
			}
			
			
		}
		
		public function animate ( frame:uint, tg:TransformGroup = null ):void
		{
			//processStimulus(frame, tg);
			
			var boneObjectID:uint = 0;
			var channels:Array = currentAnimation.channels;
			var frameAnimation:Array = currentAnimation.frames[frame];
			var rootBone:Bone3D = currentAnimation.root;
			
			var channel_id:uint = 0;
			var currentBone:Bone3D = rootBone;
			//var vectors_count:uint = currentBone.channels_count/3;

					
			currentBone.transform.translateVector(currentBone.offset);
			var nm:String = currentBone.name;
			if (frameAnimation[channels[nm+"Xposition"]] != null)
			{
				var posVector:Vector = new Vector(frameAnimation[channels[nm+"Xposition"]], frameAnimation[channels[nm+"Yposition"]], frameAnimation[channels[nm+"Zposition"]]);
				currentBone.transform.translateVector(posVector);	
			}
			if (frameAnimation[channels[nm+"Xrotation"]] != null)
			{
//				var rotVector:Vector = new Vector(frameAnimation[channels[nm+"Xrotation"]], frameAnimation[channels[nm+"Yrotation"]], frameAnimation[channels[nm+"Zrotation"]]);
				currentBone.transform.rotY(frameAnimation[channels[nm+"Yrotation"]]);
				currentBone.transform.rotX(frameAnimation[channels[nm+"Xrotation"]]);
				currentBone.transform.rotZ(frameAnimation[channels[nm+"Zrotation"]]);
			}

			
			
			//var rootOffset:Vector = VectorMath.addVector(rootBone.offset, posVector);
			//var rootRotation:Vector = VectorMath.addVector(rootBone.offset, rotVector);
			


			for (var j:String in rootBone.joints)
			{
				currentBone = rootBone.joints[j];
				currentBone.transform.translateVector(currentBone.offset);
				
				nm = currentBone.name;
				if (frameAnimation[channels[nm+"Xposition"]] != null)
				{
					posVector = new Vector(frameAnimation[channels[nm+"Xposition"]], frameAnimation[channels[nm+"Yposition"]], frameAnimation[channels[nm+"Zposition"]]);
					
					currentBone.transform.translateVector(posVector);
				}
				if (frameAnimation[channels[nm+"Xrotation"]] != null)
				{
					//rotVector = new Vector(frameAnimation[channels[nm+"Xrotation"]], frameAnimation[channels[nm+"Yrotation"]], frameAnimation[channels[nm+"Zrotation"]]);
					currentBone.transform.rotY(frameAnimation[channels[nm+"Yrotation"]]);
					currentBone.transform.rotX(frameAnimation[channels[nm+"Xrotation"]]);
					currentBone.transform.rotZ(frameAnimation[channels[nm+"Zrotation"]]);
				}
			
				//var rotationXYZ:Array = new Array();
				//var offsetXYZ:Array = new Array();
				/*
				var xLoc:Array = new Array();
				var yLoc:Array = new Array();
				var zLoc:Array = new Array();
				var xRot:Array = new Array();
				var yRot:Array = new Array();
				var zRot:Array = new Array();
				var xSize:Array = new Array();
				var ySize:Array = new Array();
				var zSize:Array = new Array(); 
				*/
				
				//var position:Vector = posVector;
				
				/*
				var position:Vector =  VectorMath.addVector(rootOffset,currentBone.offset);	
				//var position:Vector =  VectorMath.addVector(rootOffset,posVector);	
				var v:Vertex = new Vertex(rootOffset.x, rootOffset.y, rootOffset.z);
				var bones:Array = new Array(v);
				
				v = new Vertex(position.x, position.y, position.z);
				bones.push(v);
				
				do
				{
					nm = currentBone.joints[0].name;
					if (frameAnimation[channels[nm+"Xposition"]] != null)
					{
						posVector = new Vector(frameAnimation[channels[nm+"Xposition"]], frameAnimation[channels[nm+"Yposition"]], frameAnimation[channels[nm+"Zposition"]]);
					}
					if (frameAnimation[channels[nm+"Xrotation"]] != null)
					{
						rotVector = new Vector(frameAnimation[channels[nm+"Xrotation"]], frameAnimation[channels[nm+"Yrotation"]], frameAnimation[channels[nm+"Zrotation"]]);
					}
				
					position = VectorMath.addVector(position, currentBone.joints[0].offset);
					//position = VectorMath.addVector(position, posVector);
					v = new Vertex(position.x, position.y, position.z);
					bones.push(v);
					currentBone = currentBone.joints[0];
					
				} while(currentBone.joints[0]);
				*/
				
				//trace("bones ["+boneObjectID+"] : " + bones)
				//var line:Line3D = bonesObjects3D[boneObjectID];
				// i update aPoints of Line, should I dispatch some event for redrawing?
				//line.update(bones);
				boneObjectID++;
			}
			
			
		}
	}
}