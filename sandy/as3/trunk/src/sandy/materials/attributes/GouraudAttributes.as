/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author Thomas PFEIFFER
Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.mozilla.org/MPL/MPL-1.1.html
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# ***** END LICENSE BLOCK *****
*/


package sandy.materials.attributes
{
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.materials.Material;
	import sandy.util.NumberUtil;

	/**
	 * Realize a Gouraud shading on a material.
	 *
	 * <p>To make this material attribute use by the Material object, the material must have :myMAterial.lighteningEnable = true.<br />
	 * This attributes contains some parameters</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		13.11.2007
	 */
	public final class GouraudAttributes implements IAttributes
	{
		/**
		 * Flag for lightening mode.
		 * <p>If true, the lit objects use full light range from black to white.<b />
		 * If false (the default) they just range from black to their normal appearance.</p>
		 */
		public var useBright:Boolean = false;
				
		/**
		 * Level of ambient light, added to the scene if lighting is enabled.
		 */
		public var ambient:Number = 0.3;
		
		/**
		 * Create the GouraudAttribute object.
		 * @param p_nAmbient The ambient light value. A value between O and 1 is expected.
		 */
		public function GouraudAttributes( p_bBright:Boolean = false, p_nAmbient:Number = 0.0 )
		{
			useBright = p_bBright;
			ambient = NumberUtil.constrain( p_nAmbient, 0, 1 );
		}
		
		internal var v0:Vertex, v1:Vertex, v2:Vertex;
		internal var id0:int, id1:int, id2:int;
		internal var v0N:Vector, v1N:Vector, v2N:Vector;
		internal var v0L:Number, v1L:Number, v2L:Number;
		internal var aL:Array = new Array(3);
		internal var aLId:Array;
		
		internal var alpha:Array = new Array(2);
		internal var coef:Number;
		internal var p3x:Number, p3y:Number, p4x:Number, p4y:Number, d:Number, p4len:Number;
		internal var matrix:Matrix = new Matrix();
		internal var l_oVertex:Vertex;
		 
		internal const colours:Array = new Array(0,0); 
		internal const ratios:Array = [ 0x00, 0xFF ];
		
		public function draw(p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D):void
		{
			var l_aPoints:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices.slice() : p_oPolygon.vertices.slice();
			v0 = l_aPoints[0];
	        v1 = l_aPoints[1];
	        v2 = l_aPoints[2];
	        // --
	        v0N = p_oPolygon.vertexNormals[0].getVector().clone();
			p_oPolygon.shape.modelMatrix.vectorMult3x3( v0N );
			v1N = p_oPolygon.vertexNormals[1].getVector().clone();
			p_oPolygon.shape.modelMatrix.vectorMult3x3( v1N );
			v2N = p_oPolygon.vertexNormals[2].getVector().clone();
			p_oPolygon.shape.modelMatrix.vectorMult3x3( v2N );
			// --
			v0L = p_oScene.light.calculate( v0N ) + ambient;	
			v1L = p_oScene.light.calculate( v1N ) + ambient;		
			v2L = p_oScene.light.calculate( v2N ) + ambient;	
			v0L = NumberUtil.constrain( v0L, 0, 1 );
			v1L = NumberUtil.constrain( v1L, 0, 1 );
			v2L = NumberUtil.constrain( v2L, 0, 1 );	
			// --
			aL[0] = v0L; aL[1] =  v1L; aL[2] = v2L;
			aLId = aL.sort( Array.NUMERIC | Array.RETURNINDEXEDARRAY );
			// --
			id0 = int(aLId[0]);
			id1 = int(aLId[1]);
			id2 = int(aLId[2]);
			// --
			v0 = l_aPoints[int(id0)];
			v1 = l_aPoints[int(id1)];
			v2 = l_aPoints[int(id2)];
			// --
			
			alpha[0] = ( !useBright )? 1-aL[int(id0)] : NumberUtil.constrain( (aL[int(id0)] < 0.5) ? (1-2 * aL[int(id0)]) : (2 * aL[int(id0)] - 1), 0, 1 );
			alpha[1] = ( !useBright )? 1-aL[int(id2)] : NumberUtil.constrain( (aL[int(id2)] < 0.5) ? (1-2 * aL[int(id2)]) : (2 * aL[int(id2)] - 1), 0, 1 );
			
			coef = ( aL[int(id1)] - aL[int(id0)] ) / ( aL[int(id2)] - aL[int(id0)] );
			// --
			p3x = v0.sx + coef * (v2.sx - v0.sx);
			p3y = v0.sy + coef * (v2.sy - v0.sy);
			p4x = v2.sx - v0.sx;
			p4y = v2.sy - v0.sy;
			p4len = Math.sqrt(p4x*p4x + p4y*p4y);
			d = Math.atan2(p3x - v1.sx, -(p3y - v1.sy));

			// matrix
			matrix.identity();
			matrix.a = Math.cos(Math.atan2(p4y, p4x) - d) * p4len / 1600;
			matrix.rotate(d);
			matrix.translate( (v2.sx + v0.sx) / 2, (v2.sy + v0.sy) / 2);			

			p_oGraphics.beginGradientFill( "linear",colours, alpha, ratios, matrix );
			p_oGraphics.moveTo( l_aPoints[0].sx, l_aPoints[0].sy );
			for each( l_oVertex in l_aPoints )
			{
				p_oGraphics.lineTo( l_oVertex.sx, l_oVertex.sy );
			}
			p_oGraphics.endFill();
		}
	}
}