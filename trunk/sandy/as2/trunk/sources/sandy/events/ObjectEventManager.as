
import sandy.core.Object3D;
import sandy.view.IScreen;
import sandy.core.face.Polygon;
import sandy.core.World3D;
import sandy.events.ObjectEvent;

class sandy.events.ObjectEventManager
{
	public function ObjectEventManager( Void )
	{
		_aListeningObjects	= [];
		_currentRollSelection = null;
		_currentClickedSelection = null;
		_intervalLength = 40;
	}
	
	/**
	* Allows to get the array of objects which are under surveillance
	* @param	Void
	* @return Object3D array
	*/
	public function getListeningObjects( Void ):Array
	{
		return _aListeningObjects;
	}

	
	/**
	* Set the peeking frequency in ms.
	* @param	Number
	* @return 	void
	*/
	public function set peekingFrequence( n:Number ) // n in miili seconds, ex :  40 ms => 25 Hz
	{
		_intervalLength = n;
		if( _checkingInterval )
		{
			clearInterval( _checkingInterval );
			_checkingInterval = setInterval( this, "__picking", _intervalLength );
		}
		
	}
	
	/**
	* Get the peeking frequency.
	* @param	Number
	* @return 	void
	*/
	public function get peekingFrequence():Number
	{
		return _intervalLength;
	}
	
	/**
	* Add an objects to the list of the objects under surveillance
	* @param	Object3D
	* @return 	Void
	*/
	public function addEventListeningObject( lO:Object3D ):Void
	{
		if(_aListeningObjects.length == 0)
		{
			_checkingInterval = setInterval( this, "__picking", _intervalLength );
			Mouse.addListener( this );
		}
		_aListeningObjects.push( lO );
	}
	
	/**
	* Remove an object from the list of the objects under surveillance
	* @param	Object3D
	* @return 	Void
	*/
	public function removeEventListeningObject( lO:Object3D ):Void
	{
		var found :Boolean = false;
		var i:Number;
		var l:Number = _aListeningObjects.length;
		// --
		for( i = 0; i <  l && !found; i++ )
		{
			if( _aListeningObjects[i] == lO )
			{
				_aListeningObjects.splice(i, 1);
				found = true;
			}
		}
		if( _aListeningObjects.length == 0 )
		{
			clearInterval( _checkingInterval );
			Mouse.removeListener( this );
		}
	}
	
	/**
	* Allow you to get the object under the cursor if there is one unless return undef, the object return is the nearest one of the camera.
	* @param	IScreen, on what you want to pick
	* @return 	Object3D
	*/
	private function __pickAt( screen:IScreen ):Object3D
	{
		var mc:MovieClip = screen.getClip();
		var origX:Number = mc._x;
		var origy:Number = mc._y;
		var curseurX:Number = mc._xmouse;
		var curseurY:Number = mc._ymouse;
		
		//tableau des objets de notre scene
		var oA:Array = _aListeningObjects;
		var loA:Number = oA.length;
		var obj:Object3D;
		//
		var fA:Array;
		var lfA:Number;
		var fac:Polygon;
		//on va chercher le hitTest ayant une profondeur minimale.
		var depthMin:Number = Number.MAX_VALUE;
		//r�f�rence � l'objet s�lectionner sur la sc�ne
		var pickObj:Object3D;
		
		while( --loA > -1 )
		{
			obj = oA[loA];
			fA = obj.aFaces;
			lfA = fA.length;
			while( --lfA > -1 )
			{
				fac = fA[lfA];
				if(!fac.isVisible())
					continue;
				var depth = fac.getZAverage();
				if( depth < depthMin && depth > 0 )
				{
					/*
					if( fac.getClip().hitTest( origX+curseurX, origy+curseurY, false) ) //m�thode getClip() sur une face renvoie le clip sur lequel est dessinn� la face.
					{
						depthMin = depth;
						pickObj = obj;
						break;
					}
					 * 
					 */
				}
			}
		}
		return pickObj;
	}
	
	/**
	* Function which is called to check interaction with the position of the mouse over the current screen - manage rollOver and rollOut events.
	* @param	void
	* @return 	void
	*/
	private function __picking( Void ):Void
	{
		/* FIXME: Change this and do the selection by the mouse position to find the active viewport! */
		var screen:IScreen = World3D.getInstance().getCamera().getScreen();
		var pickObj:Object3D = __pickAt(screen);
		if( pickObj != undefined && _currentRollSelection != pickObj )
		{
			if( _currentRollSelection != null )
			{
				_currentRollSelection.broadcastEvent( new ObjectEvent( ObjectEvent.onRollOutEVENT, _currentRollSelection ) );
			}
			_currentRollSelection = pickObj;
			pickObj.broadcastEvent( new ObjectEvent( ObjectEvent.onRollOverEVENT, pickObj ) );
		}
		else if( pickObj == undefined && _currentRollSelection != null )
		{
			_currentRollSelection.broadcastEvent( new ObjectEvent( ObjectEvent.onRollOutEVENT, _currentRollSelection ) );
			_currentRollSelection = null;
		}
	}

	/**
	* Function called when the left button of the mouse is pressed - manage onPressEVENT.
	* active only if there is at less 1 object in the listening array.
	* @param	void
	* @return 	void
	*/
	private function onMouseDown():Void
	{	
		/* FIXME: Change this and do the selection by the mouse position to find the active viewport! */
		var screen:IScreen = World3D.getInstance().getCamera().getScreen();
		var pickObj:Object3D = __pickAt(screen);
		if( pickObj != undefined )
		{
			_currentClickedSelection = pickObj;
			pickObj.broadcastEvent( new ObjectEvent( ObjectEvent.onPressEVENT, pickObj ) );
		}
	}
	
	private function onMouseUp():Void
	{	
		/* FIXME: Change this and do the selection by the mouse position to find the active viewport! */
		var screen:IScreen = World3D.getInstance().getCamera().getScreen();
		var pickObj:Object3D = __pickAt(screen);
		if( pickObj != undefined && pickObj == _currentClickedSelection )
		{
			pickObj.broadcastEvent( new ObjectEvent( ObjectEvent.onReleaseEVENT, pickObj ) );
		}
		else if( _currentClickedSelection != null && pickObj != _currentClickedSelection)
		{
			_currentClickedSelection.broadcastEvent( new ObjectEvent( ObjectEvent.onReleaseOutsideEVENT, _currentClickedSelection ) );
		}
		_currentClickedSelection = null;
	}	
	
	private var _aListeningObjects:Array;
	private var _checkingInterval;
	private var _intervalLength:Number;
	//listening object currently under the cursor, null if there is no object.
	private var _currentRollSelection:Object3D;
	private var _currentClickedSelection:Object3D;

}