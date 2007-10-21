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
package sandy.view 
{
	/**
	 * The view port represents the rendered screen.
	 *
	 * <p>This is the area where the view of the camera is projected.<br/>
	 * It may be the whole or only a part of the stage</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */	
	public final class ViewPort
	{
	    		
		/**
		 * Flag which specifies if the viewport dimension has changed
		 */
		public var hasChanged:Boolean = false;
		
	    /**
		 * Creates a new ViewPort.
		 *
		 * @param p_nW 	The width of the rendered screen
		 * @param p_nH 	The height of the rendered screen
		 **/
		public function ViewPort ( p_nW:Number, p_nH:Number )
		{
			width = p_nW;
			height = p_nH;
		}
		
		/**
		 * Updates the view port
		 */
		public function update():void
		{
			m_nW2 = m_nW/2;
			m_nH2 = m_nH/2;
			// --
			m_nRatio = (m_nH)? m_nW / m_nH : 0;
			// --
			hasChanged = true;
		}
		
		public function get width():Number { return m_nW; }
		public function get height():Number { return m_nH; }
		public function get width2():Number { return m_nW2; }
		public function get height2():Number { return m_nH2; }
		public function get ratio():Number { return m_nRatio; }
		
		public function set width( p_nValue:Number):void { m_nW = p_nValue; update(); }
		public function set height( p_nValue:Number):void { m_nH = p_nValue; update(); }

		
		private var m_nW:Number = 0;
		private var m_nW2:Number = 0;
		private var m_nH:Number = 0;
		private var m_nH2:Number = 0;
		private var m_nRatio:Number = 0;
	}
}