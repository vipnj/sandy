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
* Matrix with 4 lines & 4 columns.
*  
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @version		1.0
* @date 		28.03.2006
*/
class sandy.core.data.Matrix4 
{
	/**
	 * {@code Matrix4} cell.
	 * <p><code>1 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n11:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 1 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n12:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 0 1 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n13:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 0 0 1 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n14:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 0 0 0 <br>
	 *          1 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n21:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 1 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n22:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 1 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n23:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 1 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n24:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 0 0 0 <br>
 	 *          0 0 0 0 <br>
	 *          1 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n31:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 1 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n32:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 1 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n33:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 1 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n34:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          1 0 0 0 </code></p>
	 */
	public var n41:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 1 0 0 </code></p>
	 */
	public var n42:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 1 0 </code></p>
	 */
	public var n43:Number;
	
	/**
	 * {@code Matrix4} cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 1 </code></p>
	 */
	public var n44:Number;
	
	/**
	 * Create a new {@code Matrix4}.
	 * <p>If 16 arguments are passed to the constructor, it will
	 * create a {@code Matrix4} with the values. In the other case,
	 * a identity {@code Matrix4} is created.</p>
	 * <code>var m:Matrix4 = new Matrix4();</code><br>
	 * <code>1 0 0 0 <br>
	 *       0 1 0 0 <br>
	 *       0 0 1 0 <br>
	 *       0 0 0 1 </code><br><br>
	 * <code>var m:Matrix4 = new Matrix4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 
	 * 13, 14, 15, 16);</code><br>
	 * <code>1  2  3  4 <br>
	 *       5  6  7  8 <br>
	 *       9  10 11 12 <br>
	 *       13 14 15 16 </code>
	 */	
	public function Matrix4() 
	{
		//TODO voir si on peut pas faire n11 = 1 || arguments[0] n12 = 0 || arguments[1] etc.
		if(arguments.length === 16)
		{
			n11 = arguments[0] ; n12 = arguments[1] ; n13 = arguments[2] ; n14 = arguments[3] ;
			n21 = arguments[4] ; n22 = arguments[5] ; n23 = arguments[6] ; n24 = arguments[7] ;
			n31 = arguments[8] ; n32 = arguments[9] ; n33 = arguments[10]; n34 = arguments[11];
			n41 = arguments[12]; n42 = arguments[13]; n43 = arguments[14]; n44 = arguments[15];
		}
		else
		{
			n11 = n22 = n33 = n44 = 1;
			n12 = n13 = n14 = n21 = n23 = n24 = n31 = n32 = n34 = n41 = n42 = n43 = 0;
		}
	}
	
	/**
	* Create a new Identity Matrix4.
	* <p>An Identity Matrix4 is represented like that :</p>
	* <code>1 0 0 0 <br>
	*       0 1 0 0 <br>
	*       0 0 1 0 <br>
	*       0 0 0 1 </code>
	* 
	* @return	The new Identity Matrix4
	*/
	public static function createIdentity(Void):Matrix4
	{
		return new Matrix4(  1, 0, 0, 0,
							0, 1, 0, 0,
							0, 0, 1, 0, 
							0, 0, 0, 1);
	}

	/**
	* Create a new Zero Matrix4.
	* <p>An zero Matrix4 is represented like that :</p>
	* <code>0 0 0 0 <br>
	*       0 0 0 0 <br>
	*       0 0 0 0 <br>
	*       0 0 0 0 </code>
	* 
	* @return	The new Identity Matrix4
	*/
	public static function createZero(Void):Matrix4
	{
		return new Matrix4( 0, 0, 0, 0,
							0, 0, 0, 0,
							0, 0, 0, 0, 
							0, 0, 0, 0);
	}
	
	/**
	 * Get a string representation of the {@code Matrix4}.
	 *
	 * @return	A String representing the {@code Matrix4}.
	 */
	public function toString( Void ): String
	{
		var s:String =  new String("Matrix4\n");
		s += n11+"\t"+n12+"\t"+n13+"\t"+n14+"\n";
		s += n21+"\t"+n22+"\t"+n23+"\t"+n24+"\n";
		s += n31+"\t"+n32+"\t"+n33+"\t"+n34+"\n";
		s += n41+"\t"+n42+"\t"+n43+"\t"+n44+"\n";
		return s;
	}
}
