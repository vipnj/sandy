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
	 * <p>Please note that this material does not handle the lightAttributes!</p>
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
		 * CelShadeMaterial is still an experimental material. You should not use it unless you perfectly know what you are doing.
		 * This material may change in the future version of the library.
		 * <strong> CelShadeMaterial does not supper MaterialAttributes! </strong>
		 * @param p_nColor	The color of the fills - Default 0
		 * @param p_nAlpha 	The alpha of the fills - Default 1, value range ( 0 - 1 )
		 * @param p_nOutlineThickness	The thickness of the outline - Default 1
		 * @param p_nOutlineColor	The color of the outline - Default 0
		 * @param p_nOutlineAlpha	The alpha of the outline - Default 1, value range ( 0 - 1 )
		 * @param p_nOutlineColor	The color map of the fills. Must be an array of 11 values. Fractional numbers from (0 - 2) work best. - Default null
		 */
		public function CelShadeMaterial( p_nColor:uint = 0, p_nAlpha:Number = 1, p_nOutlineThickness:uint = 1, p_nOutlineColor:uint = 0, p_nOutlineAlpha:Number = 1, p_aColorMap:Array = null )
		{
			super(p_nOutlineThickness, p_nOutlineColor, p_nOutlineAlpha);
			// --
			m_nType = MaterialType.COLOR;
			// --
			m_nColor = p_nColor;
			m_nAlpha = p_nAlpha;
			// --
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
            var vc:Vector     = c.getPosition();// this should be normalized
            vc.normalize();
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