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
import sandy.math.VectorMath;
/**
* BezierUtil
* All credits go to Alex Ulhmann and its Animation Package Library 
* @author		Thomas Pfeiffer - kiroukou
* @since		1.0
* @version		1.0
* @date 		27.04.2006 
**/

class sandy.util.BezierUtil 
{
	
	/**
	* @method getPointsOnQuadCurve
	* @description Returns a point on a quadratic bezier curve with Robert Penner's optimization 
	*				of the standard equation.
	* @param p (Number) A percentage between [0-1]
	* @param p1 (Vector)
	* @param p2 (Vector)
	* @param p3 (Vector)
	* @return Vector	The resulting position vector
	*/
	/*Adapted from Robert Penner.*/
	public static function getPointsOnQuadCurve(p:Number, p1:Vector, p2:Vector, p3:Vector):Vector 
	{
		var ip2:Number = 2 * ( 1 - p );
		return new Vector(
							p1.x + p*(ip2*(p2.x-p1.x) + p*(p3.x - p1.x)),
							p1.y + p*(ip2*(p2.y-p1.y) + p*(p3.y - p1.y)),
							p1.z + p*(ip2*(p2.z-p1.z) + p*(p3.z - p1.z))
						  );
	}
	
	/**
	* @method getPointsOnCubicCurve
	* @param p (Number) A percentage between [0-1]
	* @param p1 (Vector)
	* @param p2 (Vector)
	* @param p3 (Vector)
	* @param p4 (Vector)
	* @return Vector	The resulting position vector
	*/	
	/*Adapted from Paul Bourke.*/
	public static function getPointsOnCubicCurve(p:Number, p1:Vector, p2:Vector, p3:Vector, p4:Vector):Vector 
	{
		var a:Number,b:Number,c:Number,d:Number,e:Number;	
		d = p * p;
		a = 1 - p;
		e = a * a;
		b = e * a;
		c = d * p;
		return new Vector(
							b * p1.x + 3 * p * e * p2.x + 3 * d * a * p3.x + c * p4.x,
							b * p1.y + 3 * p * e * p2.y + 3 * d * a * p3.y + c * p4.y,
							b * p1.z + 3 * p * e * p2.z + 3 * d * a * p3.z + c * p4.z
						 );
	}
	
	/**
	* @method getQuadControlPoints
	* @description
	* @param start Vector	The starting point
	* @param middle Vector	The point where the curve goes throught
	* @param end Vector 	The end point of the curve
	* @return Vector The control point
	*/
	/*Adapted from Robert Penner's drawCurve3Pts() method*/
	public static function getQuadControlPoints(start:Vector, middle:Vector,end:Vector):Vector
	{						        
		return new Vector(
							(2 * middle.x) - .5 * (start.x + end.x),
							(2 * middle.y) - .5 * (start.y + end.y),  
							(2 * middle.z) - .5 * (start.z + end.z)
						 );
	}	
	
	/**
	* @method getCubicControlPoints
	* @description 	if anybody finds a generic method to compute control points 
	* 				for bezier curves with n control points, 
	* 				if only the points on the curve are given, please let us know!
	* @param start (Vector)
	* @param through1 (Vector)
	* @param through2 (Vector)
	* @param end (Vector)
	* @return Array of Vector. A two dimensionnal array containing the two controls points.
	*/	
	public static function getCubicControlPoints(start:Vector, through1:Vector, through2:Vector, end:Vector):Array 
	{
		return [
			new Vector( 
				-(10 * start.x - 3 * end.x - 8 * (3 * through1.x - through2.x)) / 9,
				-(10 * start.y - 3 * end.y - 8 * (3 * through1.y - through2.y)) / 9,
				-(10 * start.z - 3 * end.y - 8 * (3 * through1.z - through2.z)) / 9 )
			,
			new Vector(
				(3 * start.x - 10 * end.x - 8 * through1.x + 24 * through2.x) / 9,
				(3 * start.y - 10 * end.y - 8 * through1.y + 24 * through2.y) / 9,
				(3 * start.z - 10 * end.z - 8 * through1.z + 24 * through2.z) / 9 )
			];
	}

	/**
	* Apply the casteljau algorithm.
	* @param	p	Number	A percentage value between [0-1]
	* @param	plist Array of Vector The list of vector that are used as control points of the Bezier curve.
	* @return	Vector	The position on the Bezier curve at the ration p of the curve.
	*/
	public static function casteljau( p:Number, plist:Array ):Vector
	{
		var list:Array = plist.slice();
		var aNewList:Array = [];
		var i:Number = 0;
		do
		{
			for( i=0; i < list.length-1; i++ )
			{
				var v1:Vector = VectorMath.scale( VectorMath.clone( list[i] ), 1.0 - p );
				var v2:Vector = VectorMath.scale( VectorMath.clone( list[i+1] ), p );
				aNewList.push( VectorMath.addVector( v1, v2 ) );
				delete v1; delete v2;
			}
			delete list;
			list = aNewList;
			aNewList = [];
		} while( list.length > 1 );
		// --
		if( list.length != 1 )
		{
			trace('sandy.util.BezierUtil::casteljau > Error, size of array must be equal to 1');
		}
		// --
		return list[0];
	}
	
	/**
	* More robust casteljau algorithm if the intervals are wierd.
	* UNTESTED METHOD. MAY BE REMOVED IN THE FUTURE VERSION. USE IT CAREFULLY.
	* @param	p
	* @param	plist
	* @param	pdeb
	* @param	pfin
	* @return
	*/
	public static function casteljau_interval( p:Number, plist:Array, pdeb:Number, pfin:Number ):Vector
	{
		var aNewList:Array = plist.slice();
		// --
		for( var i:Number = pdeb; i < pfin; i++)
		{
			var loc_p:Number = i % ( plist.length );
			if ( p < 0 ) 
				loc_p += plist.length;
			// --
			aNewList.push( plist[loc_p] );
		}
		// --
		return BezierUtil.casteljau( p, aNewList );
	}
}	