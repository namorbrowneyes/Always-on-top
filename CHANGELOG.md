# Changelog

## [2.1.0] - 2026-05-21

### Changes:

    - Added configurable hotkey via TOGGLE_KEY variable at top of script (default: Ctrl+Space)
    - Added configurable indicator corner via CORNER variable (TopLeft | TopRight | BottomLeft | BottomRight)
    - Added per-monitor DPI awareness — indicator now scales correctly on HiDPI displays and across mixed-DPI multi-monitor setups
    - Indicator GUI is rebuilt automatically when the pinned window moves to a monitor with a different DPI
    - Fixed multi-monitor positioning bug where negative screen coordinates (monitors left of primary) could misplace the indicator
    - Installer scripts (1.0.0, 1.0.1) now use relative paths — no longer hardcoded to original author's machine
    - Added Setup2.0.0.iss installer script for the AHK v2 build
    - Changed indicator from aqua 🔼 box to transparent background with 🔒 lock emoji
    - Fixed indicator appearing behind pinned window — now uses SetWindowPos(HWND_TOPMOST) to guarantee z-order above all topmost windows

## [2.0.0] - 2026-05-21

### Changes:

    - Rewritten for AutoHotkey v2 compatibility (v1 syntax is not supported in AHK v2)
    - GUI created once at startup and reused (show/hide) rather than rebuilt each timer tick
    - Replaced legacy WinGet/Winset/Gui commands with v2 API (WinGetID, WinGetExStyle, WinSetAlwaysOnTop, SetTimer with function reference)
    - Removed IndicatorCreated flag — no longer needed with single-init GUI pattern
    - Updated README with v2 requirements and startup instructions


## [1.0.1] - 2024-10-18

### Changes:

    - Improved Icon: The icon has been replaced with a lighter and less intrusive version.
    - Timer Optimization: The timer has been optimized to reduce CPU and RAM usage, making the "Always on Top" functionality more efficient.
    - Improved Compilation Method: The executable was compiled using advanced compression techniques to reduce the final file size.

## [1.0.0] - 2024-10-10

### Initial Release:

    - First release with support for toggling "Always on Top" using the Ctrl + Space shortcut.
    - Visual indicator with an icon attached to the window that is set to "Always on Top."
    - Only one window can be "Always on Top" at a time.
    - Automatic removal of the indicator when the window is closed
