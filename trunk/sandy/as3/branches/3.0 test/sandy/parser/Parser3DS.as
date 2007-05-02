package sandy.parser
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
	

	import sandy.core.data.Matrix4;
	import sandy.core.data.Quaternion;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.parser.ParserEvent;
	import sandy.math.QuaternionMath;
	import sandy.math.VectorMath;
	import sandy.math.VertexMath;
	import sandy.core.scenegraph.Shape3D;
	import sandy.core.scenegraph.Geometry3D;

	internal final class Parser3DS extends AParser implements IParser
	{
		public function Parser3DS( p_sUrl:String )
		{
			super( p_sUrl );
			m_sDataFormat = URLLoaderDataFormat.BINARY;
		}
		
		/////////////////////
		///  PROPERTIES   ///
		/////////////////////		
		private var _rot_m:Array;
		private var currentObjectName:String;
		private var data:ByteArray;
		private var _animation:Array;
		private var startFrame:uint;
		private var endFrame:uint;   	
		private var lastRotation:Quaternion;
		
	    /**
	     * Initialize the object passed in parameter (which should be new) with the datas
	     * stored in the 3DS file given in second parameter
	     * 
	     * @param scene  Array 	All 3D objects will be added here
	     * @param url    String	The url of the .3DS file used to initialized the Object3D
	     */
	   protected override function parseData( e:Event ):void
		{
			super.parseData( e );
			// --			
			data = (m_oFileLoader.data as ByteArray );
			data.endian = Endian.LITTLE_ENDIAN;
			// --	
			var currentObjectName:String = null;
			var _rot_m:Array = new Array();		
			var ad:Array = new Array();
			var pi180:Number = 180 / Math.PI;
			var l_oGeometry:Geometry3D = null;
			var l_oShape:Shape3D = null;
			var x:Number, y:Number, z:Number;
			var l_qty:uint;
			
			var l_bFinished:Boolean = false;
			// --
			while( data.bytesAvailable > 0 && l_bFinished == false )
			{
				var id:uint = data.readUnsignedShort();
				//trace("chunk id: " + id);
				//trace("bytesAvailable: " + data.bytesAvailable);
				var l_chunk_length:uint = data.readUnsignedInt();
				//trace("chunk length: " + l_chunk_length);
				//trace("bytesAvailable: " + data.bytesAvailable);
				
				switch( id )
				{
					case Parser3DSChunkTypes.MAIN3DS:
						
						trace("0x4d4d MAIN3DS");
				        break;
				        
				    case Parser3DSChunkTypes.EDIT3DS:
				    	
				    	trace("0x3d3d EDIT3DS");
				        break;
				        
				   	case Parser3DSChunkTypes.KEYF3DS:
				   		trace("0xB000 KEYF3DS");
				   		break;
				   
				    case Parser3DSChunkTypes.EDIT_OBJECT:
		
				    	trace("0x4000");
				    	i=0;
				    	if( currentObjectName ) l_bFinished = true;
				    	else
						{
						    var str:String = readString();
					        l_oShape = new Shape3D( str );
					        l_oGeometry = new Geometry3D();
					        currentObjectName = str;
					    }
			         	break;
			         	
					case Parser3DSChunkTypes.OBJ_TRIMESH:
						
						trace("0x4100");
	         			break;
	         		 
	         		 case Parser3DSChunkTypes.TRI_VERTEXL:        //vertices
	         		 	
	         		 	trace("0x4110 vertices");
			            l_qty = data.readUnsignedShort();
			            for (var i:int=0; i<l_qty; i++)
			            {
			            	x = data.readFloat();
			            	y = data.readFloat();
			            	z = data.readFloat();
			            	//trace("vertice["+o.name+"] [" + x +","+y+","+z+"][" + x +","+(-z)+","+y+"]");
							l_oGeometry.setVertex( i, x, -z, y );
			            	//o.addPoint( x,-z, y );
			            }
			            //trace("In " + (getTimer() - time) + " ms we have list of " + vertex_list.length + " vertices");
			         	break;
			        
			         case Parser3DSChunkTypes.TRI_TEXCOORD:		// texture coords
				        
				        trace("0x4140  texture coords");
			            l_qty = data.readUnsignedShort();
			            for (i=0; i<l_qty; i++)
			            {
			            	var u:Number = data.readFloat();
			            	var v:Number = data.readFloat();
			            	//trace("u v: " + u + " , " + v);
			            	l_oGeometry.setUVCoords( i, u, 1-v );
			            	//uvCoordinates.push( o.addUVCoordinate( u, 1 - v ) );
			            }
			         	break;
			         
			         case Parser3DSChunkTypes.TRI_FACEL1:		// faces
			         
						trace("0x4120  faces");
			            l_qty = data.readUnsignedShort();
			            for (i = 0; i<l_qty; i++)
			            {
			            	var vertex_a:int = data.readUnsignedShort();
			            	var vertex_b:int = data.readUnsignedShort();
			            	var vertex_c:int = data.readUnsignedShort();
			            	
			            	var faceId:int = data.readUnsignedShort(); // TODO what is that? value is 3 or 6 ?....
			            	l_oGeometry.setFaceVertexIds(i, vertex_a, vertex_c, vertex_b );
			            	l_oGeometry.setFaceUVCoordsIds(i, vertex_a, vertex_c, vertex_b );
			            	//faces.push( [vertex_a, vertex_b, vertex_c]);
			            }
			            /*
			            for (i = 0; i<l_qty; i++)
			            {
			            	var p:Array = faces[i]
			            	f = new TriFace3D( o, o.aPoints[ p[1] ], o.aPoints[ p[0] ], o.aPoints[ p[2] ] )
			            	
			            	f.setUVCoordinates( uvCoordinates[ p[0] ], uvCoordinates[ p[1] ], uvCoordinates[ p[2] ] );
							o.addFace( f );
			            }
			            */
			            
			         	break;
			         	
			         case Parser3DSChunkTypes.TRI_LOCAL:		//ParseLocalCoordinateSystem
			         	trace("0x4160 TRI_LOCAL");
			         	
			         	var localX:Vector = readVector();
			         	var localY:Vector = readVector();
			         	var localZ:Vector = readVector();
			         	var origin:Vector = readVector();
			         	
			         	
			         	var init_m:Matrix4 = new Matrix4(	localX.x, localX.y, localX.z,0,
									         				localZ.x, localZ.y, localZ.z,0,
									         				localY.x, localY.y, localY.z,0,
									         				0,0,0,1 );
						
						l_oShape.transform.matrix = init_m;
						l_oShape.setPosition( origin.x, -origin.y, origin.z );
						/* _rot_m[currentObjectName] = init_m;
						 
			         	var originVertex:Vertex = origin.toVertex();
			         	var len:int = o.aPoints.length;
			         	for (i = 0; i<l_qty; i++)
			            {
			            	o.aPoints[i] = VertexMath.sub(  o.aPoints[i], originVertex );
			            }
			            */
			         	break;
			         	
			         case Parser3DSChunkTypes.OBJ_LIGHT:		//Lights
			         	trace("0x4600 Light");
			            var light:Vector = readVector();
			         	break;
			         	
			         case Parser3DSChunkTypes.LIT_SPOT:			//Light Spot
			         	
			         	var tx:Number = data.readFloat();
			            var ty:Number = data.readFloat();
			            var tz:Number = data.readFloat();
			            var hotspot:Number = data.readFloat();
			            var falloff:Number = data.readFloat();
			            
			         	break;
			         	
			         case Parser3DSChunkTypes.COL_TRU:			//RGB color
			         	var r:Number = data.readFloat();
			            y = data.readFloat();
			            z = data.readFloat();
			         	break;
			         	
			         case Parser3DSChunkTypes.COL_RGB:			//RGB color
			         	x = data.readByte();
			            y = data.readByte();
			            z = data.readByte();
			         	break;
			         	
			         case Parser3DSChunkTypes.OBJ_CAMERA:		//Cameras
			         	trace("0x4700 Cameras");
			         	
			         	x = data.readFloat();
			            y = data.readFloat();
			            z = data.readFloat();
			            
			            tx = data.readFloat();
			            ty = data.readFloat();
			            tz = data.readFloat();
			            
			            var angle:Number = data.readFloat();
			            var fov:Number = data.readFloat();
			            	
			         	break;
			         
			         // animation
			         case Parser3DSChunkTypes.KEYF_FRAMES:
			         	trace("0xB008 KEYF_FRAMES");
			         	startFrame = data.readInt();
			         	endFrame = data.readInt();
			         	break;
			         	
			         case Parser3DSChunkTypes.KEYF_OBJDES:
			         	trace("0xB002 KEYF_OBJDES");
			         	startFrame = data.readInt();
			         	endFrame = data.readInt();
			         	break;
			        
			         case Parser3DSChunkTypes.NODE_ID:
			         	trace("0xB030 NODE_ID");

			         	var node_id:uint = data.readUnsignedShort();
			         	/*
			         	var keyframer:Keyframer = new Keyframer();

			         	keyframer.startFrame = startFrame;
			         	keyframer.endFrame = endFrame;
			         	
			         	lastRotation = null;
			         	//ad.push(keyframer.);
			         	*/
			         	break;
			         	
			         case Parser3DSChunkTypes.NODE_HDR:
			         	trace("0xB010 NODE_HDR");
			         	/*
			         	var name:String = readString();
			         	var flag1:uint = data.readUnsignedShort();
			         	var flag2:uint = data.readUnsignedShort();
			         	var parent:int = data.readShort();
			         	
			         	keyframer.name = name;
			         	
			         	_animation[name] = keyframer;
			         	
			         	keyframer.flag1 = flag1;
			         	keyframer.flag2 = flag2;
			         	keyframer.parent = parent;
			         	//var endFrame:uint = data.readInt();
			         	*/
			         	break;	
			         
			         case Parser3DSChunkTypes.PIVOT:
			         	trace("0xB013 PIVOTR");
			         	x = data.readFloat();
			            y = data.readFloat();
			            z = data.readFloat();
			            
			            //keyframer.pivot = new Vector(x,z,y);
			            //trace("PIVOT: " + keyframer.pivot);
			         	//var endFrame:uint = data.readInt();
			         	break;
			         	
			         case Parser3DSChunkTypes.POS_TRACK_TAG:
			         	trace("0xB020 POS_TRACK_TAG");
			         	
			         	var flag1:uint = data.readUnsignedShort();
			         	for (var j:int=0; j<8; j++)
			         	{
			         		var unknown:Number = data.readByte();
			         	}
			            var keys:uint = data.readInt();
			            /*
			           	var frame0pos:Vector;
			            keyframer.track_data.pos_track_keys = keys;
			            
			            for (j = 0; j<keys; j++)
			         	{
			         		var posObj:Object = keyframer.getPositionObject();
			         		
			         		var key:uint = data.readInt();
			            	var acc:int = data.readShort();
				            //position
				            var rx:Number = data.readFloat();
				            var ry:Number = data.readFloat();
				            var rz:Number = data.readFloat();
				            
				            posObj.key = key;
				            posObj.acc = acc;
				            
				            posObj.position = new Vector(rx,rz,ry);
				            
//							trace("keyframer ["+keyframer.name+"] pos => " + posObj.position);
				         }
				         */
			         	break;	
			         	
			         case Parser3DSChunkTypes.ROT_TRACK_TAG:
			         	trace("0xB021 ROT_TRACK_TAG");
			         	
			         	flag1 = data.readUnsignedShort();
			         	for (j = 0; j<8; j++)
			         	{
			         		unknown = data.readByte();
			         	}
			            keys = data.readInt();
			            /*
			            keyframer.track_data.rot_track_keys = keys;
			            //keyframer.track_data.rot_track_data = new Array();
			            
			            for (j = 0; j<keys; j++)
			         	{
			         		var rotObj:Object = keyframer.getRotationObject();
			         		key = data.readInt();
			            	acc = data.readShort();
			            
				            var AnimAngle:Number = data.readFloat();
				            //axis
				            rx = data.readFloat();
				            ry = data.readFloat();
				            rz = data.readFloat();
				            
				            rotObj.key = key;
				            rotObj.acc = acc;
				            
				            var rotation:Quaternion = QuaternionMath.setAxisAngle(new Vector(rx,-rz,-ry), AnimAngle);
//				            trace("keyframer ["+keyframer.name+"] lastRotation1 => " + rotation);
				            if (lastRotation != null)
				            {
				            	lastRotation = QuaternionMath.multiply(lastRotation, rotation);
				            	
				            }
				            else
				            {
				            	lastRotation = QuaternionMath.setByMatrix(_rot_m[keyframer.name]);
				            	lastRotation = QuaternionMath.multiply(lastRotation, rotation);
				            	//lastRotation = QuaternionMath.clone(rotation);
				            }
				            if (key > 60)
				            {
								trace("keyframer ["+keyframer.name+"] lastRotation2["+key+"] => " + QuaternionMath.toEuler(lastRotation));
				            }
							rotObj.axis = lastRotation;
				        }
				        */
			         	break;	
			         	
			         case Parser3DSChunkTypes.SCL_TRACK_TAG:
			         	trace("0xB022 SCL_TRACK_TAG");
			         	
			         	flag1 = data.readUnsignedShort();
			         	for (j=0; j<8; j++)
			         	{
			         		unknown = data.readByte();
			         	}
			            keys = data.readInt();
			            /*
			            keyframer.track_data.scl_track_keys = keys;
			            
			            // ATTENTION:
			            // The rotation is relative to last frame to avoid the gimbal lock problem. 
			            //So if you want the "global" rotation, you need to concatenate them with quaterinion multiplication.
			            for (j = 0; j<keys; j++)
			         	{
			         		var sclObj:Object = keyframer.getScaleObject();
			         		
			         		key = data.readInt();
				            acc = data.readShort();
				            //size
				            rx = data.readFloat();
				            ry = data.readFloat();
				            rz = data.readFloat();
				            
				            sclObj.key = key;
				            sclObj.acc = acc;
				            sclObj.size = new Vector(rx,rz,ry);

							//trace("keyframer ["+keyframer.name+"] scl => " + sclObj.size);
				        }
				        */
			         	break;				
			         default:
				        trace("default");
			            data.position += l_chunk_length-6;
			 	}
			}
			// -- 
			l_oShape.geometry = l_oGeometry;
			m_oGroup.addChild( l_oShape );
			// -- Parsing is finished
			var l_eOnInit:ParserEvent = new ParserEvent( ParserEvent.onInitEVENT );
			l_eOnInit.group = m_oGroup;
			dispatchEvent( l_eOnInit );
		}

		private function readVector():Vector
		{
			var x:Number = data.readFloat();
			var y:Number = data.readFloat();
			var z:Number = data.readFloat();
			return new Vector(x, z, y);
		}
		
		private function readByte():int
		{
			return data.readByte();
		}
		
		private function readChar():uint
		{
			return data.readUnsignedByte();
		}
		private function readInt():uint 
		{
 			var temp:uint = readChar();
 			return ( temp | (readChar() << 8));
		}
		
		private function readString():String 
		{
 			var name:String = "";
 			var ch:uint;
 			while(ch = readChar())
 			{
 				if (ch == 0)
 				{
 					break;
 				}
 				name += String.fromCharCode(ch);
 			}
 			return name
		}
	}
}