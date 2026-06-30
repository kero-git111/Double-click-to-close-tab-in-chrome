#Requires AutoHotkey v2.0
#SingleInstance Force


#Include <UIA>


class Config
{
    static DoubleClickInterval := 300
    static Debug := false
    static TooltipTimeout := 1000

    static HomePage := "chrome://newtab/"
}

class Runtime
{
    static Busy := false
}

~LButton::
{
    current := A_TickCount

    static LastClickTick := 0

    if (current - LastClickTick <= Config.DoubleClickInterval)
    {
        LastClickTick := 0
        OnMouseDoubleClick()
    }
    else
    {
        LastClickTick := current
    }
}

OnMouseDoubleClick()
{
    hwnd := WinExist("A")

    if !hwnd
        return

    if !IsChromeWindow(hwnd)
        return

    element := GetHoveredElement()

    if !element
    {
        Debug_Show("No UIA Element")
        return
    }

    tab := GetTabElement(element)

    if !tab
    {
        Debug_Show("Not Tab")
        return
    }

    Debug_ShowElement(tab)

    HandleTabDoubleClick(tab)
}

IsChromeWindow(hwnd)
{
    try
    {
        if (WinGetClass(hwnd) != "Chrome_WidgetWin_1")
            return false

        return (WinGetProcessName(hwnd) = "chrome.exe")
    }
    catch
    {
        return false
    }
}

GetHoveredElement()
{
    try
    {
        return UIA.ElementFromPoint()
    }
    catch
    {
        return 0
    }
}

Debug_ShowElement(element)
{
    if !Config.Debug
        return

    info := ""

    try info .= "Name: " element.Name
    catch
        info .= "Name: <null>"

    info .= "`n"

    try info .= "TypeId: " element.LocalizedControlType
    catch
        info .= "Type: <null>"

    info .= "`n"

    try info .= "Class: " element.ClassName
    catch
        info .= "Class: <null>"

    Debug_Show(info)
}

Debug_Show(text)
{
    if !Config.Debug
        return

    ToolTip(text)

    SetTimer(HideToolTip, -Config.TooltipTimeout)
}

HideToolTip()
{
    ToolTip()
}
GetTabElement(element)
{
    if !element
        return 0

    try
    {
        t := element.LocalizedControlType

        if (t = "pane")
            return 0
    }
    catch
    {
        return 0
    }

    walker := UIA.RawViewWalker

    loop 4
    {
        try
        {
            if (element.ControlType = UIA.Type.TabItem)
                return element
        }
        catch
        {
        }

        try
        {
            element := walker.GetParentElement(element)
        }
        catch
        {
            break
        }

        if !element
            break
    }

    return 0
}

IsTabElement(element)
{
    return GetTabElement(element) != 0
}
HandleTabDoubleClick(tab)
{
    if Runtime.Busy
        return

    if !CanCloseTab(tab)
        return

    hwnd := WinExist("A")

    Runtime.Busy := true

    try
    {
        if CloseCurrentTab(hwnd, tab)
        {
            if Config.Debug
                Debug_Show("Tab Closed")
        }
    }
    finally
    {
        SetTimer(UnlockBusy, -350)
    }
}

CanCloseTab(tab)
{
    if !tab
        return false

    try
    {
        if (tab.ControlType != UIA.Type.TabItem)
            return false
    }
    catch
    {
        return false
    }

    try
    {
        if (tab.Name = "")
            return false
    }
    catch
    {
        return false
    }

    return true
}

IsLastTab(hwnd)
{
    try
    {
        root := UIA.ElementFromHandle(hwnd)

        tabs := root.FindAll({
            ControlType: UIA.Type.TabItem
        })

        count := 0

        for tab in tabs
        {
            try
            {
                if (tab.Name != "")
                    count++
            }
        }

        return count = 1
    }
    catch
    {
        return false
    }
}

CloseCurrentTab(hwnd, tab)
{
    if IsLastTab(hwnd)
        return NavigateToHome()

    return SendCloseTab(hwnd)
}

SendCloseTab(hwnd)
{
    SendEvent("^w")

    return true
}

NavigateToHome()
{
    SendEvent("^l")

    Sleep 30

    SendText(Config.HomePage)

    Sleep 10

    SendEvent("{Enter}")

    return true
}

UnlockBusy()
{
    Runtime.Busy := false
}