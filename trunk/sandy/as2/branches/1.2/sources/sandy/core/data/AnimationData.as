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

import sandy.core.data.Vertex;
import sandy.core.Object3D;

/**
* AnimationData
* Handles the data allowing to transform a {@code Object3D} instance.
* @author		Thomas Pfeiffer - kiroukou
* @version		1.0
* @date 		24.06.2006
*/
class sandy.core.data.AnimationData
{
	/**
	* <p>Create a new {@code AnimationData} Instance</p>
	*/ 	
	public function AnimationData()
	{
		_aFrames = new Array();
		_nMaxFrames = 0;
	}
	
	/**
	* Returns the number of frames of the animation
	* @param	Void
	* @return Number the number of frames of the animation
	*/
	public function getTotalFrames( Void ):Number
	{
		return _nMaxFrames;
	}
	

	/**
	* Add a frame animation for a specified vertex.
	* The value given in parameter is the position of the vertex (not an offset).
	* @param	idFrame Number the frame id
	* @param	idVertex Number the id of the vertex to modify
	* @param	x Number The x 3D component you want to apply to the Object3D original vertex
	* @param	y Number The y 3D component you want to apply to the Object3D original vertex
	* @param	z Number The z 3D component you want to apply to the Object3D original vertex
	*/
	public function addElement( idFrame:Number, idVertex:Number, x:Number, y:Number, z:Number ):Void
	{
		if( _aFrames[ idFrame ] == undefined )
		{
			_aFrames[ idFrame ] = new Array();
			_nMaxFrames = Math.max( _nMaxFrames, idFrame );
		}
		_aFrames[ idFrame ].push( {id:idVertex, x:x, y:y, z:z } );
	}
	
	/**
	* Modify an objet with this animator.
	* THe object vertex will be changed to the animator positions at he specified frame.
	* @param	o Object3D The object you want to animate
	* @param	idFrame Number the frame number you want to animate the object at.
	*/
	public function animate( o:Object3D, idFrame:Number )
	{
		var i:Number,l:Number;
		var v:Vertex;
		var p:Object;
		var aV:Array = o.aPoints;
		var a:Array = _aFrames[ idFrame ];
		//
		if( (l = a.length) )
		{
			for( i = 0; i < l; i++ )
			{
				p = a[i];
				v = Vertex( aV[ p.id ] );
				v.x = p.x;
				v.y = p.y;
				v.z = p.z;
			}
			// we notify the object modification to the cache system
			o.setModified( true );
		}
	}
	
	/**
	* Get a String representation of the {@code AnimationData}.
	* 
	* @return	A String representing the {@code AnimationData}.
	*/ 	
	public function toString(Void):String
	{
		return "sandy.core.data.AnimationData";
	}
	
	private var _aFrames:Array;
	private var _nMaxFrames:Number;
}

