////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.utils
{
	
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;

import mx.core.UIComponent;
import mx.events.SandboxMouseEvent;

[ExcludeClass]

/**
 *  @private
 * 
 *  Utilities to help with event dispatching or event handling.
 */
public class EventUtil
{
	include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Static Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Set up event listeners for a complete down-drag-up mouse gesture.
     *  
     *  Add MOUSE_DOWN, MOUSE_MOVE, and MOUSE_UP listeners to the target component
     *  which call the handleDown(), handleDrag(), and handleUp() functions respectively.
     * 
     *  The handleDrag() method will be called for as long as the mouse button is down,
     *  whenever the mouse is dragged within the stage.   The handleUp() method will be
     *  called no matter where the mouse button is released, however a MouseEvent type argument
     *  will only be provided if the button is released over the stage.
     * 
     *  The handleDown() and handleDrag() functions are passed a single MouseEvent
     *  argument, and the handleUp() is passed an Event which may be a MouseEvent 
     *  or a SandboxMouseEvent.  Typically handleUp() functions ignore their event
     *  argument.
     * 
     *  Any of the functions arguments can be null.
     * 
     *  The implementation only adds MOUSE_MOVE and MOUSE_UP listeners in response
     *  to a MOUSE_DOWN event.   Similarly, the implementation removes its MOUSE_MOVE
     *  and MOUSE_UP listeners when it receives a MOUSE_UP event.
     * 
     *  @param target A MOUSE_DOWN event on this component begins the down-drag-up gesture
     *  @param handleDown A function with a MouseEvent parameter; called when the MOUSE_DOWN event occurs.
     *  @param handleDrag A function with a MouseEvent parameter; called when the mouse moves with the button down.
     *  @param handleUp A function with an Event parameter; called when the button is relesed.
     * 
     *  @see #removeDownDragUpListeners
     */
    public static function addDownDragUpListeners(
                                target:UIComponent, 
                                handleDown:Function, 
                                handleDrag:Function, 
                                handleUp:Function):void
    {        
        var f:Function = function(e:Event):void 
        {
            var sbr:IEventDispatcher;
            switch(e.type)
            {
                case MouseEvent.MOUSE_DOWN:
                    if (e.isDefaultPrevented())
                        break;
                    handleDown(e);
                    sbr = target.systemManager.getSandboxRoot();
                    sbr.addEventListener(MouseEvent.MOUSE_MOVE, f, true);
                    sbr.addEventListener(MouseEvent.MOUSE_UP, f, true );
                    sbr.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, f, true); 
                    break;
                case MouseEvent.MOUSE_MOVE:
                    handleDrag(e);
                    break;
                case MouseEvent.MOUSE_UP:
                    handleUp(e);
                    sbr = target.systemManager.getSandboxRoot(); 
                    sbr.removeEventListener(MouseEvent.MOUSE_MOVE, f, true);
                    sbr.removeEventListener(MouseEvent.MOUSE_UP, f, true);
                    sbr.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, f, true); 
                    break;
                case "removeHandler":
                    target.removeEventListener("removeHandler", f);            
                    target.removeEventListener(MouseEvent.MOUSE_DOWN, f);
                    sbr = target.systemManager.getSandboxRoot();
                    sbr.removeEventListener(MouseEvent.MOUSE_MOVE, f, true);
                    sbr.removeEventListener(MouseEvent.MOUSE_UP, f, true);
                    sbr.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, f, true); 
                    break;
            }
        }
        target.addEventListener(MouseEvent.MOUSE_DOWN, f);
        target.addEventListener("removeHandler", f);
    }    
    
    /**
     *  Removes the listeners added by a matching addDownDragUpListeners call.
     * 
     *  @param target A MOUSE_DOWN event on this component begins the down-drag-up gesture
     *  @param handleDown The listener for MOUSE_DOWN events
     *  @param handleDrag The listener for MOUSE_MOVE events when the button is down.
     *  @param handleUp The listener for MOUSE_UP events 
     * 
     *  @see #addDownDragUpListeners
     */
    public static function removeDownDragUpListeners(
                                target:UIComponent, 
                                handleDown:Function, 
                                handleDrag:Function, 
                                handleUp:Function):void
    {
        target.dispatchEvent(
            new RemoveHandlerEvent(handleDown, handleDrag, handleUp));
    }
    
	//--------------------------------------------------------------------------
	//
	//  Class properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
    //  sandboxMouseEventMap
	//----------------------------------

	/**
     *  @private
     */
    private static var _sandboxEventMap:Object;

	/**
	 *  Mapping of MouseEvents to SandboxMouseEvent types.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static function get sandboxMouseEventMap():Object
	{
		if (!_sandboxEventMap)
		{
			_sandboxEventMap = {};

			_sandboxEventMap[SandboxMouseEvent.CLICK_SOMEWHERE] =
                MouseEvent.CLICK;
			_sandboxEventMap[SandboxMouseEvent.DOUBLE_CLICK_SOMEWHERE] =
                MouseEvent.DOUBLE_CLICK;
			_sandboxEventMap[SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE] =
                MouseEvent.MOUSE_DOWN;
			_sandboxEventMap[SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE] =
                MouseEvent.MOUSE_MOVE;
			_sandboxEventMap[SandboxMouseEvent.MOUSE_UP_SOMEWHERE] =
                MouseEvent.MOUSE_UP;
			_sandboxEventMap[SandboxMouseEvent.MOUSE_WHEEL_SOMEWHERE] =
                MouseEvent.MOUSE_WHEEL;
		}

		return _sandboxEventMap;
	}

	//----------------------------------
    //  mouseEventMap
	//----------------------------------

	/**
     *  @private
     */
	private static var _mouseEventMap:Object;

	/**
	 *  Mapping of SandboxMouseEvent to MouseEvents types.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static function get mouseEventMap():Object
	{
		if (!_mouseEventMap)
		{
			_mouseEventMap = {};

			_mouseEventMap[MouseEvent.CLICK] =
                SandboxMouseEvent.CLICK_SOMEWHERE;
			_mouseEventMap[MouseEvent.DOUBLE_CLICK] =
                SandboxMouseEvent.DOUBLE_CLICK_SOMEWHERE;
			_mouseEventMap[MouseEvent.MOUSE_DOWN] =
                SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE;
			_mouseEventMap[MouseEvent.MOUSE_MOVE] =
                SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE;
			_mouseEventMap[MouseEvent.MOUSE_UP] =
                SandboxMouseEvent.MOUSE_UP_SOMEWHERE;
			_mouseEventMap[MouseEvent.MOUSE_WHEEL] =
                SandboxMouseEvent.MOUSE_WHEEL_SOMEWHERE;
		}

		return _mouseEventMap;
	}
    
}
}

/**
 * Event used to remove the handlers associated with the press-drag-release
 * gesture handlers.
 */
class RemoveHandlerEvent extends flash.events.Event
{
    public var handleDown:Function;
    public var handleDrag:Function;
    public var handleUp:Function;
    public function RemoveHandlerEvent(handleDown:Function, 
                                       handleDrag:Function = null, 
                                       handleUp:Function = null)
    {
        this.handleDown = handleDown;
        this.handleDown = handleDrag;
        this.handleUp = handleUp;
        super("removeHandler");
    }
}
