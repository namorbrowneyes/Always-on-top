#Requires AutoHotkey v2.0
#SingleInstance Force

; Per-monitor DPI awareness — WinGetPos returns physical screen pixels across all monitors
DllCall("SetProcessDpiAwarenessContext", "Ptr", -4)

; ── Configuration ─────────────────────────────────────────────────────────────
TOGGLE_KEY     := "^SPACE"   ; Hotkey to toggle — AHK v2 notation (^ Ctrl, ! Alt, + Shift, # Win)
CORNER         := "TopLeft"  ; Indicator corner: TopLeft | TopRight | BottomLeft | BottomRight
INDICATOR_BASE := 30         ; Indicator size in pixels at 96 DPI (100% scaling); auto-scaled on HiDPI
; ──────────────────────────────────────────────────────────────────────────────

PinnedWindows := Map()  ; WindowID → {Gui: indicator Gui, Dpi: last seen DPI}

BuildIndicator(dpi) {
    global INDICATOR_BASE
    sz   := Round(INDICATOR_BASE * dpi / 96)
    fsz  := Round(20 * dpi / 96)
    yOff := Round(-2 * dpi / 96)
    g := Gui("+AlwaysOnTop +ToolWindow -Caption -SysMenu +E0x20")
    g.BackColor := "000000"
    g.SetFont("s" fsz, "Arial")
    g.Add("Text", "x0 y" yOff " w" sz " h" sz " Center cWhite", "🔒")
    WinSetTransColor("000000", g)
    return g
}

HotKey(TOGGLE_KEY, TogglePin)

TogglePin(*) {
    global PinnedWindows

    WindowID := WinGetID("A")
    ExStyle  := WinGetExStyle("ahk_id " WindowID)

    if (ExStyle & 0x8) {
        WinSetAlwaysOnTop(0, "ahk_id " WindowID)
        if PinnedWindows.Has(WindowID) {
            PinnedWindows[WindowID].Gui.Destroy()
            PinnedWindows.Delete(WindowID)
        }
    } else {
        dpi := DllCall("GetDpiForWindow", "Ptr", WindowID, "UInt")
        WinSetAlwaysOnTop(1, "ahk_id " WindowID)
        PinnedWindows[WindowID] := {Gui: BuildIndicator(dpi), Dpi: dpi}
    }

    if PinnedWindows.Count > 0
        SetTimer(UpdateIndicator, 100)
    else
        SetTimer(UpdateIndicator, 0)
}

UpdateIndicator() {
    global PinnedWindows, CORNER, INDICATOR_BASE

    for WindowID, entry in PinnedWindows.Clone() {
        if !WinExist("ahk_id " WindowID) {
            entry.Gui.Destroy()
            PinnedWindows.Delete(WindowID)
            continue
        }

        WinGetPos(&X, &Y, &W, &H, "ahk_id " WindowID)
        dpi := DllCall("GetDpiForWindow", "Ptr", WindowID, "UInt")
        sz  := Round(INDICATOR_BASE * dpi / 96)

        if (dpi != entry.Dpi) {
            entry.Gui.Destroy()
            entry.Gui := BuildIndicator(dpi)
            entry.Dpi := dpi
        }

        iX := (CORNER = "TopRight" || CORNER = "BottomRight") ? X + W - sz : X
        iY := (CORNER = "BottomLeft" || CORNER = "BottomRight") ? Y + H - sz : Y

        DllCall("SetWindowPos", "Ptr", entry.Gui.Hwnd, "Ptr", -1,
            "Int", iX, "Int", iY, "Int", sz, "Int", sz, "UInt", 0x0050)
    }

    if PinnedWindows.Count = 0
        SetTimer(UpdateIndicator, 0)
}
