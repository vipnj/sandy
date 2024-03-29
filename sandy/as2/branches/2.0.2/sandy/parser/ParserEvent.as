﻿/*
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

import com.bourre.events.BasicEvent;
import com.bourre.events.EventType;
	
import sandy.core.scenegraph.Group;

/**
 * Events that are used by the parser classes.
 * 
 * @author		Thomas Pfeiffer - kiroukou
 * @author		(porting) Floris - xdevltd
 * @version		2.0.2
 * @date 		16.03.2007
 */
	 
class sandy.parser.ParserEvent extends BasicEvent
{
	
    /**
	 * Defines the value of the <code>type</code> property of a <code>onFailEVENT</code> event object.
     *
     * @eventType onFailEVENT
     */ 
    public static var FAIL:EventType = new EventType( 'onFailEVENT' );
		
    /**
	 * Defines the value of the <code>type</code> property of a <code>onInitEVENT</code> event object.
     *
     * @eventType onInitEVENT
     */
    public static var INIT:EventType = new EventType( 'onInitEVENT' );
	
    /**
	 * Defines the value of the <code>type</code> property of a <code>onLoadEVENT</code> event object.
     *
     * @eventType onLoadEVENT
     */
    public static var LOAD:EventType = new EventType( 'onLoadEVENT' );
		
    /**
	 * Defines the value of the <code>type</code> property of a <code>onProgressEVENT</code> event object.
     *
     * @eventType onProgressEVENT
     */
	public static var PROGRESS:EventType = new EventType( 'onProgressEVENT' );
		
    /**
	 * Defines the value of the <code>type</code> property of a <code>onParsingEVENT</code> event object.
     *
     * @eventType onParsingEVENT
     */
	public static var PARSING:EventType = new EventType( 'onParsingEVENT' );
		
	/**
	 * The percent of the loading that is complete.
	 */
	public var percent:Number;
	
	/**
	 * The group the object will be assigned to.
	 */
	public var group:Group;

	/**
	 * The ParserEvent constructor
	 * 
	 * @param p_sType		The event type
	 */
	public function ParserEvent( p_sType:EventType )
	{
		super( p_sType );
	}
	
}