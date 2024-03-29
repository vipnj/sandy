package sandy.primitive
{
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
	
	import sandy.core.Object3D;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.face.Edge3D;
	import sandy.skin.SimpleLineSkin;
	import sandy.skin.Skin;
	
	/**
	* Line3D
	* <p>Line3D, or how to create a simple line in Sandy</p>
	* 
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		26.06.2006 
	**/
	public class Line3D extends Object3D implements Primitive3D
	{
		/**
		* Constructor
		*
		* <p>This is the constructor to call when you nedd to create a Line3D primitiv.</p>
		*
		* <p>This method will create a complete object with vertex,
		*    and the faces.</p>
		*
		* @param As many parameters as needed points can be passed. However a minimum of 2 vector instance must be given.
		*/
		public function Line3D ( points:Array )
		{
			super ();
			aPoints = [];
			update(points);
		}
		
		public function update ( points:Array ) : void
		{
			aPoints = [];
			if( points.length < 2 )
			{
				trace('Line3D::Number of arguments to low');
			}
			else
			{
				for( var i:Number = 0; i < points.length; i++ )
				{
					aPoints.push ( new Vertex( points[i].x, - points[i].y, points[i].z ) );
				}
				generate ();
			}
		}
		
		
		/**
		* generate
		* 
		* <p>Generate all is needed to construct the Line3D : </p>
		*/
		public function generate ( ) : void
		{
			// initialisation
			aFaces = [];
			var l:Number = aPoints.length;
			for( var i:Number = 0; i < l-1; i++ )
			{
				addFace( new Edge3D( this,aPoints[i], aPoints[i+1] ) );
			}
		}
		
		/**
		* Set a Skin to the Line3D.
		* <p>This method will set the a new skin to the line, but the skin must be a SimpleLineSkin instance.</p>
		* @param	SimpleLineSkin s	The new SimpleLineSkin skin
		* @param	bOverWrite	Boolean, overwrite or not all specific Faces's Skin
		* @return	Boolean True to apply the skin to the non default faces skins , false otherwise (default).
		*/
		//public override function setSkin( s:SimpleLineSkin, bOverWrite:Boolean ):Boolean
		public override function setSkin( s:Skin, bOverWrite:Boolean = false ):Boolean
		{
			//bOverWrite = (bOverWrite == undefined ) ? false : bOverWrite;
			super.setSkin( s, bOverWrite );
			return true;
		}
		
	}

}