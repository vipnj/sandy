package demos
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import sandy.core.World3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Polygon;
	import sandy.core.data.UVCoord;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.Shape3D;
	import sandy.core.scenegraph.TransformGroup;
	import sandy.events.BubbleEvent;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.attributes.LineAttributes;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.math.VectorMath;
	import sandy.primitive.Line3D;
	import sandy.primitive.Sphere;
	import sandy.util.NumberUtil;


	public class InteractionDemo extends Sprite
	{
		private var m_oScene:World3D;
		private var m_oPlane:Shape3D;
		private var keyPressed:Array = new Array();
		private var m_oLine3D:Line3D;
		
		private var texture:BitmapData;
		private var info:TextField = new TextField();
		private var lTg:TransformGroup = new TransformGroup("rotation");
		
		public function InteractionDemo()
		{
			super();
		}
		
		public function init():void
		{
			createTexture();
			// --
			var lCamera:Camera3D = new Camera3D( 640, 480 );
			m_oScene = World3D.getInstance();
			m_oScene.container = this;
			m_oScene.camera = lCamera ;
			lCamera.z = -400;
			lCamera.y = 90;
			lCamera.lookAt( 0, 0, 0 );
			m_oScene.root = _createScene3D();
			m_oScene.root.addChild( lCamera );
			
			info.multiline = true;
			info.width = 300;
			this.addChild( info );
			
			// --
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
	
		public function __onKeyDown(e:KeyboardEvent):void
		{
            keyPressed[e.keyCode]=true;
        }

        public function __onKeyUp(e:KeyboardEvent):void
        {
           keyPressed[e.keyCode]=false;
        }
  
  
  		private function createTexture():void
  		{
  			texture = new BitmapData( 200, 200, false, 0x0000FF );
  		}
  		
		private function enterFrameHandler( event : Event ) : void
		{
			var cam:Camera3D = m_oScene.camera;
			// --
			if( keyPressed[Keyboard.RIGHT] ) 
			{   
			    cam.rotateY -= 5;
			}
			if( keyPressed[Keyboard.LEFT] )     
			{
			    cam.rotateY += 5;
			}		
			if( keyPressed[Keyboard.UP] )
			{ 
			    cam.moveHorizontally( 10 );
			}
			if( keyPressed[Keyboard.DOWN] )
			{ 
			    cam.moveHorizontally( -10 );
			}
			//lTg.rotateY ++;
			m_oScene.render();

		}
			
		private function _createScene3D():Group
		{
			var lG:Group = new Group("rootGroup");
			// --
			//m_oLine3D = new Line3D("normale", new Vector(), new Vector(0, 50, 0) );
			
			m_oPlane = new Sphere("sphere");//new Plane3D("myPlane", 300, 300, 2, 2, Plane3D.ZX_ALIGNED, PrimitiveMode.TRI );
			m_oPlane.useSingleContainer = false;
			m_oPlane.enableEvents = true;
			m_oPlane.addEventListener( MouseEvent.CLICK, onClick );
			m_oPlane.enableForcedDepth = true;
			m_oPlane.forcedDepth = 999999999999;
			
			var l_oAttr:MaterialAttributes = new MaterialAttributes( new LineAttributes() );
			m_oPlane.appearance = new Appearance( new BitmapMaterial( texture, l_oAttr ) );
			m_oPlane.enableNearClipping = true;
			
			lTg.addChild( m_oPlane );
			lG.addChild( lTg );

			return lG;
		}
		
		//
		// line intersection
		// see http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline3d/
		//
		private function __lineIntersection (p1:Vector, p2:Vector, p3:Vector, p4:Vector):Array
		{
			var res:Array = [
				new Vector (0.5 * (p1.x + p2.x), 0.5 * (p1.y + p2.y), 0.5 * (p1.z + p2.z)),
				new Vector (0.5 * (p3.x + p4.x), 0.5 * (p3.y + p4.y), 0.5 * (p3.z + p4.z))
			];

			var p13_x:Number = p1.x - p3.x;
			var p13_y:Number = p1.y - p3.y;
			var p13_z:Number = p1.z - p3.z;

			var p43_x:Number = p4.x - p3.x;
			var p43_y:Number = p4.y - p3.y;
			var p43_z:Number = p4.z - p3.z;

			if (NumberUtil.isZero (p43_x) && NumberUtil.isZero (p43_y) && NumberUtil.isZero (p43_z))
				return res;

			var p21_x:Number = p2.x - p1.x;
			var p21_y:Number = p2.y - p1.y;
			var p21_z:Number = p2.z - p1.z;

			if (NumberUtil.isZero (p21_x) && NumberUtil.isZero (p21_y) && NumberUtil.isZero (p21_z))
				return res;

			var d1343:Number = p13_x * p43_x + p13_y * p43_y + p13_z * p43_z;
			var d4321:Number = p43_x * p21_x + p43_y * p21_y + p43_z * p21_z;
			var d1321:Number = p13_x * p21_x + p13_y * p21_y + p13_z * p21_z;
			var d4343:Number = p43_x * p43_x + p43_y * p43_y + p43_z * p43_z;
			var d2121:Number = p21_x * p21_x + p21_y * p21_y + p21_z * p21_z;

			var denom:Number = d2121 * d4343 - d4321 * d4321;

			if (NumberUtil.isZero (denom))
				return res;

			var mua:Number = (d1343 * d4321 - d1321 * d4343) / denom;
			var mub:Number = (d1343 + d4321 * mua) / d4343;

			return [
				new Vector (p1.x + mua * p21_x, p1.y + mua * p21_y, p1.z + mua * p21_z),
				new Vector (p3.x + mub * p43_x, p3.y + mub * p43_y, p3.z + mub * p43_z)
			];
		}
		
		
		// calculates intersection and checks for parallel lines.
		// also checks that the intersection point is actually on
		// the line segment p1-p2
		private function findIntersection( p1:Point, p2:Point,  p3:Point, p4:Point) : Point
		{
		  var xD1,yD1,xD2,yD2,xD3,yD3;
		  var dot,deg,len1,len2;
		  var segmentLen1,segmentLen2;
		  var ua,ub,div;
		
		  // calculate differences
		  xD1=p2.x-p1.x;
		  xD2=p4.x-p3.x;
		  yD1=p2.y-p1.y;
		  yD2=p4.y-p3.y;
		  xD3=p1.x-p3.x;
		  yD3=p1.y-p3.y;  
		
		  // calculate the lengths of the two lines
		  len1=Math.sqrt(xD1*xD1+yD1*yD1);
		  len2=Math.sqrt(xD2*xD2+yD2*yD2);
		 
		  // calculate angle between the two lines.
		  dot=(xD1*xD2+yD1*yD2); // dot product
		  deg=dot/(len1*len2);
		
		  // if abs(angle)==1 then the lines are parallell,
		  // so no intersection is possible
		  if(Math.abs(deg)==1) return null;
		 
		  // find intersection Pt between two lines  
		  var pt:Point=new Point(0,0);
		  div=yD2*xD1-xD2*yD1;
		  ua=(xD2*yD3-yD2*xD3)/div;
		  ub=(xD1*yD3-yD1*xD3)/div;
		  pt.x=p1.x+ua*xD1;
		  pt.y=p1.y+ua*yD1;
		
		  // calculate the combined length of the two segments
		  // between Pt-p1 and Pt-p2
		  xD1=pt.x-p1.x;
		  xD2=pt.x-p2.x;
		  yD1=pt.y-p1.y;
		  yD2=pt.y-p2.y;
		  segmentLen1= Math.sqrt(xD1*xD1+yD1*yD1)+Math.sqrt(xD2*xD2+yD2*yD2);
		
		  // calculate the combined length of the two segments
		  // between Pt-p3 and Pt-p4
		  xD1=pt.x-p3.x;
		  xD2=pt.x-p4.x;
		  yD1=pt.y-p3.y;
		  yD2=pt.y-p4.y;
		  segmentLen2= Math.sqrt(xD1*xD1+yD1*yD1)+Math.sqrt(xD2*xD2+yD2*yD2);
		 
		  // if the lengths of both sets of segments are the same as
		  // the lenghts of the two lines the point is actually 
		  // on the line segment.
		 
		  // if the point isn't on the line, return null
		  if( Math.abs(len1-segmentLen1)>0.01 || Math.abs(len2-segmentLen2)>0.01)
		    return null;
		 
		  // return the valid intersection
		  return pt;
		}

        private function onClick( p_eEvent:BubbleEvent ):void
        {
            var l_oPoly:Polygon = ( p_eEvent.target as Polygon );
            //m_vMouse.ignore(  l_oPoly.container );
            // -- Maintenant on calcule le rayon depuis la camera jusqu'au point d'intersection
            // -- il nous faut le point 2D de click, et en profondeur c'est 0
            var l_nClicX:Number = m_oScene.container.mouseX;
            var l_nClicY:Number = m_oScene.container.mouseY;
            
            var l_nX:Number = (m_oScene.container.mouseX - m_oScene.camera.viewport.w2)/ m_oScene.camera.viewport.w2;
            var l_nY:Number = -(m_oScene.container.mouseY - m_oScene.camera.viewport.h2)/m_oScene.camera.viewport.h2;
            var l_oPoint:Vector = new Vector( l_nX, l_nY, 0 );
          
          
            // -- on prend la matrice de projection inverse
            var l_oMatrix:Matrix4 = m_oScene.camera.getProjectionMatrixInverse();
            l_oMatrix.vectorMult( l_oPoint );
            l_oMatrix = m_oScene.camera.matrix;
            l_oMatrix.vectorMult( l_oPoint );

            // -- maintenant nous avons la direction du rayon logiquement.
            // -- reste ‡ calculer son intersection avec le polygone
            var l_oNormale:Vector = l_oPoly.normal.getVector();
            var l_oOrigineRayon:Vector = m_oScene.camera.getPosition();
                  
            l_oPoint.sub( l_oOrigineRayon );
            //on normalise le vecteur car c'est lui qui sert de vecteur directeur du rayon qui part
            l_oPoint.normalize();
  
            // on chope la constante du plan
            var l_nPlaneConst:Number = VectorMath.dot( (l_oPoly.vertices[0] as Vertex).getVector(), l_oNormale );
          
            // Calcul le produit scalaire Normale du plan avec le vecteur directeur du rayon
            var PScalaireNormalePlanRayon:Number = l_oNormale.dot( l_oPoint );

            // Le rayon est parallele au plan
            if( PScalaireNormalePlanRayon >= -0.0000000001 && PScalaireNormalePlanRayon <= 0.0000000001 )
                return;
          
            // Calcul la distance du rayon au plan du triangle (d=N.R0+Cp : http://homeomath.imingo.net/displan.htm )
            var DistanceRayonPlan:Number = Math.abs(l_oOrigineRayon.dot( l_oNormale ))/(l_oNormale.getNorm());          
      
            // Intersection avec le plan
            var t:Number =  - DistanceRayonPlan / PScalaireNormalePlanRayon
      
            // Pas de collision
            if( t < 0.0000000001 )
            {
                return;
            }
          
            // on calcule le point d'intersection
            var l_oIntersectionPoint:Vector = new Vector(   l_oOrigineRayon.x + t * l_oPoint.x,
                                                            l_oOrigineRayon.y + t * l_oPoint.y,
                                                            l_oOrigineRayon.z + t * l_oPoint.z );
                                                          
          
            info.text = l_oIntersectionPoint.x+" \n "+l_oIntersectionPoint.y+"  \n "+l_oIntersectionPoint.z;
          
            if( m_oLine3D ) m_oLine3D.remove();
          
            var top:Vector = l_oNormale.clone();
            top.scale( 50 );
            top.add( l_oIntersectionPoint );
            m_oLine3D = new Line3D("normal", l_oIntersectionPoint, top );
            lTg.addChild( m_oLine3D );
           
           
            var p0:Point = new Point(l_oPoly.vertices[0].sx, l_oPoly.vertices[0].sy);
            var p1:Point = new Point(l_oPoly.vertices[1].sx, l_oPoly.vertices[1].sy);
            var p2:Point = new Point(l_oPoly.vertices[2].sx, l_oPoly.vertices[2].sy);
           
			var u0:UVCoord = l_oPoly.aUVCoord[0];
            var u1:UVCoord = l_oPoly.aUVCoord[1];
            var u2:UVCoord = l_oPoly.aUVCoord[2];
           
            var v01:Point = new Point(p1.x - p0.x, p1.y - p0.y );
            
            var vn01:Point = v01.clone(); 
            vn01.normalize(1);
            
            var v02:Point = new Point(p2.x - p0.x, p2.y - p0.y );
            var vn02:Point = v02.clone(); vn02.normalize(1);
            
            // sub that from click point
            var v4:Point = new Point( l_nClicX - v01.x, l_nClicY - v01.y );
            // we now have everything to find 1 intersection
            var l_oInter:Point = findIntersection( p0, p2, new Point(l_nClicX, l_nClicY), v4 );
            
            // If no intersection was found. Strage case since we can be sure the Sprite has received a mouse event so....
            if( l_oInter == null )
            	return;
            	
            // find vectors to intersection
            var vi02:Point = new Point( l_oInter.x - p0.x, l_oInter.y - p0.y ); 
            var vi01:Point = new Point( l_nClicX - l_oInter.x , l_nClicY - l_oInter.y );

            // interpolation coeffs
            var d1:Number = vi01.length / v01.length;
            var d2:Number = vi02.length / v02.length;
           
            // -- on interpole linéairement pour trouver la position du point dans repere de la texture (normalisé)
            var l_oIntersectionUV:UVCoord;
            l_oIntersectionUV = new UVCoord(
                u0.u + d1*(u1.u - u0.u) + d2*(u2.u - u0.u),
                u0.v + d1*(u1.v - u0.v) + d2*(u2.v - u0.v));
                
            // -- recuperation du material appliqué sur le polygone
            var l_oMaterial:BitmapMaterial = (l_oPoly.visible ? l_oPoly.appearance.frontMaterial : l_oPoly.appearance.backMaterial) as BitmapMaterial;
           
            if( l_oMaterial == null )
            {
                trace("ce material doit etre un moviematerial");
            }
            else
            {
                var l_oRealTexturePosition:UVCoord = new UVCoord( l_oIntersectionUV.u * l_oMaterial.texture.width, l_oIntersectionUV.v * l_oMaterial.texture.height );
               
                // -- et là on joue sur la texture
                var l_oTexture:BitmapData = l_oMaterial.texture;
                //l_oTexture.setPixel( l_oRealTexturePosition.u, l_oRealTexturePosition.v, 0xFF0000 );
                //l_oTexture.fillRect( l_oTexture.rect, Math.random()*0xFFFFFF );
                l_oTexture.fillRect( new Rectangle( l_oRealTexturePosition.u-2, l_oRealTexturePosition.v-2, 4, 4 ), 0xFF0000 );
                l_oMaterial.texture = l_oTexture;           
            }

        }
	
	}
}