/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author or authors.
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

package sandy.materials
{
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vertex;

	/**
	 * Displays a kind of Z shading of any object that this material is applied to
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */	
	public class ZShaderMaterial extends Material
	{
		public var matrix:Matrix = new Matrix();
		// --
		
		public function ZShaderMaterial( p_nCoef:Number = 1 )
		{
		}
		
		/**
		 * Renders this material on the face it dresses
		 *
		 * @param p_oPolygon	The face to be rendered
		 * @param p_mcContainer	The container to draw on
		 */
		public override function renderPolygon( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ):void 
		{
			const l_points:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;
			if( !l_points.length ) return;
			const l_graphics:Graphics = p_mcContainer.graphics;	
			//-- get zSort
			var zIndices: Array = l_points.sortOn( "wz", Array.NUMERIC | Array.RETURNINDEXEDARRAY );
			
			var v0: Vertex = l_points[zIndices[0]];
			var v1: Vertex = l_points[zIndices[1]];
			var v2: Vertex = l_points[zIndices[2]];
			
			//-- local
			var x0: Number = v0.sx;
			var y0: Number = v0.sy;
			var x1: Number = v1.sx;
			var y1: Number = v1.sy;
			var x2: Number = v2.sx;
			var y2: Number = v2.sy;

			var zM: Number = p_oPolygon.shape.boundingBox.min.z;
			
			//-- get projected normal
			var normal: Vertex = p_oPolygon.normal;
			normal.projected = false;
			p_oScene.camera.projectVertex( normal );
			var nx: Number = normal.sx;
			var ny: Number = normal.sy;
			
			//-- compute gray values
			var zR: Number = p_oPolygon.shape.boundingBox.max.z - p_oPolygon.shape.boundingBox.min.z;
			
			var g0: Number = 0xff - ( v0.wz - zM ) / zR * 0xff;
			var g1: Number = 0xff - ( v2.wz - zM ) / zR * 0xff;
			
			//-- compute gradient matrix
			var dx20: Number = x2 - x0;
			var dy20: Number = y2 - y0;
			
			var zLen: Number = nx * dx20 + ny * dy20;
			var zLen2: Number = zLen * 2;
			
			matrix.createGradientBox( zLen2, zLen2, Math.atan2( ny, nx ), x0 - zLen, y0 - zLen );
	
			//-- draw gradient
			l_graphics.beginGradientFill( "linear", [ ( g0 << 16 ) | ( g0 << 8 ) | g0, ( g1 << 16 ) | ( g1 << 8 ) | g1 ], [ 100, 100 ], [ 128, 0xff ], matrix );
			l_graphics.moveTo( x0, y0 );
            for each (var l_oVertex:Vertex in l_points )
            {
                l_graphics.lineTo( l_oVertex.sx, l_oVertex.sy );
            }
			l_graphics.endFill();
		}

	}
	
}