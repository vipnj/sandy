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

import sandy.core.data.Vector;
import sandy.core.transform.Transform3D;

/**
* This class is a wrapper helping you to create your transformation objet faster.
* The methods names are the same as in Transform3D class, and the arguments are the same too.
* @author Thomas PFEIFFER / kiroukou
* @see Transform3D
* @date 19/05/06
* 
*/
class sandy.util.TransformUtil
{

	public static function rotX( pAngle:Number ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.rotX( pAngle );
		return t;
	}

	public static function translateVector ( v:Vector ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.translateVector( v );
		return t;
	}

	public static function translate ( tx:Number, ty:Number, tz:Number ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.translate( tx, ty, tz );
		return t;
	}
	
	public static function rotY( pAngle:Number ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.rotY( pAngle );
		return t;
	}
	
	public static function rotZ( pAngle:Number ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.rotZ( pAngle );
		return t;
	}
	
	public static function rot( px:Number, py:Number, pz:Number ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.rot( px, py, pz );
		return t;
	}
	
	public static function translateX ( val:Number ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.translateX( val );
		return t;
	}	
	
	public static function translateZ ( val:Number ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.translateZ( val );
		return t;
	}	
	
	public static function translateY ( val:Number ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.translateY( val );
		return t;
	}
	
	public static function rotVector( v:Vector ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.rotVector( v );
		return t;
	}
	
	public static function scale( px:Number, py:Number, pz:Number ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.scale( px, py, pz );
		return t;
	}	
	
	public static function scaleVector ( v:Vector ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.scaleVector( v );
		return t;
	}	

	
	public static function rotAxis ( pAxis:Vector, pAngle:Number ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.rotAxis( pAxis, pAngle );
		return t;
	}
	
	public static function rotAxisWithReference ( axis:Vector, ref:Vector, pAngle:Number ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.rotAxisWithReference( axis, ref, pAngle );
		return t;
	}
	

	public static function scaleX ( pVal:Number ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.scaleX( pVal );
		return t;
	}
	
	public static function scaleY ( pVal:Number ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.scaleY( pVal );
		return t;
	}	

	public static function scaleZ ( pVal:Number ):Transform3D
	{
		var t:Transform3D = new Transform3D();
		t.scaleZ( pVal );
		return t;
	}	

}
