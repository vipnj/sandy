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
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vertex;
	import sandy.materials.Material;
	
	/**
	 * Holds all new line style Attributes data for a material.
	 *
	 * 
	 * @author		Max Pellizzaro
	 * @version		3.0.2
	 * @date 		29.12.2007
	 */
	public class LineStyleAttributes extends LineAttributes
	{
		 private var thisLenght:Number;
		 private var thisGap:Number;
		 
		
		/**
		 * Creates a new LineAStyleAttributes object.
		 *
		 * @param p_nThickness	The line thickness - Defaoult 1
		 * @param p_nColor	The line color - Defaoult 0 ( black )
		 * @param p_nAlpha	The alpha value in percent of full opacity ( 0 - 1 )
		 * @param p_style		The Style you want to use
		 */
		public function LineStyleAttributes( p_nThickness:uint = 1, p_nColor:uint = 0, p_nAlpha:Number = 1, p_lenght:Number = 10, p_gap:Number = 10 )
		{
			super(p_nThickness,p_nColor,p_nAlpha);
			thisLenght = p_lenght;
			thisGap = p_gap;
		}
		
		
		/**
		 * Draw the edges of the polygon into the graphics object.
		 *  
		 * @param p_oGraphics the Graphics object to draw attributes into
		 * @param p_oPolygon the polygon which is going o be drawn
		 * @param p_oMaterial the refering material
		 * @param p_oScene the scene
		 *
		 */
		override public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			var l_aPoints:Array = (p_oPolygon.isClipped)?p_oPolygon.cvertices : p_oPolygon.vertices;
			var l_oVertex:Vertex;
			p_oGraphics.lineStyle( this.thickness, this.color, this.alpha );
			// --
			p_oGraphics.moveTo( l_aPoints[0].sx, l_aPoints[0].sy );
			var lId:int = l_aPoints.length;
			while( l_oVertex = l_aPoints[ --lId ] )
			{
				if(  thisGap != 0 ) dashTo(p_oGraphics,l_aPoints[0].sx,l_aPoints[0].sy, l_oVertex.sx, l_oVertex.sy, thisLenght, thisGap); 
			  	else p_oGraphics.lineTo( l_oVertex.sx, l_oVertex.sy );
			}	
		}
		
	       
       private function dashTo(p_oGraphics:Graphics,startx:Number, starty:Number, endx:Number, endy:Number, len:Number, gap:Number):void 
       {
			// startx, starty = beginning of dashed line
			// endx, endy = end of dashed line
			// len = length of dash
			// gap = length of gap between dashes
			 
			// init vars
			var seglength:Number, deltax:Number, deltay:Number, delta:Number, segs:Number, radians:Number, cx:Number, cy:Number;
			// calculate the legnth of a segment
			seglength = len + gap;
			// calculate the length of the dashed line
			deltax = endx - startx;
			deltay = endy - starty;
			delta = Math.sqrt((deltax * deltax) + (deltay * deltay));
			// calculate the number of segments needed
			segs = Math.floor(Math.abs(delta / seglength));
			// get the angle of the line in radians
			radians = Math.atan2(deltay,deltax);
			// start the line here
			cx = startx;
			cy = starty;
			// add these to cx, cy to get next seg start
			deltax = Math.cos(radians)*seglength;
			deltay = Math.sin(radians)*seglength;
			// loop through each seg
			for ( var n:int = 0; n < segs; n+=1 ) 
			{
				p_oGraphics.moveTo(cx,cy);
				p_oGraphics.lineTo(cx+Math.cos(radians)*len,cy+Math.sin(radians)*len);
				cx += deltax;
				cy += deltay;
			}
			// handle last segment as it is likely to be partial
			p_oGraphics.moveTo(cx,cy);
			delta = Math.sqrt((endx-cx)*(endx-cx)+(endy-cy)*(endy-cy));
			if(delta>len)
			{
				// segment ends in the gap, so draw a full dash
				p_oGraphics.lineTo(cx+Math.cos(radians)*len,cy+Math.sin(radians)*len);
			} 
			else if(delta>0) 
			{
				// segment is shorter than dash so only draw what is needed
				p_oGraphics.lineTo(cx+Math.cos(radians)*delta,cy+Math.sin(radians)*delta);
			}
			// move the pen to the end position
			p_oGraphics.moveTo(endx,endy);
       }
	}
}