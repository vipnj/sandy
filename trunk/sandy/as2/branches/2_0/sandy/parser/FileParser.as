/**
 * @ClassName:			sandy.util.FileParser
 * @Version:			V 1.0.3
 * @Author:				Peanut
 * @Description:			
 *		sandy.util
 *		for sandy 1.2
 * @Date:				2007-1-24	
 * @Usage:
 * 		parse WRL/ASE file information
 */

import sandy.core.data.Matrix4;
import sandy.core.data.Quaternion;
import sandy.core.data.UVCoord;
import sandy.core.data.Vector;
import sandy.core.scenegraph.Object3D;
import sandy.core.scenegraph.Shape3D;
import sandy.core.transform.Transform3D;
import sandy.math.QuaternionMath;
import sandy.skin.MovieSkin;
import sandy.util.ArrayUtil;
import sandy.util.StringUtil;

 
class sandy.parser.FileParser 
{
	// seems that WRL format use a different face orientation than Sandy
	private var __reverseFace:Boolean;	//

	/**
	 *Parse WRL file.
	 *@Surport	WRL(3D Max/Maya)
	 */
	function FileParser()
	{
		reverseFace = false;
	}
	
	/**Parse WRL/ASE fiel
	 * @param f:String -> WRL file url
	 */
	public function parse(f:String):Array
	{
		//check VRML version
		if(f.indexOf("#VRML V2.0") > -1)
		{
			// select a parser
			if(f.indexOf("3D Studio MAX")>-1)
			{
				return WRL_3DMax(f);
			}
			else if(f.indexOf("Alias Maya")>-1)
			{
				return WRL_Maya(f);
			}
		}
		if(f.indexOf("ASCIIEXPORT")>-1)
		{
			if(f.indexOf("3DSMAX")>-1)
			{
				return ASE_3DMax(f);
			}
		}
		return ["File version is unsurport!"];
	}
	
	/**
	 * WRL parser, file exported from Maya. VRM Version 2.0
	 * @param	f:String		WRL file text.
	 * @return	An array with shape describes
	 */
	private function WRL_Maya(f:String):Array
	{
		//clear up source
		f = StringUtil.clear(f,["\t"]);
		//
		var pairs:Array = StringUtil.findBlockIndex(f, "{", "}");
		var tShape:Array = new Array();
		var defID:Number = f.indexOf("Transform");	//transform start label index
		defID = f.lastIndexOf("DEF", defID);
		
		while( defID >- 1 )
		{
			//find transform header -> tfh
			var tfhStart:Number, tfhLen:Number, tfhn:String, tfhName:String;
			var tfhLabel:String, geodef:String;
			var shape:Object3D = new Object3D();
			
			tfhStart = StringUtil.indexTimes(f, " ", 2, defID);
			tfhLen = StringUtil.indexTimes(f, " ", 3, defID)-1-tfhStart;
			tfhLabel = f.substr(tfhStart+1, tfhLen);
			
			if(tfhLabel == "Transform")
			{				
				var id:Number, id2:Number, dstr:Array, p:Array;
				var tfRange:Array, geoRange:Array;
				var translation:Matrix4 = new Matrix4();
				var quaternion:Quaternion = new Quaternion();
				var scale:Matrix4 = new Matrix4();
				shape.name = f.substr(defID+4, f.indexOf("Transform",defID)-defID-5);
				//collection shape infomation
				id = f.indexOf("{", defID);
//--------------//get transform block range
				tfRange = StringUtil.getBlockRange(pairs, id);
				id2 = f.indexOf("children", id+1);
				dstr = ArrayUtil.clear(f.substr(id,id2-id).split(" "));
				for(var i=0;i<dstr.length;i++)
				{
					switch(dstr[i])
					{
						case "translation":
							translation.n14 = parseFloat(dstr[i+1]);
							translation.n24 = -parseFloat(dstr[i+2]);			
							translation.n34 = -parseFloat(dstr[i+3]);
							i+=3;
							break;
						case "scale":
							scale.n11 = parseFloat(dstr[i+1]);
							scale.n22 = parseFloat(dstr[i+2]);
							scale.n33 = parseFloat(dstr[i+3]);
							i+=3;
							break;
						case "rotation":
							quaternion.x = parseFloat(dstr[i+1]);
							quaternion.y = parseFloat(dstr[i+2]),
							quaternion.z = parseFloat(dstr[i+3]),
							quaternion.w = parseFloat(dstr[i+4]);
							i+=4;
							break;
						case "scaleOrientation":
						/** FIXME Don't kow what to do with that
							scaleOri = [{	x:parseFloat(dstr[i+1]),
													y:parseFloat(dstr[i+2]),
													z:parseFloat(dstr[i+3]),
													o:parseFloat(dstr[i+4])}];
													 
						*/
							i+=4;
							break;
					}
					var t:Transform3D = new Transform3D();
					t.combineMatrix( QuaternionMath.getRotationMatrix() );
					t.combineMatrix( scale );
					t.combineMatrix( translation );
					shape.transform = t;
				}
				//check if it use a texture
				id = f.indexOf("texture ImageTexture", id2);
				
				if(id > tfRange[0] && id < tfRange[1])
				{
					id = f.indexOf("\"", id)+1;
					id2 = f.indexOf("\"", id);
					var s:MovieSkin = new MovieSkin( f.substr(id, id2-id) );
					//$shape.textureURL = f.substr(id, id2-id);
				}
//--------------//find geometry define header
				id = f.indexOf("geometry USE", id2)+13;
				id2 = f.indexOf(" ", id+1);
				geodef = "geometry DEF "+f.substr(id, id2-id);
				//geometry define block range
			
				geoRange = StringUtil.getBlockRange(pairs, f.indexOf("{", f.indexOf(geodef)));
				//point
				id = f.indexOf("point [", f.indexOf(geodef))+7;
				id2 = f.indexOf("]", id);
				dstr = f.substr(id, id2-id).split(", ");
				p = new Array();

				for(var i=0; i<dstr.length;i++)
				{
					p = ArrayUtil.clear(dstr[i].split(" "), null, parseFloat);
					shape.geometry.addPointByCoords( p[0], p[1], -p[2] );
				}
				//coord
				id = f.indexOf("coordIndex [", id2)+12;
				id2 = f.indexOf("]", id);
				dstr = f.substr(id, id2-id).split(", ");
				p = new Array();
				
				for(var i=0; i<dstr.length;i++)
				{
					var t:Array = ArrayUtil.clear( dstr[i].split(" "), null, parseFloat );
					if(reverseFace)
					{
						t.pop();
						t.reverse();
						t.push(-1);
					}
					shape.geometry.createFaceByIds( t );
				}
				
//--------------//texture points and coordIndex
				//find texture header
				id = f.indexOf("texCoord TextureCoordinate", id2);
				//check if texture coord is correct.
				if( id > geoRange[0] && id < geoRange[1] )
				{

					id = f.indexOf("point [", id)+8;
					id2 = f.indexOf("]", id)-1;
					dstr = f.substr(id, id2-id).split(" ");
					p = new Array();
					for(var i = 0; i<dstr.length; i+=2)
					{
						p.push(new UVCoord(		parseFloat(dstr[i]	),
												parseFloat(dstr[i+1]) ));
					}
//					Debug.d("shape ["+$shape.name+"] texture coordinate:\r\t["+p.join("],\r\t[")+"]");
					$shape.texturePoint = p;
				//texture corrdIndex
					id = f.indexOf("texCoordIndex [", id2)+16;
					id2 = f.indexOf("]", id)-1;
					dstr = f.substr(id, id2-id).split(", ");
					p = new Array();
					for (var i=0; i<dstr.length; i++)
					{
						var t:Array = ArrayUtil.clear(dstr[i].split(" "), null, parseFloat);
						if(reverseFace)
						{
							t.pop();
							t.reverse();
							t.push(-1);
						}
						p.push(t);
					}
					$shape.textureCoord = p;
				}
			}
			tShape.push($shape);
	
			defID = f.indexOf("DEF", defID+10);
		}
		return tShape;
	}
	
	/**
	 * WRL parser, file exported from 3D Max. VRM Version 2.0
	 * @param	f:String		WRL file text.
	 * @return	An array with shape describes
	 */
	private function WRL_3DMax(f:String):Array
	{
		
		//clear up source
		f = StringUtil.clear(f,["\t"]);
		//find all transforms
		var tShape:Array = new Array();	//store all shapes
		var tGroup:Array = new Array();	//store all groups
		var $defPairs:Array = StringUtil.findBlockIndex(f, "{", "}");	//DEF xx Transform {...} block
		var $dataPairs:Array = StringUtil.findBlockIndex(f, "[", "]");	//poin and coordIndex block
		
		//search all alone object and group transform
		var defID:Number = f.indexOf("DEF");	//transform start label index
		while(defID>-1)
		{
			var $transform:Object = new Object();
			//find transform header -> tfh
			var tfhStart:Number, tfhLen:Number, tfhn:String, tfhName:String;
			var tfhLabel:String;
			tfhStart = StringUtil.indexTimes(f, " ", 2, defID);
			tfhLen = StringUtil.indexTimes(f, " ", 3, defID)-1-tfhStart;
			tfhLabel = f.substr(tfhStart+1, tfhLen);

			if(tfhLabel == "Transform")
			{
				$transform.name = f.substr(defID+4, tfhStart-defID-4);
				$transform.index = defID;
				$transform.excursion = $transform.name.length + 14;	//"DEF object_name Transform".length
				$transform.block = StringUtil.getBlockRange($defPairs, f.indexOf("{",defID));
				
				//judge transform type
				var gem:Number = f.indexOf("geometry", defID+$transform.excursion);
				var nexttf:Number = f.indexOf("Transform", defID+$transform.excursion);
				if(nexttf==-1) nexttf = f.length+1;
				if(gem < nexttf)
				{
//------------------// a shape found
					$transform.type = "shape";
					//collection shape infomation					
					var id:Number, id2:Number, dstr:Array;
					id = f.indexOf("Transform {", $transform.index)+12;
					id2 = f.indexOf("children", id);
					dstr = ArrayUtil.clear(f.substr(id, id2-id).split(" "));
					for(var i=0;i<dstr.length;i++)
					{
						switch(dstr[i])
						{
							case "translation":
								$transform.translation = new Vector(
														parseFloat(dstr[i+1]),
														parseFloat(dstr[i+2]),
														-parseFloat(dstr[i+3]));
								i+=3;
								break;
							case "scale":
								$transform.scale = new Vector(
														parseFloat(dstr[i+1]),
														parseFloat(dstr[i+2]),
														parseFloat(dstr[i+3]));
								i+=3;
								break;
							case "rotation":
								$transform.rotation = [{x:parseFloat(dstr[i+1]),
														y:parseFloat(dstr[i+2]),
														z:parseFloat(dstr[i+3]),
														o:parseFloat(dstr[i+4])}];
								i+=4;
								break;
							case "scaleOrientation":
								$transform.scaleOri = [{x:parseFloat(dstr[i+1]),
														y:parseFloat(dstr[i+2]),
														z:parseFloat(dstr[i+3]),
														o:parseFloat(dstr[i+4])}];
								i+=4;
								break;
						}
					}
					//point
					id = f.indexOf("point", gem);
					if(id<nexttf && id>-1)
					{
						dstr = StringUtil.getBlockByIndex(f, $dataPairs, f.indexOf("[", id), true).split(",");
						var p:Array = new Array();
						for(var i=0; i<dstr.length;i++)
						{
							var v:Array = ArrayUtil.clear(dstr[i].split(" "), null, parseFloat);
							p.push(new Vector(v[0], v[1], -v[2]));
						}
						$transform.point = p;
					}
					//coord
					id = f.indexOf("coordIndex", gem);
					if(id<nexttf && id>-1)
					{
						dstr = StringUtil.getBlockByIndex(f, $dataPairs, f.indexOf("[", id), true).split("-1,");
						dstr = dstr.join("-1_").split("_");
						var p:Array = new Array();
						for(var i=0; i<dstr.length;i++)
						{
							var t:Array = ArrayUtil.clear(dstr[i].split(" "), null, parseFloat);
//							if(reverseFace){
//								t.pop();
//								t.reverse();
//								t.push(-1);
//							}
							p.push(t);
						}
						$transform.coord = p;
					}
				}
				else
				{
//------------------//a group found
					$transform.type = "group";
					//collection group transform infomation
					var gtfs:Number = defID+$transform.excursion;
					var gtfStr:Array = f.substr(gtfs, f.indexOf("children", gtfs)-gtfs).split(" ");
					var gtf:Object = new Object();
					
					
					var c:Number = 0;
					while(c<gtfStr.length)
					{
						switch(gtfStr[c])
						{
							case "scale":
								$transform.scale = new Vector(
															parseFloat(gtfStr[c+1]),
															parseFloat(gtfStr[c+2]), 
															parseFloat(gtfStr[c+3]));
								c+=3;
								break;
							case "translation":
								$transform.translation = new Vector(
															parseFloat(gtfStr[c+1]),
															parseFloat(gtfStr[c+2]),
															-parseFloat(gtfStr[c+3]));
								c+=3;
								break;
							case "rotation":
								$transform.rotation = [{	x:parseFloat(gtfStr[c+1]), 
															y:parseFloat(gtfStr[c+2]), 
															z:parseFloat(gtfStr[c+3]), 
															o:parseFloat(gtfStr[c+4])}];
								c+=4;
								break;
							case "scaleOrientation":
								$transform.scaleOri = [{	x:parseFloat(gtfStr[c+1]), 
															y:parseFloat(gtfStr[c+2]), 
															z:parseFloat(gtfStr[c+3]), 
															o:parseFloat(gtfStr[c+4])}];
								c+=4;
								break;
							default:
								c++;
						}
					}
				}
				if($transform.type == "shape")
				{
					var s3d:Shape3D = new Shape3D();
					s3d.name = $transform.name;
					s3d.point = $transform.point;
					s3d.coord = $transform.coord;
					
					if($transform.scale) s3d.scale = $transform.scale;
					if($transform.scaleOri) s3d.scaleOri = $transform.scaleOri;
					if($transform.translation) s3d.translation = $transform.translation;
					if($transform.rotation) s3d.rotation = $transform.rotation;

					tShape.push(s3d);
				}
				else
				{
					tGroup.push($transform);
				}
			}
			defID = f.indexOf("DEF", defID+10);
		}
		delete f;
		delete $defPairs;
		delete $dataPairs;
		
		//combine group transform
		for(var o=0; o<tShape.length; o++)
		{
			//find parent and adjust transform
			var _id:Number = tShape[o].index;
			for(var k=tGroup.length-1; k>-1; k--)
			{
				//check if a shape is in a group
				var tg:Object = tGroup[k];
				if(_id > tg.block[0] && _id < tg.block[1])
				{
					if(tg.translation.length>0)
					{
						tShape[o].translation.x += tg.translation.x;
						tShape[o].translation.y += tg.translation.y;
						tShape[o].translation.z += tg.translation.z;
					}
					if(tg.scale.length>0)
					{
						tShape[o].scale.x *= tg.scale.x;
						tShape[o].scale.y *= tg.scale.y;
						tShape[o].scale.z *= tg.scale.z;
					}
					if(tg.scaleOri.length>0)
					{
						tShape[o].scaleOri.push(tg.scaleOri);
					}
					if(tg.rotation.length>0)
					{
						tShape[o].rotation.push(tg.rotation);
					}
				}
			}
		}
		
		return tShape;
	}
	
//---------------------------------------------------------------------------------------------------------//
	
	/**
	 * ASE parser, file exported from 3D Max. ASE Version 2.0
	 * @param	f:String		ASE file text.
	 * @return	An array with shape describes
	 */
	private function ASE_3DMax(f:String):Array
	{
		//clear up source
		f = StringUtil.clear(f, ["\t","*"]);
		//
		var blockIndex:Array = StringUtil.findBlockIndex(f, "{", "}");
		var bRange:Array = new Array();
		var $shapes:Array = new Array();
		//GEOMOBJECT define start index
		var defID:Number = f.indexOf("GEOMOBJECT", 0);
		
		while(defID > -1)
		{
			bRange = StringUtil.getBlockRange(blockIndex, f.indexOf("{", defID));
			if(bRange[1] <= bRange[0])
			{
				defID = f.indexOf("GEOMOBJECT", defID+5);
				continue;
			}
			
			var id:Number, id2:Number;
			var block:String, values:Array;
			var $shape:Shape3D = new Shape3D();
			//get name
			id = f.indexOf("\"", defID)+1;
			id2 = f.indexOf("\"", id);
			$shape.name = f.substr(id, id2-id);

			//get transform
			id = f.indexOf("NODE_TM", id2)+8;
			values = StringUtil.getBlockByIndex(f, blockIndex, id, true).split(" ");
			for( var i=0; i<values.length; i++)
			{
				switch(values[i])
				{
					case "TM_POS":
						//translation
						$shape.translation = new Vector(	parseFloat(values[i+1]),
															-parseFloat(values[i+2]),
															parseFloat(values[i+3]));
						i+=3;
						break;
					case "TM_ROTAXIS":
						//rotationOri
						$shape.rotationOri = [{		x:parseFloat(values[i+1]),
													y:parseFloat(values[i+2]),
													z:parseFloat(values[i+3]),
													o:parseFloat(values[i+5])}];
						i+=5;
						break;
					case "TM_SCALE":
						//scale
						$shape.scale = new Vector(		parseFloat(values[i+1]),
														parseFloat(values[i+2]),
														parseFloat(values[i+3]));
						i+=3;
						break;
					case "TM_SCALEAXIS":
						//scaleOri
						$shape.scaleOri = [{	x:parseFloat(values[i+1]),
												y:parseFloat(values[i+2]),
												z:parseFloat(values[i+3]),
												o:parseFloat(values[i+5])}];
						i+=5;
						break;
				}
			}
//-----------------------------debug start-------------------------------
//			Debug.d("shape transform:");
//			Debug.d("translation: \t"+$shape.translation);
//			Debug.d("scale: \t"+$shape.scale);
//			Debug.d("scaleOri: \t"+$shape.scaleOri);
//-----------------------------debug end-------------------------------
//----------//get shape define
			//collect points
			id = f.indexOf("MESH_VERTEX_LIST", id)+17;
			values = StringUtil.getBlockByIndex(f, blockIndex, id, true).split(" MESH_VERTEX ");
			values.shift();
			$shape.point = new Array();
			for(var i=0; i<values.length; i++)
			{
				var t:Array = values[i].split(" ");
				$shape.point.push( new Vector(		parseFloat(t[1]),
													parseFloat(t[3]),
													parseFloat(t[2])) );
			}
			//collect coordIndex
			id = f.indexOf("MESH_FACE_LIST", id)+15;
//			id2 = f.indexOf("}", id);
			values = StringUtil.getBlockByIndex(f, blockIndex, id, true).split(" MESH_FACE ");
			values.shift();
			$shape.coord = new Array();
			for(var i=0; i<values.length; i++)
			{
				var t:Array = values[i].split(" ");
				$shape.coord.push([		parseFloat(t[2]),
										parseFloat(t[4]),
										parseFloat(t[6]),
										-1]);
			}
//----------//texture point
			id2 = id;
			id = f.indexOf("MESH_TVERTLIST", id)+15;

			if(id > bRange[0] && id < bRange[1])
			{
				//exist a uv define-----------------
				values = StringUtil.getBlockByIndex(f, blockIndex, id, true).split(" MESH_TVERT ");
				values.shift();
				$shape.texturePoint = new Array();
				for(var i=0; i<values.length; i++)
				{
					var t:Array = values[i].split(" ");
					$shape.texturePoint.push(new UVCoord(	parseFloat	(t[1]),
															1-parseFloat(t[2])	));
				}
				//texture coordIndex-----------------
				id = f.indexOf("MESH_TFACELIST {", id)+15;
				values = StringUtil.getBlockByIndex(f, blockIndex, id, true).split(" MESH_TFACE ");
				values.shift();
				$shape.textureCoord = new Array();
				for(var i=0; i<values.length; i++)
				{
					var t:Array = values[i].split(" ");
					t.shift();
//					$shape.textureCoord.push([		parseFloat(t[1]),
//													parseFloat(t[2]),
//													parseFloat(t[3])]);
					$shape.textureCoord.push( ArrayUtil.clear(t, null, parseFloat));
				}
				id2 = id;
			}
//-----------------------------debug start-------------------------------
//			Debug.d("points and texture:\r");
//			Debug.d("point:\r\t["+$shape.point.join("],\r\t[")+"]");
//			Debug.d("coord:\r\t["+$shape.coord.join("],\r\t[")+"]");
//			Debug.d("texturePoint:\r\t["+$shape.texturePoint.join("],\r\t[")+"]");
//			Debug.d("textureCoord:\r\t["+$shape.textureCoord.join("],\r\t[")+"]");
//-----------------------------debug end-------------------------------
//-----------------a shape end
			$shapes.push($shape);
			//find next
			defID = f.indexOf("GEOMOBJECT", id2);
		}
		
		return $shapes;
	}
	
	/*
	 * getter setter
	 */
	public function set reverseFace(rf:Boolean):Void{
		__reverseFace = rf;
	}
	public function get reverseFace(Void):Boolean{
		return __reverseFace;
	}
}