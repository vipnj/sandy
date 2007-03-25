package sandy.core.data
{
	import sandy.core.data.Vector;
	import sandy.core.data.Quaternion;
	
// THIS CLASS DEFINES A BONE IN THE ANIMATION SYSTEM
// A BONE IS ACTUALLY AN ABSTRACT REPRESENTATION OF A OBJECT
// IN THE 3D WORLD.  A CHARACTER COULD BE MADE OF ONE BONE
// WITH MULTIPLE VISUALS OF ANIMATION ATTACHED.  THIS WOULD
// BE SIMILAR TO A QUAKE CHARACTER.  BY MAKING IT HAVE LEVELS
// OF HIERARCHY AND CHANNELS OF ANIMATION IT IS JUST MORE FLEXIBLE

	public class Bone
	{
		public static const CHANNEL_TYPE_NONE:int			= 0;		// NO CHANNEL APPLIED
		public static const CHANNEL_TYPE_SRT:int			= 1;		// SCALE ROTATION AND TRANSLATION
		public static const CHANNEL_TYPE_TRANS:int			= 2;		// CHANNEL HAS TRANSLATION (X Y Z) ORDER
		public static const CHANNEL_TYPE_RXYZ:int			= 4;		// ROTATION (RX RY RZ) ORDER
		public static const CHANNEL_TYPE_RZXY:int			= 8;		// ROTATION (RZ RX RY) ORDER
		public static const CHANNEL_TYPE_RYZX:int			= 16;		// ROTATION (RY RZ RX) ORDER
		public static const CHANNEL_TYPE_RZYX:int			= 32;		// ROTATION (RZ RY RX) ORDER
		public static const CHANNEL_TYPE_RXZY:int			= 64;		// ROTATION (RX RZ RY) ORDER
		public static const CHANNEL_TYPE_RYXZ:int			= 128;		// ROTATION (RY RX RZ) ORDER
		public static const CHANNEL_TYPE_S:int				= 256;		// SCALE ONLY
		public static const CHANNEL_TYPE_T:int				= 512;		// TRANSLATION ONLY (X Y Z) ORDER
		public static const CHANNEL_TYPE_INTERLEAVED:int	= 1024;	// THIS DATA STREAM HAS MULTIPLE CHANNELS
		public static const CHANNEL_TYPE_BVH:int			= 2048;	// SPECIAL FORMAT FOR BVH

		public var id						:Number;		// BONE ID
		public var name						:String;		// BONE NAME
		public var flags					:Number;		// BONE FLAGS
		// HIERARCHY INFO
		public var parent					:Bone;			// POINTER TO PARENT BONE
		public var childCnt					:int;			// COUNT OF CHILD BONES
		public var children					:Array;			// POINTER TO CHILDREN
		// TRANSFORMATION INFO
		public var b_scale					:Vector;		// BASE SCALE FACTORS
		public var b_rot					:Vector;		// BASE ROTATION FACTORS
		public var b_trans					:Vector;		// BASE TRANSLATION FACTORS
		public var scale					:Vector;		// CURRENT SCALE FACTORS
		public var rot						:Vector;		// CURRENT ROTATION FACTORS
		public var trans					:Vector;		// CURRENT TRANSLATION FACTORS
		public var quat						:Quaternion;	// QUATERNION USEFUL FOR ANIMATION
	
		// ANIMATION INFO
		public var primChanType				:Number;		// WHAT TYPE OF PREIMARY CHAN IS ATTACHED
		public var primChannel				:Array;			// POINTER TO PRIMARY CHANNEL OF ANIMATION
		public var primFrameCount			:Number;		// FRAMES IN PRIMARY CHANNEL
		public var primSpeed				:Number;		// CURRENT PLAYBACK SPEED
		public var primCurFrame				:Number;		// CURRENT FRAME NUMBER IN CHANNEL
		public var secChanType				:Number;		// WHAT TYPE OF SECONDARY CHAN IS ATTACHED
		public var secChannel				:Array;			// POINTER TO SECONDARY CHANNEL OF ANIMATION
		public var secFrameCount			:Number;		// FRAMES IN SECONDARY CHANNEL
		public var secCurFrame				:Number;		// CURRENT FRAME NUMBER IN CHANNEL
		public var secSpeed					:Number;		// CURRENT PLAYBACK SPEED
		public var animBlend				:Number;		// BLENDING FACTOR (ANIM WEIGHTING)
		// DOF CONSTRAINTS
		public var min_rx					:int;			// ROTATION X LIMITS
		public var max_rx					:int;			// ROTATION X LIMITS
		public var min_ry					:int;			// ROTATION Y LIMITS
		public var max_ry					:int;			// ROTATION Y LIMITS
		public var min_rz					:int;			// ROTATION Z LIMITS
		public var max_rz					:int;			// ROTATION Z LIMITS
		public var damp_width				:Number;		// DAMPENING SETTINGS
		public var damp_strength			:Number;		// DAMPENING SETTINGS
		// VISUAL ELEMENTS
		public var visualCnt				:int;			// COUNT OF ATTACHED VISUAL ELEMENTS
		public var visuals					:Array;			// POINTER TO VISUALS
		public var CV_ptr					:int;			// POINTER TO CONTROL VERTICES
		public var CV_weight				:Number;		// POINTER TO ARRAY OF WEIGHTING VALUES
		// COLLISION ELEMENTS
		//public var float	bbox[6];					// BOUNDING BOX (UL XYZ, LR XYZ)
		//public var tVector	center;						// CENTER OF OBJECT (MASS)
		//public var float	bsphere;					// BOUNDING SPHERE (RADIUS)  
		// PHYSICS
		//public var tVector	length;						// BONE LENGTH VECTOR
		//public var float	mass;						// MASS
		//public var float	friction;					// STATIC FRICTION
		//public var float	kfriction;					// KINETIC FRICTION
		//public var float	elast;						// ELASTICITY
	
		public function Bone()
		{
			children = new Array();
			primChannel = new Array();
			secChannel = new Array();
			
			//initialize();
		}
		
		public function initialize():void
		{
			// INITIALIZE SOME OF THE SKELETON VARIABLES
			Bone.resetBone(this, null);
			children = new Array();
			primChannel = new Array();
			secChannel = new Array();
			
			id = -1;
			name ="Skeleton";

		}
		///////////////////////////////////////////////////////////////////////////////
		// Function:	DestroySkeleton
		// Purpose:		Clear memory for a skeletal system
		// Arguments:	Pointer to bone system
		///////////////////////////////////////////////////////////////////////////////
		public function destroySkeleton(root:Bone):void
		{
			/// Local Variables ///////////////////////////////////////////////////////////
			var loop:int;
			var child:Bone;
			///////////////////////////////////////////////////////////////////////////////
			// NEED TO RECURSIVELY GO THROUGH THE CHILDREN
			if (root.childCnt > 0)
			{
				child = root.children[0];
				for (loop = 0; loop < root.childCnt; loop++)
				{
					//TODO: must iterate on children
					if (child.childCnt > 0)
					{
						destroySkeleton(child);
					}
					if (child.primChannel > null)
					{
						//free(child.primChannel);
						//child.primChannel = NULL;
					}
				}
				//free(root.children);
			}
		
			root.primChanType = Bone.CHANNEL_TYPE_NONE;
			root.secChanType = Bone.CHANNEL_TYPE_NONE;
			root.primFrameCount = 0;
			root.secFrameCount = 0;
			root.primCurFrame = 0;
			root.secCurFrame = 0;
			root.primChannel = null;
			root.secChannel = null;
		
			root.visualCnt = 0;					// COUNT OF ATTACHED VISUAL ELEMENTS
			root.visuals = null;					// POINTER TO VISUALS
			root.childCnt = 0;						// COUNT OF ATTACHED BONE ELEMENTS
			root.children = null;					// POINTER TO CHILDREN
		}
		//// DestroySkeleton //////////////////////////////////////////////////////////
	
		///////////////////////////////////////////////////////////////////////////////
		// Function:	ResetBone
		// Purpose:		Reset the bone system and set the parent bone
		// Arguments:	Pointer to bone system, and parent bone (could be null)
		///////////////////////////////////////////////////////////////////////////////
		static public function resetBone(bone:Bone, parent:Bone):void
		{
			//bone.b_scale.x = bone.b_scale.y = bone.b_scale.z = 1;
			bone.b_scale = new Vector(1,1,1);
			//bone.scale.x = bone.scale.y = bone.scale.z = 1;
			bone.scale = new Vector(1,1,1);
			
			//bone.b_rot.x = bone.b_rot.y = bone.b_rot.z = 0;
			bone.b_rot = new Vector(0,0,0);
			//bone.rot.x = bone.rot.y = bone.rot.z = 0;
			bone.rot = new Vector(0,0,0);
		
			//bone.b_trans.x = bone.b_trans.y = bone.b_trans.z = 0;
			bone.b_trans = new Vector(0,0,0);
			//bone.trans.x = bone.trans.y = bone.trans.z = 0;
			bone.trans = new Vector(0,0,0);
		
			bone.primChanType = Bone.CHANNEL_TYPE_NONE;
			bone.secChanType = Bone.CHANNEL_TYPE_NONE;
			bone.primFrameCount = 0;
			bone.secFrameCount = 0;
			bone.primCurFrame = 0;
			bone.secCurFrame = 0;
			bone.primChannel = new Array();
			bone.secChannel = new Array();
		
			bone.visualCnt = 0;					// COUNT OF ATTACHED VISUAL ELEMENTS
			bone.visuals = new Array();					// POINTER TO VISUALS
			bone.childCnt = 0;						// COUNT OF ATTACHED BONE ELEMENTS
			bone.children = new Array();					// POINTER TO CHILDREN
			bone.parent = parent;
		}
		//// ResetBone ////////////////////////////////////////////////////////////////
		
		///////////////////////////////////////////////////////////////////////////////
		// Function:	BoneSetFrame
		// Purpose:		Set the animation stream for a bone
		// Arguments:	Pointer to bone system, frame to set to
		///////////////////////////////////////////////////////////////////////////////
		public function boneSetFrame(bone:Bone, frame:int):void
		{
			/// Local Variables ///////////////////////////////////////////////////////////
			var offset:Number;
			///////////////////////////////////////////////////////////////////////////////
		
			if (bone.primChannel != null)
			{
				//offset = (float *)(bone.primChannel + (s_Channel_Type_Size[bone.primChanType] * frame));
		
				// THIS HANDLES THE INDIVIDUAL STREAM TYPES.  ONLY ONE NOW.
				switch (bone.primChanType)
				{
					// TYPE_SRT HAS 9 FLOATS IN TXYZ,RXYZ,SXYZ ORDER
					case Bone.CHANNEL_TYPE_SRT:
						bone.trans.x = offset[0];
						bone.trans.y = offset[1];
						bone.trans.z = offset[2];
			
						bone.rot.x = offset[3];
						bone.rot.y = offset[4];
						bone.rot.z = offset[5];
			
			// I DON'T REALLY WANT MY ANIMATION TO DEAL WITH SCALE RIGHT NOW 
			// EVEN THOUGH IT IS IN THE BVA FILE
			//			bone.scale.x = offset[6];
			//			bone.scale.y = offset[7];
			//			bone.scale.z = offset[8];
						break;
				}
			}
		}
		//// BoneSetFrame /////////////////////////////////////////////////////////////////
		
		///////////////////////////////////////////////////////////////////////////////
		// Function:	BoneAdvanceFrame
		// Purpose:		Increment the animation stream for a bone and possible the
		//				children attached to that bone1
		// Arguments:	Pointer to bone system, Delta frame value to move, if it is recursive
		///////////////////////////////////////////////////////////////////////////////
		public function boneAdvanceFrame(bone:Bone, direction:int, doChildren:Boolean):void
		{
			/// Local Variables ///////////////////////////////////////////////////////////
			var loop:int;
			var child:Bone;
			//float **dataptr,*animData = NULL;
			///////////////////////////////////////////////////////////////////////////////
			if (bone.primChanType != Bone.CHANNEL_TYPE_BVH)
			{
				// THERE MUST BE SOME THINGS TO ADVANCE 
				if (bone.childCnt > 0)
				{
					child = bone.children[0];
					for (loop = 0; loop < bone.childCnt; loop++)
					{
						//TODO:must iterate children
						
						// ADVANCE THE STREAM
						child.primCurFrame += direction;
						if (child.primCurFrame >= child.primFrameCount)
						{
							child.primCurFrame = 0;
						}
						if (child.primCurFrame < 0)
						{
							child.primCurFrame += child.primFrameCount;
						}
						boneSetFrame(child,int(child.primCurFrame));
						if (doChildren && child.childCnt > 0)				// IF THIS CHILD HAS CHILDREN
						{
							boneAdvanceFrame(child,direction,doChildren);	// RECURSE DOWN HIER
						}
					}
				}
			}
			else	// Handle BVH
			{
				bone.primCurFrame += direction;
				if (bone.primCurFrame >= bone.primFrameCount)
				{
					bone.primCurFrame = 0;
				}
				if (bone.primCurFrame < 0)
				{
					bone.primCurFrame += bone.primFrameCount;
				}
				/*dataptr = (float **)bone.secChannel;
				animData = (float *)bone.primChannel;
				animData = &animData[(int)(bone.primCurFrame * bone.secFrameCount)];
				for (loop = 0; loop < bone.secFrameCount; loop++)
				{
					*dataptr[loop] = animData[loop];
				}*/
			}
		}
		//// BoneAdvanceFrame /////////////////////////////////////////////////////////////////
	
	}
	
	

}