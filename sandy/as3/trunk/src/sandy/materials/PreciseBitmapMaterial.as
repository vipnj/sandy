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
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vector;
	import sandy.materials.attributes.MaterialAttributes;
	
	/**
	 * Experimental port of the Away3D PreciseBitmapMaterial class.
	 * Don't use it for any commercial purpose unless you know ecactly what you are doing.
	 * The behaviour and name of this class may change in the future.
	 */
	public class PreciseBitmapMaterial extends BitmapMaterial
	{
        public var precision:Number = 1;
		public var threshold:Number = 10;
		// Changing this value makes the player not crash...
		public static var MAX_LEVEL:uint = 20;
		
		/**
		 * precision : the lower, the more accurate it is !
		 * threshold : the lower, the more accurate it is!
		 */
        public function PreciseBitmapMaterial(bitmap:BitmapData, p_oAttr:MaterialAttributes=null, p_nPrecision:uint = 1, p_nThreshold:Number = 10 )
        {
            super(bitmap, p_oAttr);

            precision = p_nPrecision;

            precision = precision * precision * 1.4;
            
            threshold = p_nThreshold;
            
            createVertexArray();
        }
        
        public function createVertexArray():void
        {
        	var index:Number = MAX_LEVEL;
        	while (index--) 
        	{
        		svArray.push(new Vector());
        	}
        }
        
        public override function renderPolygon( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ):void 
        {
        	if( m_oTexture == null ) return;
        	// --
			const l_points:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;
			const l_uv:Array = (p_oPolygon.isClipped) ? p_oPolygon.caUVCoord : p_oPolygon.aUVCoord;
			if( !l_points.length ) return;
			// --
			polygon = p_oPolygon;
        	graphics = p_mcContainer.graphics;
			// --
			if( p_oPolygon.isClipped && enableAccurateClipping )
			{
				_drawPolygon( l_points, l_uv );
			}
			else
			{
				_drawPolygon( l_points, l_uv );
	  		}
        }
        
        private function _drawPolygon( p_aPoints:Array, p_aUv:Array ):void
		{
			var l_points: Array = p_aPoints.slice();
			var l_uv: Array = p_aUv.slice();
			// --
			if( l_points.length > 3 )
			{
				l_points = l_points.slice( 0, 3 );
				l_uv = l_uv.slice( 0, 3 );
				// --
				p_aPoints.splice( 1, 1 );
				p_aUv.splice( 1, 1 );
				// --
				_drawPolygon( p_aPoints, p_aUv );
			}
			// --
			if( enableAccurateClipping == false )
				m_oTmp = (m_oPolygonMatrixMap[polygon] as Matrix );
			else
				m_oTmp = _createTextureMatrix( l_uv );
			// --
			map.a = m_oTmp.a;
	        map.b = m_oTmp.b;
	        map.c = m_oTmp.c;
	        map.d = m_oTmp.d;
	        map.tx = m_oTmp.tx;
	        map.ty = m_oTmp.ty;	
	        // --
	        renderRec( l_points[0].getScreenPoint(), l_points[1].getScreenPoint(), l_points[2].getScreenPoint(), 0 );
		}
        
        internal var polygon:Polygon;
        internal var map:Matrix = new Matrix();        
        internal var svArray:Array = new Array();
        internal var graphics:Graphics;
        
		internal var faz:Number;
        internal var fbz:Number;
        internal var fcz:Number;

        internal var mabz:Number;
        internal var mbcz:Number;
        internal var mcaz:Number;

        internal var mabx:Number;
        internal var maby:Number;
        internal var mbcx:Number;
        internal var mbcy:Number;
        internal var mcax:Number;
        internal var mcay:Number;

        internal var dabx:Number;
        internal var daby:Number;
        internal var dbcx:Number;
        internal var dbcy:Number;
        internal var dcax:Number;
        internal var dcay:Number;
            
        internal var dsab:Number;
        internal var dsbc:Number;
        internal var dsca:Number;
        
        internal var dmax:Number;
        
        internal var ax:Number;
        internal var ay:Number;
        internal var az:Number;
        internal var bx:Number;
        internal var by:Number;
        internal var bz:Number;
        internal var cx:Number;
        internal var cy:Number;
        internal var cz:Number;
        
        protected function renderRec( a:Vector, b:Vector, c:Vector, index:Number):void
        {
        	ax = a.x;
        	ay = a.y;
        	az = a.z;
        	bx = b.x;
        	by = b.y;
        	bz = b.z;
        	cx = c.x;
        	cy = c.y;
        	cz = c.z;

            if (index >= (MAX_LEVEL-3) || (Math.max(Math.max(ax, bx), cx) - Math.min(Math.min(ax, bx), cx) < threshold) || (Math.max(Math.max(ay, by), cy) - Math.min(Math.min(ay, by), cy) < threshold))
            {
                renderTriangle( map, ax, ay, bx, by, cx, cy );
                return;
            }

            faz = az;
            fbz = bz;
            fcz = cz;

            mabz = 2 / (faz + fbz);
            mbcz = 2 / (fbz + fcz);
            mcaz = 2 / (fcz + faz);

            dabx = ax + bx - (mabx = (ax*faz + bx*fbz)*mabz);
            daby = ay + by - (maby = (ay*faz + by*fbz)*mabz);
            dbcx = bx + cx - (mbcx = (bx*fbz + cx*fcz)*mbcz);
            dbcy = by + cy - (mbcy = (by*fbz + cy*fcz)*mbcz);
            dcax = cx + ax - (mcax = (cx*fcz + ax*faz)*mcaz);
            dcay = cy + ay - (mcay = (cy*fcz + ay*faz)*mcaz);
            
            dsab = (dabx*dabx + daby*daby);
            dsbc = (dbcx*dbcx + dbcy*dbcy);
            dsca = (dcax*dcax + dcay*dcay);

            if ((dsab <= precision) && (dsca <= precision) && (dsbc <= precision))
            {
    			renderTriangle( map, ax, ay, bx, by, cx, cy );
                return;
            }
            
			var map_a:Number = map.a;
			var map_b:Number = map.b;
			var map_c:Number = map.c;
			var map_d:Number = map.d;
			var map_tx:Number = map.tx;
			var map_ty:Number = map.ty;
        	
        	var sv1:Vector;
        	var sv2:Vector;
        	var sv3:Vector = svArray[index++];
        	if( sv3 )
        	{
	        	sv3.x = mbcx/2;
	        	sv3.y = mbcy/2;
	        	sv3.z = (bz+cz)/2;
        	}
        	else return;
        	
            if ((dsab > precision) && (dsca > precision) && (dsbc > precision))
            {
            	sv1 = svArray[index++];
            	if( sv1 )
            	{
	            	sv1.x = mabx/2;
		        	sv1.y = maby/2;
		        	sv1.z = (az+bz)/2;
		        	
		        	sv2 = svArray[index++];
		        	if( sv2 )
		        	{
			        	sv2.x = mcax/2;
				        sv2.y = mcay/2;
				        sv2.z = (cz+az)/2;
			        	
		            	map.a = map_a*=2;
		            	map.b = map_b*=2;
		            	map.c = map_c*=2;
		            	map.d = map_d*=2;
		            	map.tx = map_tx*=2;
		            	map.ty = map_ty*=2;
		                renderRec(a, sv1, sv2, index);
			        	
						map.a = map_a;
		            	map.b = map_b;
		            	map.c = map_c;
		            	map.d = map_d;
		            	map.tx = map_tx-1;
		            	map.ty = map_ty;
		                renderRec(sv1, b, sv3, index);
			        	
						map.a = map_a;
		            	map.b = map_b;
		            	map.c = map_c;
		            	map.d = map_d;
		            	map.tx = map_tx;
		            	map.ty = map_ty-1;
		                renderRec(sv2, sv3, c, index);
			        	
						map.a = -map_a;
		            	map.b = -map_b;
		            	map.c = -map_c;
		            	map.d = -map_d;
		            	map.tx = 1-map_tx;
		            	map.ty = 1-map_ty;
		                renderRec(sv3, sv2, sv1, index);
	          		}
            	}
            	return;
            }

            dmax = Math.max(dsab, Math.max(dsca, dsbc));
            if (dsab == dmax)
            {
            	sv1 = svArray[index++];
            	if( sv1 )
            	{
	            	sv1.x = mabx/2;
		        	sv1.y = maby/2;
		        	sv1.z = (az+bz)/2;
		        	
	            	map.a = map_a*=2;
	            	map.c = map_c*=2;
	            	map.tx = map_tx*=2;
	                renderRec(a, sv1, c, index);
		        	
					map.a = map_a + map_b;
	            	map.b = map_b;
	            	map.c = map_c + map_d;
	            	map.d = map_d;
	            	map.tx = map_tx + map_ty - 1;
	            	map.ty = map_ty;
	                renderRec(sv1, b, c, index);
            	}
                return;
            }

            if (dsca == dmax)
            {
            	sv2 = svArray[index++];
            	if( sv2 )
            	{
	            	sv2.x = mcax/2;
		        	sv2.y = mcay/2;
		        	sv2.z = (cz+az)/2;
	            	
	            	map.b = map_b*=2;
	            	map.d = map_d*=2;
	            	map.ty = map_ty*=2;
	                renderRec(a, b, sv2, index);
		        	
					map.a = map_a;
	            	map.b = map_b + map_a;
	            	map.c = map_c;
	            	map.d = map_d + map_c;
	            	map.tx = map_tx;
	            	map.ty = map_ty + map_tx - 1;
	                renderRec(sv2, b, c, index);
            	}
                return;
            }
	        	
		    map.a = map_a - map_b;
        	map.b = map_b*2;
        	map.c = map_c - map_d;
        	map.d = map_d*2;
        	map.tx = map_tx - map_ty;
        	map.ty = map_ty*2;
            renderRec(a, b, sv3, index);
	        	
		    map.a = map_a*2;
        	map.b = map_b - map_a;
        	map.c = map_c*2;
        	map.d = map_d - map_c;
        	map.tx = map_tx*2;
        	map.ty = map_ty - map_tx;
        	
            renderRec(a, sv3, c, index);
        }
        
        protected function renderTriangle(	p_oMatrix:Matrix, v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number):void
		{
			const a2:Number = v1x - v0x;
			const b2:Number = v1y - v0y;
			const c2:Number = v2x - v0x;
			const d2:Number = v2y - v0y;
								   
			matrix.a = p_oMatrix.a*a2 + p_oMatrix.b*c2;
			matrix.b = p_oMatrix.a*b2 + p_oMatrix.b*d2;
			matrix.c = p_oMatrix.c*a2 + p_oMatrix.d*c2;
			matrix.d = p_oMatrix.c*b2 + p_oMatrix.d*d2;
			matrix.tx = p_oMatrix.tx*a2 + p_oMatrix.ty*c2 + v0x;
			matrix.ty = p_oMatrix.tx*b2 + p_oMatrix.ty*d2 + v0y;
			
			graphics.lineStyle( 1, 0xFF);
			graphics.beginBitmapFill(m_oTexture, matrix, repeat, smooth);
			graphics.moveTo(v0x, v0y);
			graphics.lineTo(v1x, v1y);
			graphics.lineTo(v2x, v2y);
			graphics.endFill();
		}
	}
	
}