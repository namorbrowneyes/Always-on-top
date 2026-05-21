#Requires AutoHotkey v2.0
#SingleInstance Force

CurrentWindowID := 0

IndicatorGui := Gui("+AlwaysOnTop +ToolWindow -Caption -SysMenu +E0x20")
IndicatorGui.BackColor := "Aqua"
IndicatorGui.SetFont("s20", "Arial")
IndicatorGui.Add("Text", "x0 y-2 w30 h30 Center cWhite", "🔼")

^SPACE:: {
    global CurrentWindowID, IndicatorGui

    WindowID := WinGetID("A")
    ExStyle := WinGetExStyle("ahk_id " WindowID)

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
    global CurrentWindowID, IndicatorGui

    if !WinExist("ahk_id " CurrentWindowID) {
        SetTimer(UpdateIndicator, 0)
        IndicatorGui.Hide()
        CurrentWindowID := 0
        return
    }

    WinGetPos(&X, &Y, &W, &H, "ahk_id " CurrentWindowID)
    IndicatorGui.Show("NoActivate x" X " y" Y " w30 h30")
}
