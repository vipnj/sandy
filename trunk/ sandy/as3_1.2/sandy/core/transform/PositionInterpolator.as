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
package sandy.core.transform {

	import flash.events.Event;
	
	import sandy.events.SandyEvent;
	import sandy.core.transform.Interpolator3D;
	import sandy.core.data.Vector;
	import sandy.core.transform.BasicInterpolator;
	import sandy.math.VectorMath;
	import sandy.core.data.Matrix4;
	import sandy.math.Matrix4Math;
	import sandy.core.World3D;
	import sandy.core.transform.TransformType;
	
	
	
	
	/**
	* PositionInterpolator
	*  
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		28.03.2006
	*/
	public class PositionInterpolator extends BasicInterpolator
	{	
		
	// ______________
	// [PRIVATE] DATA________________________________________________		
		private var _vMin:Vector;
		private var _vMax:Vector;
		private var _vDiff:Vector;
		private var _current:Vector;
		
		
		
		
	// ___________
	// CONSTRUCTOR___________________________________________________
		
		/**
		 * Create a new TranslationInterpolator.
		 * <p> This class realise a position interpolation of the group of objects it has been applied to</p>
		 * 
		 * @param f Function 	The function generating the interpolation value. 
		 * 						You can use what you want even if Sandy recommends the Ease class
		 * 						The function must return a number between [0,1] and must have a parameter between [0,1] too.
		 * @param onFrames Number	The number of frames that would be used to do the interpolation. 
		 * 							The smaller the faster the interpolation will be.
		 * @param min Vector The vector containing the initial offset that will be applied to the object's positions.
		 * @param max Vector The vector containing the final offset to apply to the object's positions.
		 */	
		public function PositionInterpolator( f:Function, pnFrames:Number, min:Vector, max:Vector ) 
		{
			super( f, pnFrames );
			
			_type = TransformType.TRANSLATION_INTERPOLATION
			
			_vMin = min;
			_vMax = max;
			_vDiff = VectorMath.sub( max, min );
			
			_current = _vMin;
			
			__updatePosition();
			
			World3D.getInstance().addEventListener( SandyEvent.RENDER, __render );
		}
		
		
		
		
	// __________________
	// [PUBLIC] FUNCTIONS____________________________________________		
	
		/**
		* set the start position vector. The objects will be initialized after this method call with this offset.
		* @param	v The start position offset vector
		*/
		public function setStartPositionVector( v:Vector ):void
		{
			_current = _vMin = v;
			_vDiff = VectorMath.sub( _vMax, _vMin );
			__updatePosition();
		}
		
		/**
		* set the start position vector. The objects will be initialized after this method call with this offset.
		* @param	x The start X position offset value
		* @param	y The start Y position offset value
		* @param	z The start Z position offset value
		*/
		public function setStartPosition( x:Number, y:Number, z:Number ):void
		{
			_current = _vMin = new Vector( x, y, z );
			_vDiff = VectorMath.sub( _vMax, _vMin );
			__updatePosition();
		}
		
		/**
		* Set the end position vector.
		* The objects will be initialized after this method call with this start offset and will stop at the offset given in argument.
		* @param	v The end position offset vector
		*/
		public function setEndPositionVector( v:Vector ):void
		{
			_current = _vMin;
			_vMax = v;
			_vDiff = VectorMath.sub( _vMax, _vMin );
			__updatePosition();
		}
		
		/**
		* Set the end position vector. 
		* The objects will be initialized after this method call with this start offset and will stop at the offset given in argument.
		* @param	x The end X position offset value
		* @param	y The end Y position offset value
		* @param	z The end Z position offset value
		*/
		public function setEndPosition( x:Number, y:Number, z:Number ):void
		{
			_current = _vMin;
			_vMax = new Vector( x, y, z );
			_vDiff = VectorMath.sub( _vMax, _vMin );
			__updatePosition();
		}
		
		
		
		
	// ___________________________
	// [OVERRIDEN] BasicInterpolator_________________________________
		
		override public function __render(e:Event):void
		{
			if( !_paused && !_finished )
			{
				var p:Number = getProgress();
				if( _way == 1 )
				{
					_current = VectorMath.addVector( _vMin, VectorMath.scale( _vDiff, _f ( p ) ) );
				} else {
					_current = VectorMath.sub( _vMax, VectorMath.scale( _vDiff, _f ( p ) ) );
				}
				
				// --
				__updatePosition();
				
				// --
				dispatchEvent( progressEvent );
				
				// --
				if ( (_frame == 0 && _way == -1) || (_way == 1 && _frame == _duration) )
				{
					_finished = true;
					dispatchEvent( endEvent );
				} else {
					_frame += _way;
				}
			}
		}
		
		override public function getStartMatrix():Matrix4
		{
			return Matrix4Math.translation(_vMin.x, _vMin.y, _vMin.z);
		}
		
		override public function getEndMatrix():Matrix4
		{
			return Matrix4Math.translation(_vMax.x, _vMax.y, _vMax.z);
		}
		
		
		
		
		
	// ___________________
	// [PRIVATE] FUNCTIONS___________________________________________
		
		private function __updatePosition():void
		{
			_m = Matrix4Math.translation( _current.x, _current.y, _current.z );
			_modified = true;
		}
		
	}
}