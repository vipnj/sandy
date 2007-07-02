/*
 * Copyright (c) 2003, Xith3D Project Group
 * All rights reserved.
 *
 * Portions based on the Java3D interface, Copyright by Sun Microsystems.
 * Many thanks to the developers of Java3D and Sun Microsystems for their
 * innovation and design.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * Neither the name of the 'Xith3D Project Group' nor the names of its
 * contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) A
 * RISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE
 *
 */
package sandy.parser.md2 
{
	
	import sandy.math.Vector
	import sandy.math.UVCoord;
	import flash.utils.ByteArray;
	import sandy.parser.md2.MD2Header;
	/**
	 * A single frame within an MD2 file
	 *
	 * @author wish
	 */
	public class MD2Frame 
	{
	    /** The scale adjustment for this frame */
	    private var scale:Array;
	    /** The trnaslation adjustment for this frame */
	    private var translate:Array;
	    /** The name of this frame */
	    private var name:String;
	    /** The list of vertexs that build up this frame */
	    private var verts:Array;
	
	    /**
	     * Creates new MD2Frame
	     *
	     * @param tin The datainput stream to read the frame from
	     * @param header The header to assist the load
	     */
	    public function MD2Frame( stream:ByteArray, header:MD2Header)  
	    {
		  scale=new Array(3);
		  translate=new Array(3);
	        verts = new Array(header.getVertexCount());
	
	        scale[0] = stream.readFloat() ;
	        scale[1] = stream.readFloat() ;
	        scale[2] = stream.readFloat() ;
	        translate[0] = stream.readFloat() ;
	        translate[1] = stream.readFloat() ;
	        translate[2] = stream.readFloat() ;
		  var temp:ByteArray=new ByteArray();
		  stream.readBytes(temp,0,16);
		  var name:String ;
		  var i:int;
		  temp.position=0;
	        name = readStrz(temp);
	        for ( i=0;i<header.getVertexCount();i++) 
	        {
	            verts[i] = new MD2Vertex(stream,scale,translate);
	        }
		 // trace("name ="+name);
	    }
	
	    /**
	     * Retrieve the name of this frame
	     *
	     * @return The name of this frame
	     */
	    public function getName():String 
	    {
	        return name;
	    }
	    
	    public function readStrz( bytes: ByteArray ): String
		{
				var l_char: uint;
				var str: String = new String( '' );
				do
				{
					l_char = bytes.readByte();
	
					if( l_char == 0 )
					{
						break;
					}
					str += String.fromCharCode( l_char );
				}
				while( true );
	
				return str;
		}
	
	    /**
	     * Retrieve a specfied vertex
	     *
	     * @param i The index of the vertex to retrieve
	     * @return The specified vertex
	     */
	    public function getVertex(i:int):MD2Vertex 
	    {
	        return verts[i];
	    }
	}
}