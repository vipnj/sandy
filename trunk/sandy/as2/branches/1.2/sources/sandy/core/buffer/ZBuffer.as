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

/**
* Buffer of the z-depths.
* <p>
* This class is not a real Z-buffer as it is in all the real 3D engines.
* It handles the Z-sorting of MovieClips that's all in fact.
* The movieClips are drawn is the correct order to create the good depth effect.
* As this technic is fast but not very accurate, you may have some sorting problems when object faces are too close, or with large faces.
* </p>
* 
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin C�dric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @date 		28.03.2006
*/
class sandy.core.buffer.ZBuffer
{
	private static var _a:Array = new Array();
	
	/**
	* 
	* Store an Object into the buffer.
	* <p>Currently, an object must be into this form :
	* <code>{face:aFace, depth:zDepth}</code>.</p>
	* 
	* @param o : An Object
	*/ 
	public static function push( o:Object ):Void
	{
		_a.push( o );
	}

	/**
	* 
	* Sort the Array by depth, using {@link Array#NUMERIC} and
	* {@link Array#DESCENDING}.
	* 
	* @return	The sorted Array
	*/ 
	public static function sort( Void ): Array
	{
		// -- computes the sort depending on the z average of the faces
		_a.sortOn( "depth", Array.NUMERIC | Array.DESCENDING );
		return _a;
	}

	/**
	* Clear the current buffer.
	*/ 
	public static function dispose( Void ):Void
	{
		delete _a;
		_a = new Array();
	}
	
}
