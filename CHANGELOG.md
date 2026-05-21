# Changelog

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
