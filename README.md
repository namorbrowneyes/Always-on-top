# AlwaysOnTop AutoHotkey Script
![AOT_Icon32-1](https://github.com/user-attachments/assets/cb2024a0-5143-409e-b39f-38f141ae8b78)

Toggle "Always on Top" for any window with a single hotkey. A small aqua indicator appears in the top-left corner while a window is pinned.

> **Fork of [TobiaRigon/Always-on-top](https://github.com/TobiaRigon/Always-on-top) — rewritten for AutoHotkey v2.**

## Features

- **Toggle via `Ctrl + Space`** — pins or unpins the active window instantly
- **Visual indicator** — aqua 🔼 badge in the top-left corner while active
- **Single window at a time** — pinning a new window auto-unpins the previous one
- **Auto-cleanup** — indicator disappears when the pinned window closes

## Requirements

- [AutoHotkey v2](https://www.autohotkey.com/) (v2.0+)

## Installation

1. Install AutoHotkey v2
2. Clone or download `AlwaysOnTop.ahk`
3. Double-click the script to run it (or right-click → Run Script)

**To run on startup:** place a shortcut to `AlwaysOnTop.ahk` in:
```
%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
```

## Hotkey

| Hotkey | Action |
|--------|--------|
| `Ctrl + Space` | Toggle Always on Top for the active window |

## Compiling to a standalone .exe

Ahk2Exe ships with AutoHotkey v2 (under `C:\Program Files\AutoHotkey\Compiler\`).

**Via GUI:** right-click `AlwaysOnTop.ahk` → **Compile Script** → set **Custom Icon** to `img\AOT_Icon32.ico` → click **Convert**

**Via command line:**
```
Ahk2Exe.exe /in AlwaysOnTop.ahk /out Compiled\AlwaysOnTop_2.0.0.exe /icon img\AOT_Icon32.ico
```

## Contributing

This is a fork of [TobiaRigon/Always-on-top](https://github.com/TobiaRigon/Always-on-top). The original script used AutoHotkey v1 syntax; this fork rewrites it for **AutoHotkey v2**, which is not backwards-compatible with v1.

**What changed in the v2 rewrite:**
- All v1 commands replaced with v2 API (`WinGetID`, `WinGetExStyle`, `WinSetAlwaysOnTop`, `SetTimer` with function references)
- GUI created once at startup and reused via `Show`/`Hide` — eliminates the flicker from v1's per-tick GUI recreation
- Pinned-state detection via `WinGetExStyle` bitmask instead of a local flag — correctly handles windows set topmost by other tools
- Per-monitor DPI awareness and configurable hotkey/corner preference

If you contribute, avoid re-introducing v1 patterns. AHK v2 docs: https://www.autohotkey.com/docs/v2/

## License

MIT — see [LICENSE](LICENSE)
