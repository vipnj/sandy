
{
	import sandy.core.scenegraph.Camera3D;	

	{
		// - rotations are available only by the rotateY and tilt methods (other are desactivated)
		// - the lookAt method is overrided to respect the available rotations


		private const PIon180 : Number = PI / 180;
		private const sin : Function = Math.sin;
		private const cos : Function = Math.cos;
		private const aTan2 : Function = Math.atan2;

		{
			super(p_nWidth, p_nHeight, p_nFov, p_nNear, p_nFar);
		}



		public override function set rotateX(p_nAngle : Number) : void 





		public override function lookAt(p_nX : Number, p_nY : Number, p_nZ : Number) : void
		{
			_xTarget = p_nX - x;
			_yTarget = p_nY - y;
			_zTarget = p_nZ - z;
			
			_yAngle = -aTan2(_xTarget, _zTarget);
			rotateY = _yAngle / PIon180;
			
			_zTargetBis = _xTarget * sin(-_yAngle) + _zTarget * cos(-_yAngle);
			_tiltAngle = -aTan2(_yTarget, _zTargetBis);
			tilt = _tiltAngle / PIon180;
		}

		private var _xTarget : Number;
		private var _yTarget : Number;
		private var _zTarget : Number;
		private var _yAngle : Number;
		private var _zTargetBis : Number;
		private var _tiltAngle : Number;
	}
}