package sandy.materials
{
	import flash.display.Graphics;
	import flash.display.Sprite;

	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.scenegraph.Camera3D;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.math.VectorMath;

	/**
	 * Displays the faces of a 3D shape as a Cel Shaded Material (polygon based cel shading).
	 *
	 * <p>Material which draws in CelShading style using a lighting map and outlines.</p>
	 *
	 * @author		Collin CUSCE - Rafajafar
	 * @version		3.0
	 * @date 		10.08.2007
	 */
	public final class CelShadeMaterial extends OutlineMaterial
	{
		private var m_nColor:Number;
		private var m_nAlpha:Number;
		private var lightingMap:Array;
		/**
		 * Creates a new CelShadeMaterial.
		 *
		 * @param p_nColor	The color of the fills - Default 0
		 * @param p_nAlpha 	The alpha of the fills - Default 100, value range ( 0 - 100 )
		 * @param p_nOutlineThickness	The thickness of the outline - Default 1
		 * @param p_nOutlineColor	The color of the outline - Default 0
		 * @param p_nOutlineAlpha	The alpha of the outline - Default 100, value range ( 0 - 100 )
		 * @param p_nOutlineColor	The color map of the fills. Must be an array of 11 values. Fractional numbers from (0 - 2) work best. - Default null
		 * @param p_oAttr	The attributes for this material
		 */
		public function CelShadeMaterial( p_nColor:uint = 0, p_nAlpha:uint = 100, p_nOutlineThickness:uint = 1, p_nOutlineColor:uint = 0, p_nOutlineAlpha:uint = 100, p_aColorMap:Array = null, p_oAttr:MaterialAttributes = null )
		{
			super(p_nOutlineThickness, p_nOutlineColor, p_nOutlineAlpha, p_oAttr);
			// --
			m_nType = MaterialType.COLOR;
			// --
			m_nColor = p_nColor;
			m_nAlpha = p_nAlpha/100;
			// --
			attributes = p_oAttr;

			if(p_aColorMap)
				lightingMap = p_aColorMap;
			else
				 lightingMap = [0.1, 0.1, 0.3, 0.3, 0.3, 0.6, 0.6, 0.6, 1, 1, 1.3];
		}
		/**
		 * Renders this material on the face it dresses.
		 *
		 * @param p_oScene		The current scene
		 * @param p_oPolygon	The face to be rendered
		 * @param p_mcContainer	The container to draw on
		 */
		public override function renderPolygon( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ):void
        {

            const l_points:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;
            const l_graphics:Graphics = p_mcContainer.graphics;
            var l_nCol:uint = m_nColor;
            var c:Camera3D     = p_oScene.camera;
            var vn:Vector     = p_oPolygon.normal.getWorldVector(); // Normalized
            var vc:Vector     = new Vector(c.x, c.y, c.z);// this should be normalized
            VectorMath.normalize(vc);
            var cp:Number    = 1;


            var r:Number = ( l_nCol >> 16 ) & 0xFF;
            var g:Number = ( l_nCol >> 8  ) & 0xFF;
            var b:Number = ( l_nCol )       & 0xFF;


            var dot:Number = (VectorMath.dot( vn, vc ));
            dot = Math.abs(dot);

            r = r * lightingMap[Math.round(dot * 10)];
            g = g * lightingMap[Math.round(dot * 10)];
            b = b * lightingMap[Math.round(dot * 10)];


            l_nCol =  r << 16 | g << 8 |  b;


	if( attributes.outlineAttributes) attributes.outlineAttributes.draw( l_graphics, p_oPolygon, p_oPolygon.vertices );
	if( attributes.lineAttributes ) attributes.lineAttributes.draw( p_mcContainer.graphics, p_oPolygon, p_oPolygon.vertices );

        if( attributes.lineAttributes )
                l_graphics.lineStyle( attributes.lineAttributes.thickness, attributes.lineAttributes.color, attributes.lineAttributes.alpha );
            else
            	l_graphics.lineStyle(0,0,0);

            l_graphics.beginFill( l_nCol, m_nAlpha );

            l_graphics.moveTo( l_points[0].sx, l_points[0].sy );
            for each (var l_oVertex:Vertex in l_points )
            {
                l_graphics.lineTo( l_oVertex.sx, l_oVertex.sy );
            }

            l_graphics.endFill();
        }


		public function get alpha():Number
		{return m_nAlpha;}

		public function get color():Number
		{return m_nColor;}


		public function set alpha(p_nValue:Number):void
		{m_nAlpha = p_nValue; m_bModified = true;}

		public function set color(p_nValue:Number):void
		{m_nColor = p_nValue; m_bModified = true;}

	}
}