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


package mx.components
{

import mx.components.baseClasses.FxScrollBar;
import mx.components.Group;
import mx.core.ILayoutElement;
import mx.core.IViewport;
import mx.core.ScrollPolicy;
import mx.layout.LayoutBase;
import mx.layout.LayoutElementFactory;
import mx.components.FxScroller;
import mx.components.baseClasses.GroupBase;
import mx.components.Skin;


internal class FxScrollerLayout extends LayoutBase
{
    public function FxScrollerLayout()    
    {
        super();
    }
    
    static private function LayoutElementFor(item:Object):ILayoutElement
    {
        return (item) ? LayoutElementFactory.getLayoutElementFor(item) : null;
    }
    
    private function getScroller():FxScroller
    {
        var g:Skin = target as Skin;
        return (g) ? g.fxComponent as FxScroller : null;
    }
    
    /**
     * @private
     *  Computes the union of the preferred size of the visible 
     *  scrollbars and the viewport.  
     * 
     *  This becomes the ScrollerSkin's measuredWidth,Height.
     *    
     *  The ScrollerSkin's minimum size is only big enough to 
     *  acccomodate the visible scrollbars.
     * 
     *  The viewport does not contribute to the minimum size.
     * 
     *  Note also: at updateDisplayList() time, we honor the vertical
     *  scrollbar's minimum height, and the horizontal scrollbar's 
     *  minimum width.  
     */
    override public function measure():void
    {
        var scroller:FxScroller = getScroller();
        if (!scroller) 
            return;
            
        var hsb:FxScrollBar = scroller.horizontalScrollBar;
        var showHSB:Boolean = false;
        switch(scroller.horizontalScrollPolicy) {
            case ScrollPolicy.ON: 
                if (hsb) showHSB = true; 
                break;
            case ScrollPolicy.AUTO: 
                if (hsb) showHSB = hsb.visible; 
                break;
        } 

        var vsb:FxScrollBar = scroller.verticalScrollBar;
        var showVSB:Boolean = false;
        switch(scroller.verticalScrollPolicy) {
           case ScrollPolicy.ON: 
                if (vsb) showVSB = true; 
                break;
            case ScrollPolicy.AUTO: 
                if (vsb) showVSB = vsb.visible; 
                break;
        }
        
        var measuredW:Number = 0;
        var measuredH:Number = 0;
        var minW:Number = 0;
        var minH:Number = 0;            
        
        var viewport:IViewport = scroller.viewport;
        if (viewport)
        {
            var viewportElt:ILayoutElement = LayoutElementFor(viewport);
            measuredW = viewportElt.getPreferredBoundsWidth();
            measuredH = viewportElt.getPreferredBoundsHeight();
        }
        
        if (showHSB)
        {
            var hsbElt:ILayoutElement = LayoutElementFor(hsb);
            measuredH += hsbElt.getPreferredBoundsHeight();
            minW += hsbElt.getMinBoundsWidth();              
            minH += hsbElt.getMinBoundsHeight();  
        }
        if (showVSB)
        {
            var vsbElt:ILayoutElement = LayoutElementFor(vsb);
            measuredW += vsbElt.getPreferredBoundsWidth();
            minW += vsbElt.getMinBoundsWidth();
            minH += vsbElt.getMinBoundsHeight();
        }
        
        var g:GroupBase = target;
        g.measuredWidth = measuredW;
        g.measuredHeight = measuredH;
        g.minWidth = minW; 
        g.minHeight = minH;
    }
    
    /** 
     *  @private
     *  Arrange the viewport and scrollbars conventionally within
     *  the specified width and height: vertical scrollbar on the 
     *  right, horizontal scrollbar along the bottom.
     * 
     *  In other words, the Scroller's height will not
     *  shrink below the vertical scrollbar's minimum height, and its
     *  width will not shrink below the horizontal scrollbar's
     *  minimum width.
     * 
     *  The scrollbars are made visible if the viewport's content size is
     *  bigger than the actual size.
     * 
     *  If the visibility of either scrollbar changes we apply invalidateSize()
     *  to the ScrollerSkin.
     * 
     *  This causes new values for measuredWidth,Height to be computed, and 
     *  it causes the update process to be restarted.
     * 
     *  Note also: the logic for calling updateDisplayList and then restarting
     *  the process if the component has become invalid is in
     *  mx.managers.LayoutManager::validateDisplayList.
     * 
     */
    override public function updateDisplayList(w:Number, h:Number):void
    {  
        var scroller:FxScroller = getScroller();
        if (!scroller) 
            return;
            
        var viewport:IViewport = scroller.viewport;
        var hsb:FxScrollBar = scroller.horizontalScrollBar;
        var vsb:FxScrollBar = scroller.verticalScrollBar;
        var hsbElt:ILayoutElement = LayoutElementFor(hsb);
        var vsbElt:ILayoutElement = LayoutElementFor(vsb);
           
        // Decide which scrollbars will be visible
        var showHSB:Boolean = false;
        var hAuto:Boolean = false; 
        switch(scroller.horizontalScrollPolicy) {
            case ScrollPolicy.ON: 
                if (hsb) showHSB = true; 
                break;
            case ScrollPolicy.AUTO: 
                if (hsb && viewport)
                {
                    showHSB = viewport.contentWidth > w;
                    hAuto = true;
                } 
                break;
        } 
        var showVSB:Boolean = false;
        var vAuto:Boolean = false;
        switch(scroller.verticalScrollPolicy) {
           case ScrollPolicy.ON: 
                if (vsb) showVSB = true; 
                break;
            case ScrollPolicy.AUTO: 
                if (vsb && viewport)
                { 
                    showVSB = viewport.contentHeight > h;
                    vAuto = true;
                }                        
                break;
        }
        
        // Shrink the viewport's width,height for the visible scrollbars
        var viewportH:Number = h;
        var hsbH:Number = 0;
        if (showHSB) 
        {
            hsbH = hsbElt.getPreferredBoundsHeight();
            viewportH -= hsbH;
        }
        var viewportW:Number = w;
        var vsbW:Number = 0;
        if (showVSB) 
        {
            vsbW = vsbElt.getPreferredBoundsWidth();
            viewportW -= vsbW;
        }
        
        // If the scrollBarPolicy is auto, and we're only showing one scrollbar, 
        // the viewport may have shrunk enough to require showing the other one.
        
        if (showVSB && !showHSB && hAuto && (viewport.contentWidth > viewportW))
        {
            showHSB = true;
            hsbH = hsbElt.getPreferredBoundsHeight();                
            viewportH -= hsbH;
        }
        else if (!showVSB && showHSB && vAuto && (viewport.contentHeight > viewportH))
        {
            showVSB = true;
            vsbW = vsbElt.getPreferredBoundsWidth();                
            viewportW -= vsbW;
        }

        // layout the viewport
        if (viewport)
        {
            var viewportElt:ILayoutElement = LayoutElementFor(viewport);
            viewportElt.setLayoutBoundsSize(viewportW, viewportH);
            viewportElt.setLayoutBoundsPosition(0,0);
        }
        
        // layout the scrollbars
        if (hsb) hsb.visible = showHSB;
        if (showHSB)
        {
            hsbElt.setLayoutBoundsSize(Math.max(hsbElt.getMinBoundsWidth(), viewportW), hsbH);
            hsbElt.setLayoutBoundsPosition(0, h - hsbH);
        }
        if (vsb) vsb.visible = showVSB;
        if (showVSB)
        {
            vsbElt.setLayoutBoundsSize(vsbW, Math.max(vsbElt.getMinBoundsHeight(), viewportH));
            vsbElt.setLayoutBoundsPosition(w - vsbW, 0);
        }
        
        target.setContentSize(w, h);
    }

}

}