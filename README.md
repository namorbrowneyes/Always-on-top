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

**To compile to a standalone .exe:** right-click the `.ahk` file → Compile Script (requires AHK v2 with compiler tools).

## Hotkey

| Hotkey | Action |
|--------|--------|
| `Ctrl + Space` | Toggle Always on Top for the active window |

## License

MIT — see [LICENSE](LICENSE)
