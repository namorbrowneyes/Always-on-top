#Requires AutoHotkey v2.0
#SingleInstance Force

; Per-monitor DPI awareness — WinGetPos returns physical screen pixels across all monitors
DllCall("SetProcessDpiAwarenessContext", "Ptr", -4)

; ── Configuration ─────────────────────────────────────────────────────────────
HOTKEY         := "^SPACE"   ; Hotkey to toggle — AHK v2 notation (^ Ctrl, ! Alt, + Shift, # Win)
CORNER         := "TopLeft"  ; Indicator corner: TopLeft | TopRight | BottomLeft | BottomRight
INDICATOR_BASE := 30         ; Indicator size in pixels at 96 DPI (100% scaling); auto-scaled on HiDPI
; ──────────────────────────────────────────────────────────────────────────────

CurrentWindowID := 0
LastDpi         := 0
IndicatorGui    := ""

BuildIndicator(dpi) {
    global IndicatorGui, INDICATOR_BASE
    if (IndicatorGui != "")
        IndicatorGui.Destroy()
    sz   := Round(INDICATOR_BASE * dpi / 96)
    fsz  := Round(20 * dpi / 96)
    yOff := Round(-2 * dpi / 96)
    IndicatorGui := Gui("+AlwaysOnTop +ToolWindow -Caption -SysMenu +E0x20")
    IndicatorGui.BackColor := "Aqua"
    IndicatorGui.SetFont("s" fsz, "Arial")
    IndicatorGui.Add("Text", "x0 y" yOff " w" sz " h" sz " Center cWhite", "🔼")
}

BuildIndicator(DllCall("GetDpiForSystem", "UInt"))
HotKey(HOTKEY, TogglePin)

TogglePin(*) {
    global CurrentWindowID, IndicatorGui

    WindowID := WinGetID("A")
    ExStyle  := WinGetExStyle("ahk_id " WindowID)

    if (ExStyle & 0x8) {
        WinSetAlwaysOnTop(0, "ahk_id " WindowID)
        SetTimer(UpdateIndicator, 0)
        IndicatorGui.Hide()
        CurrentWindowID := 0
    } else {
        if CurrentWindowID
            WinSetAlwaysOnTop(0, "ahk_id " CurrentWindowID)
        SetTimer(UpdateIndicator, 0)
        IndicatorGui.Hide()

        WinSetAlwaysOnTop(1, "ahk_id " WindowID)
        CurrentWindowID := WindowID
        SetTimer(UpdateIndicator, 100)
    }
}

UpdateIndicator() {
    global CurrentWindowID, LastDpi, IndicatorGui, CORNER, INDICATOR_BASE

    if !WinExist("ahk_id " CurrentWindowID) {
        SetTimer(UpdateIndicator, 0)
        IndicatorGui.Hide()
        CurrentWindowID := 0
        return
    }

    WinGetPos(&X, &Y, &W, &H, "ahk_id " CurrentWindowID)
    dpi := DllCall("GetDpiForWindow", "Ptr", CurrentWindowID, "UInt")
    sz  := Round(INDICATOR_BASE * dpi / 96)

    if (dpi != LastDpi) {
        BuildIndicator(dpi)
        LastDpi := dpi
    }

    iX := (CORNER = "TopRight" || CORNER = "BottomRight") ? X + W - sz : X
    iY := (CORNER = "BottomLeft" || CORNER = "BottomRight") ? Y + H - sz : Y

    IndicatorGui.Show("NoActivate x" iX " y" iY " w" sz " h" sz)
}
